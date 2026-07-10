import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/playlist_model.dart';
import 'playlist_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<PlaylistModel> _playlists = [
    PlaylistModel(
      playlistId: 1,
      userId: '1',
      title: 'Chill Vibes',
    ),
    PlaylistModel(
      playlistId: 2,
      userId: '1',
      title: 'Workout Mix',
    ),
    PlaylistModel(
      playlistId: 3,
      userId: '1',
      title: 'Late Night Drive',
    ),
  ];

  void _showCreatePlaylistDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: const Text(
          'New Playlist',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Playlist name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  _playlists.add(
                    PlaylistModel(
                      playlistId: _playlists.length + 1,
                      userId: '1',
                      title: nameController.text.trim(),
                    ),
                  );
                });
              }
              Navigator.pop(context);
            },
            child: const Text(
              'Create',
              style: TextStyle(color: AppColors.primaryNeon),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          automaticallyImplyLeading: false,
          title: const Text('Your Library'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: _showCreatePlaylistDialog,
            ),
          ],
        ),
        if (_playlists.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(
                    Icons.library_music_rounded,
                    size: 64,
                    color: AppColors.textMuted.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No playlists yet',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your first playlist to get started',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildPlaylistTile(_playlists[index]),
                childCount: _playlists.length,
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildPlaylistTile(PlaylistModel playlist) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryNeon.withValues(alpha: 0.3),
              AppColors.surfaceCard,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.queue_music_rounded,
          color: AppColors.primaryNeon,
        ),
      ),
      title: Text(
        playlist.title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        '0 tracks',
        style: TextStyle(
          color: AppColors.textMuted.withValues(alpha: 0.7),
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMuted,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlaylistDetailScreen(playlist: playlist),
          ),
        );
      },
    );
  }
}
