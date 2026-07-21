import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/genre_model.dart';
import '../../../data/models/track_model.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/track_provider.dart';
import '../now_playing/player_screen.dart';

class GenreDetailScreen extends StatefulWidget {
  final GenreModel genre;

  const GenreDetailScreen({super.key, required this.genre});

  @override
  State<GenreDetailScreen> createState() => _GenreDetailScreenState();
}

class _GenreDetailScreenState extends State<GenreDetailScreen> {
  List<TrackModel> _tracks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  Future<void> _loadTracks() async {
    final trackProvider = context.read<TrackProvider>();
    await trackProvider.fetchTracks();
    if (mounted) {
      setState(() {
        _tracks = trackProvider.tracks
            .where((t) => t.genresId == widget.genre.genresId)
            .toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.genre.name)),
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
                        'No tracks in this genre',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 16),
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
                        track.artistName ?? '',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                      trailing: Text(
                        track.durationFormatted,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
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
