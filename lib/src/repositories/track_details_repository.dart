import '../models/lyrics.dart';
import '../models/track.dart';
import '../services/connectivity_service.dart';
import '../services/deezer_api_service.dart';
import '../services/lrclib_service.dart';
import 'library_repository.dart';

class TrackDetailsRepository {
  TrackDetailsRepository({
    required DeezerApiService deezerApiService,
    required LrcLibService lrcLibService,
    required ConnectivityService connectivityService,
  })  : _deezerApiService = deezerApiService,
        _lrcLibService = lrcLibService,
        _connectivityService = connectivityService;

  final DeezerApiService _deezerApiService;
  final LrcLibService _lrcLibService;
  final ConnectivityService _connectivityService;

  Future<Track> getTrackDetails(int trackId) async {
    if (!await _connectivityService.hasConnection) {
      throw const NoInternetException();
    }
    return _deezerApiService.fetchTrackDetails(trackId);
  }

  Future<Lyrics> getLyrics({
    required String trackName,
    required String artistName,
    required String albumName,
    required int duration,
  }) async {
    if (!await _connectivityService.hasConnection) {
      throw const NoInternetException();
    }

    return _lrcLibService.fetchCachedLyrics(
      trackName: trackName,
      artistName: artistName,
      albumName: albumName,
      duration: duration,
    );
  }
}
