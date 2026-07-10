class AlbumModel {
  final int albumId;
  final String title;
  final DateTime? releaseDate;
  final String? coverPng;
  final DateTime? createdAt;

  AlbumModel({
    required this.albumId,
    required this.title,
    this.releaseDate,
    this.coverPng,
    this.createdAt,
  });

  factory AlbumModel.fromMap(Map<String, dynamic> map) {
    return AlbumModel(
      albumId: map['album_id'] is int
          ? map['album_id']
          : int.parse(map['album_id'].toString()),
      title: map['title']?.toString() ?? '',
      releaseDate: map['release_date'] != null
          ? DateTime.tryParse(map['release_date'].toString())
          : null,
      coverPng: map['cover_png']?.toString(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'album_id': albumId,
      'title': title,
      'release_date': releaseDate?.toIso8601String(),
      'cover_png': coverPng,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
