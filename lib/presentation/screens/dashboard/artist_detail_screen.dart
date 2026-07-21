import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/artist_model.dart';
import '../../../data/models/track_model.dart';
import '../../../data/models/album_model.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/track_provider.dart';
import '../now_playing/player_screen.dart';

class ArtistDetailScreen extends StatefulWidget {
  final ArtistModel? artist;

  const ArtistDetailScreen({super.key, this.artist});

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  List<TrackModel> _tracks = [];
  List<AlbumModel> _albums = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.artist == null) {
      setState(() => _isLoading = false);
      return;
    }
    final tp = context.read<TrackProvider>();
    final tracks = await tp.fetchTracksByArtist(widget.artist!.artistId);
    final albums = await tp.fetchAlbumsByArtist(widget.artist!.artistId);
    if (mounted) {
      setState(() {
        _tracks = tracks;
        _albums = albums;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final artist = widget.artist;

    if (artist == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Artist')),
        body: const Center(child: Text('No artist selected', style: TextStyle(color: AppColors.textMuted))),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryNeon.withValues(alpha: 0.25),
                      AppColors.surfaceDark,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryNeon.withValues(alpha: 0.2),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: artist.profilePic != null && artist.profilePic!.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  artist.profilePic!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded, size: 72, color: AppColors.primaryNeon),
                                ),
                              )
                            : const Icon(Icons.person_rounded, size: 72, color: AppColors.primaryNeon),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artist.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_tracks.length} tracks · ${_albums.length} albums',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _tracks.isNotEmpty
                              ? () => context.read<AudioProvider>().playTrackFromQueue(_tracks, 0)
                              : null,
                          icon: const Icon(Icons.play_arrow_rounded, color: Colors.black),
                          label: const Text('Play', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryNeon,
                            minimumSize: const Size(0, 48),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          side: const BorderSide(color: AppColors.borderDark),
                        ),
                        child: const Text('Follow', style: TextStyle(color: AppColors.textPrimary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Popular Tracks',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(color: AppColors.primaryNeon),
                ),
              ),
            )
          else if (_tracks.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: Center(
                  child: Text('No tracks by this artist', style: TextStyle(color: AppColors.textMuted)),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final track = _tracks[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                    leading: Text(
                      '${index + 1}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                    ),
                    title: Text(
                      track.title,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      '${track.streamCount ~/ 1000}K streams',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert, color: AppColors.textMuted, size: 20),
                      onPressed: () {},
                    ),
                    onTap: () {
                      context.read<AudioProvider>().playTrackFromQueue(_tracks, index);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PlayerScreen(track: track)),
                      );
                    },
                  );
                },
                childCount: _tracks.length,
              ),
            ),
          if (_albums.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Text(
                  'Albums',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final album = _albums[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceCard,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: album.coverPng != null && album.coverPng!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(album.coverPng!, fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.album_rounded, size: 40, color: AppColors.textMuted),
                                    ),
                                  )
                                : const Icon(Icons.album_rounded, size: 40, color: AppColors.textMuted),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          album.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${album.releaseDate?.year ?? "Unknown"}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                        ),
                      ],
                    );
                  },
                  childCount: _albums.length,
                ),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
