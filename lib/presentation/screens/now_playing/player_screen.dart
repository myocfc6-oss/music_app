import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/track_model.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/track_provider.dart';
import '../../global_widgets/track_art_widget.dart';
import '../../screens/dashboard/artist_detail_screen.dart';

class PlayerScreen extends StatefulWidget {
  final TrackModel? track;

  const PlayerScreen({super.key, this.track});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _isDragging = false;
  double _dragValue = 0;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audio = context.read<AudioProvider>();
      if (widget.track != null && audio.currentTrack?.trackId != widget.track!.trackId) {
        audio.playTrack(widget.track!);
      }
      if (audio.isPlaying) {
        _rotationController.repeat();
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AudioProvider>(
          builder: (context, audio, _) {
            final track = audio.currentTrack ?? widget.track;

            // Sync rotation animation with play state
            if (audio.isPlaying && !_rotationController.isAnimating) {
              _rotationController.repeat();
            } else if (!audio.isPlaying && _rotationController.isAnimating) {
              _rotationController.stop();
            }

            if (track == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.music_note_rounded, size: 80, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text(
                      'No track selected',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'NOW PLAYING',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          letterSpacing: 2,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_horiz_rounded),
                        onPressed: () => _showTrackOptions(context, track),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Album art with rotation
                  Expanded(
                    child: Center(
                      child: RotationTransition(
                        turns: _rotationController,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 320),
                            child: TrackArtWidget(
                              imageUrl: track.coverPng,
                              borderRadius: 20,
                              iconSize: 80,
                              glowColor: AppColors.primaryNeon.withValues(alpha: audio.isPlaying ? 0.25 : 0.1),
                              glowBlur: audio.isPlaying ? 60 : 40,
                              glowSpread: audio.isPlaying ? 8 : 4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Track info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.title,
                              style: Theme.of(context).textTheme.titleLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              track.artistName ?? '',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      _buildLikeButton(track),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Progress bar
                  _buildProgressBar(audio),
                  const SizedBox(height: 16),

                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous_rounded, size: 32),
                        onPressed: audio.hasPrevious ? () => audio.previousTrack() : null,
                      ),
                      _buildPlayButton(audio),
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded, size: 32),
                        onPressed: audio.hasNext ? () => audio.nextTrack() : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Extra controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.shuffle_rounded,
                          size: 22,
                          color: audio.isShuffleOn
                              ? AppColors.primaryNeon
                              : AppColors.textMuted,
                        ),
                        onPressed: () => audio.toggleShuffle(),
                      ),
                      IconButton(
                        icon: Icon(
                          _getRepeatIcon(audio.repeatMode),
                          size: 22,
                          color: audio.repeatMode != AppRepeatMode.off
                              ? AppColors.primaryNeon
                              : AppColors.textMuted,
                        ),
                        onPressed: () => audio.toggleRepeat(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.playlist_add_rounded, size: 22),
                        onPressed: () => _showAddToPlaylist(context, track),
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressBar(AudioProvider audio) {
    final double maxDuration = audio.duration > 0 ? audio.duration : 1.0;
    final double position = _isDragging ? _dragValue : audio.currentPosition;

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            trackHeight: 3,
            activeTrackColor: AppColors.primaryNeon,
            inactiveTrackColor: AppColors.surfaceElevated,
            thumbColor: AppColors.primaryNeon,
            overlayColor: AppColors.primaryNeon.withValues(alpha: 0.1),
          ),
          child: Slider(
            value: (position.clamp(0.0, maxDuration)).toDouble(),
            min: 0,
            max: maxDuration.toDouble(),
            onChangeStart: (value) {
              setState(() {
                _isDragging = true;
                _dragValue = value;
              });
            },
            onChanged: (value) {
              setState(() {
                _dragValue = value;
              });
            },
            onChangeEnd: (value) {
              setState(() {
                _isDragging = false;
              });
              audio.seekTo(value);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position.toInt()),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                _formatDuration(audio.duration.toInt()),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton(AudioProvider audio) {
    final processingState = audio.player.processingState;

    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      return Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          color: AppColors.primaryNeon,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              color: Colors.black,
              strokeWidth: 3,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.primaryNeon,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          audio.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          size: 36,
          color: Colors.black,
        ),
        onPressed: () => audio.togglePlayPause(),
      ),
    );
  }

  IconData _getRepeatIcon(AppRepeatMode mode) {
    switch (mode) {
      case AppRepeatMode.off:
        return Icons.repeat_rounded;
      case AppRepeatMode.all:
        return Icons.repeat_rounded;
      case AppRepeatMode.one:
        return Icons.repeat_one_rounded;
    }
  }

  Widget _buildLikeButton(TrackModel track) {
    final auth = context.watch<AuthProvider>();
    final trackProvider = context.watch<TrackProvider>();

    if (auth.user == null) {
      return IconButton(
        icon: const Icon(Icons.favorite_border_rounded),
        color: AppColors.textMuted,
        onPressed: () {},
      );
    }

    final isLiked = trackProvider.isTrackLiked(track.trackId);

    return IconButton(
      icon: Icon(
        isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        color: isLiked ? AppColors.primaryNeon : AppColors.textMuted,
      ),
      onPressed: () {
        if (isLiked) {
          trackProvider.unlikeTrack(auth.user!.id, track.trackId);
        } else {
          trackProvider.likeTrack(auth.user!.id, track.trackId);
        }
      },
    );
  }

  void _showTrackOptions(BuildContext context, TrackModel track) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: AppColors.borderDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.queue_music_rounded, color: AppColors.textMuted),
              title: const Text('Add to Queue', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                context.read<AudioProvider>().addToQueue(track);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add_rounded, color: AppColors.textMuted),
              title: const Text('Add to Playlist', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _showAddToPlaylist(context, track);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_rounded, color: AppColors.textMuted),
              title: const Text('Go to Artist', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                final trackProvider = context.read<TrackProvider>();
                final artist = trackProvider.artists.firstWhere(
                  (a) => a.name == track.artistName,
                  orElse: () => trackProvider.artists.isNotEmpty
                      ? trackProvider.artists.first
                      : throw Exception('No artist found'),
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArtistDetailScreen(artist: artist),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddToPlaylist(BuildContext context, TrackModel track) {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Consumer<TrackProvider>(
        builder: (context, trackProvider, _) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: AppColors.borderDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Add to Playlist',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (trackProvider.playlists.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No playlists yet. Create one first.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: trackProvider.playlists.length,
                      itemBuilder: (context, index) {
                        final playlist = trackProvider.playlists[index];
                        return ListTile(
                          leading: const Icon(Icons.queue_music_rounded, color: AppColors.primaryNeon),
                          title: Text(
                            playlist.title,
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                          onTap: () {
                            trackProvider.addTrackToPlaylist(playlist.playlistId, track.trackId);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added to ${playlist.title}'),
                                backgroundColor: AppColors.primaryNeon,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
