import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/genre_model.dart';
import '../genre_detail_screen.dart';

class GenreCard extends StatelessWidget {
  final GenreModel genre;

  const GenreCard({super.key, required this.genre});

  IconData _getGenreIcon(String name) {
    switch (name.toLowerCase()) {
      case 'pop':
        return Icons.star_rounded;
      case 'rock':
        return Icons.electric_bolt_rounded;
      case 'hip-hop':
      case 'hip hop':
        return Icons.mic_rounded;
      case 'electronic':
      case 'edm':
        return Icons.headphones_rounded;
      case 'jazz':
        return Icons.piano;
      case 'classical':
        return Icons.queue_music_rounded;
      case 'r&b':
      case 'rnb':
        return Icons.favorite_rounded;
      case 'country':
        return Icons.terrain_rounded;
      case 'metal':
        return Icons.local_fire_department_rounded;
      default:
        return Icons.music_note_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GenreDetailScreen(genre: genre),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getGenreIcon(genre.name),
                color: AppColors.primaryNeon,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                genre.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
