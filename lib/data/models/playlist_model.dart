class PlaylistModel {
  final int playlistId;
  final String userId;
  final String title;
  final String? coverPng;
  final DateTime? createdAt;

  PlaylistModel({
    required this.playlistId,
    required this.userId,
    required this.title,
    this.coverPng,
    this.createdAt,
  });

  factory PlaylistModel.fromMap(Map<String, dynamic> map) {
    return PlaylistModel(
      playlistId: map['playlist_id'] is int
          ? map['playlist_id']
          : int.parse(map['playlist_id'].toString()),
      userId: map['user_id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      coverPng: map['cover_png']?.toString(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'playlist_id': playlistId,
      'user_id': userId,
      'title': title,
      'cover_png': coverPng,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
