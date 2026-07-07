class ArtistModel {
  final int artistId;
  final String name;
  final String? profilePic;

  ArtistModel({
    required this.artistId,
    required this.name,
    this.profilePic,
  });

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    return ArtistModel(
      artistId: json['artist_id'] as int,
      name: json['name'] as String,
      profilePic: json['profile_pic'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'artist_id': artistId,
      'name': name,
      'profile_pic': profilePic,
    };
  }
}
