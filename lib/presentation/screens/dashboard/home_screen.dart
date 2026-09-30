import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/track_model.dart';
import '../../../data/models/album_model.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/download_provider.dart';
import '../../../providers/track_provider.dart';
import '../../global_widgets/mini_audio_player.dart';
import '../../global_widgets/track_art_widget.dart';
import '../search/search_screen.dart';
import '../library/library_screen.dart';
import '../now_playing/player_screen.dart';
import '../profile/profile_screen.dart';
import 'album_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trackProvider = context.read<TrackProvider>();
      trackProvider.fetchTrendingTracks();
      trackProvider.fetchAlbums();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
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
          color: context.surfaceDark,
          child: SafeArea(
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: context.surfaceDark,
              selectedItemColor: context.primaryNeon,
              unselectedItemColor: context.textMuted,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Search'),
                BottomNavigationBarItem(icon: Icon(Icons.library_music_rounded), label: 'Library'),
                BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
              ],
            ),
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
      case 3:
        return const ProfileScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return Consumer3<TrackProvider, AuthProvider, DownloadProvider>(
      builder: (context, trackProvider, auth, downloadProvider, _) {
        final tracks = trackProvider.tracks;
        final albums = trackProvider.albums;
        final downloadedTracks = downloadProvider.downloadedTracks;

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('Sonus'),
                ],
              ),
              actions: [
                if (auth.isGuest)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.primaryNeon.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.primaryNeon.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.offline_pin_rounded, size: 14, color: context.primaryNeon),
                        const SizedBox(width: 4),
                        Text(
                          'Offline Mode',
                          style: TextStyle(
                            color: context.primaryNeon,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
              ],
            ),
            if (tracks.isEmpty && downloadedTracks.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Icon(Icons.offline_pin_rounded, color: context.primaryNeon, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Downloaded Songs (Offline)',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildTrackTile(
                    context,
                    downloadedTracks[index],
                    downloadedTracks,
                    index,
                  ),
                  childCount: downloadedTracks.length,
                ),
              ),
            ] else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Text(
                    'Trending Now',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              if (trackProvider.isLoadingTracks && tracks.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: context.primaryNeon),
                    ),
                  ),
                )
              else if (tracks.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.wifi_off_rounded, size: 48, color: context.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'No tracks available offline',
                          style: TextStyle(color: context.textMuted, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Connect to the internet or listen to your downloads',
                          style: TextStyle(color: context.textMuted.withValues(alpha: 0.7), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildTrackTile(context, tracks[index], tracks, index),
                    childCount: tracks.length,
                  ),
                ),
            ],
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Text(
                  'Recent Albums',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            if (trackProvider.isLoadingAlbums && albums.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: context.primaryNeon),
                  ),
                ),
              )
            else if (albums.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No albums cached yet',
                      style: TextStyle(color: context.textMuted),
                    ),
                  ),
                ),
              )
            else
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
                    (context, index) => _buildAlbumCard(context, albums[index]),
                    childCount: albums.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  Widget _buildTrackTile(BuildContext context, TrackModel track, List<TrackModel> allTracks, int index) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: TrackArtWidget(
        imageUrl: track.coverPng,
        size: 48,
        borderRadius: 8,
      ),
      title: Text(
        track.title,
        style: TextStyle(
          color: context.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        track.artistName ?? '',
        style: TextStyle(color: context.textMuted, fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            track.durationFormatted,
            style: TextStyle(color: context.textMuted, fontSize: 12),
          ),
          const SizedBox(width: 8),
          Icon(Icons.more_vert, color: context.textMuted, size: 20),
        ],
      ),
      onTap: () {
        context.read<AudioProvider>().playTrackFromQueue(allTracks, index);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlayerScreen(track: track),
          ),
        );
      },
    );
  }

  Widget _buildAlbumCard(BuildContext context, AlbumModel album) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AlbumDetailScreen(album: album),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TrackArtWidget(
              imageUrl: album.coverPng,
              width: double.infinity,
              height: double.infinity,
              borderRadius: 8,
              placeholderIcon: Icons.album_rounded,
              iconSize: 48,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            album.title,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            album.artistName ?? '',
            style: TextStyle(
              color: context.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
