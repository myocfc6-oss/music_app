import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/track_model.dart';
import '../../../data/models/album_model.dart';
import '../../global_widgets/mini_audio_player.dart';
import '../search/search_screen.dart';
import '../library/library_screen.dart';
import '../now_playing/player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<TrackModel> _trendingTracks = [
    TrackModel(
      trackId: 1,
      artistId: 1,
      albumId: 1,
      genreId: 1,
      title: 'Midnight Pulse',
      duration: 234,
      streamCount: 1500000,
    ),
    TrackModel(
      trackId: 2,
      artistId: 2,
      albumId: 2,
      genreId: 2,
      title: 'Neon Skyline',
      duration: 198,
      streamCount: 980000,
    ),
    TrackModel(
      trackId: 3,
      artistId: 3,
      albumId: 3,
      genreId: 3,
      title: 'Velvet Echoes',
      duration: 267,
      streamCount: 750000,
    ),
    TrackModel(
      trackId: 4,
      artistId: 1,
      albumId: 1,
      genreId: 1,
      title: 'Distant Frequencies',
      duration: 312,
      streamCount: 620000,
    ),
    TrackModel(
      trackId: 5,
      artistId: 4,
      albumId: 4,
      genreId: 4,
      title: 'Golden Hour',
      duration: 185,
      streamCount: 540000,
    ),
  ];

  final List<AlbumModel> _recentAlbums = [
    AlbumModel(
      albumId: 1,
      artistId: 1,
      title: 'Electric Dreams',
      releaseDate: 2025,
    ),
    AlbumModel(
      albumId: 2,
      artistId: 2,
      title: 'City Lights',
      releaseDate: 2025,
    ),
    AlbumModel(
      albumId: 3,
      artistId: 3,
      title: 'Ocean Waves',
      releaseDate: 2024,
    ),
    AlbumModel(
      albumId: 4,
      artistId: 4,
      title: 'Sunset Boulevard',
      releaseDate: 2024,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBody(),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MiniAudioPlayer(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: AppColors.surfaceDark,
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: AppColors.surfaceDark,
            selectedItemColor: AppColors.primaryNeon,
            unselectedItemColor: AppColors.textMuted,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Search'),
              BottomNavigationBarItem(icon: Icon(Icons.library_music_rounded), label: 'Library'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const SearchScreen();
      case 2:
        return const LibraryScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          automaticallyImplyLeading: false,
          title: const Text('Sonus'),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              'Trending Now',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildTrackTile(_trendingTracks[index]),
            childCount: _trendingTracks.length,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Text(
              'Recent Albums',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildAlbumCard(_recentAlbums[index]),
              childCount: _recentAlbums.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildTrackTile(TrackModel track) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.music_note_rounded, color: AppColors.primaryNeon),
      ),
      title: Text(
        track.title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        'Artist ${track.artistId}',
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            track.durationFormatted,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.more_vert, color: AppColors.textMuted, size: 20),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlayerScreen(track: track),
          ),
        );
      },
    );
  }

  Widget _buildAlbumCard(AlbumModel album) {
    return GestureDetector(
      onTap: () {},
      child: Column(
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
                size: 48,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            album.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Artist ${album.artistId}',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
