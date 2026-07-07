import 'track_model.dart';

class PlaylistModel {
  final int playlistId;
  final int userId;
  final String title;
  final String? coverPng;
  final List<TrackModel>? tracks;

  PlaylistModel({
    required this.playlistId,
    required this.userId,
    required this.title,
    this.coverPng,
    this.tracks,
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      playlistId: json['playlist_id'] as int,
      userId: json['user_id'] as int,
      title: json['title'] as String,
      coverPng: json['cover_png'] as String?,
      tracks: json['tracks'] != null
          ? (json['tracks'] as List)
              .map((t) => TrackModel.fromJson(t as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playlist_id': playlistId,
      'user_id': userId,
      'title': title,
      'cover_png': coverPng,
    };
  }
}
