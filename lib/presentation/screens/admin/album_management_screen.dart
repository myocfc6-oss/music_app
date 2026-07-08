import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/album_model.dart';
import '../../global_widgets/custom_textfield.dart';

class AlbumManagementScreen extends StatefulWidget {
  const AlbumManagementScreen({super.key});

  @override
  State<AlbumManagementScreen> createState() => _AlbumManagementScreenState();
}

class _AlbumManagementScreenState extends State<AlbumManagementScreen> {
  final List<AlbumModel> _albums = [
    AlbumModel(
      albumId: 1,
      artistId: 1,
      title: 'Electric Dreams',
      releaseDate: 2025,
      coverPng: 'https://picsum.photos/seed/album1/400/400',
    ),
    AlbumModel(
      albumId: 2,
      artistId: 2,
      title: 'City Lights',
      releaseDate: 2025,
      coverPng: 'https://picsum.photos/seed/album2/400/400',
    ),
    AlbumModel(
      albumId: 3,
      artistId: 3,
      title: 'Ocean Waves',
      releaseDate: 2024,
      coverPng: 'https://picsum.photos/seed/album3/400/400',
    ),
    AlbumModel(
      albumId: 4,
      artistId: 1,
      title: 'Neon Skyline',
      releaseDate: 2024,
    ),
    AlbumModel(
      albumId: 5,
      artistId: 4,
      title: 'Midnight Pulse',
      releaseDate: 2023,
      coverPng: 'https://picsum.photos/seed/album5/400/400',
    ),
  ];

  int _nextId() {
    if (_albums.isEmpty) return 1;
    return _albums.map((a) => a.albumId).reduce((a, b) => a > b ? a : b) + 1;
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final yearCtrl = TextEditingController();
    final imageCtrl = TextEditingController();
    Uint8List? localBytes;

    showDialog(
      context: context,
      builder: (ctx) => _AlbumDialog(
        dialogTitle: 'Add Album',
        titleController: titleCtrl,
        yearController: yearCtrl,
        imageController: imageCtrl,
        confirmLabel: 'Add',
        onConfirm: () {
          if (titleCtrl.text.trim().isEmpty) return;
          final imgUrl = imageCtrl.text.trim();
          setState(() {
            _albums.add(AlbumModel(
              albumId: _nextId(),
              artistId: 1,
              title: titleCtrl.text.trim(),
              releaseDate: int.tryParse(yearCtrl.text),
              coverPng: imgUrl.isNotEmpty ? imgUrl : null,
            ));
          });
        },
        initialLocalBytes: localBytes,
        onBytesPicked: (bytes) {
          localBytes = bytes;
        },
      ),
    );
  }

