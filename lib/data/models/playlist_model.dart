class PlaylistModel {
  final int playlistId;
  final String userId;
  final String title;
  final String? coverPng;
  final DateTime? createdAt;
  final int trackCount;

  PlaylistModel({
    required this.playlistId,
    required this.userId,
    required this.title,
    this.coverPng,
    this.createdAt,
    this.trackCount = 0,
  });

  factory PlaylistModel.fromMap(Map<String, dynamic> map) {
    int count = 0;
    if (map['track_count'] != null) {
      count = int.tryParse(map['track_count'].toString()) ?? 0;
    } else if (map['playlist_track_tbl'] is List) {
      final list = map['playlist_track_tbl'] as List;
      if (list.isNotEmpty && list[0] is Map && list[0].containsKey('count')) {
        count = int.tryParse(list[0]['count'].toString()) ?? 0;
      } else {
        count = list.length;
      }
    }

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
      trackCount: count,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'playlist_id': playlistId,
      'user_id': userId,
      'title': title,
      'cover_png': coverPng,
      'created_at': createdAt?.toIso8601String(),
      'track_count': trackCount,
    };
  }
}
