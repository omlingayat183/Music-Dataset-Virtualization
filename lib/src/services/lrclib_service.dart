import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/lyrics.dart';

class LrcLibService {
  LrcLibService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Lyrics> fetchCachedLyrics({
    required String trackName,
    required String artistName,
    required String albumName,
    required int duration,
  }) async {
    final query = {
      'track_name': trackName,
      'artist_name': artistName,
      'album_name': albumName,
      'duration': '$duration',
    };

    final uri = Uri.https('lrclib.net', '/api/get-cached', query);
    final response = await _client.get(uri);

    if (response.statusCode == 404) return Lyrics.empty;
    if (response.statusCode >= 400) {
      throw Exception('Failed to fetch lyrics');
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    return Lyrics.fromJson(body);
  }
}
