class UserLikeModel {
  final int id;
  final int userId;
  final int trackId;
  final String? likeAt;

  UserLikeModel({
    required this.id,
    required this.userId,
    required this.trackId,
    this.likeAt,
  });

  factory UserLikeModel.fromJson(Map<String, dynamic> json) {
    return UserLikeModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      trackId: json['track_id'] as int,
      likeAt: json['like_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'track_id': trackId,
      'like_at': likeAt,
    };
  }
}
