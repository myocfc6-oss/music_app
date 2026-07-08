import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/track_model.dart';
import '../../global_widgets/custom_textfield.dart';

class TrackManagementScreen extends StatefulWidget {
  const TrackManagementScreen({super.key});

  @override
  State<TrackManagementScreen> createState() => _TrackManagementScreenState();
}

class _TrackManagementScreenState extends State<TrackManagementScreen> {
  final List<TrackModel> _tracks = [
    TrackModel(
      trackId: 1,
      artistId: 1,
      albumId: 1,
      genreId: 1,
      title: 'Midnight Pulse',
      duration: 234,
      streamCount: 1500000,
    ),
    TrackModel(
      trackId: 2,
      artistId: 2,
      albumId: 2,
      genreId: 2,
      title: 'Neon Skyline',
      duration: 198,
      streamCount: 980000,
    ),
    TrackModel(
      trackId: 3,
      artistId: 3,
      albumId: 3,
      genreId: 3,
      title: 'Velvet Echoes',
      duration: 267,
      streamCount: 750000,
    ),
    TrackModel(
      trackId: 4,
      artistId: 1,
      albumId: 1,
      genreId: 1,
      title: 'Digital Horizon',
      duration: 312,
      streamCount: 420000,
    ),
    TrackModel(
      trackId: 5,
      artistId: 4,
      albumId: 4,
      genreId: 2,
      title: 'Crystal Waves',
      duration: 186,
      streamCount: 650000,
    ),
  ];

  int _nextId() {
    if (_tracks.isEmpty) return 1;
    return _tracks.map((t) => t.trackId).reduce((a, b) => a > b ? a : b) + 1;
  }

  // ─── Add ────────────────────────────────────────────

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    final coverCtrl = TextEditingController();
    final audioCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => _TrackDialog(
        dialogTitle: 'Add Track',
        titleController: titleCtrl,
        durationController: durationCtrl,
        coverController: coverCtrl,
        audioController: audioCtrl,
        confirmLabel: 'Add',
        onConfirm: () {
          if (titleCtrl.text.trim().isEmpty) return;
          final durSec = _parseDuration(durationCtrl.text);
          setState(() {
            _tracks.add(TrackModel(
              trackId: _nextId(),
              artistId: 1,
              albumId: 1,
              genreId: 1,
              title: titleCtrl.text.trim(),
              duration: durSec,
              streamCount: 0,
            ));
          });
        },
      ),
    );
  }

  // ─── Edit ───────────────────────────────────────────

  void _showEditDialog(TrackModel track) {
    final titleCtrl = TextEditingController(text: track.title);
    final durationCtrl =
        TextEditingController(text: track.durationFormatted);
    final coverCtrl = TextEditingController();
    final audioCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => _TrackDialog(
        dialogTitle: 'Edit Track',
        titleController: titleCtrl,
        durationController: durationCtrl,
        coverController: coverCtrl,
        audioController: audioCtrl,
        confirmLabel: 'Save',
        onConfirm: () {
          if (titleCtrl.text.trim().isEmpty) return;
          final durSec = _parseDuration(durationCtrl.text);
          setState(() {
            final idx =
                _tracks.indexWhere((t) => t.trackId == track.trackId);
            if (idx != -1) {
              _tracks[idx] = TrackModel(
                trackId: track.trackId,
                artistId: track.artistId,
                albumId: track.albumId,
                genreId: track.genreId,
                title: titleCtrl.text.trim(),
                duration: durSec,
                streamCount: track.streamCount,
              );
            }
          });
        },
      ),
    );
  }

  // ─── Delete ─────────────────────────────────────────

  void _deleteTrack(TrackModel track) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Track',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${track.title}"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        setState(
            () => _tracks.removeWhere((t) => t.trackId == track.trackId));
      }
    });
  }

  // ─── Helpers ────────────────────────────────────────

  /// Parses a "M:SS" or "SS" string back to total seconds.
  int _parseDuration(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return 0;
    final parts = trimmed.split(':');
    if (parts.length == 2) {
      final m = int.tryParse(parts[0]) ?? 0;
      final s = int.tryParse(parts[1]) ?? 0;
      return m * 60 + s;
    }
    return int.tryParse(trimmed) ?? 0;
  }

  String _artistLabel(TrackModel track) {
    if (track.artist != null) return track.artist!.name;
    return 'Artist ${track.artistId}';
  }

  // ─── Build ──────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tracks')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryNeon,
        onPressed: _showAddDialog,
        child: const Icon(Icons.add_rounded, color: Colors.black),
      ),
      body: _tracks.isEmpty
          ? const Center(
              child: Text(
                'No tracks yet',
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _tracks.length,
              separatorBuilder: (_, i) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final track = _tracks[index];
                return _TrackTile(
                  track: track,
                  artistLabel: _artistLabel(track),
                  onEdit: () => _showEditDialog(track),
                  onDelete: () => _deleteTrack(track),
                );
              },
            ),
    );
  }
}

// ──────────────────────────────────────────────────────
//  Track Tile
// ──────────────────────────────────────────────────────

class _TrackTile extends StatelessWidget {
  final TrackModel track;
  final String artistLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TrackTile({
    required this.track,
    required this.artistLabel,
    required this.onEdit,
    required this.onDelete,
  });

