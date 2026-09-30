import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/track_model.dart';

class DeviceMusicProvider extends ChangeNotifier {
  static const String _storageKey = 'sonus_device_music_tracks';

  final List<TrackModel> _deviceTracks = [];
  bool _isLoading = false;

  List<TrackModel> get deviceTracks => List.unmodifiable(_deviceTracks);
  int get trackCount => _deviceTracks.length;
  bool get hasTracks => _deviceTracks.isNotEmpty;
  bool get isLoading => _isLoading;

  int get totalStorageBytes {
    int total = 0;
    for (final track in _deviceTracks) {
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

  DeviceMusicProvider() {
    _loadFromPrefs();
  }

  Future<void> init() async {
    await _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_storageKey) ?? [];
      _deviceTracks.clear();

      for (final raw in rawList) {
        try {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          final track = TrackModel.fromMap(map);
          // Only keep tracks where the physical file still exists on device
          if (track.localAudioPath != null && File(track.localAudioPath!).existsSync()) {
            _deviceTracks.add(track);
          }
        } catch (e) {
          debugPrint('Error parsing device track: $e');
        }
      }
    } catch (e) {
      debugPrint('Error loading device tracks from prefs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stringList = _deviceTracks.map((t) => jsonEncode(t.toMap())).toList();
      await prefs.setStringList(_storageKey, stringList);
    } catch (e) {
      debugPrint('Error saving device tracks to prefs: $e');
    }
  }

  /// Opens the native device file picker to select audio files.
  /// Returns the number of successfully imported songs.
  Future<int> pickAndImportAudioFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'flac', 'ogg', 'wma', 'opus'],
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        return 0;
      }

      int addedCount = 0;
      final existingPaths = _deviceTracks.map((t) => t.localAudioPath).toSet();
      final nowTimestamp = DateTime.now().millisecondsSinceEpoch;

      for (int i = 0; i < result.files.length; i++) {
        final file = result.files[i];
        final filePath = file.path;
        if (filePath == null || filePath.trim().isEmpty) continue;

        // Skip if already in the library
        if (existingPaths.contains(filePath)) continue;

        final ioFile = File(filePath);
        if (!ioFile.existsSync()) continue;

        final rawFileName = file.name;
        final (title, artist) = _parseFileName(rawFileName);
        final fileSizeBytes = file.size > 0 ? file.size : ioFile.lengthSync();

        // Use a unique negative ID to differentiate device tracks from database IDs
        final trackId = -((nowTimestamp % 100000000) * 10 + i + 1);

        final track = TrackModel(
          trackId: trackId,
          albumId: -1,
          genresId: -1,
          title: title,
          artistName: artist,
          albumTitle: 'Device Storage',
          audioUrl: '',
          localAudioPath: filePath,
          duration: 0,
          streamCount: 0,
          fileSizeBytes: fileSizeBytes,
          createdAt: DateTime.now(),
        );

        _deviceTracks.add(track);
        existingPaths.add(filePath);
        addedCount++;
      }

      if (addedCount > 0) {
        await _saveToPrefs();
        notifyListeners();
      }

      return addedCount;
    } catch (e) {
      debugPrint('Error picking and importing audio files: $e');
      return 0;
    }
  }

  (String, String) _parseFileName(String fileName) {
    // 1. Remove file extension
    String name = fileName;
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex != -1) {
      name = name.substring(0, dotIndex);
    }

    // 2. Remove leading track numbers like "01 - ", "01. ", "1. ", "01 "
    name = name.replaceFirst(RegExp(r'^\d+[\s.-]+'), '').trim();

    // 3. Check for "Artist - Title" pattern
    if (name.contains(' - ')) {
      final parts = name.split(' - ');
      if (parts.length >= 2) {
        final artist = parts[0].trim();
        final title = parts.sublist(1).join(' - ').trim();
        if (artist.isNotEmpty && title.isNotEmpty) {
          return (title, artist);
        }
      }
    }

    return (name.isNotEmpty ? name : 'Unknown Device Song', 'Device Audio');
  }

  Future<void> removeTrack(int trackId) async {
    _deviceTracks.removeWhere((t) => t.trackId == trackId);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _deviceTracks.clear();
    await _saveToPrefs();
    notifyListeners();
  }

  List<TrackModel> search(String query) {
    if (query.trim().isEmpty) return _deviceTracks;
    final q = query.toLowerCase().trim();
    return _deviceTracks.where((t) {
      final titleMatch = t.title.toLowerCase().contains(q);
      final artistMatch = (t.artistName ?? '').toLowerCase().contains(q);
      return titleMatch || artistMatch;
    }).toList();
  }
}
