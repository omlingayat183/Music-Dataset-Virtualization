import '../models/track.dart';
import '../services/connectivity_service.dart';
import '../services/deezer_api_service.dart';

class LibraryRepository {
  LibraryRepository({
    required DeezerApiService deezerApiService,
    required ConnectivityService connectivityService,
  })  : _deezerApiService = deezerApiService,
        _connectivityService = connectivityService;

  final DeezerApiService _deezerApiService;
  final ConnectivityService _connectivityService;

  Future<List<Track>> fetchTracksPage({
    required String query,
    required int index,
    int limit = 50,
  }) async {
    if (!await _connectivityService.hasConnection) {
      throw const NoInternetException();
    }
    return _deezerApiService.fetchTracksPage(
      query: query,
      index: index,
      limit: limit,
    );
  }
}

class NoInternetException implements Exception {
  const NoInternetException();
}
