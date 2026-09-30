import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/track_model.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/device_music_provider.dart';
import '../now_playing/player_screen.dart';

class DeviceMusicScreen extends StatefulWidget {
  const DeviceMusicScreen({super.key});

  @override
  State<DeviceMusicScreen> createState() => _DeviceMusicScreenState();
}

class _DeviceMusicScreenState extends State<DeviceMusicScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _importSongs(BuildContext context) async {
    final provider = context.read<DeviceMusicProvider>();
    final count = await provider.pickAndImportAudioFiles();
    if (context.mounted) {
      if (count > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully imported $count ${count == 1 ? 'song' : 'songs'} from device!'),
            backgroundColor: context.primaryNeon,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No new audio files imported.'),
            backgroundColor: context.surfaceCard,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showTrackDetailsDialog(BuildContext context, TrackModel track) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceCard,
        title: Text(
          'File Details',
          style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(context, 'Title', track.title),
            const SizedBox(height: 8),
            _buildDetailRow(context, 'Artist', track.artistName ?? 'Device Audio'),
            const SizedBox(height: 8),
            _buildDetailRow(context, 'Size', track.fileSizeFormatted),
            const SizedBox(height: 8),
            _buildDetailRow(context, 'Location', track.localAudioPath ?? 'Local Storage'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: TextStyle(color: context.primaryNeon)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: context.textMuted, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(color: context.textPrimary, fontSize: 13),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, TrackModel track) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceCard,
        title: Text(
          'Remove from Library',
          style: TextStyle(color: context.textPrimary),
        ),
        content: Text(
          'Remove "${track.title}" from your Sonus library? (The original file on your device will not be deleted).',
          style: TextStyle(color: context.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: context.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<DeviceMusicProvider>().removeTrack(track.trackId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Removed "${track.title}" from library'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Music'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_to_photos_rounded),
            tooltip: 'Import Music from Device',
            onPressed: () => _importSongs(context),
          ),
        ],
      ),
      body: Consumer<DeviceMusicProvider>(
        builder: (context, provider, _) {
          final tracks = provider.search(_searchQuery);

          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: context.primaryNeon),
            );
          }

          if (provider.deviceTracks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: context.primaryNeon.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.primaryNeon.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.phonelink_ring_rounded,
                        size: 52,
                        color: context.primaryNeon,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Device Music Yet',
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Import MP3, WAV, FLAC, M4A, or AAC files from your device to play offline anytime with Sonus.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.textMuted,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _importSongs(context),
                        icon: const Icon(Icons.folder_open_rounded, size: 22),
                        label: const Text(
                          'Import from Device Storage',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Storage Stats Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.primaryNeon.withValues(alpha: 0.15),
                          context.surfaceCard,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.primaryNeon.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: context.primaryNeon.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.phone_android_rounded,
                            color: context.primaryNeon,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Local Device Audio',
                                style: TextStyle(
                                  color: context.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${provider.trackCount} ${provider.trackCount == 1 ? 'track' : 'tracks'} • ${provider.totalStorageFormatted}',
                                style: TextStyle(
                                  color: context.textMuted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline_rounded, color: context.primaryNeon),
                          tooltip: 'Add more songs',
                          onPressed: () => _importSongs(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: TextStyle(color: context.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search device songs or artists...',
                      prefixIcon: Icon(Icons.search_rounded, color: context.textMuted),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear_rounded, color: context.textMuted),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: context.surfaceCard,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.borderDark),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.borderDark),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.primaryNeon),
                      ),
                    ),
                  ),
                ),
              ),

              // Play All & Shuffle Buttons
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: tracks.isNotEmpty
                              ? () {
                                  final audio = context.read<AudioProvider>();
                                  audio.playTrackFromQueue(tracks, 0);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PlayerScreen(track: tracks.first),
                                    ),
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.play_arrow_rounded, size: 22),
                          label: const Text('Play All'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.primaryNeon,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: tracks.isNotEmpty
                              ? () {
                                  final audio = context.read<AudioProvider>();
                                  final shuffled = List<TrackModel>.from(tracks)..shuffle();
                                  audio.playTrackFromQueue(shuffled, 0);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PlayerScreen(track: shuffled.first),
                                    ),
                                  );
                                }
                              : null,
                          icon: Icon(Icons.shuffle_rounded, color: context.primaryNeon, size: 20),
                          label: Text(
                            'Shuffle',
                            style: TextStyle(color: context.textPrimary),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: context.borderDark),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Track List
              if (tracks.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No matching device songs found.',
                        style: TextStyle(color: context.textMuted),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildTrackTile(context, tracks[index], tracks, index),
                      childCount: tracks.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTrackTile(BuildContext context, TrackModel track, List<TrackModel> allTracks, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderDark.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.primaryNeon.withValues(alpha: 0.25),
                context.surfaceElevated,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.music_note_rounded,
            color: context.primaryNeon,
            size: 24,
          ),
        ),
        title: Text(
          track.title,
          style: TextStyle(
            color: context.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                track.artistName ?? 'Device Audio',
                style: TextStyle(color: context.textMuted, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (track.fileSizeFormatted.isNotEmpty) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: context.surfaceElevated,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  track.fileSizeFormatted,
                  style: TextStyle(color: context.textMuted, fontSize: 10),
                ),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded, color: context.textMuted),
          color: context.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (action) {
            final audio = context.read<AudioProvider>();
            switch (action) {
              case 'play_next':
                audio.addToQueue(track);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${track.title}" added to queue')),
                );
                break;
              case 'details':
                _showTrackDetailsDialog(context, track);
                break;
              case 'remove':
                _showDeleteDialog(context, track);
                break;
            }
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(
              value: 'play_next',
              child: Row(
                children: [
                  Icon(Icons.queue_music_rounded, size: 20),
                  SizedBox(width: 10),
                  Text('Add to Queue'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'details',
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 20),
                  SizedBox(width: 10),
                  Text('File Details'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                  SizedBox(width: 10),
                  Text('Remove from Library', style: TextStyle(color: Colors.redAccent)),
                ],
              ),
            ),
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
      ),
    );
  }
}
