import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/artist_model.dart';
import '../../../data/models/track_model.dart';
import '../../../data/models/album_model.dart';
import '../now_playing/player_screen.dart';

class ArtistDetailScreen extends StatelessWidget {
  final ArtistModel? artist;

  const ArtistDetailScreen({super.key, this.artist});

  static final _dummyArtist = ArtistModel(
    artistId: 1,
    name: 'Aurora Beats',
  );

  static final _dummyTracks = [
    TrackModel(trackId: 1, artistId: 1, albumId: 1, genreId: 1, title: 'Midnight Pulse', duration: 234, streamCount: 1500000),
    TrackModel(trackId: 2, artistId: 1, albumId: 1, genreId: 1, title: 'Distant Frequencies', duration: 312, streamCount: 620000),
    TrackModel(trackId: 3, artistId: 1, albumId: 1, genreId: 1, title: 'Electric Pulse', duration: 256, streamCount: 410000),
    TrackModel(trackId: 4, artistId: 1, albumId: 1, genreId: 1, title: 'Dreamcatcher', duration: 280, streamCount: 350000),
  ];

  static final _dummyAlbums = [
    AlbumModel(albumId: 1, artistId: 1, title: 'Electric Dreams', releaseDate: 2025),
    AlbumModel(albumId: 5, artistId: 1, title: 'Neon Horizons', releaseDate: 2024),
  ];

  @override
  Widget build(BuildContext context) {
    final displayArtist = artist ?? _dummyArtist;

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
                        child: const Icon(
                          Icons.person_rounded,
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
                    displayArtist.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Grammy-nominated electronic producer known for blending ambient textures with driving beats. Active since 2018 with over 2M monthly listeners worldwide.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                      height: 1.5,
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
                    '${track.streamCount ~/ 1000}K streams',
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
                  final album = _dummyAlbums[index];
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
                          child: const Icon(
                            Icons.album_rounded,
                            size: 40,
                            color: AppColors.textMuted,
                          ),
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
                        '${album.releaseDate ?? "Unknown"}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  );
                },
                childCount: _dummyAlbums.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
