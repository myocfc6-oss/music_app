class UserLikeModel {
  final int id;
  final String userId;
  final int trackId;
  final DateTime? likeAt;

  UserLikeModel({
    required this.id,
    required this.userId,
    required this.trackId,
    this.likeAt,
  });

  factory UserLikeModel.fromMap(Map<String, dynamic> map) {
    return UserLikeModel(
      id: map['id'] is int
          ? map['id']
          : int.parse(map['id'].toString()),
      userId: map['user_id']?.toString() ?? '',
      trackId: map['track_id'] is int
          ? map['track_id']
          : int.parse(map['track_id'].toString()),
      likeAt: map['like_at'] != null
          ? DateTime.tryParse(map['like_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'track_id': trackId,
      'like_at': likeAt?.toIso8601String(),
    };
  }
}
