import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/album_model.dart';
import '../../../data/models/track_model.dart';
import '../now_playing/player_screen.dart';

class AlbumDetailScreen extends StatelessWidget {
  final AlbumModel? album;

  const AlbumDetailScreen({super.key, this.album});

  static final _dummyAlbum = AlbumModel(
    albumId: 1,
    title: 'Electric Dreams',
    releaseDate: DateTime(2025),
  );

  static final _dummyTracks = [
    TrackModel(trackId: 1, albumId: 1, genresId: 1, title: 'Midnight Pulse', audioUrl: '', duration: 234, streamCount: 1500000),
    TrackModel(trackId: 2, albumId: 1, genresId: 1, title: 'Neon Skyline', audioUrl: '', duration: 198, streamCount: 980000),
    TrackModel(trackId: 3, albumId: 1, genresId: 1, title: 'Distant Frequencies', audioUrl: '', duration: 312, streamCount: 620000),
    TrackModel(trackId: 4, albumId: 1, genresId: 1, title: 'Electric Pulse', audioUrl: '', duration: 256, streamCount: 410000),
    TrackModel(trackId: 5, albumId: 1, genresId: 1, title: 'Dreamcatcher', audioUrl: '', duration: 280, streamCount: 350000),
    TrackModel(trackId: 6, albumId: 1, genresId: 1, title: 'Starlight', audioUrl: '', duration: 205, streamCount: 290000),
  ];

  @override
  Widget build(BuildContext context) {
    final displayAlbum = album ?? _dummyAlbum;

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
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryNeon.withValues(alpha: 0.2),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.album_rounded,
                          size: 72,
                          color: AppColors.primaryNeon,
                        ),
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
                    displayAlbum.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Album ${displayAlbum.albumId}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${displayAlbum.releaseDate?.year ?? "Unknown"} · ${_dummyTracks.length} tracks',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
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
                        onPressed: () {},
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
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final track = _dummyTracks[index];
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PlayerScreen(track: track)),
                    );
                  },
                );
              },
              childCount: _dummyTracks.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
