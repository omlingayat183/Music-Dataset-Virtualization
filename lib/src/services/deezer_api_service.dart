import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/track.dart';

class DeezerApiService {
  DeezerApiService({http.Client? client}) : _client = client ?? http.Client();

  static const _baseSearchTrack = 'https://api.deezer.com/search/track';
  static const _baseSearch = 'https://api.deezer.com/search';
  static const _baseTrack = 'https://api.deezer.com/track';

  final http.Client _client;

  Future<List<Track>> fetchTracksPage({
    required String query,
    required int index,
    int limit = 50,
  }) async {
    final params =
        'q=${Uri.encodeQueryComponent(query)}&index=$index&limit=$limit';
    final endpoints = [
      '$_baseSearchTrack?$params',
      '$_baseSearch?$params',
    ];

    Object? lastError;
    for (final endpoint in endpoints) {
      try {
        final response = await _client.get(
          Uri.parse(endpoint),
          headers: const {'Accept': 'application/json'},
        );

        if (response.statusCode >= 400) {
          lastError = Exception('HTTP ${response.statusCode}');
          continue;
        }

        final decoded = json.decode(response.body);
        if (decoded is! Map<String, dynamic>) {
          lastError = Exception('Invalid Deezer response');
          continue;
        }

        if (decoded['error'] != null) {
          lastError = Exception(decoded['error']['message'] ?? 'Deezer error');
          continue;
        }

        final rawData = decoded['data'];
        if (rawData is! List) {
          return const <Track>[];
        }

        return rawData
            .whereType<Map<String, dynamic>>()
            .map(Track.fromSearchJson)
            .toList();
      } catch (e) {
        lastError = e;
      }
    }

    throw Exception('Failed to fetch tracks: $lastError');
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
