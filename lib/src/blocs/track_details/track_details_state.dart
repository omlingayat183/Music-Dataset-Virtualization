import 'package:equatable/equatable.dart';

import '../../models/lyrics.dart';
import '../../models/track.dart';

enum TrackDetailsStatus { initial, loading, success, failure }

class TrackDetailsState extends Equatable {
  const TrackDetailsState({
    this.status = TrackDetailsStatus.initial,
    this.track,
    this.lyrics = Lyrics.empty,
    this.errorMessage,
  });

  final TrackDetailsStatus status;
  final Track? track;
  final Lyrics lyrics;
  final String? errorMessage;

  TrackDetailsState copyWith({
    TrackDetailsStatus? status,
    Track? track,
    Lyrics? lyrics,
    String? errorMessage,
  }) {
    return TrackDetailsState(
      status: status ?? this.status,
      track: track ?? this.track,
      lyrics: lyrics ?? this.lyrics,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, track, lyrics, errorMessage];
}
