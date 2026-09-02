import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/album_model.dart';
import '../../../data/models/artist_model.dart';
import '../../../data/models/genre_model.dart';
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
    final audioUrlCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    int? selectedArtistId;
    int? selectedAlbumId;
    int? selectedGenreId;

    final tp = context.read<TrackProvider>();
    if (tp.artists.isNotEmpty) selectedArtistId = tp.artists.first.artistId;
    if (tp.albums.isNotEmpty) selectedAlbumId = tp.albums.first.albumId;
    if (tp.genres.isNotEmpty) selectedGenreId = tp.genres.first.genresId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => _TrackDialog(
          dialogTitle: 'Add Track',
          titleController: titleCtrl,
          audioUrlController: audioUrlCtrl,
          durationController: durationCtrl,
          artists: tp.artists,
          albums: tp.albums,
          genres: tp.genres,
          selectedArtistId: selectedArtistId,
          selectedAlbumId: selectedAlbumId,
          selectedGenreId: selectedGenreId,
          onArtistChanged: (id) => setDialogState(() => selectedArtistId = id),
          onAlbumChanged: (id) => setDialogState(() => selectedAlbumId = id),
          onGenreChanged: (id) => setDialogState(() => selectedGenreId = id),
          confirmLabel: 'Add',
          onConfirm: () {
            if (titleCtrl.text.trim().isEmpty) return;
            final durSec = _parseDuration(durationCtrl.text);
            if (tp.artists.isEmpty || tp.albums.isEmpty || tp.genres.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please add artists, albums, and genres first')),
              );
              return;
            }
            if (selectedArtistId == null || selectedAlbumId == null || selectedGenreId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select an artist, album, and genre')),
              );
              return;
            }
            tp.createTrack(
              title: titleCtrl.text.trim(),
              audioUrl: audioUrlCtrl.text.trim(),
              artistId: selectedArtistId!,
              albumId: selectedAlbumId!,
              genresId: selectedGenreId!,
              duration: durSec,
            );
          },
        ),
      ),
    );
  }

  void _showEditDialog(TrackModel track) {
    final titleCtrl = TextEditingController(text: track.title);
    final audioUrlCtrl = TextEditingController(text: track.audioUrl);
    final durationCtrl = TextEditingController(text: track.durationFormatted);
    final tp = context.read<TrackProvider>();

    showDialog(
      context: context,
      builder: (ctx) => _TrackDialog(
        dialogTitle: 'Edit Track',
        titleController: titleCtrl,
        audioUrlController: audioUrlCtrl,
        durationController: durationCtrl,
        artists: tp.artists,
        albums: tp.albums,
        genres: tp.genres,
        isEdit: true,
        confirmLabel: 'Save',
        onConfirm: () {
          if (titleCtrl.text.trim().isEmpty) return;
          final durSec = _parseDuration(durationCtrl.text);
          context.read<TrackProvider>().updateTrack(
            track.trackId,
            title: titleCtrl.text.trim(),
            audioUrl: audioUrlCtrl.text.trim(),
            duration: durSec,
          );
        },
      ),
    );
  }

  Future<void> _deleteTrack(TrackModel track) async {
    final confirmed = await showDialog<bool>(
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
    );
    if (confirmed == true && mounted) {
      context.read<TrackProvider>().deleteTrack(track.trackId);
    }
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${track.artistName ?? 'Artist'} • ${track.albumTitle ?? 'Album ${track.albumId}'}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            if (track.audioUrl.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                'URL: ${track.audioUrl}',
                style: const TextStyle(color: AppColors.primaryNeon, fontSize: 11),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
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
  final TextEditingController audioUrlController;
  final TextEditingController durationController;
  final List<ArtistModel> artists;
  final List<AlbumModel> albums;
  final List<GenreModel> genres;
  final int? selectedArtistId;
  final int? selectedAlbumId;
  final int? selectedGenreId;
  final ValueChanged<int?>? onArtistChanged;
  final ValueChanged<int?>? onAlbumChanged;
  final ValueChanged<int?>? onGenreChanged;
  final bool isEdit;
  final String confirmLabel;
  final VoidCallback onConfirm;

  const _TrackDialog({
    required this.dialogTitle,
    required this.titleController,
    required this.audioUrlController,
    required this.durationController,
    this.artists = const [],
    this.albums = const [],
    this.genres = const [],
    this.selectedArtistId,
    this.selectedAlbumId,
    this.selectedGenreId,
    this.onArtistChanged,
    this.onAlbumChanged,
    this.onGenreChanged,
    this.isEdit = false,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(hintText: 'Track Title', controller: titleController),
            const SizedBox(height: 12),
            CustomTextField(hintText: 'Track Audio URL (http://... or https://...)', controller: audioUrlController),
            const SizedBox(height: 12),
            CustomTextField(hintText: 'Duration (e.g. 3:45)', controller: durationController),
            if (!isEdit) ...[
              const SizedBox(height: 16),
              const Text('Artist', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              _buildDropdown<int>(
                value: selectedArtistId,
                items: artists.map((a) => DropdownMenuItem(value: a.artistId, child: Text(a.name))).toList(),
                onChanged: onArtistChanged,
                hint: 'Select Artist',
              ),
              const SizedBox(height: 12),
              const Text('Album', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              _buildDropdown<int>(
                value: selectedAlbumId,
                items: albums.map((a) => DropdownMenuItem(value: a.albumId, child: Text(a.title))).toList(),
                onChanged: onAlbumChanged,
                hint: 'Select Album',
              ),
              const SizedBox(height: 12),
              const Text('Genre', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              _buildDropdown<int>(
                value: selectedGenreId,
                items: genres.map((g) => DropdownMenuItem(value: g.genresId, child: Text(g.name))).toList(),
                onChanged: onGenreChanged,
                hint: 'Select Genre',
              ),
            ],
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

  Widget _buildDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.surfaceCard,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          hint: Text(hint, style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