  static const _coverUrls = [
    'https://picsum.photos/seed/track1/200/200',
    'https://picsum.photos/seed/track2/200/200',
    'https://picsum.photos/seed/track3/200/200',
    'https://picsum.photos/seed/track4/200/200',
    'https://picsum.photos/seed/track5/200/200',
  ];

  @override
  Widget build(BuildContext context) {
    final coverUrl = track.trackId <= _coverUrls.length
        ? _coverUrls[track.trackId - 1]
        : null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: _buildCover(coverUrl),
        title: Text(
          track.title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          artistLabel,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              track.durationFormatted,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            _ActionChip(icon: Icons.edit_rounded, onTap: onEdit),
            const SizedBox(width: 4),
            _ActionChip(
              icon: Icons.delete_rounded,
              color: AppColors.error,
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(String? url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 48,
        height: 48,
        child: url != null
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, st) => _fallbackIcon(),
              )
            : _fallbackIcon(),
      ),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      color: AppColors.surfaceElevated,
      child: const Icon(
        Icons.music_note_rounded,
        color: AppColors.primaryNeon,
        size: 24,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
//  Action Chip (edit / delete)
// ──────────────────────────────────────────────────────

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    this.color = AppColors.textMuted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.overlay,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
//  Add / Edit Dialog
// ──────────────────────────────────────────────────────

class _TrackDialog extends StatefulWidget {
  final String dialogTitle;
  final TextEditingController titleController;
  final TextEditingController durationController;
  final TextEditingController coverController;
  final TextEditingController audioController;
  final String confirmLabel;
  final VoidCallback onConfirm;

  const _TrackDialog({
    required this.dialogTitle,
    required this.titleController,
    required this.durationController,
    required this.coverController,
    required this.audioController,
    required this.confirmLabel,
    required this.onConfirm,
  });

  @override
  State<_TrackDialog> createState() => _TrackDialogState();
}

class _TrackDialogState extends State<_TrackDialog> {
  Uint8List? _localCoverBytes;
  String? _pickedAudioName;

  Future<void> _pickCoverImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _localCoverBytes = result.files.single.bytes;
        });
        widget.coverController.clear();
      }
    } catch (_) {
      // cancelled or unavailable
    }
  }

  Future<void> _pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'aac', 'ogg', 'flac'],
      );
      if (result != null && result.files.single.name.isNotEmpty) {
        setState(() {
          _pickedAudioName = result.files.single.name;
        });
        widget.audioController.clear();
      }
    } catch (_) {
      // cancelled or unavailable
    }
  }

  Widget _buildCoverPreview() {
    final url = widget.coverController.text.trim();
    final hasUrl = url.isNotEmpty;
    final hasLocal = _localCoverBytes != null && _localCoverBytes!.isNotEmpty;

    if (!hasUrl && !hasLocal) {
      return Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 32, color: AppColors.textMuted),
            SizedBox(height: 6),
            Text('No cover image',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 120,
        width: double.infinity,
        child: hasUrl
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, st) => _coverError(),
              )
            : Image.memory(
                _localCoverBytes!,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, st) => _coverError(),
              ),
      ),
    );
  }

  Widget _coverError() {
    return Container(
      color: AppColors.surfaceElevated,
      child: const Center(
        child: Text('Failed to load image',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ),
    );
  }

  Widget _buildAudioIndicator() {
    final url = widget.audioController.text.trim();
    final hasUrl = url.isNotEmpty;
    final hasLocal = _pickedAudioName != null && _pickedAudioName!.isNotEmpty;

    if (!hasUrl && !hasLocal) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.audiotrack_rounded,
              color: AppColors.primaryNeon, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasLocal ? _pickedAudioName! : url,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.dialogTitle,
          style: const TextStyle(color: AppColors.textPrimary)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Cover image preview ──
            _buildCoverPreview(),
            const SizedBox(height: 12),

            // ── Title ──
            CustomTextField(
              hintText: 'Track Title',
              controller: widget.titleController,
            ),
            const SizedBox(height: 12),

            // ── Duration ──
            CustomTextField(
              hintText: 'Duration (e.g. 3:45)',
              controller: widget.durationController,
            ),
            const SizedBox(height: 12),

            // ── Cover image URL ──
            CustomTextField(
              hintText: 'Cover Image URL (optional)',
              controller: widget.coverController,
              prefixIcon: Icons.link_rounded,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickCoverImage,
                icon: const Icon(Icons.image_rounded, size: 18),
                label: const Text('Pick cover from device'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.borderDark),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Audio URL ──
            CustomTextField(
              hintText: 'Audio URL (optional)',
              controller: widget.audioController,
              prefixIcon: Icons.link_rounded,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickAudioFile,
                icon: const Icon(Icons.audio_file_rounded, size: 18),
                label: const Text('Pick audio from device'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.borderDark),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            // ── Audio file indicator ──
            _buildAudioIndicator(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onConfirm();
            Navigator.pop(context);
          },
          child: Text(
            widget.confirmLabel,
            style: const TextStyle(color: AppColors.primaryNeon),
          ),
        ),
      ],
    );
  }
}
