class TrackModel {
  final int trackId;
  final int albumId;
  final int genresId;
  final String title;
  final String audioUrl;
  final int duration;
  final int streamCount;
  final DateTime? createdAt;
  final String? artistName;
  final String? albumTitle;
  final String? genreName;

  TrackModel({
    required this.trackId,
    required this.albumId,
    required this.genresId,
    required this.title,
    required this.audioUrl,
    required this.duration,
    required this.streamCount,
    this.createdAt,
    this.artistName,
    this.albumTitle,
    this.genreName,
  });

  factory TrackModel.fromMap(Map<String, dynamic> map, {String? artistName, String? albumTitle, String? genreName}) {
    return TrackModel(
      trackId: map['track_id'] is int
          ? map['track_id']
          : int.parse(map['track_id'].toString()),
      albumId: map['album_id'] is int
          ? map['album_id']
          : int.parse(map['album_id'].toString()),
      genresId: map['genres_id'] is int
          ? map['genres_id']
          : int.parse(map['genres_id'].toString()),
      title: map['title']?.toString() ?? '',
      audioUrl: map['audio_url']?.toString() ?? '',
      duration: map['duration'] is int
          ? map['duration']
          : int.parse(map['duration'].toString()),
      streamCount: map['stream_count'] is int
          ? map['stream_count']
          : int.parse(map['stream_count'].toString()),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      artistName: artistName,
      albumTitle: albumTitle,
      genreName: genreName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'track_id': trackId,
      'album_id': albumId,
      'genres_id': genresId,
      'title': title,
      'audio_url': audioUrl,
      'duration': duration,
      'stream_count': streamCount,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String get durationFormatted {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
