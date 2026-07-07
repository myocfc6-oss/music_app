class GenreModel {
  final int genreId;
  final String name;

  GenreModel({
    required this.genreId,
    required this.name,
  });

  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      genreId: json['genre_id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'genre_id': genreId,
      'name': name,
    };
  }
}
