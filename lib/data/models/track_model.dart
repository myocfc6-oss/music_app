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
  final String? coverPng;
  final String? localAudioPath;
  final String? localCoverPath;
  final int? fileSizeBytes;

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
    this.coverPng,
    this.localAudioPath,
    this.localCoverPath,
    this.fileSizeBytes,
  });

  bool get isDownloaded => localAudioPath != null && localAudioPath!.isNotEmpty;

  factory TrackModel.fromMap(
    Map<String, dynamic> map, {
    String? artistName,
    String? albumTitle,
    String? genreName,
    String? coverPng,
    String? localAudioPath,
    String? localCoverPath,
    int? fileSizeBytes,
  }) {
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
      artistName: artistName ?? map['artist_name']?.toString(),
      albumTitle: albumTitle ?? map['album_title']?.toString(),
      genreName: genreName ?? map['genre_name']?.toString(),
      coverPng: coverPng ?? map['cover_png']?.toString() ?? map['cover_url']?.toString(),
      localAudioPath: localAudioPath ?? map['local_audio_path']?.toString(),
      localCoverPath: localCoverPath ?? map['local_cover_path']?.toString(),
      fileSizeBytes: fileSizeBytes ?? (map['file_size_bytes'] is int ? map['file_size_bytes'] : null),
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
      'cover_png': coverPng,
      'artist_name': artistName,
      'album_title': albumTitle,
      'genre_name': genreName,
      'local_audio_path': localAudioPath,
      'local_cover_path': localCoverPath,
      'file_size_bytes': fileSizeBytes,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  TrackModel copyWith({
    int? trackId,
    int? albumId,
    int? genresId,
    String? title,
    String? audioUrl,
    int? duration,
    int? streamCount,
    DateTime? createdAt,
    String? artistName,
    String? albumTitle,
    String? genreName,
    String? coverPng,
    String? localAudioPath,
    String? localCoverPath,
    int? fileSizeBytes,
  }) {
    return TrackModel(
      trackId: trackId ?? this.trackId,
      albumId: albumId ?? this.albumId,
      genresId: genresId ?? this.genresId,
      title: title ?? this.title,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      streamCount: streamCount ?? this.streamCount,
      createdAt: createdAt ?? this.createdAt,
      artistName: artistName ?? this.artistName,
      albumTitle: albumTitle ?? this.albumTitle,
      genreName: genreName ?? this.genreName,
      coverPng: coverPng ?? this.coverPng,
      localAudioPath: localAudioPath ?? this.localAudioPath,
      localCoverPath: localCoverPath ?? this.localCoverPath,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
    );
  }

  String get durationFormatted {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get fileSizeFormatted {
    if (fileSizeBytes == null || fileSizeBytes == 0) return '';
    final mb = fileSizeBytes! / (1024 * 1024);
    if (mb >= 1.0) {
      return '${mb.toStringAsFixed(1)} MB';
    }
    final kb = fileSizeBytes! / 1024;
    return '${kb.toStringAsFixed(0)} KB';
  }
}
