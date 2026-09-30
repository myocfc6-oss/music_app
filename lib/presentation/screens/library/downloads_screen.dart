import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/track_model.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/download_provider.dart';
import '../../global_widgets/track_art_widget.dart';
import '../now_playing/player_screen.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadProvider>(
      builder: (context, downloadProvider, _) {
        final downloadedTracks = downloadProvider.downloadedTracks;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Downloaded Music'),
            actions: [
              if (downloadedTracks.isNotEmpty)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (value) async {
                    if (value == 'clear_all') {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: context.surfaceCard,
                          title: Text('Delete All Downloads', style: TextStyle(color: context.textPrimary)),
                          content: Text(
                            'Are you sure you want to remove all ${downloadedTracks.length} downloaded songs from this device?',
                            style: TextStyle(color: context.textMuted),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text('Cancel', style: TextStyle(color: context.textMuted)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete All', style: TextStyle(color: AppColors.error)),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await downloadProvider.clearAllDownloads();
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'clear_all',
                      child: Row(
                        children: [
                          Icon(Icons.delete_sweep_rounded, color: AppColors.error, size: 20),
                          SizedBox(width: 8),
                          Text('Delete All Downloads', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: downloadedTracks.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: context.primaryNeon.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.download_done_rounded,
                            size: 40,
                            color: context.primaryNeon,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No Downloaded Songs',
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the download icon on any track to listen offline without internet connection.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: context.primaryNeon.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.offline_pin_rounded, size: 14, color: context.primaryNeon),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Offline Storage: ${downloadProvider.totalStorageFormatted}',
                                        style: TextStyle(
                                          color: context.primaryNeon,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${downloadedTracks.length} ${downloadedTracks.length == 1 ? "track" : "tracks"}',
                                  style: TextStyle(color: context.textMuted, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      context.read<AudioProvider>().playTrackFromQueue(downloadedTracks, 0);
                                    },
                                    icon: Icon(Icons.play_arrow_rounded, color: context.isDarkMode ? Colors.black : Colors.white),
                                    label: Text(
                                      'Play All',
                                      style: TextStyle(
                                        color: context.isDarkMode ? Colors.black : Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: context.primaryNeon,
                                      minimumSize: const Size(0, 48),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      final shuffled = List<TrackModel>.from(downloadedTracks)..shuffle();
                                      context.read<AudioProvider>().playTrackFromQueue(shuffled, 0);
                                    },
                                    icon: Icon(Icons.shuffle_rounded, color: context.primaryNeon),
                                    label: Text(
                                      'Shuffle',
                                      style: TextStyle(
                                        color: context.primaryNeon,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: context.primaryNeon),
                                      minimumSize: const Size(0, 48),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final track = downloadedTracks[index];
                          return _buildDownloadedTrackTile(context, track, downloadedTracks, index, downloadProvider);
                        },
                        childCount: downloadedTracks.length,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildDownloadedTrackTile(
    BuildContext context,
    TrackModel track,
    List<TrackModel> allTracks,
    int index,
    DownloadProvider downloadProvider,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: TrackArtWidget(
        imageUrl: track.localCoverPath ?? track.coverPng,
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
      subtitle: Row(
        children: [
          Icon(Icons.offline_pin_rounded, size: 12, color: context.primaryNeon),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '${track.artistName ?? "Unknown"} · ${track.fileSizeFormatted}',
              style: TextStyle(color: context.textMuted, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            track.durationFormatted,
            style: TextStyle(color: context.textMuted, fontSize: 12),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: context.surfaceCard,
                  title: Text('Delete Download', style: TextStyle(color: context.textPrimary)),
                  content: Text('Remove "${track.title}" from downloaded music?', style: TextStyle(color: context.textMuted)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: TextStyle(color: context.textMuted))),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await downloadProvider.deleteDownload(track.trackId);
              }
            },
          ),
        ],
      ),
      onTap: () {
        context.read<AudioProvider>().playTrackFromQueue(allTracks, index);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PlayerScreen(track: track)),
        );
      },
    );
  }
}
