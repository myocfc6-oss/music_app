import 'package:flutter_test/flutter_test.dart';
import 'package:music_app/data/models/track_model.dart';
import 'package:music_app/providers/download_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Offline TrackModel Tests', () {
    test('TrackModel serialization retains local paths and size bytes', () {
      final track = TrackModel(
        trackId: 101,
        albumId: 1,
        genresId: 1,
        title: 'Cyberpunk Beats',
        artistName: 'Neon Synth',
        audioUrl: 'https://example.com/audio.mp3',
        coverPng: 'https://example.com/cover.png',
        duration: 240,
        streamCount: 1500,
        localAudioPath: '/data/user/0/com.example/app_flutter/downloads/tracks/101_audio.mp3',
        localCoverPath: '/data/user/0/com.example/app_flutter/downloads/covers/101_cover.png',
        fileSizeBytes: 5242880, // 5 MB
      );

      expect(track.isDownloaded, isTrue);
      expect(track.fileSizeFormatted, '5.0 MB');

      final map = track.toMap();
      final restored = TrackModel.fromMap(map);

      expect(restored.trackId, 101);
      expect(restored.title, 'Cyberpunk Beats');
      expect(restored.localAudioPath, track.localAudioPath);
      expect(restored.localCoverPath, track.localCoverPath);
      expect(restored.fileSizeBytes, 5242880);
      expect(restored.isDownloaded, isTrue);
    });

    test('TrackModel copyWith updates local paths properly', () {
      final track = TrackModel(
        trackId: 202,
        albumId: 2,
        genresId: 2,
        title: 'Ambient Echoes',
        audioUrl: 'https://example.com/ambient.mp3',
        duration: 180,
        streamCount: 42,
      );

      expect(track.isDownloaded, isFalse);
      expect(track.fileSizeFormatted, '');

      final downloaded = track.copyWith(
        localAudioPath: '/local/audio.mp3',
        fileSizeBytes: 10485760, // 10 MB
      );

      expect(downloaded.isDownloaded, isTrue);
      expect(downloaded.fileSizeFormatted, '10.0 MB');
    });
  });

  group('DownloadProvider Helpers Tests', () {
    test('Default states for tracks', () {
      final provider = DownloadProvider();
      final track = TrackModel(
        trackId: 303,
        albumId: 3,
        genresId: 3,
        title: 'Drive Track',
        audioUrl: 'https://example.com/stream.mp3',
        duration: 200,
        streamCount: 10,
      );

      expect(provider.isDownloaded(track.trackId), isFalse);
      expect(provider.isDownloading(track.trackId), isFalse);
      expect(provider.getProgress(track.trackId), 0.0);
    });
  });
}
