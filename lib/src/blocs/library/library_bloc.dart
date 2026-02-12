import 'dart:async';
import 'dart:isolate';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/track.dart';
import '../../repositories/library_repository.dart';
import 'library_event.dart';
import 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc(this._repository) : super(const LibraryState()) {
    on<LibraryStarted>(_onStarted);
    on<LibraryFetchNextPage>(_onFetchNextPage);
    on<LibrarySearchChanged>(_onSearchChanged);
    on<LibraryGroupByChanged>(_onGroupByChanged);
  }

  final LibraryRepository _repository;

  static const int _pageSize = 50;
  static const int _targetSize = 50000;
  static const int _maxStored = 55000;
  static const List<String> _seedQueries = [
    ...'abcdefghijklmnopqrstuvwxyz'.split(''),
    ...'0123456789'.split(''),
    'love',
    'the',
    'remix',
    'live',
  ];

  int _queryCursor = 0;
  int _offset = 0;
  final Set<int> _seenIds = <int>{};
  Timer? _debounce;

  Future<void> _onStarted(
    LibraryStarted event,
    Emitter<LibraryState> emit,
  ) async {
    emit(state.copyWith(status: LibraryStatus.loading, errorMessage: null));
    await _fetchMore(emit);
  }

  Future<void> _onFetchNextPage(
    LibraryFetchNextPage event,
    Emitter<LibraryState> emit,
  ) async {
    if (state.isFetchingMore || state.hasReachedTarget) return;
    await _fetchMore(emit);
  }

  Future<void> _fetchMore(Emitter<LibraryState> emit) async {
    emit(state.copyWith(isFetchingMore: true, errorMessage: null));

    try {
      while (_queryCursor < _seedQueries.length) {
        final page = await _repository.fetchTracksPage(
          query: _seedQueries[_queryCursor],
          index: _offset,
          limit: _pageSize,
        );

        if (page.isEmpty) {
          _queryCursor++;
          _offset = 0;
          continue;
        }

        _offset += _pageSize;
        final deduped = page.where((t) => _seenIds.add(t.id)).toList();
        final combined = List<Track>.from(state.tracks)..addAll(deduped);

        if (combined.length > _maxStored) {
          final toTrim = combined.length - _maxStored;
          final trimmed = combined.sublist(toTrim);
          _seenIds
            ..clear()
            ..addAll(trimmed.map((e) => e.id));
          _emitSuccess(emit, trimmed);
        } else {
          _emitSuccess(emit, combined);
        }

        if (state.loadedCount >= _targetSize) {
          emit(state.copyWith(hasReachedTarget: true, isFetchingMore: false));
        }
        return;
      }

      emit(state.copyWith(hasReachedTarget: true, isFetchingMore: false));
    } on NoInternetException {
      emit(
        state.copyWith(
          status: LibraryStatus.failure,
          errorMessage: 'NO INTERNET CONNECTION',
          isFetchingMore: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: LibraryStatus.failure,
          errorMessage: 'Failed to load tracks',
          isFetchingMore: false,
        ),
      );
    }
  }

  void _emitSuccess(Emitter<LibraryState> emit, List<Track> allTracks) {
    final filtered = _applyFilterSync(allTracks, state.searchQuery);
    emit(
      state.copyWith(
        status: LibraryStatus.success,
        tracks: allTracks,
        filteredTracks: filtered,
        loadedCount: allTracks.length,
        isFetchingMore: false,
        errorMessage: null,
      ),
    );
  }

  Future<void> _onSearchChanged(
    LibrarySearchChanged event,
    Emitter<LibraryState> emit,
  ) async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final filtered = await Isolate.run(
        () => _applyFilterSync(state.tracks, event.query),
      );
      emit(state.copyWith(searchQuery: event.query, filteredTracks: filtered));
    });
  }

  void _onGroupByChanged(LibraryGroupByChanged event, Emitter<LibraryState> emit) {
    emit(state.copyWith(groupByArtist: event.groupByArtist));
  }

  static List<Track> _applyFilterSync(List<Track> tracks, String query) {
    if (query.trim().isEmpty) return tracks;
    final q = query.toLowerCase();
    return tracks
        .where(
          (track) =>
              track.title.toLowerCase().contains(q) ||
              track.artist.toLowerCase().contains(q) ||
              '${track.id}'.contains(q),
        )
        .toList();
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
