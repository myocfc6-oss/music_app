import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/track_model.dart';
import '../data/models/album_model.dart';
import '../data/models/artist_model.dart';
import '../data/models/genre_model.dart';
import '../data/models/playlist_model.dart';
import '../data/models/user_model.dart';

class TrackProvider extends ChangeNotifier {
  static const String _cachedTrendingKey = 'sonus_cached_trending_tracks';
  static const String _cachedAlbumsKey = 'sonus_cached_albums';

  final SupabaseClient _supabase = Supabase.instance.client;

  List<TrackModel> _tracks = [];
  List<AlbumModel> _albums = [];
  List<ArtistModel> _artists = [];
  List<GenreModel> _genres = [];
  List<PlaylistModel> _playlists = [];
  List<TrackModel> _likedTracks = [];
  List<TrackModel> _searchResults = [];

  bool _isLoadingTracks = false;
  bool _isLoadingAlbums = false;
  bool _isLoadingPlaylists = false;
  bool _isLoadingLiked = false;

  TrackProvider() {
    _loadCachedContent();
  }

  Future<void> _loadCachedContent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tracksRaw = prefs.getStringList(_cachedTrendingKey);
      if (tracksRaw != null && tracksRaw.isNotEmpty && _tracks.isEmpty) {
        _tracks = tracksRaw
            .map((s) => TrackModel.fromMap(jsonDecode(s) as Map<String, dynamic>))
            .toList();
      }

