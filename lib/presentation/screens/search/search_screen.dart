import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/genre_model.dart';
import '../../../data/models/track_model.dart';
import 'widgets/genre_card.dart';
import '../now_playing/player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  final List<GenreModel> _genres = [
    GenreModel(genreId: 1, name: 'Pop'),
    GenreModel(genreId: 2, name: 'Rock'),
    GenreModel(genreId: 3, name: 'Hip-Hop'),
    GenreModel(genreId: 4, name: 'Electronic'),
    GenreModel(genreId: 5, name: 'Jazz'),
    GenreModel(genreId: 6, name: 'Classical'),
    GenreModel(genreId: 7, name: 'R&B'),
    GenreModel(genreId: 8, name: 'Country'),
  ];

  final List<TrackModel> _allTracks = [
    TrackModel(trackId: 1, artistId: 1, albumId: 1, genreId: 1, title: 'Midnight Pulse', duration: 234, streamCount: 1500000),
    TrackModel(trackId: 2, artistId: 2, albumId: 2, genreId: 2, title: 'Neon Skyline', duration: 198, streamCount: 980000),
    TrackModel(trackId: 3, artistId: 3, albumId: 3, genreId: 5, title: 'Velvet Echoes', duration: 267, streamCount: 750000),
    TrackModel(trackId: 4, artistId: 1, albumId: 1, genreId: 1, title: 'Distant Frequencies', duration: 312, streamCount: 620000),
    TrackModel(trackId: 5, artistId: 4, albumId: 4, genreId: 7, title: 'Golden Hour', duration: 185, streamCount: 540000),
  ];

  List<TrackModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchTracks(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = _allTracks
          .where((t) => t.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _searchTracks,
              style: const TextStyle(color: AppColors.textPrimary),
              cursorColor: AppColors.primaryNeon,
              decoration: InputDecoration(
                hintText: 'Search songs, artists...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          _searchTracks('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryNeon),
                ),
              ),
            ),
          ),
        ),
        if (_isSearching && _searchResults.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildSearchResult(_searchResults[index]),
                childCount: _searchResults.length,
              ),
            ),
          )
        else if (_isSearching && _searchResults.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No results found',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            ),
          )
        else ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Text(
                'Browse Genres',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => GenreCard(genre: _genres[index]),
                childCount: _genres.length,
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildSearchResult(TrackModel track) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.music_note_rounded, color: AppColors.primaryNeon),
      ),
      title: Text(
        track.title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        'Artist ${track.artistId}',
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
      trailing: Text(
        track.durationFormatted,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PlayerScreen(track: track)),
        );
      },
    );
  }
}
