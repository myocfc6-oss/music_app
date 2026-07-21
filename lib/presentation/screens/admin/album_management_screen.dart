import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/album_model.dart';
import '../../../providers/track_provider.dart';
import '../../global_widgets/custom_textfield.dart';

class AlbumManagementScreen extends StatefulWidget {
  const AlbumManagementScreen({super.key});

  @override
  State<AlbumManagementScreen> createState() => _AlbumManagementScreenState();
}

class _AlbumManagementScreenState extends State<AlbumManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tp = context.read<TrackProvider>();
      tp.fetchAlbums();
      tp.fetchArtists();
    });
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final imageCtrl = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (ctx) => _AlbumDialog(
        dialogTitle: 'Add Album',
        titleController: titleCtrl,
        selectedDate: selectedDate,
        imageController: imageCtrl,
        confirmLabel: 'Add',
        onDateChanged: (date) => selectedDate = date,
        onConfirm: () {
          if (titleCtrl.text.trim().isEmpty) return;
          context.read<TrackProvider>().createAlbum(
            titleCtrl.text.trim(),
            releaseDate: selectedDate,
            coverPng: imageCtrl.text.trim().isEmpty ? null : imageCtrl.text.trim(),
          );
        },
      ),
    );
  }

  void _showEditDialog(AlbumModel album) {
    final titleCtrl = TextEditingController(text: album.title);
    final imageCtrl = TextEditingController(text: album.coverPng ?? '');
    DateTime? selectedDate = album.releaseDate;

    showDialog(
      context: context,
      builder: (ctx) => _AlbumDialog(
        dialogTitle: 'Edit Album',
        titleController: titleCtrl,
        selectedDate: selectedDate,
        imageController: imageCtrl,
        confirmLabel: 'Save',
        onDateChanged: (date) => selectedDate = date,
        onConfirm: () {
          if (titleCtrl.text.trim().isEmpty) return;
          context.read<TrackProvider>().updateAlbum(
            album.albumId,
            titleCtrl.text.trim(),
            releaseDate: selectedDate,
            coverPng: imageCtrl.text.trim().isEmpty ? null : imageCtrl.text.trim(),
          );
        },
      ),
    );
  }

  void _deleteAlbum(AlbumModel album) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Album', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Are you sure you want to delete "${album.title}"?',
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
        context.read<TrackProvider>().deleteAlbum(album.albumId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Albums')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryNeon,
        onPressed: _showAddDialog,
        child: const Icon(Icons.add_rounded, color: Colors.black),
      ),
      body: Consumer<TrackProvider>(
        builder: (context, tp, _) {
          final albums = tp.albums;
          if (albums.isEmpty) {
            return const Center(child: Text('No albums yet', style: TextStyle(color: AppColors.textMuted)));
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final crossAxisCount = w > 900 ? 4 : w > 600 ? 3 : 2;
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: albums.length,
                itemBuilder: (context, index) {
                  final album = albums[index];
                  return _AlbumCard(
                    album: album,
                    onEdit: () => _showEditDialog(album),
                    onDelete: () => _deleteAlbum(album),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  final AlbumModel album;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AlbumCard({required this.album, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final hasImage = album.coverPng != null && album.coverPng!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: hasImage
                      ? Image.network(album.coverPng!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _fallback())
                      : _fallback(),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: Column(
                    children: [
                      _ActionChip(icon: Icons.edit_rounded, onTap: onEdit),
                      const SizedBox(height: 6),
                      _ActionChip(icon: Icons.delete_rounded, color: AppColors.error, onTap: onDelete),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(album.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${album.releaseDate?.year ?? "—"}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: AppColors.surfaceElevated,
      child: const Icon(Icons.album_rounded, size: 48, color: AppColors.primaryNeon),
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

class _AlbumDialog extends StatefulWidget {
  final String dialogTitle;
  final TextEditingController titleController;
  final DateTime? selectedDate;
  final TextEditingController imageController;
  final String confirmLabel;
  final ValueChanged<DateTime?> onDateChanged;
  final VoidCallback onConfirm;

  const _AlbumDialog({
    required this.dialogTitle,
    required this.titleController,
    this.selectedDate,
    required this.imageController,
    required this.confirmLabel,
    required this.onDateChanged,
    required this.onConfirm,
  });

  @override
  State<_AlbumDialog> createState() => _AlbumDialogState();
}

class _AlbumDialogState extends State<_AlbumDialog> {
  late DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2024),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryNeon,
              onPrimary: Colors.black,
              surface: AppColors.surfaceCard,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      widget.onDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _selectedDate != null
        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
        : '';

    return AlertDialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.dialogTitle, style: const TextStyle(color: AppColors.textPrimary)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(hintText: 'Album Title', controller: widget.titleController),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: AppColors.textMuted, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        dateText.isEmpty ? 'Release Date (optional)' : dateText,
                        style: TextStyle(
                          color: dateText.isEmpty ? AppColors.textMuted : AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (_selectedDate != null)
                      GestureDetector(
                        onTap: () {
                          setState(() => _selectedDate = null);
                          widget.onDateChanged(null);
                        },
                        child: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            CustomTextField(hintText: 'Cover Image URL (optional)', controller: widget.imageController, prefixIcon: Icons.link_rounded),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            widget.onConfirm();
            Navigator.pop(context);
          },
          child: Text(widget.confirmLabel, style: const TextStyle(color: AppColors.primaryNeon)),
        ),
      ],
    );
  }
}
