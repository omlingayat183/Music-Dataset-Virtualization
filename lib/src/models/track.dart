import 'package:equatable/equatable.dart';

class Track extends Equatable {
  const Track({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.duration,
  });

  final int id;
  final String title;
  final String artist;
  final String? album;
  final int? duration;

  String get groupKey {
    if (title.trim().isEmpty) return '#';
    final first = title.trimLeft()[0].toUpperCase();
    final alphaNum = RegExp(r'[A-Z0-9]');
    return alphaNum.hasMatch(first) ? first : '#';
  }

  factory Track.fromSearchJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      artist: (json['artist']?['name'] ?? 'Unknown Artist') as String,
      album: json['album']?['title'] as String?,
      duration: json['duration'] as int?,
    );
  }

  factory Track.fromDetailJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      artist: (json['artist']?['name'] ?? 'Unknown Artist') as String,
      album: json['album']?['title'] as String?,
      duration: json['duration'] as int?,
    );
  }

  @override
  List<Object?> get props => [id, title, artist, album, duration];
}
