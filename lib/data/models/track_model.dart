import 'artist_model.dart';
import 'album_model.dart';
import 'genre_model.dart';

class TrackModel {
  final int trackId;
  final int artistId;
  final int albumId;
  final int genreId;
  final String title;
  final int duration;
  final int streamCount;
  final ArtistModel? artist;
  final AlbumModel? album;
  final GenreModel? genre;

  TrackModel({
    required this.trackId,
    required this.artistId,
    required this.albumId,
    required this.genreId,
    required this.title,
    required this.duration,
    required this.streamCount,
    this.artist,
    this.album,
    this.genre,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      trackId: json['track_id'] as int,
      artistId: json['artist_id'] as int,
      albumId: json['album_id'] as int,
      genreId: json['genre_id'] as int,
      title: json['title'] as String,
      duration: json['duration'] as int,
      streamCount: json['stream_count'] as int,
      artist: json['artist'] != null
          ? ArtistModel.fromJson(json['artist'] as Map<String, dynamic>)
          : null,
      album: json['album'] != null
          ? AlbumModel.fromJson(json['album'] as Map<String, dynamic>)
          : null,
      genre: json['genre'] != null
          ? GenreModel.fromJson(json['genre'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'track_id': trackId,
      'artist_id': artistId,
      'album_id': albumId,
      'genre_id': genreId,
      'title': title,
      'duration': duration,
      'stream_count': streamCount,
    };
  }

  String get durationFormatted {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
