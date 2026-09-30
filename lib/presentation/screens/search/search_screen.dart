import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/genre_model.dart';
import '../../../data/models/track_model.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/track_provider.dart';
import '../../global_widgets/track_art_widget.dart';
import 'widgets/genre_card.dart';
import '../now_playing/player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<GenreModel> _genres = [];
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trackProvider = context.read<TrackProvider>();
      trackProvider.fetchGenres();
      setState(() {
        _genres = trackProvider.genres;
      });
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _searchTracks(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      context.read<TrackProvider>().searchTracks('');
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        context.read<TrackProvider>().searchTracks(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TrackProvider>(
      builder: (context, trackProvider, _) {
        final searchResults = trackProvider.searchResults;
        final isSearching = _searchController.text.isNotEmpty;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: _searchTracks,
                  style: TextStyle(color: context.textPrimary),
                  cursorColor: context.primaryNeon,
                  decoration: InputDecoration(
                    hintText: 'Search songs, artists...',
                    prefixIcon: Icon(Icons.search, color: context.textMuted),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: context.textMuted),
                            onPressed: () {
                              _debounceTimer?.cancel();
                              _searchController.clear();
                              context.read<TrackProvider>().searchTracks('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: context.surfaceCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.primaryNeon),
                    ),
                  ),
                ),
              ),
            ),
            if (isSearching && searchResults.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildSearchResult(context, searchResults[index], searchResults, index),
                    childCount: searchResults.length,
                  ),
                ),
              )
            else if (isSearching && searchResults.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No results found',
                      style: TextStyle(color: context.textMuted),
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
      },
    );
  }

  Widget _buildSearchResult(BuildContext context, TrackModel track, List<TrackModel> allTracks, int index) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: TrackArtWidget(
        imageUrl: track.coverPng,
        size: 48,
        borderRadius: 8,
      ),
      title: Text(
        track.title,
        style: TextStyle(
          color: context.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        track.artistName ?? '',
        style: TextStyle(color: context.textMuted, fontSize: 12),
      ),
      trailing: Text(
        track.durationFormatted,
        style: TextStyle(color: context.textMuted, fontSize: 12),
      ),
      onTap: () {
        context.read<AudioProvider>().playTrackFromQueue(allTracks, index);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PlayerScreen(track: track)),
        );
      },
    );
  }
}
