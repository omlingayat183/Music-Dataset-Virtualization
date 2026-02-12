import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/track.dart';

class DeezerApiService {
  DeezerApiService({http.Client? client}) : _client = client ?? http.Client();

  static const _baseSearch = 'https://api.deezer.com/search/track';
  static const _baseTrack = 'https://api.deezer.com/track';

  final http.Client _client;

  Future<List<Track>> fetchTracksPage({
    required String query,
    required int index,
    int limit = 50,
  }) async {
    final uri = Uri.parse(
      '$_baseSearch?q=${Uri.encodeQueryComponent(query)}&index=$index&limit=$limit',
    );
    final response = await _client.get(uri);
    if (response.statusCode >= 400) {
      throw Exception('Failed to fetch tracks');
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    final data = (body['data'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();

    return data.map(Track.fromSearchJson).toList();
  }

  Future<Track> fetchTrackDetails(int trackId) async {
    final response = await _client.get(Uri.parse('$_baseTrack/$trackId'));
    if (response.statusCode >= 400) {
      throw Exception('Failed to fetch track details');
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    if (body['error'] != null) {
      throw Exception(body['error']['message']);
    }

    return Track.fromDetailJson(body);
  }
}
