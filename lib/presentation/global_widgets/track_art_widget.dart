import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class TrackArtWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final double size;
  final double borderRadius;
  final IconData placeholderIcon;
  final double? iconSize;
  final Color? glowColor;
  final double glowBlur;
  final double glowSpread;
  final BoxFit fit;

  const TrackArtWidget({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.size = 48,
    this.borderRadius = 8,
    this.placeholderIcon = Icons.music_note_rounded,
    this.iconSize,
    this.glowColor,
    this.glowBlur = 0,
    this.glowSpread = 0,
    this.fit = BoxFit.cover,
  });

  String? _formatImageUrl(String? url) {
    if (url == null) return null;
    var trimmed = url.trim();
    if (trimmed.isEmpty) return null;

    // Handle Google Drive direct links if needed
    if (trimmed.contains('drive.google.com/file/d/')) {
      final regExp = RegExp(r'drive\.google\.com/file/d/([a-zA-Z0-9_-]+)');
      final match = regExp.firstMatch(trimmed);
      if (match != null && match.groupCount >= 1) {
        final fileId = match.group(1);
        return 'https://docs.google.com/uc?export=download&id=$fileId';
      }
    }
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? size;
    final effectiveHeight = height ?? size;
    final effectiveIconSize = iconSize ?? (size * 0.45).clamp(16.0, 96.0);
    final formattedUrl = _formatImageUrl(imageUrl);

    final boxDecoration = BoxDecoration(
      color: AppColors.surfaceCard,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: glowColor != null && glowBlur > 0
          ? [
              BoxShadow(
                color: glowColor!,
                blurRadius: glowBlur,
                spreadRadius: glowSpread,
              ),
            ]
          : null,
    );

    if (formattedUrl != null) {
      return Container(
        width: effectiveWidth,
        height: effectiveHeight,
        decoration: boxDecoration,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.network(
            formattedUrl,
            width: effectiveWidth,
            height: effectiveHeight,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder(effectiveWidth, effectiveHeight, effectiveIconSize);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: effectiveWidth,
                height: effectiveHeight,
                color: AppColors.surfaceCard,
                child: Center(
                  child: SizedBox(
                    width: (effectiveWidth * 0.3).clamp(12.0, 24.0),
                    height: (effectiveHeight * 0.3).clamp(12.0, 24.0),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryNeon,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return Container(
      width: effectiveWidth,
      height: effectiveHeight,
      decoration: boxDecoration,
      child: _buildPlaceholder(effectiveWidth, effectiveHeight, effectiveIconSize),
    );
  }

  Widget _buildPlaceholder(double w, double h, double iconSize) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Icon(
          placeholderIcon,
          color: AppColors.primaryNeon,
          size: iconSize,
        ),
      ),
    );
  }
}
