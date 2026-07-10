class GenreModel {
  final int genresId;
  final String name;

  GenreModel({
    required this.genresId,
    required this.name,
  });

  factory GenreModel.fromMap(Map<String, dynamic> map) {
    return GenreModel(
      genresId: map['genres_id'] is int
          ? map['genres_id']
          : int.parse(map['genres_id'].toString()),
      name: map['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'genres_id': genresId,
      'name': name,
    };
  }
}
