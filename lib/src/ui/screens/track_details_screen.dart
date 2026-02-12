import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/track_details/track_details_bloc.dart';
import '../../blocs/track_details/track_details_event.dart';
import '../../blocs/track_details/track_details_state.dart';
import '../../repositories/track_details_repository.dart';

class TrackDetailsScreen extends StatelessWidget {
  const TrackDetailsScreen({
    super.key,
    required this.trackId,
    required this.repository,
  });

  final int trackId;
  final TrackDetailsRepository repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TrackDetailsBloc(repository)
        ..add(TrackDetailsRequested(trackId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Track Details + Lyrics')),
        body: BlocBuilder<TrackDetailsBloc, TrackDetailsState>(
          builder: (context, state) {
            if (state.status == TrackDetailsStatus.loading ||
                state.status == TrackDetailsStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == TrackDetailsStatus.failure) {
              return Center(
                child: Text(state.errorMessage ?? 'Failed to load details'),
              );
            }

            final track = state.track!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(track.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('Artist: ${track.artist}'),
                Text('Album: ${track.album ?? 'Unknown'}'),
                Text('Track ID: ${track.id}'),
                Text('Duration: ${track.duration ?? 0} sec'),
                const Divider(height: 32),
                Text('Lyrics', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Text(
                  state.lyrics.hasLyrics
                      ? (state.lyrics.plainLyrics?.trim().isNotEmpty ?? false)
                          ? state.lyrics.plainLyrics!
                          : state.lyrics.syncedLyrics ?? ''
                      : 'Lyrics not found',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
