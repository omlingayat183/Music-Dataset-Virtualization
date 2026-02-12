import 'package:equatable/equatable.dart';

import '../../models/track.dart';

enum LibraryStatus { initial, loading, success, failure }

class LibraryState extends Equatable {
  const LibraryState({
    this.status = LibraryStatus.initial,
    this.tracks = const <Track>[],
    this.filteredTracks = const <Track>[],
    this.errorMessage,
    this.isFetchingMore = false,
    this.hasReachedTarget = false,
    this.searchQuery = '',
    this.groupByArtist = false,
    this.loadedCount = 0,
  });

  final LibraryStatus status;
  final List<Track> tracks;
  final List<Track> filteredTracks;
  final String? errorMessage;
  final bool isFetchingMore;
  final bool hasReachedTarget;
  final String searchQuery;
  final bool groupByArtist;
  final int loadedCount;

  LibraryState copyWith({
    LibraryStatus? status,
    List<Track>? tracks,
    List<Track>? filteredTracks,
    String? errorMessage,
    bool? isFetchingMore,
    bool? hasReachedTarget,
    String? searchQuery,
    bool? groupByArtist,
    int? loadedCount,
  }) {
    return LibraryState(
      status: status ?? this.status,
      tracks: tracks ?? this.tracks,
      filteredTracks: filteredTracks ?? this.filteredTracks,
      errorMessage: errorMessage,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasReachedTarget: hasReachedTarget ?? this.hasReachedTarget,
      searchQuery: searchQuery ?? this.searchQuery,
      groupByArtist: groupByArtist ?? this.groupByArtist,
      loadedCount: loadedCount ?? this.loadedCount,
    );
  }

  @override
  List<Object?> get props => [
        status,
        tracks,
        filteredTracks,
        errorMessage,
        isFetchingMore,
        hasReachedTarget,
        searchQuery,
        groupByArtist,
        loadedCount,
      ];
}
