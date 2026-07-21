import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/track_model.dart';
import '../../../providers/track_provider.dart';
import '../../global_widgets/custom_textfield.dart';

class TrackManagementScreen extends StatefulWidget {
  const TrackManagementScreen({super.key});

  @override
  State<TrackManagementScreen> createState() => _TrackManagementScreenState();
}

class _TrackManagementScreenState extends State<TrackManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tp = context.read<TrackProvider>();
      tp.fetchTracks();
      tp.fetchArtists();
      tp.fetchAlbums();
      tp.fetchGenres();
    });
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final durationCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => _TrackDialog(
        dialogTitle: 'Add Track',
        titleController: titleCtrl,
        durationController: durationCtrl,
        confirmLabel: 'Add',
        onConfirm: () {
          if (titleCtrl.text.trim().isEmpty) return;
          final durSec = _parseDuration(durationCtrl.text);
          final tp = context.read<TrackProvider>();
          if (tp.artists.isEmpty || tp.albums.isEmpty || tp.genres.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please add artists, albums, and genres first')),
            );
            return;
          }
          tp.createTrack(
            title: titleCtrl.text.trim(),
            artistId: tp.artists.first.artistId,
            albumId: tp.albums.first.albumId,
            genresId: tp.genres.first.genresId,
            duration: durSec,
          );
        },
      ),
    );
  }

  void _showEditDialog(TrackModel track) {
    final titleCtrl = TextEditingController(text: track.title);
    final durationCtrl = TextEditingController(text: track.durationFormatted);

    showDialog(
      context: context,
      builder: (ctx) => _TrackDialog(
        dialogTitle: 'Edit Track',
        titleController: titleCtrl,
        durationController: durationCtrl,
        confirmLabel: 'Save',
        onConfirm: () {
          if (titleCtrl.text.trim().isEmpty) return;
          final durSec = _parseDuration(durationCtrl.text);
          context.read<TrackProvider>().updateTrack(
            track.trackId,
            title: titleCtrl.text.trim(),
            duration: durSec,
          );
        },
      ),
    );
  }

  void _deleteTrack(TrackModel track) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Track', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Are you sure you want to delete "${track.title}"?',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        context.read<TrackProvider>().deleteTrack(track.trackId);
      }
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tracks')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryNeon,
        onPressed: _showAddDialog,
        child: const Icon(Icons.add_rounded, color: Colors.black),
      ),
      body: Consumer<TrackProvider>(
        builder: (context, tp, _) {
          final tracks = tp.tracks;
          if (tracks.isEmpty) {
            return const Center(child: Text('No tracks yet', style: TextStyle(color: AppColors.textMuted)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tracks.length,
            separatorBuilder: (_, i) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final track = tracks[index];
              return _TrackTile(
                track: track,
                onEdit: () => _showEditDialog(track),
                onDelete: () => _deleteTrack(track),
              );
            },
          );
        },
      ),
    );
  }
}

class _TrackTile extends StatelessWidget {
  final TrackModel track;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TrackTile({required this.track, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.music_note_rounded, color: AppColors.primaryNeon, size: 24),
        ),
        title: Text(
          track.title,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Album ${track.albumId}',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(track.durationFormatted, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            _ActionChip(icon: Icons.edit_rounded, onTap: onEdit),
            const SizedBox(width: 4),
            _ActionChip(icon: Icons.delete_rounded, color: AppColors.error, onTap: onDelete),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({required this.icon, this.color = AppColors.textMuted, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(color: AppColors.overlay, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

class _TrackDialog extends StatelessWidget {
  final String dialogTitle;
  final TextEditingController titleController;
  final TextEditingController durationController;
  final String confirmLabel;
  final VoidCallback onConfirm;

  const _TrackDialog({
    required this.dialogTitle,
    required this.titleController,
    required this.durationController,
    required this.confirmLabel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(dialogTitle, style: const TextStyle(color: AppColors.textPrimary)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(hintText: 'Track Title', controller: titleController),
            const SizedBox(height: 12),
            CustomTextField(hintText: 'Duration (e.g. 3:45)', controller: durationController),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: Text(confirmLabel, style: const TextStyle(color: AppColors.primaryNeon)),
        ),
      ],
    );
  }
}
