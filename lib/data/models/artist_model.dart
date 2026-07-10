class ArtistModel {
  final int artistId;
  final String name;
  final String? profilePic;
  final DateTime? createdAt;

  ArtistModel({
    required this.artistId,
    required this.name,
    this.profilePic,
    this.createdAt,
  });

  factory ArtistModel.fromMap(Map<String, dynamic> map) {
    return ArtistModel(
      artistId: map['artist_id'] is int
          ? map['artist_id']
          : int.parse(map['artist_id'].toString()),
      name: map['name']?.toString() ?? '',
      profilePic: map['profile_pic']?.toString(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'artist_id': artistId,
      'name': name,
      'profile_pic': profilePic,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
