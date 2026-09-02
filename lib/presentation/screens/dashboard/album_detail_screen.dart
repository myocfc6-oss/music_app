import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/album_model.dart';
import '../../../data/models/track_model.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/track_provider.dart';
import '../../global_widgets/track_art_widget.dart';
import '../now_playing/player_screen.dart';

class AlbumDetailScreen extends StatefulWidget {
  final AlbumModel? album;

  const AlbumDetailScreen({super.key, this.album});

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  List<TrackModel> _tracks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  Future<void> _loadTracks() async {
    if (widget.album == null) {
      setState(() => _isLoading = false);
      return;
    }
    final tracks = await context.read<TrackProvider>().fetchTracksByAlbum(
      widget.album!.albumId,
      albumCover: widget.album!.coverPng,
    );
    if (mounted) {
      setState(() {
        _tracks = tracks;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final album = widget.album;

    if (album == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Album')),
        body: const Center(child: Text('No album selected', style: TextStyle(color: AppColors.textMuted))),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
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
                      AppColors.primaryNeon.withValues(alpha: 0.3),
                      AppColors.surfaceDark,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      TrackArtWidget(
                        imageUrl: album.coverPng,
                        size: 180,
                        borderRadius: 12,
                        placeholderIcon: Icons.album_rounded,
                        iconSize: 72,
                        glowColor: AppColors.primaryNeon.withValues(alpha: 0.2),
                        glowBlur: 30,
                        glowSpread: 2,
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
                    album.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    album.artistName ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${album.releaseDate?.year ?? "Unknown"} · ${_tracks.length} tracks',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_border_rounded),
                        color: AppColors.textMuted,
                      ),
                      IconButton(
                        onPressed: _tracks.isNotEmpty
                            ? () {
                                context.read<AudioProvider>().toggleShuffle();
                                context.read<AudioProvider>().playTrackFromQueue(_tracks, 0);
                              }
                            : null,
                        icon: const Icon(Icons.shuffle_rounded),
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
                  child: Text('No tracks in this album', style: TextStyle(color: AppColors.textMuted)),
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
                      track.durationFormatted,
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
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