  void _showEditDialog(AlbumModel album) {
    final titleCtrl = TextEditingController(text: album.title);
    final yearCtrl =
        TextEditingController(text: album.releaseDate?.toString() ?? '');
    final imageCtrl = TextEditingController(text: album.coverPng ?? '');
    Uint8List? localBytes;

    showDialog(
      context: context,
      builder: (ctx) => _AlbumDialog(
        dialogTitle: 'Edit Album',
        titleController: titleCtrl,
        yearController: yearCtrl,
        imageController: imageCtrl,
        confirmLabel: 'Save',
        onConfirm: () {
          if (titleCtrl.text.trim().isEmpty) return;
          final imgUrl = imageCtrl.text.trim();
          setState(() {
            final idx = _albums.indexWhere((a) => a.albumId == album.albumId);
            if (idx != -1) {
              _albums[idx] = AlbumModel(
                albumId: album.albumId,
                artistId: album.artistId,
                title: titleCtrl.text.trim(),
                releaseDate: int.tryParse(yearCtrl.text),
                coverPng: imgUrl.isNotEmpty ? imgUrl : album.coverPng,
              );
            }
          });
        },
        initialLocalBytes: localBytes,
        onBytesPicked: (bytes) {
          localBytes = bytes;
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
        title: const Text(
          'Delete Album',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${album.title}"?',
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
        setState(() => _albums.removeWhere((a) => a.albumId == album.albumId));
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
      body: _albums.isEmpty
          ? const Center(
              child: Text(
                'No albums yet',
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final crossAxisCount = w > 900
                    ? 4
                    : w > 600
                        ? 3
                        : 2;

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _albums.length,
                  itemBuilder: (context, index) {
                    final album = _albums[index];
                    return _AlbumCard(
                      album: album,
                      onEdit: () => _showEditDialog(album),
                      onDelete: () => _deleteAlbum(album),
                    );
                  },
                );
              },
            ),
    );
  }
}

// ──────────────────────────────────────────────────────
//  Album Card
// ──────────────────────────────────────────────────────

class _AlbumCard extends StatelessWidget {
  final AlbumModel album;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AlbumCard({
    required this.album,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
                _buildImage(),
                _buildActionButtons(),
              ],
            ),
          ),
          _buildInfoBar(),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final url = album.coverPng;
    final hasImage = url != null && url.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, st) => _buildFallback(),
            )
          : _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: AppColors.surfaceElevated,
      child: const Icon(
        Icons.album_rounded,
        size: 48,
        color: AppColors.primaryNeon,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      top: 8,
      right: 8,
      child: Column(
        children: [
          _ActionChip(icon: Icons.edit_rounded, onTap: onEdit),
          const SizedBox(height: 6),
          _ActionChip(
            icon: Icons.delete_rounded,
            color: AppColors.error,
            onTap: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBar() {
    final yearText =
        album.releaseDate != null ? album.releaseDate.toString() : '—';

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            album.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            yearText,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
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

class _AlbumDialog extends StatefulWidget {
  final String dialogTitle;
  final TextEditingController titleController;
  final TextEditingController yearController;
  final TextEditingController imageController;
  final String confirmLabel;
  final Uint8List? initialLocalBytes;
  final ValueChanged<Uint8List?> onBytesPicked;
  final VoidCallback onConfirm;

  const _AlbumDialog({
    required this.dialogTitle,
    required this.titleController,
    required this.yearController,
    required this.imageController,
    required this.confirmLabel,
    this.initialLocalBytes,
    required this.onBytesPicked,
    required this.onConfirm,
  });

  @override
  State<_AlbumDialog> createState() => _AlbumDialogState();
}

class _AlbumDialogState extends State<_AlbumDialog> {
  Uint8List? _localBytes;

  @override
  void initState() {
    super.initState();
    _localBytes = widget.initialLocalBytes;
  }

  Future<void> _pickLocalImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        setState(() => _localBytes = bytes);
        widget.imageController.clear();
        widget.onBytesPicked(bytes);
      }
    } catch (_) {
      // File picker cancelled or unavailable
    }
  }

  Widget _buildPreview() {
    final url = widget.imageController.text.trim();
    final hasUrl = url.isNotEmpty;
    final hasLocal = _localBytes != null && _localBytes!.isNotEmpty;

    if (!hasUrl && !hasLocal) {
      return Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 40, color: AppColors.textMuted),
            SizedBox(height: 8),
            Text('No image selected',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 160,
        width: double.infinity,
        child: hasUrl
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, st) => Container(
                  color: AppColors.surfaceElevated,
                  child: const Center(
                    child: Text('Failed to load image',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12)),
                  ),
                ),
              )
            : Image.memory(
                _localBytes!,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, st) => Container(
                  color: AppColors.surfaceElevated,
                  child: const Center(
                    child: Text('Failed to load image',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12)),
                  ),
                ),
              ),
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
            CustomTextField(
              hintText: 'Album Title',
              controller: widget.titleController,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              hintText: 'Release Year',
              controller: widget.yearController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              hintText: 'Image URL (optional)',
              controller: widget.imageController,
              prefixIcon: Icons.link_rounded,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickLocalImage,
                icon: const Icon(Icons.folder_open_rounded, size: 18),
                label: const Text('Pick from device'),
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
            _buildPreview(),
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
