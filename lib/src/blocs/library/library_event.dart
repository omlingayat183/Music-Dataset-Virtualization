import 'package:equatable/equatable.dart';

abstract class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

class LibraryStarted extends LibraryEvent {
  const LibraryStarted();
}

class LibraryFetchNextPage extends LibraryEvent {
  const LibraryFetchNextPage();
}

class LibrarySearchChanged extends LibraryEvent {
  const LibrarySearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class LibraryGroupByChanged extends LibraryEvent {
  const LibraryGroupByChanged(this.groupByArtist);

  final bool groupByArtist;

  @override
  List<Object?> get props => [groupByArtist];
}
