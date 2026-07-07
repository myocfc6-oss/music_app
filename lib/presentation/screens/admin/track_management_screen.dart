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
    TrackModel(trackId: 1, artistId: 1, albumId: 1, genreId: 1, title: 'Midnight Pulse', duration: 234, streamCount: 1500000),
    TrackModel(trackId: 2, artistId: 2, albumId: 2, genreId: 2, title: 'Neon Skyline', duration: 198, streamCount: 980000),
    TrackModel(trackId: 3, artistId: 3, albumId: 3, genreId: 3, title: 'Velvet Echoes', duration: 267, streamCount: 750000),
  ];

  void _showAddDialog() {
    final titleController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: const Text('Add Track', style: TextStyle(color: AppColors.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(hintText: 'Track Title', controller: titleController),
              const SizedBox(height: 12),
              CustomTextField(
                hintText: 'Duration (seconds)',
                controller: durationController,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                setState(() {
                  _tracks.add(TrackModel(
                    trackId: _tracks.length + 1,
                    artistId: 1,
                    albumId: 1,
                    genreId: 1,
                    title: titleController.text.trim(),
                    duration: int.tryParse(durationController.text) ?? 0,
                    streamCount: 0,
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

  void _showEditDialog(TrackModel track) {
    final titleController = TextEditingController(text: track.title);
    final durationController = TextEditingController(text: track.duration.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: const Text('Edit Track', style: TextStyle(color: AppColors.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(hintText: 'Track Title', controller: titleController),
              const SizedBox(height: 12),
              CustomTextField(
                hintText: 'Duration (seconds)',
                controller: durationController,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                setState(() {
                  final index = _tracks.indexWhere((t) => t.trackId == track.trackId);
                  if (index != -1) {
                    _tracks[index] = TrackModel(
                      trackId: track.trackId,
                      artistId: track.artistId,
                      albumId: track.albumId,
                      genreId: track.genreId,
                      title: titleController.text.trim(),
                      duration: int.tryParse(durationController.text) ?? 0,
                      streamCount: track.streamCount,
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

  void _deleteTrack(TrackModel track) {
    final confirm = showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: const Text('Delete Track', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to delete "${track.title}"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );

    confirm.then((value) {
      if (value == true) {
        setState(() => _tracks.removeWhere((t) => t.trackId == track.trackId));
      }
    });
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
      body: _tracks.isEmpty
          ? const Center(child: Text('No tracks yet', style: TextStyle(color: AppColors.textMuted)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tracks.length,
              itemBuilder: (context, index) {
                final track = _tracks[index];
                return Card(
                  color: AppColors.surfaceCard,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.surfaceElevated,
                      child: const Icon(Icons.music_note_rounded, color: AppColors.primaryNeon),
                    ),
                    title: Text(track.title, style: const TextStyle(color: AppColors.textPrimary)),
                    subtitle: Text(
                      'Artist ${track.artistId} - Album ${track.albumId}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          track.durationFormatted,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.textMuted, size: 20),
                          onPressed: () => _showEditDialog(track),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error, size: 20),
                          onPressed: () => _deleteTrack(track),
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
