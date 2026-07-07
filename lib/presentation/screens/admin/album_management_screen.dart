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
    AlbumModel(albumId: 1, artistId: 1, title: 'Electric Dreams', releaseDate: 2025),
    AlbumModel(albumId: 2, artistId: 2, title: 'City Lights', releaseDate: 2025),
    AlbumModel(albumId: 3, artistId: 3, title: 'Ocean Waves', releaseDate: 2024),
  ];

  void _showAddDialog() {
    final titleController = TextEditingController();
    final yearController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: const Text('Add Album', style: TextStyle(color: AppColors.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(hintText: 'Album Title', controller: titleController),
              const SizedBox(height: 12),
              CustomTextField(
                hintText: 'Release Year',
                controller: yearController,
                keyboardType: TextInputType.number,
              ),
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
              if (titleController.text.trim().isNotEmpty) {
                setState(() {
                  _albums.add(AlbumModel(
                    albumId: _albums.length + 1,
                    artistId: 1,
                    title: titleController.text.trim(),
                    releaseDate: int.tryParse(yearController.text),
                  ));
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add', style: TextStyle(color: AppColors.primaryNeon)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(AlbumModel album) {
    final titleController = TextEditingController(text: album.title);
    final yearController = TextEditingController(text: album.releaseDate?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: const Text('Edit Album', style: TextStyle(color: AppColors.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(hintText: 'Album Title', controller: titleController),
              const SizedBox(height: 12),
              CustomTextField(
                hintText: 'Release Year',
                controller: yearController,
                keyboardType: TextInputType.number,
              ),
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
              if (titleController.text.trim().isNotEmpty) {
                setState(() {
                  final index = _albums.indexWhere((a) => a.albumId == album.albumId);
                  if (index != -1) {
                    _albums[index] = AlbumModel(
                      albumId: album.albumId,
                      artistId: album.artistId,
                      title: titleController.text.trim(),
                      releaseDate: int.tryParse(yearController.text),
                    );
                  }
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: AppColors.primaryNeon)),
          ),
        ],
      ),
    );
  }

  void _deleteAlbum(AlbumModel album) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: const Text('Delete Album', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to delete "${album.title}"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: AppColors.error))),
        ],
      ),
    ).then((value) {
      if (value == true) {
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
          ? const Center(child: Text('No albums yet', style: TextStyle(color: AppColors.textMuted)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _albums.length,
              itemBuilder: (context, index) {
                final album = _albums[index];
                return Card(
                  color: AppColors.surfaceCard,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.surfaceElevated,
                      child: const Icon(Icons.album_rounded, color: AppColors.primaryNeon),
                    ),
                    title: Text(album.title, style: const TextStyle(color: AppColors.textPrimary)),
                    subtitle: Text(
                      'Artist ${album.artistId}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.textMuted, size: 20),
                          onPressed: () => _showEditDialog(album),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
                          onPressed: () => _deleteAlbum(album),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
