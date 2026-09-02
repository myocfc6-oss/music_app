import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/playlist_model.dart';
import '../../../data/models/track_model.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/track_provider.dart';
import '../../global_widgets/track_art_widget.dart';
import '../now_playing/player_screen.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final PlaylistModel playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  List<TrackModel> _tracks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  Future<void> _loadTracks() async {
    final tracks = await context.read<TrackProvider>().fetchPlaylistTracks(widget.playlist.playlistId);
    if (mounted) {
      setState(() {
        _tracks = tracks;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist.title),
        actions: [
          if (_tracks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.play_arrow_rounded),
              onPressed: () {
                context.read<AudioProvider>().playTrackFromQueue(_tracks, 0);
              },
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'delete') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.surfaceCard,
                    title: const Text('Delete Playlist', style: TextStyle(color: AppColors.textPrimary)),
                    content: Text('Delete "${widget.playlist.title}"?',
                        style: const TextStyle(color: AppColors.textMuted)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  final navigator = Navigator.of(context);
                  await context.read<TrackProvider>().deletePlaylist(widget.playlist.playlistId);
                  navigator.pop();
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'delete', child: Text('Delete Playlist')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon))
          : _tracks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.music_off_rounded,
                        size: 64,
                        color: AppColors.textMuted.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'This playlist is empty',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add songs from the home screen',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _tracks.length,
                  itemBuilder: (context, index) {
                    final track = _tracks[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      leading: TrackArtWidget(
                        imageUrl: track.coverPng,
                        size: 40,
                        borderRadius: 6,
                        iconSize: 20,
                      ),
                      title: Text(
                        track.title,
                        style: const TextStyle(color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${track.artistName ?? ''} · ${track.durationFormatted}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                        onPressed: () async {
                          await context.read<TrackProvider>().removeTrackFromPlaylist(
                            widget.playlist.playlistId,
                            track.trackId,
                          );
                          _loadTracks();
                        },
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
                ),
    );
  }
}
