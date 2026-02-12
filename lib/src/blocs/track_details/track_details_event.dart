import 'package:equatable/equatable.dart';

class TrackDetailsRequested extends Equatable {
  const TrackDetailsRequested(this.trackId);

  final int trackId;

  @override
  List<Object?> get props => [trackId];
}
