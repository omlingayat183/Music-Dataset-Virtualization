import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/library/library_bloc.dart';
import '../../blocs/library/library_event.dart';
import '../../blocs/library/library_state.dart';
import '../../models/track.dart';
import '../../repositories/track_details_repository.dart';
import '../widgets/group_header.dart';
import '../widgets/track_tile.dart';
import 'track_details_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key, required this.trackDetailsRepository});

  final TrackDetailsRepository trackDetailsRepository;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<LibraryBloc>().add(const LibraryStarted());
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 1200) {
      context.read<LibraryBloc>().add(const LibraryFetchNextPage());
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Library (50k+)'),
        actions: [
          BlocBuilder<LibraryBloc, LibraryState>(
            buildWhen: (p, c) => p.groupByArtist != c.groupByArtist,
            builder: (context, state) {
              return Row(
                children: [
                  const Text('Artist'),
                  Switch(
                    value: state.groupByArtist,
                    onChanged: (v) => context
                        .read<LibraryBloc>()
                        .add(LibraryGroupByChanged(v)),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (value) =>
                  context.read<LibraryBloc>().add(LibrarySearchChanged(value)),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search by track / artist / id',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<LibraryBloc, LibraryState>(
              builder: (context, state) {
                if (state.status == LibraryStatus.loading &&
                    state.filteredTracks.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == LibraryStatus.failure &&
                    state.filteredTracks.isEmpty) {
                  return Center(
                    child: Text(state.errorMessage ?? 'Failed to load tracks'),
                  );
                }

                final grouped = _groupTracks(
                  state.filteredTracks,
                  groupByArtist: state.groupByArtist,
                );
                final groupKeys = grouped.keys.toList()..sort();

                return CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    for (final key in groupKeys) ...[
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: GroupHeaderDelegate(key),
                      ),
                      SliverList.builder(
                        itemCount: grouped[key]!.length,
                        itemBuilder: (context, index) {
                          final track = grouped[key]![index];
                          return TrackTile(
                            track: track,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => TrackDetailsScreen(
                                    trackId: track.id,
                                    repository: widget.trackDetailsRepository,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: state.hasReachedTarget
                              ? Text(
                                  'Loaded ${state.loadedCount} tracks (target reached)',
                                )
                              : state.isFetchingMore
                                  ? const CircularProgressIndicator()
                                  : Text('Loaded ${state.loadedCount} tracks'),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<Track>> _groupTracks(
    List<Track> tracks, {
    required bool groupByArtist,
  }) {
    final map = <String, List<Track>>{};
    for (final track in tracks) {
      final source = groupByArtist ? track.artist : track.title;
      final key = source.trim().isEmpty
          ? '#'
          : source.trimLeft()[0].toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '#');
      map.putIfAbsent(key, () => <Track>[]).add(track);
    }
    return map;
  }
}
