import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/backend/podcast_backend.dart';
import '../../core/metadata_sanitizer.dart';
import '../../providers.dart';
import '../details/podcast_detail_screen.dart';
import '../shared/artwork.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  List<RemotePodcast> _results = const [];
  String _provider = 'podcast_index';
  bool _loading = false;
  bool _showingCache = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
      _showingCache = false;
    });
    final app = ref.read(appControllerProvider);
    final cached = await app.searchCachedPodcasts(query);
    if (mounted && cached.isNotEmpty) {
      setState(() {
        _results = cached;
        _showingCache = true;
      });
    }
    try {
      final results = await app.searchPodcasts(query, provider: _provider);
      if (mounted) {
        setState(() {
          _results = results;
          _showingCache = false;
        });
      }
    } catch (exception) {
      if (mounted) {
        setState(() {
          _error = cached.isEmpty
              ? exception.toString()
              : 'Offline — showing saved search results.';
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Text(
              'Discover',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: const InputDecoration(
                      hintText: 'Search podcasts',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'Search',
                  onPressed: _loading ? null : _search,
                  icon: const Icon(Icons.arrow_forward_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: DropdownButtonFormField<String>(
              initialValue: _provider,
              decoration: const InputDecoration(
                labelText: 'Pinepods search provider',
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'podcast_index',
                  child: Text('Podcast Index'),
                ),
                DropdownMenuItem(value: 'itunes', child: Text('iTunes')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _provider = value);
                if (_controller.text.trim().isNotEmpty) _search();
              },
            ),
          ),
          if (_loading || _showingCache)
            const LinearProgressIndicator(minHeight: 2),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(child: _content()),
        ],
      ),
    );
  }

  Widget _content() {
    if (_controller.text.trim().isEmpty && _results.isEmpty) {
      return const EmptyState(
        icon: Icons.travel_explore_rounded,
        title: 'Find something worth hearing',
        body:
            'Search through the discovery provider configured on your Pinepods server.',
      );
    }
    if (_loading && _results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_results.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No podcasts found',
        body: 'Try another title, author, or search provider.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 28),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final podcast = _results[index];
        final author = MetadataSanitizer.plainText(podcast.author);
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(11),
            leading: Artwork(
              id: podcast.podcastIndexId,
              title: podcast.title,
              url: podcast.artworkUrl,
              size: 64,
            ),
            title: Text(
              MetadataSanitizer.plainText(podcast.title).isEmpty
                  ? 'Untitled podcast'
                  : MetadataSanitizer.plainText(podcast.title),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              author.isNotEmpty
                  ? author
                  : podcast.episodeCount > 0
                  ? '${podcast.episodeCount} episodes'
                  : 'Podcast',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PodcastDetailScreen(podcast: podcast),
              ),
            ),
          ),
        );
      },
    );
  }
}
