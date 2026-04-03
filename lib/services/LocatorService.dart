import 'package:get_it/get_it.dart';
import 'package:music_player/db/db.dart';
import 'package:music_player/db/repo/track.dart';
import 'package:music_player/services/AudioPlayerHandlerService.dart';
import 'package:music_player/services/LocalMediaService.dart';
import 'package:music_player/services/MusicService.dart';
import 'package:music_player/services/PageManagerService.dart';

GetIt getIt = GetIt.instance;

Future<void> setupLocatorService() async {
  getIt.registerSingleton<AppDatabase>(AppDatabase());
  getIt.registerSingleton<AudioPlayerHandlerService>(AudioPlayerHandlerService());
  getIt.registerSingleton<LocalMediaService>(await LocalMediaService.create());
  getIt.registerSingleton<TrackRepository>(TrackRepository(getIt<AppDatabase>(), getIt<LocalMediaService>()));
  getIt.registerLazySingleton<MusicService>(() => MusicService());
  getIt.registerLazySingleton<PlayerStateService>(() => PlayerStateService());
}