      final albumsRaw = prefs.getStringList(_cachedAlbumsKey);
      if (albumsRaw != null && albumsRaw.isNotEmpty && _albums.isEmpty) {
        _albums = albumsRaw
            .map((s) => AlbumModel.fromMap(jsonDecode(s) as Map<String, dynamic>))
            .toList();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cached tracks/albums: $e');
    }
  }

  Future<void> _saveCachedTrending(List<TrackModel> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stringList = list.map((t) => jsonEncode(t.toMap())).toList();
      await prefs.setStringList(_cachedTrendingKey, stringList);
    } catch (e) {
      debugPrint('Error saving cached trending tracks: $e');
    }
  }

  Future<void> _saveCachedAlbums(List<AlbumModel> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stringList = list.map((a) => jsonEncode(a.toMap())).toList();
      await prefs.setStringList(_cachedAlbumsKey, stringList);
    } catch (e) {
      debugPrint('Error saving cached albums: $e');
    }
  }

  // Getters
  List<TrackModel> get tracks => _tracks;
  List<AlbumModel> get albums => _albums;
  List<ArtistModel> get artists => _artists;
  List<GenreModel> get genres => _genres;
  List<PlaylistModel> get playlists => _playlists;
  List<TrackModel> get likedTracks => _likedTracks;
  List<TrackModel> get searchResults => _searchResults;
  bool get isLoadingTracks => _isLoadingTracks;
  bool get isLoadingAlbums => _isLoadingAlbums;
  bool get isLoadingPlaylists => _isLoadingPlaylists;
  bool get isLoadingLiked => _isLoadingLiked;

  // ─── Helper: Parse track from Supabase row with joined data ───
  TrackModel _parseTrack(Map<String, dynamic> map, {String? defaultCover}) {
    final trackArtistRelations = map['track_artist_tbl'] as List?;
    String artistName = '';
    if (trackArtistRelations != null && trackArtistRelations.isNotEmpty) {
      artistName = trackArtistRelations[0]['artist_tbl']?['name'] ?? '';
    }
    final cover = map['cover_png'] ??
        map['cover_url'] ??
        map['album_tbl']?['cover_png'] ??
        defaultCover;
    return TrackModel(
      trackId: map['track_id'] is int ? map['track_id'] : int.parse(map['track_id'].toString()),
      albumId: map['album_id'] is int ? map['album_id'] : int.parse(map['album_id'].toString()),
      genresId: map['genres_id'] is int ? map['genres_id'] : int.parse(map['genres_id'].toString()),
      title: map['title']?.toString() ?? '',
      audioUrl: map['audio_url']?.toString() ?? '',
      duration: map['duration'] is int ? map['duration'] : int.parse((map['duration'] ?? 0).toString()),
      streamCount: map['stream_count'] is int ? map['stream_count'] : int.parse((map['stream_count'] ?? 0).toString()),
      artistName: artistName,
      albumTitle: map['album_tbl']?['title']?.toString(),
      genreName: map['genres_tbl']?['name']?.toString(),
      coverPng: cover?.toString(),
    );
  }

  // ─── Fetch all tracks ────────────────────────────────────
  Future<void> fetchTracks() async {
    _isLoadingTracks = true;
    notifyListeners();

    try {
      final data = await _supabase
          .from('track_tbl')
          .select('*, track_artist_tbl!inner(artist_tbl!inner(name)), album_tbl!inner(title, cover_png), genres_tbl!inner(name)');

      _tracks = data.map<TrackModel>((map) => _parseTrack(map)).toList();
    } catch (e) {
      debugPrint('Failed to fetch tracks (likely offline): $e');
    } finally {
      _isLoadingTracks = false;
      notifyListeners();
    }
  }

  // ─── Fetch trending tracks ──────────────────────────────
  Future<void> fetchTrendingTracks({int limit = 10}) async {
    _isLoadingTracks = true;
    notifyListeners();

    try {
      final data = await _supabase
          .from('track_tbl')
          .select('*, track_artist_tbl!inner(artist_tbl!inner(name)), album_tbl!inner(title, cover_png), genres_tbl!inner(name)')
          .order('stream_count', ascending: false)
          .limit(limit);

      _tracks = data.map<TrackModel>((map) => _parseTrack(map)).toList();
      await _saveCachedTrending(_tracks);
    } catch (e) {
      debugPrint('Failed to fetch trending tracks (likely offline): $e');
    } finally {
      _isLoadingTracks = false;
      notifyListeners();
    }
  }

  // ─── Fetch all albums (via album_artist_tbl junction) ────
  Future<void> fetchAlbums() async {
    _isLoadingAlbums = true;
    notifyListeners();

    try {
      final data = await _supabase
          .from('album_tbl')
          .select('*, album_artist_tbl!inner(artist_tbl!inner(name))')
          .order('release_date', ascending: false);

      _albums = data.map<AlbumModel>((map) {
        final relations = map['album_artist_tbl'] as List?;
        String artistName = '';
        if (relations != null && relations.isNotEmpty) {
          artistName = relations[0]['artist_tbl']?['name'] ?? '';
        }
        return AlbumModel.fromMap(map, artistName: artistName);
      }).toList();
      await _saveCachedAlbums(_albums);
    } catch (e) {
      debugPrint('Failed to fetch albums (likely offline): $e');
    } finally {
      _isLoadingAlbums = false;
      notifyListeners();
    }
  }

  // ─── Fetch all artists ──────────────────────────────────
  Future<void> fetchArtists() async {
    try {
      final data = await _supabase
          .from('artist_tbl')
          .select()
          .order('name');

      _artists = data.map<ArtistModel>((map) => ArtistModel.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch artists: $e');
    }
  }

  // ─── Fetch all genres ───────────────────────────────────
  Future<void> fetchGenres() async {
    try {
      final data = await _supabase
          .from('genres_tbl')
          .select()
          .order('name');

      _genres = data.map<GenreModel>((map) => GenreModel.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch genres: $e');
    }
  }

  // ─── Playlists ──────────────────────────────────────────
  Future<void> fetchPlaylists(String userId) async {
    _isLoadingPlaylists = true;
    notifyListeners();

    try {
      final data = await _supabase
          .from('playlist_tbl')
          .select('*, playlist_track_tbl(count)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _playlists = data.map<PlaylistModel>((map) => PlaylistModel.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Failed to fetch playlists: $e');
    } finally {
      _isLoadingPlaylists = false;
      notifyListeners();
    }
  }

  Future<void> createPlaylist(String userId, String title) async {
    try {
      final data = await _supabase.from('playlist_tbl').insert({
        'user_id': userId,
        'title': title,
      }).select().single();

      _playlists.insert(0, PlaylistModel.fromMap(data));
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to create playlist: $e');
    }
  }

  Future<void> deletePlaylist(int playlistId) async {
    try {
      await _supabase.from('playlist_tbl').delete().eq('playlist_id', playlistId);
      _playlists.removeWhere((p) => p.playlistId == playlistId);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to delete playlist: $e');
    }
  }

  Future<void> addTrackToPlaylist(int playlistId, int trackId) async {
    try {
      await _supabase.from('playlist_track_tbl').insert({
        'playlist_id': playlistId,
        'track_id': trackId,
      });

      final idx = _playlists.indexWhere((p) => p.playlistId == playlistId);
      if (idx != -1) {
        final p = _playlists[idx];
        _playlists[idx] = PlaylistModel(
          playlistId: p.playlistId,
          userId: p.userId,
          title: p.title,
          coverPng: p.coverPng,
          createdAt: p.createdAt,
          trackCount: p.trackCount + 1,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to add track to playlist: $e');
    }
  }

  Future<void> removeTrackFromPlaylist(int playlistId, int trackId) async {
    try {
      await _supabase
          .from('playlist_track_tbl')
          .delete()
          .eq('playlist_id', playlistId)
          .eq('track_id', trackId);

      final idx = _playlists.indexWhere((p) => p.playlistId == playlistId);
      if (idx != -1) {
        final p = _playlists[idx];
        _playlists[idx] = PlaylistModel(
          playlistId: p.playlistId,
          userId: p.userId,
          title: p.title,
          coverPng: p.coverPng,
          createdAt: p.createdAt,
          trackCount: (p.trackCount - 1).clamp(0, 999999),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to remove track from playlist: $e');
    }
  }

  Future<List<TrackModel>> fetchPlaylistTracks(int playlistId) async {
    try {
      final data = await _supabase
          .from('playlist_track_tbl')
          .select('track_tbl(*, track_artist_tbl!inner(artist_tbl!inner(name)), album_tbl(title, cover_png), genres_tbl!inner(name))')
          .eq('playlist_id', playlistId);

      return data.map<TrackModel>((map) {
        final trackData = map['track_tbl'];
        return _parseTrack(trackData);
      }).toList();
    } catch (e) {
      debugPrint('Failed to fetch playlist tracks: $e');
      return [];
    }
  }

  // ─── Likes ──────────────────────────────────────────────
  Future<void> likeTrack(String userId, int trackId) async {
    try {
      await _supabase.from('user_like_tbl').insert({
        'user_id': userId,
        'track_id': trackId,
      });
      final track = _tracks.firstWhere((t) => t.trackId == trackId);
      _likedTracks.add(track);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to like track: $e');
    }
  }

  Future<void> unlikeTrack(String userId, int trackId) async {
    try {
      await _supabase
          .from('user_like_tbl')
          .delete()
          .eq('user_id', userId)
          .eq('track_id', trackId);
      _likedTracks.removeWhere((t) => t.trackId == trackId);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to unlike track: $e');
    }
  }

  bool isTrackLiked(int trackId) {
    return _likedTracks.any((t) => t.trackId == trackId);
  }

  Future<void> fetchLikedTracks(String userId) async {
    _isLoadingLiked = true;
    notifyListeners();

    try {
      final data = await _supabase
          .from('user_like_tbl')
          .select('track_tbl(*, track_artist_tbl!inner(artist_tbl!inner(name)), album_tbl(title, cover_png), genres_tbl!inner(name))')
          .eq('user_id', userId);

      _likedTracks = data.map<TrackModel>((map) {
        final trackData = map['track_tbl'];
        return _parseTrack(trackData);
      }).toList();
    } catch (e) {
      debugPrint('Failed to fetch liked tracks: $e');
    } finally {
      _isLoadingLiked = false;
      notifyListeners();
    }
  }

  // ─── Search ─────────────────────────────────────────────
  Future<void> searchTracks(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    try {
      final data = await _supabase
          .from('track_tbl')
          .select('*, track_artist_tbl!inner(artist_tbl!inner(name)), album_tbl!inner(title, cover_png), genres_tbl!inner(name)')
          .ilike('title', '%$query%');

      _searchResults = data.map<TrackModel>((map) => _parseTrack(map)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to search tracks: $e');
    }
  }

  // ─── Detail Screen Queries ──────────────────────────────

  Future<List<TrackModel>> fetchTracksByAlbum(int albumId, {String? albumCover}) async {
    try {
      final data = await _supabase
          .from('track_tbl')
          .select('*, track_artist_tbl!inner(artist_tbl!inner(name)), genres_tbl!inner(name)')
          .eq('album_id', albumId)
          .order('track_id');

      return data.map<TrackModel>((map) => _parseTrack(map, defaultCover: albumCover)).toList();
    } catch (e) {
      debugPrint('Failed to fetch tracks by album: $e');
      return [];
    }
  }

  Future<List<TrackModel>> fetchTracksByArtist(int artistId) async {
    try {
      final data = await _supabase
          .from('track_artist_tbl')
          .select('track_tbl!inner(*, album_tbl!inner(title, cover_png), genres_tbl!inner(name))')
          .eq('artist_id', artistId);

      return data.map<TrackModel>((map) {
        final trackData = map['track_tbl'];
        return _parseTrack(trackData);
      }).toList();
    } catch (e) {
      debugPrint('Failed to fetch tracks by artist: $e');
      return [];
    }
  }

  Future<List<AlbumModel>> fetchAlbumsByArtist(int artistId) async {
    try {
      final data = await _supabase
          .from('album_artist_tbl')
          .select('album_tbl!inner(*)')
          .eq('artist_id', artistId);

      return data.map<AlbumModel>((map) {
        final albumData = map['album_tbl'];
        return AlbumModel.fromMap(albumData);
      }).toList();
    } catch (e) {
      debugPrint('Failed to fetch albums by artist: $e');
      return [];
    }
  }

  // ─── Admin CRUD ─────────────────────────────────────────

  // Users
  List<UserModel> _users = [];
  bool _isLoadingUsers = false;
  List<UserModel> get users => _users;
  bool get isLoadingUsers => _isLoadingUsers;

  Future<void> fetchUsers() async {
    _isLoadingUsers = true;
    notifyListeners();
    try {
      final data = await _supabase.from('user_tbl').select().order('name');
      _users = data.map<UserModel>((map) => UserModel.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Failed to fetch users: $e');
    } finally {
      _isLoadingUsers = false;
      notifyListeners();
    }
  }

  Future<void> updateUserRole(String userId, String role) async {
    try {
      await _supabase.from('user_tbl').update({'role': role}).eq('user_id', userId);
      final idx = _users.indexWhere((u) => u.id == userId);
      if (idx != -1) {
        _users[idx] = UserModel(
          id: _users[idx].id,
          name: _users[idx].name,
          email: _users[idx].email,
          role: role,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to update user role: $e');
    }
  }

  // Artists admin CRUD
  Future<void> createArtist(String name, {String? profilePic}) async {
    try {
      final data = await _supabase.from('artist_tbl').insert({
        'name': name,
        'profile_pic': profilePic,
      }).select().single();
      _artists.add(ArtistModel.fromMap(data));
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to create artist: $e');
    }
  }

  Future<void> updateArtist(int artistId, String name, {String? profilePic}) async {
    try {
      await _supabase.from('artist_tbl').update({
        'name': name,
        'profile_pic': profilePic,
      }).eq('artist_id', artistId);
      final idx = _artists.indexWhere((a) => a.artistId == artistId);
      if (idx != -1) {
        _artists[idx] = ArtistModel(artistId: artistId, name: name, profilePic: profilePic);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to update artist: $e');
    }
  }

  Future<void> deleteArtist(int artistId) async {
    try {
      await _supabase.from('artist_tbl').delete().eq('artist_id', artistId);
      _artists.removeWhere((a) => a.artistId == artistId);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to delete artist: $e');
    }
  }

  // Albums admin CRUD (album_tbl has no artist_id — use album_artist_tbl)
  Future<void> createAlbum(String title, {int? artistId, DateTime? releaseDate, String? coverPng}) async {
    try {
      final data = await _supabase.from('album_tbl').insert({
        'title': title,
        'release_date': releaseDate?.toIso8601String(),
        'cover_png': coverPng,
      }).select().single();

      final album = AlbumModel.fromMap(data);

      // Insert into junction table if artist provided
      if (artistId != null) {
        await _supabase.from('album_artist_tbl').insert({
          'album_id': album.albumId,
          'artist_id': artistId,
        });
      }

      _albums.add(album);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to create album: $e');
    }
  }

  Future<void> updateAlbum(int albumId, String title, {DateTime? releaseDate, String? coverPng}) async {
    try {
      await _supabase.from('album_tbl').update({
        'title': title,
        'release_date': releaseDate?.toIso8601String(),
        'cover_png': coverPng,
      }).eq('album_id', albumId);
      final idx = _albums.indexWhere((a) => a.albumId == albumId);
      if (idx != -1) {
        _albums[idx] = AlbumModel(
          albumId: albumId,
          title: title,
          releaseDate: releaseDate,
          coverPng: coverPng,
          artistName: _albums[idx].artistName,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to update album: $e');
    }
  }

  Future<void> deleteAlbum(int albumId) async {
    try {
      await _supabase.from('album_tbl').delete().eq('album_id', albumId);
      _albums.removeWhere((a) => a.albumId == albumId);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to delete album: $e');
    }
  }

  // Tracks admin CRUD (track_tbl has no artist_id — use track_artist_tbl)
  Future<void> createTrack({
    required String title,
    required int artistId,
    required int albumId,
    required int genresId,
    required int duration,
    String? audioUrl,
  }) async {
    try {
      final data = await _supabase.from('track_tbl').insert({
        'title': title,
        'album_id': albumId,
        'genres_id': genresId,
        'duration': duration,
        'audio_url': audioUrl ?? '',
      }).select().single();

      final track = TrackModel.fromMap(data);

      // Insert into junction table
      await _supabase.from('track_artist_tbl').insert({
        'track_id': track.trackId,
        'artist_id': artistId,
      });

      _tracks.add(track);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to create track: $e');
    }
  }

  Future<void> updateTrack(int trackId, {
    required String title,
    required int duration,
    String? audioUrl,
  }) async {
    try {
      await _supabase.from('track_tbl').update({
        'title': title,
        'duration': duration,
        'audio_url': audioUrl,
      }).eq('track_id', trackId);
      final idx = _tracks.indexWhere((t) => t.trackId == trackId);
      if (idx != -1) {
        _tracks[idx] = TrackModel(
          trackId: trackId,
          albumId: _tracks[idx].albumId,
          genresId: _tracks[idx].genresId,
          title: title,
          audioUrl: audioUrl ?? _tracks[idx].audioUrl,
          duration: duration,
          streamCount: _tracks[idx].streamCount,
          artistName: _tracks[idx].artistName,
          albumTitle: _tracks[idx].albumTitle,
          genreName: _tracks[idx].genreName,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to update track: $e');
    }
  }

  Future<void> deleteTrack(int trackId) async {
    try {
      await _supabase.from('track_tbl').delete().eq('track_id', trackId);
      _tracks.removeWhere((t) => t.trackId == trackId);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to delete track: $e');
    }
  }

  // Increment stream count
  Future<void> incrementStreamCount(int trackId) async {
    try {
      await _supabase.rpc('increment_stream_count', params: {'tid': trackId});
      _updateLocalStreamCount(trackId);
    } catch (e) {
      debugPrint('Failed to increment stream count: $e');
    }
  }

  void notifyStreamIncremented(int trackId) {
    _updateLocalStreamCount(trackId);
  }

  void _updateLocalStreamCount(int trackId) {
    bool changed = false;
    _tracks = _tracks.map((t) {
      if (t.trackId == trackId) {
        changed = true;
        return t.copyWith(streamCount: t.streamCount + 1);
      }
      return t;
    }).toList();

    _searchResults = _searchResults.map((t) {
      if (t.trackId == trackId) {
        changed = true;
        return t.copyWith(streamCount: t.streamCount + 1);
      }
      return t;
    }).toList();

    _likedTracks = _likedTracks.map((t) {
      if (t.trackId == trackId) {
        changed = true;
        return t.copyWith(streamCount: t.streamCount + 1);
      }
      return t;
    }).toList();

    if (changed) {
      notifyListeners();
    }
  }
}
