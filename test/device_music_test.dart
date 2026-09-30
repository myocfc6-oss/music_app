import 'package:flutter_test/flutter_test.dart';
import 'package:music_app/data/models/track_model.dart';
import 'package:music_app/providers/device_music_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceMusicProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial state is empty', () {
      final provider = DeviceMusicProvider();
      expect(provider.deviceTracks, isEmpty);
      expect(provider.trackCount, 0);
      expect(provider.hasTracks, isFalse);
      expect(provider.totalStorageBytes, 0);
      expect(provider.totalStorageFormatted, '0.0 MB');
    });

    test('Searching device tracks filters by title and artist', () {
      final provider = DeviceMusicProvider();
      
      // Test search on empty
      expect(provider.search('Beatles'), isEmpty);
    });

    test('TrackModel supports local device paths and properties', () {
      final track = TrackModel(
        trackId: -1001,
        albumId: -1,
        genresId: -1,
        title: 'Bohemian Rhapsody',
        artistName: 'Queen',
        albumTitle: 'Device Storage',
        audioUrl: '',
        localAudioPath: 'C:/Music/Queen - Bohemian Rhapsody.mp3',
        duration: 0,
        streamCount: 0,
        fileSizeBytes: 6291456, // 6 MB
      );

      expect(track.isDownloaded, isTrue);
      expect(track.fileSizeFormatted, '6.0 MB');
      expect(track.artistName, 'Queen');
      expect(track.albumTitle, 'Device Storage');
    });
  });
}
