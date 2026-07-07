import 'artist_model.dart';

class AlbumModel {
  final int albumId;
  final int artistId;
  final String title;
  final int? releaseDate;
  final String? coverPng;
  final ArtistModel? artist;

  AlbumModel({
    required this.albumId,
    required this.artistId,
    required this.title,
    this.releaseDate,
    this.coverPng,
    this.artist,
  });

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      albumId: json['album_id'] as int,
      artistId: json['artist_id'] as int,
      title: json['title'] as String,
      releaseDate: json['release_date'] as int?,
      coverPng: json['cover_png'] as String?,
      artist: json['artist'] != null
          ? ArtistModel.fromJson(json['artist'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'album_id': albumId,
      'artist_id': artistId,
      'title': title,
      'release_date': releaseDate,
      'cover_png': coverPng,
    };
  }
}
