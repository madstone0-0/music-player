import 'package:get_it/get_it.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/db/repo/history.dart';
import 'package:music_player/db/repo/playlist.dart';
import 'package:music_player/db/repo/track.dart';
import 'package:music_player/services/ApiService.dart';
import 'package:music_player/services/AudioPlayerHandlerService.dart';
import 'package:music_player/services/LocalMediaService.dart';
import 'package:music_player/services/LyricsService.dart';
import 'package:music_player/services/MusicService.dart';
import 'package:music_player/services/PlayerStateService.dart';
import 'package:music_player/services/PlaylistService.dart';
import 'package:music_player/services/SearchService.dart';
import 'package:dio/dio.dart';

GetIt getIt = GetIt.instance;

Future<void> setupLocatorService() async {
  getIt.registerSingleton<Db>(Db());
  getIt.registerSingleton<LocalMediaService>(await LocalMediaService.create());
  getIt.registerSingleton<TrackRepository>(TrackRepository(getIt<Db>(), getIt<LocalMediaService>()));
  getIt.registerSingleton<PlaylistRepository>(PlaylistRepository(getIt<Db>()));
  getIt.registerSingleton<HistoryRepository>(HistoryRepository(getIt<Db>()));
  getIt.registerLazySingleton<PlaylistService>(() => PlaylistService(repo: getIt<PlaylistRepository>()));
  getIt.registerSingleton<AudioPlayerHandlerService>(AudioPlayerHandlerService());
  getIt.registerLazySingleton<MusicService>(() => MusicService());
  getIt.registerLazySingleton<PlayerStateService>(() => PlayerStateService());
  getIt.registerLazySingleton<SearchService>(() => SearchService(repo: getIt<TrackRepository>()));

  final dio = Dio();
  final api = ApiService(dio);
  getIt.registerSingleton<ApiService>(api);

  getIt.registerLazySingleton(() => LyricsService(api: getIt<ApiService>()));
}
