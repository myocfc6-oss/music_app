class PlaylistTrackModel {
  final int id;
  final int playlistId;
  final int trackId;
  final DateTime? addedAt;

  PlaylistTrackModel({
    required this.id,
    required this.playlistId,
    required this.trackId,
    this.addedAt,
  });

  factory PlaylistTrackModel.fromMap(Map<String, dynamic> map) {
    return PlaylistTrackModel(
      id: map['id'] is int
          ? map['id']
          : int.parse(map['id'].toString()),
      playlistId: map['playlist_id'] is int
          ? map['playlist_id']
          : int.parse(map['playlist_id'].toString()),
      trackId: map['track_id'] is int
          ? map['track_id']
          : int.parse(map['track_id'].toString()),
      addedAt: map['added_at'] != null
          ? DateTime.tryParse(map['added_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'playlist_id': playlistId,
      'track_id': trackId,
      'added_at': addedAt?.toIso8601String(),
    };
  }
}
