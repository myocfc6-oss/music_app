import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/track_model.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/track_provider.dart';
import '../../global_widgets/track_art_widget.dart';
import '../now_playing/player_screen.dart';

class LikedSongsScreen extends StatefulWidget {
  const LikedSongsScreen({super.key});

  @override
  State<LikedSongsScreen> createState() => _LikedSongsScreenState();
}

class _LikedSongsScreenState extends State<LikedSongsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        context.read<TrackProvider>().fetchLikedTracks(auth.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liked Songs')),
      body: Consumer2<AuthProvider, TrackProvider>(
        builder: (context, auth, trackProvider, _) {
          if (auth.user == null) {
            return const Center(
              child: Text('Please sign in to view liked songs',
                  style: TextStyle(color: AppColors.textMuted)),
            );
          }

          if (trackProvider.isLoadingLiked) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryNeon),
            );
          }

          final likedTracks = trackProvider.likedTracks;

          if (likedTracks.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_outline_rounded,
                    size: 64,
                    color: AppColors.textMuted.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No liked songs yet',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap the heart icon on any track to like it',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: likedTracks.length,
            itemBuilder: (context, index) {
              final track = likedTracks[index];
              return _buildLikedTrackTile(track, likedTracks, index, auth, trackProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildLikedTrackTile(
    TrackModel track,
    List<TrackModel> allTracks,
    int index,
    AuthProvider auth,
    TrackProvider trackProvider,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: TrackArtWidget(
        imageUrl: track.coverPng,
        size: 48,
        borderRadius: 8,
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
        track.artistName ?? '',
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
          IconButton(
            icon: const Icon(Icons.favorite_rounded, color: AppColors.primaryNeon, size: 20),
            onPressed: () {
              trackProvider.unlikeTrack(auth.user!.id, track.trackId);
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
