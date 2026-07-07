import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/artist_model.dart';
import '../../global_widgets/custom_textfield.dart';

class ArtistManagementScreen extends StatefulWidget {
  const ArtistManagementScreen({super.key});

  @override
  State<ArtistManagementScreen> createState() => _ArtistManagementScreenState();
}

class _ArtistManagementScreenState extends State<ArtistManagementScreen> {
  final List<ArtistModel> _artists = [
    ArtistModel(
      artistId: 1,
      name: 'Aurora Beats',
      profilePic: 'https://i.pravatar.cc/150?img=1',
    ),
    ArtistModel(
      artistId: 2,
      name: 'Luna Wave',
      profilePic: 'https://i.pravatar.cc/150?img=2',
    ),
    ArtistModel(
      artistId: 3,
      name: 'Neon Drift',
    ),
    ArtistModel(
      artistId: 4,
      name: 'Solar Echo',
      profilePic: 'https://i.pravatar.cc/150?img=4',
    ),
    ArtistModel(
      artistId: 5,
      name: 'Violet Haze',
    ),
    ArtistModel(
      artistId: 6,
      name: 'Ember Soul',
      profilePic: 'https://i.pravatar.cc/150?img=6',
    ),
  ];

  void _showAddDialog() {
    final nameController = TextEditingController();
    final imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => _ArtistDialog(
        title: 'Add Artist',
        nameController: nameController,
        imageController: imageController,
        confirmLabel: 'Add',
        onConfirm: () {
          if (nameController.text.trim().isNotEmpty) {
            setState(() {
              _artists.add(ArtistModel(
                artistId: _artists.isEmpty
                    ? 1
                    : _artists.map((a) => a.artistId).reduce((a, b) => a > b ? a : b) + 1,
                name: nameController.text.trim(),
                profilePic: imageController.text.trim().isEmpty
                    ? null
                    : imageController.text.trim(),
              ));
            });
          }
        },
      ),
    );
  }

  void _showEditDialog(ArtistModel artist) {
    final nameController = TextEditingController(text: artist.name);
    final imageController = TextEditingController(text: artist.profilePic ?? '');

    showDialog(
      context: context,
      builder: (context) => _ArtistDialog(
        title: 'Edit Artist',
        nameController: nameController,
        imageController: imageController,
        confirmLabel: 'Save',
        onConfirm: () {
          if (nameController.text.trim().isNotEmpty) {
            setState(() {
              final index = _artists.indexWhere((a) => a.artistId == artist.artistId);
              if (index != -1) {
                _artists[index] = ArtistModel(
                  artistId: artist.artistId,
                  name: nameController.text.trim(),
                  profilePic: imageController.text.trim().isEmpty
                      ? null
                      : imageController.text.trim(),
                );
              }
            });
          }
        },
      ),
    );
  }

  void _deleteArtist(ArtistModel artist) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Artist',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${artist.name}"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        setState(() => _artists.removeWhere((a) => a.artistId == artist.artistId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artists')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryNeon,
        onPressed: _showAddDialog,
        child: const Icon(Icons.add_rounded, color: Colors.black),
      ),
      body: _artists.isEmpty
          ? const Center(
              child: Text('No artists yet', style: TextStyle(color: AppColors.textMuted)),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = width > 900
                    ? 4
                    : width > 600
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
                  itemCount: _artists.length,
                  itemBuilder: (context, index) {
                    return _ArtistCard(
                      artist: _artists[index],
                      onEdit: () => _showEditDialog(_artists[index]),
                      onDelete: () => _deleteArtist(_artists[index]),
                    );
                  },
                );
              },
            ),
    );
  }
}

// ──────────────────────────────────────────────────────
//  Artist Card
// ──────────────────────────────────────────────────────

class _ArtistCard extends StatelessWidget {
  final ArtistModel artist;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ArtistCard({
    required this.artist,
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
          _buildNameLabel(),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final hasImage = artist.profilePic != null && artist.profilePic!.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              artist.profilePic!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
            )
          : _buildFallbackIcon(),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      color: AppColors.surfaceElevated,
      child: const Icon(
        Icons.person_rounded,
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
          _ActionChip(
            icon: Icons.edit_rounded,
            onTap: onEdit,
          ),
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

  Widget _buildNameLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      child: Text(
        artist.name,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
//  Action Chip (edit / delete buttons)
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

class _ArtistDialog extends StatelessWidget {
  final String title;
  final TextEditingController nameController;
  final TextEditingController imageController;
  final String confirmLabel;
  final VoidCallback onConfirm;

  const _ArtistDialog({
    required this.title,
    required this.nameController,
    required this.imageController,
    required this.confirmLabel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            hintText: 'Artist Name',
            controller: nameController,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            hintText: 'Image URL (optional)',
            controller: imageController,
            prefixIcon: Icons.link_rounded,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: Text(
            confirmLabel,
            style: const TextStyle(color: AppColors.primaryNeon),
          ),
        ),
      ],
    );
  }
}
