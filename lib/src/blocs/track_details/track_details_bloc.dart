import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/library_repository.dart';
import '../../repositories/track_details_repository.dart';
import 'track_details_event.dart';
import 'track_details_state.dart';

class TrackDetailsBloc extends Bloc<TrackDetailsRequested, TrackDetailsState> {
  TrackDetailsBloc(this._repository) : super(const TrackDetailsState()) {
    on<TrackDetailsRequested>(_onRequested);
  }

  final TrackDetailsRepository _repository;

  Future<void> _onRequested(
    TrackDetailsRequested event,
    Emitter<TrackDetailsState> emit,
  ) async {
    emit(const TrackDetailsState(status: TrackDetailsStatus.loading));

    try {
      final track = await _repository.getTrackDetails(event.trackId);
      final lyrics = await _repository.getLyrics(
        trackName: track.title,
        artistName: track.artist,
        albumName: track.album ?? '',
        duration: track.duration ?? 0,
      );

      emit(
        TrackDetailsState(
          status: TrackDetailsStatus.success,
          track: track,
          lyrics: lyrics,
        ),
      );
    } on NoInternetException {
      emit(
        const TrackDetailsState(
          status: TrackDetailsStatus.failure,
          errorMessage: 'NO INTERNET CONNECTION',
        ),
      );
    } catch (_) {
      emit(
        const TrackDetailsState(
          status: TrackDetailsStatus.failure,
          errorMessage: 'Failed to load track details',
        ),
      );
    }
  }
}
