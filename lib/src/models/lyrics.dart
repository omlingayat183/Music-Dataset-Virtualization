import 'package:equatable/equatable.dart';

class Lyrics extends Equatable {
  const Lyrics({required this.plainLyrics, required this.syncedLyrics});

  final String? plainLyrics;
  final String? syncedLyrics;

  bool get hasLyrics =>
      (plainLyrics != null && plainLyrics!.trim().isNotEmpty) ||
      (syncedLyrics != null && syncedLyrics!.trim().isNotEmpty);

  factory Lyrics.fromJson(Map<String, dynamic> json) {
    return Lyrics(
      plainLyrics: json['plainLyrics'] as String?,
      syncedLyrics: json['syncedLyrics'] as String?,
    );
  }

  static const empty = Lyrics(plainLyrics: null, syncedLyrics: null);

  @override
  List<Object?> get props => [plainLyrics, syncedLyrics];
}
