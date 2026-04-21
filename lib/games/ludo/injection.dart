

import 'package:games_hub/games/ludo/data/game_repository_impl.dart';
import 'package:games_hub/games/ludo/domain/game_repository.dart';
import 'package:games_hub/games/ludo/presentation/provider/game_provider.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencyInjection() {
  getIt.registerLazySingleton<GameRepository>(() => GameRepositoryImpl());

  getIt.registerFactory<GameProvider>(
    () => GameProvider(repository: getIt<GameRepository>()),
  );
}