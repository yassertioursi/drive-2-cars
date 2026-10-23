import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/game_constants.dart';
import 'data/data_sources/local_score_data_source.dart';
import 'data/repositories/score_repository_impl.dart';
import 'domain/use_cases/get_high_score_use_case.dart';
import 'domain/use_cases/save_high_score_use_case.dart';
import 'game/cars_drive_game.dart';
import 'presentation/cubits/game_cubit.dart';
import 'presentation/widgets/game_over_overlay.dart';
import 'presentation/widgets/hud_overlay.dart';
import 'presentation/widgets/main_menu_overlay.dart';
import 'presentation/widgets/pause_overlay.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: GameConstants.asphalt,
    ),
  );

  // ── Dependency injection (manual, no service locator at this scale) ──────
  final prefs = await SharedPreferences.getInstance();
  final dataSource = LocalScoreDataSource(prefs);
  final repository = ScoreRepositoryImpl(dataSource);
  final getHighScore = GetHighScoreUseCase(repository);
  final saveHighScore = SaveHighScoreUseCase(repository);

  final gameCubit = GameCubit(
    getHighScore: getHighScore,
    saveHighScore: saveHighScore,
  );

  runApp(CarsDriveApp(gameCubit: gameCubit));
}

/// Root application widget: provides [GameCubit] and mounts the game.
class CarsDriveApp extends StatelessWidget {
  const CarsDriveApp({super.key, required this.gameCubit});

  final GameCubit gameCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GameCubit>.value(
      value: gameCubit,
      child: MaterialApp(
        title: 'Cars Drive',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: GameConstants.asphalt,
        ),
        home: _GameScreen(gameCubit: gameCubit),
      ),
    );
  }
}

class _GameScreen extends StatefulWidget {
  const _GameScreen({required this.gameCubit});

  final GameCubit gameCubit;

  @override
  State<_GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<_GameScreen> {
  late final CarsDriveGame _game;

  @override
  void initState() {
    super.initState();
    _game = CarsDriveGame(gameCubit: widget.gameCubit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConstants.asphalt,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final gameWidget = GameWidget<CarsDriveGame>(
            game: _game,
            overlayBuilderMap: {
              GameConstants.overlayMainMenu: (context, game) =>
                  MainMenuOverlay(game: game),
              GameConstants.overlayHud: (context, game) => const HudOverlay(),
              GameConstants.overlayPause: (context, game) =>
                  PauseOverlay(game: game),
              GameConstants.overlayGameOver: (context, game) =>
                  GameOverOverlay(game: game),
            },
            initialActiveOverlays: const [GameConstants.overlayMainMenu],
          );

          if (constraints.maxWidth > 500) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: AspectRatio(
                  aspectRatio: 9 / 19.5,
                  child: ClipRect(child: gameWidget),
                ),
              ),
            );
          }

          return gameWidget;
        },
      ),
    );
  }
}
