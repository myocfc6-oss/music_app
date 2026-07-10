import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/track_model.dart';

class PlayerScreen extends StatefulWidget {
  final TrackModel? track;

  const PlayerScreen({super.key, this.track});

  static final _dummyTrack = TrackModel(
    trackId: 0,
    albumId: 0,
    genresId: 0,
    title: 'Sample Track',
    audioUrl: '',
    duration: 215,
    streamCount: 0,
  );

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _isPlaying = false;
  double _currentPosition = 0;
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
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
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Album art
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 320),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryNeon.withValues(alpha: 0.1),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.music_note_rounded,
                          size: 80,
                          color: AppColors.primaryNeon,
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
                          (widget.track ?? PlayerScreen._dummyTrack).title,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Album ${(widget.track ?? PlayerScreen._dummyTrack).albumId}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: _isLiked ? AppColors.primaryNeon : AppColors.textMuted,
                    ),
                    onPressed: () => setState(() => _isLiked = !_isLiked),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Progress bar
              Column(
                children: [
                  Slider(
                    value: _currentPosition,
                    min: 0,
                    max: (widget.track ?? PlayerScreen._dummyTrack).duration.toDouble(),
                    onChanged: (value) {
                      setState(() => _currentPosition = value);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_currentPosition.toInt()),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          (widget.track ?? PlayerScreen._dummyTrack).durationFormatted,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous_rounded, size: 32),
                    onPressed: () {},
                  ),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryNeon,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 36,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() => _isPlaying = !_isPlaying);
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded, size: 32),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Extra controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shuffle_rounded, size: 22),
                    onPressed: () {},
                    color: AppColors.textMuted,
                  ),
                  IconButton(
                    icon: const Icon(Icons.repeat_rounded, size: 22),
                    onPressed: () {},
                    color: AppColors.textMuted,
                  ),
                  IconButton(
                    icon: const Icon(Icons.playlist_add_rounded, size: 22),
                    onPressed: () {},
                    color: AppColors.textMuted,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
