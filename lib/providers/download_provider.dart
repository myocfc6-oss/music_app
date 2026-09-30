import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/track_model.dart';

class DownloadProvider extends ChangeNotifier {
  static const String _storageKey = 'sonus_offline_downloads';

  final Map<int, TrackModel> _downloadedTracks = {};
  final Map<int, double> _downloadProgress = {};
  final Set<int> _downloadingIds = {};
  final Map<int, http.Client> _activeClients = {};

  List<TrackModel> get downloadedTracks => _downloadedTracks.values.toList();
  int get downloadCount => _downloadedTracks.length;
  bool get hasDownloads => _downloadedTracks.isNotEmpty;

  int get totalStorageBytes {
    int total = 0;
    for (final track in _downloadedTracks.values) {
      total += track.fileSizeBytes ?? 0;
    }
    return total;
  }

  String get totalStorageFormatted {
    final mb = totalStorageBytes / (1024 * 1024);
    if (mb >= 1024) {
      return '${(mb / 1024).toStringAsFixed(2)} GB';
    }
    return '${mb.toStringAsFixed(1)} MB';
  }

  DownloadProvider() {
    _loadDownloadsFromPrefs();
  }

  Future<void> init() async {
    await _loadDownloadsFromPrefs();
  }

  bool isDownloaded(int trackId) => _downloadedTracks.containsKey(trackId);
  bool isDownloading(int trackId) => _downloadingIds.contains(trackId);
  double getProgress(int trackId) => _downloadProgress[trackId] ?? 0.0;
  TrackModel? getLocalTrack(int trackId) => _downloadedTracks[trackId];

  String _formatAudioUrl(String url) {
    var formatted = url.trim();
    if (formatted.contains('drive.google.com/file/d/')) {
      final regExp = RegExp(r'drive\.google\.com/file/d/([a-zA-Z0-9_-]+)');
      final match = regExp.firstMatch(formatted);
      if (match != null && match.groupCount >= 1) {
        final fileId = match.group(1);
        return 'https://docs.google.com/uc?export=download&id=$fileId';
      }
    }
    return formatted;
  }

  Future<void> _loadDownloadsFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_storageKey) ?? [];
      _downloadedTracks.clear();

      for (final raw in rawList) {
        try {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          final track = TrackModel.fromMap(map);
          // Verify file still exists on disk
          if (track.localAudioPath != null && File(track.localAudioPath!).existsSync()) {
            _downloadedTracks[track.trackId] = track;
          }
        } catch (e) {
          debugPrint('Error parsing stored offline track: $e');
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading offline downloads: $e');
    }
  }

  Future<void> _saveDownloadsToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _downloadedTracks.values.map((t) => jsonEncode(t.toMap())).toList();
      await prefs.setStringList(_storageKey, list);
    } catch (e) {
      debugPrint('Error saving offline downloads: $e');
    }
  }

  Future<bool> downloadTrack(TrackModel track) async {
    if (isDownloaded(track.trackId)) return true;
    if (isDownloading(track.trackId)) return false;
    if (track.audioUrl.trim().isEmpty) return false;

    _downloadingIds.add(track.trackId);
    _downloadProgress[track.trackId] = 0.0;
    notifyListeners();

    final client = http.Client();
    _activeClients[track.trackId] = client;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final tracksDir = Directory('${appDir.path}/downloads/tracks');
      final coversDir = Directory('${appDir.path}/downloads/covers');

      if (!tracksDir.existsSync()) tracksDir.createSync(recursive: true);
      if (!coversDir.existsSync()) coversDir.createSync(recursive: true);

      // 1. Download Cover Art if available
      String? localCoverPath;
      if (track.coverPng != null && track.coverPng!.trim().isNotEmpty) {
        try {
          final coverFile = File('${coversDir.path}/${track.trackId}_cover.png');
          final coverRes = await http.get(Uri.parse(track.coverPng!.trim()));
          if (coverRes.statusCode == 200) {
            await coverFile.writeAsBytes(coverRes.bodyBytes);
            localCoverPath = coverFile.path;
          }
        } catch (e) {
          debugPrint('Failed to download cover art: $e');
        }
      }

      // 2. Download Audio Stream with Progress Tracking
      final audioUrl = _formatAudioUrl(track.audioUrl);
      final request = http.Request('GET', Uri.parse(audioUrl));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception('HTTP error ${response.statusCode}');
      }

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;
      final localAudioFile = File('${tracksDir.path}/${track.trackId}_audio.mp3');
      final sink = localAudioFile.openWrite();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          _downloadProgress[track.trackId] = (receivedBytes / totalBytes).clamp(0.0, 1.0);
          notifyListeners();
        }
      }
      await sink.flush();
      await sink.close();

      final actualSizeBytes = localAudioFile.lengthSync();

      final downloadedTrack = track.copyWith(
        localAudioPath: localAudioFile.path,
        localCoverPath: localCoverPath,
        fileSizeBytes: actualSizeBytes,
      );

      _downloadedTracks[track.trackId] = downloadedTrack;
      _downloadProgress.remove(track.trackId);
      _downloadingIds.remove(track.trackId);
      _activeClients.remove(track.trackId);

      await _saveDownloadsToPrefs();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Download error for track ${track.trackId}: $e');
      _downloadProgress.remove(track.trackId);
      _downloadingIds.remove(track.trackId);
      _activeClients.remove(track.trackId);
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteDownload(int trackId) async {
    final track = _downloadedTracks[trackId];
    if (track == null) return;

    try {
      if (track.localAudioPath != null) {
        final audioFile = File(track.localAudioPath!);
        if (audioFile.existsSync()) {
          await audioFile.delete();
        }
      }

      if (track.localCoverPath != null) {
        final coverFile = File(track.localCoverPath!);
        if (coverFile.existsSync()) {
          await coverFile.delete();
        }
      }

      _downloadedTracks.remove(trackId);
      await _saveDownloadsToPrefs();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting downloaded track: $e');
    }
  }

  Future<void> clearAllDownloads() async {
    for (final trackId in _downloadedTracks.keys.toList()) {
      await deleteDownload(trackId);
    }
  }

  void cancelDownload(int trackId) {
    if (_activeClients.containsKey(trackId)) {
      _activeClients[trackId]?.close();
      _activeClients.remove(trackId);
      _downloadingIds.remove(trackId);
      _downloadProgress.remove(trackId);
      notifyListeners();
    }
  }
}
