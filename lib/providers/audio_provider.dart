import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/track_model.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  ConcatenatingAudioSource _playlistSource = ConcatenatingAudioSource(children: []);

  TrackModel? _currentTrack;
  List<TrackModel> _queue = [];
  int _currentIndex = -1;
  bool _isShuffleOn = false;
  AppRepeatMode _repeatMode = AppRepeatMode.off;
  int? _countedTrackId;
  void Function(int trackId)? onStreamIncremented;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<bool>? _shuffleModeEnabledSub;
  StreamSubscription<LoopMode>? _loopModeSub;
  StreamSubscription<int?>? _currentIndexSub;

  // Getters
  TrackModel? get currentTrack => _currentTrack;
  List<TrackModel> get queue => _queue;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _player.playing;
  double get currentPosition => _player.position.inSeconds.toDouble();
  double get duration => (_player.duration ?? Duration.zero).inSeconds.toDouble();
  bool get isShuffleOn => _isShuffleOn;
  AppRepeatMode get repeatMode => _repeatMode;
  bool get hasTrack => _currentTrack != null;
  bool get hasNext => _currentIndex < _queue.length - 1;
  bool get hasPrevious => _currentIndex > 0;
  AudioPlayer get player => _player;

  AudioProvider() {
    _initAudioSession();
    _initStreams();
  }

  void _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Handle headphone button / notification controls
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            _player.setVolume((_player.volume * 0.8).clamp(0.0, 1.0));
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            _player.pause();
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            _player.setVolume(1.0);
            break;
          case AudioInterruptionType.pause:
            _player.play();
            break;
          case AudioInterruptionType.unknown:
            break;
        }
      }
    });

    session.becomingNoisyEventStream.listen((_) {
      _player.pause();
    });
  }

  void _initStreams() {
    _positionSub = _player.positionStream.listen((position) {
      _checkStreamCount(position);
      notifyListeners();
    });

    _durationSub = _player.durationStream.listen((duration) {
      notifyListeners();
    });

    _playerStateSub = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onTrackComplete();
      }
      notifyListeners();
    });

    _shuffleModeEnabledSub = _player.shuffleModeEnabledStream.listen((enabled) {
      _isShuffleOn = enabled;
      notifyListeners();
    });

    _loopModeSub = _player.loopModeStream.listen((mode) {
      switch (mode) {
        case LoopMode.off:
          _repeatMode = AppRepeatMode.off;
          break;
        case LoopMode.all:
          _repeatMode = AppRepeatMode.all;
          break;
        case LoopMode.one:
          _repeatMode = AppRepeatMode.one;
          break;
      }
      notifyListeners();
    });

    _currentIndexSub = _player.currentIndexStream.listen((index) {
      if (index != null && index >= 0 && index < _queue.length && index != _currentIndex) {
        _currentIndex = index;
        _currentTrack = _queue[index];
        _countedTrackId = null;
        notifyListeners();
      }
    });
  }

  void _checkStreamCount(Duration position) {
    if (_currentTrack == null) return;
    final trackId = _currentTrack!.trackId;
    if (_countedTrackId == trackId) return;

    final dur = _player.duration;
    final threshold = (dur != null && dur.inSeconds < 15 && dur.inSeconds > 0)
        ? (dur.inSeconds ~/ 2)
        : 15;

    if (position.inSeconds >= threshold) {
      _countedTrackId = trackId;
      _incrementStreamCount(trackId);
    }
  }

  Future<void> _incrementStreamCount(int trackId) async {
    try {
      await Supabase.instance.client.rpc('increment_stream_count', params: {'tid': trackId});
      onStreamIncremented?.call(trackId);
    } catch (e) {
      debugPrint('Stream count increment error: $e');
    }
  }

  void _onTrackComplete() {
    if (_currentTrack != null && _countedTrackId != _currentTrack!.trackId) {
      _countedTrackId = _currentTrack!.trackId;
      _incrementStreamCount(_currentTrack!.trackId);
    }

    if (_repeatMode == AppRepeatMode.one) {
      _player.seek(Duration.zero);
      _player.play();
      return;
    }

    if (_repeatMode == AppRepeatMode.all && !_player.hasNext) {
      _player.seek(Duration.zero, index: 0);
      _player.play();
    }
  }

  AudioSource _buildAudioSource(TrackModel track) {
    Uri audioUri;
    if (track.localAudioPath != null && File(track.localAudioPath!).existsSync()) {
      audioUri = Uri.file(track.localAudioPath!);
    } else {
      final formattedUrl = formatAudioUrl(track.audioUrl);
      audioUri = Uri.parse(formattedUrl);
    }

    Uri? artUri;
    if (track.localCoverPath != null && File(track.localCoverPath!).existsSync()) {
      artUri = Uri.file(track.localCoverPath!);
    } else if (track.coverPng != null && track.coverPng!.trim().isNotEmpty) {
      try {
        final parsed = Uri.parse(track.coverPng!.trim());
        if (parsed.hasScheme) {
          artUri = parsed;
        }
      } catch (_) {}
    }

    return AudioSource.uri(
      audioUri,
      tag: MediaItem(
        id: track.trackId.toString(),
        album: (track.albumTitle != null && track.albumTitle!.isNotEmpty)
            ? track.albumTitle!
            : 'Sonus Music',
        title: track.title.isNotEmpty ? track.title : 'Unknown Track',
        artist: (track.artistName != null && track.artistName!.isNotEmpty)
            ? track.artistName!
            : 'Unknown Artist',
        artUri: artUri,
        duration: track.duration > 0 ? Duration(seconds: track.duration) : null,
      ),
    );
  }

  // Play a single track (no queue)
  Future<void> playTrack(TrackModel track) async {
    await playTrackFromQueue([track], 0);
  }

  // Play a track within a queue
  Future<void> playTrackFromQueue(List<TrackModel> tracks, int index) async {
    if (tracks.isEmpty || index < 0 || index >= tracks.length) return;
    _queue = List.from(tracks);
    _currentIndex = index;
    _currentTrack = _queue[index];
    _errorMessage = null;
    _countedTrackId = null;

    try {
      final sources = <AudioSource>[];
      for (final t in _queue) {
        if (t.audioUrl.isNotEmpty || (t.localAudioPath != null && File(t.localAudioPath!).existsSync())) {
          sources.add(_buildAudioSource(t));
        }
      }

      if (sources.isEmpty) {
        _errorMessage = 'No audio available for the selected tracks.';
        notifyListeners();
        return;
      }

      _playlistSource = ConcatenatingAudioSource(children: sources);
      await _player.stop();
      await _player.setAudioSource(
        _playlistSource,
        initialIndex: index.clamp(0, sources.length - 1),
        initialPosition: Duration.zero,
      );
      await _player.play();
    } catch (e) {
      _errorMessage = 'Playback error: $e';
      debugPrint('Failed to play audio queue: $e');
    }
    notifyListeners();
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String formatAudioUrl(String url) {
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

  Future<void> playByIndex(int index) async {
    if (index < 0 || index >= _queue.length) return;
    _currentIndex = index;
    _currentTrack = _queue[index];
    _countedTrackId = null;
    try {
      await _player.seek(Duration.zero, index: index);
      if (!_player.playing) {
        await _player.play();
      }
    } catch (e) {
      debugPrint('Failed to play index $index: $e');
    }
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
    notifyListeners();
  }

  Future<void> pause() async {
    await _player.pause();
    notifyListeners();
  }

  Future<void> resume() async {
    await _player.play();
    notifyListeners();
  }

  Future<void> seekTo(double position) async {
    await _player.seek(Duration(seconds: position.toInt()));
    notifyListeners();
  }

  Future<void> nextTrack() async {
    if (_queue.isEmpty) return;

    if (_repeatMode == AppRepeatMode.one) {
      await _player.seek(Duration.zero);
      await _player.play();
      return;
    }

    if (_player.hasNext) {
      await _player.seekToNext();
    } else if (_repeatMode == AppRepeatMode.all) {
      await _player.seek(Duration.zero, index: 0);
    } else {
      await _player.pause();
      await _player.seek(Duration.zero);
      notifyListeners();
    }
  }

  Future<void> previousTrack() async {
    if (_queue.isEmpty) return;

    // If more than 3 seconds in, restart current track
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      notifyListeners();
      return;
    }

    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    } else if (_repeatMode == AppRepeatMode.all) {
      await _player.seek(Duration.zero, index: _queue.length - 1);
    }
  }

  Future<void> toggleShuffle() async {
    _isShuffleOn = !_isShuffleOn;
    await _player.setShuffleModeEnabled(_isShuffleOn);
    notifyListeners();
  }

  Future<void> toggleRepeat() async {
    switch (_repeatMode) {
      case AppRepeatMode.off:
        _repeatMode = AppRepeatMode.all;
        await _player.setLoopMode(LoopMode.all);
        break;
      case AppRepeatMode.all:
        _repeatMode = AppRepeatMode.one;
        await _player.setLoopMode(LoopMode.one);
        break;
      case AppRepeatMode.one:
        _repeatMode = AppRepeatMode.off;
        await _player.setLoopMode(LoopMode.off);
        break;
    }
    notifyListeners();
  }

  Future<void> addToQueue(TrackModel track) async {
    _queue.add(track);
    if (_player.audioSource != null && track.audioUrl.isNotEmpty) {
      await _playlistSource.add(_buildAudioSource(track));
    }
    notifyListeners();
  }

  Future<void> removeFromQueue(int index) async {
    if (index < 0 || index >= _queue.length) return;
    _queue.removeAt(index);
    if (_player.audioSource != null && index < _playlistSource.length) {
      await _playlistSource.removeAt(index);
    }
    if (_queue.isEmpty) {
      await _player.stop();
      _currentTrack = null;
      _currentIndex = -1;
    }
    notifyListeners();
  }

  Future<void> clearQueue() async {
    await _player.stop();
    await _playlistSource.clear();
    _queue.clear();
    _currentIndex = -1;
    _currentTrack = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    _shuffleModeEnabledSub?.cancel();
    _loopModeSub?.cancel();
    _currentIndexSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}

enum AppRepeatMode { off, all, one }
