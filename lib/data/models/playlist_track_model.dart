class PlaylistTrackModel {
  final int id;
  final int playlistId;
  final int trackId;

  PlaylistTrackModel({
    required this.id,
    required this.playlistId,
    required this.trackId,
  });

  factory PlaylistTrackModel.fromJson(Map<String, dynamic> json) {
    return PlaylistTrackModel(
      id: json['id'] as int,
      playlistId: json['playlist_id'] as int,
      trackId: json['track_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'playlist_id': playlistId,
      'track_id': trackId,
    };
  }
}
