import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/blocs/library/library_bloc.dart';
import 'src/repositories/library_repository.dart';
import 'src/repositories/track_details_repository.dart';
import 'src/services/connectivity_service.dart';
import 'src/services/deezer_api_service.dart';
import 'src/services/lrclib_service.dart';
import 'src/ui/screens/library_screen.dart';

void main() {
  final connectivityService = ConnectivityService(Connectivity());
  final deezerApi = DeezerApiService();
  final lrcLibService = LrcLibService();

  final libraryRepository = LibraryRepository(
    deezerApiService: deezerApi,
    connectivityService: connectivityService,
  );

  final trackDetailsRepository = TrackDetailsRepository(
    deezerApiService: deezerApi,
    lrcLibService: lrcLibService,
    connectivityService: connectivityService,
  );

  runApp(MyApp(
    libraryRepository: libraryRepository,
    trackDetailsRepository: trackDetailsRepository,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.libraryRepository,
    required this.trackDetailsRepository,
  });

  final LibraryRepository libraryRepository;
  final TrackDetailsRepository trackDetailsRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LibraryBloc(libraryRepository),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Music Dataset Virtualization',
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        home: LibraryScreen(trackDetailsRepository: trackDetailsRepository),
      ),
    );
  }
}
