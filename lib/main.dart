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
import 'game/drive_two_cars_game.dart';
import 'presentation/cubits/game_cubit.dart';
import 'presentation/widgets/game_over_overlay.dart';
import 'presentation/widgets/hud_overlay.dart';
import 'presentation/widgets/main_menu_overlay.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Dependency injection (manual, no service locator needed at this scale) ─
  final prefs = await SharedPreferences.getInstance();
  final dataSource = LocalScoreDataSource(prefs);
  final repository = ScoreRepositoryImpl(dataSource);
  final getHighScore = GetHighScoreUseCase(repository);
  final saveHighScore = SaveHighScoreUseCase(repository);

  final gameCubit = GameCubit(
    getHighScore: getHighScore,
    saveHighScore: saveHighScore,
  );

  runApp(DriveTwoCarsApp(gameCubit: gameCubit));
}

/// Root application widget.
///
/// Provides [GameCubit] to the entire widget tree and mounts
/// [GameWidget] with the three Flutter overlays registered.
class DriveTwoCarsApp extends StatelessWidget {
  const DriveTwoCarsApp({super.key, required this.gameCubit});

  final GameCubit gameCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GameCubit>.value(
      value: gameCubit,
      child: MaterialApp(
        title: 'Drive Two Cars',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: _GameScreen(gameCubit: gameCubit),
      ),
    );
  }
}

/// Stateful screen that owns the [DriveTwoCarsGame] instance.
///
/// Using a [StatefulWidget] here ensures the game object lives exactly as long
/// as the screen and is not recreated on widget rebuilds.
class _GameScreen extends StatefulWidget {
  const _GameScreen({required this.gameCubit});

  final GameCubit gameCubit;

  @override
  State<_GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<_GameScreen> {
  late final DriveTwoCarsGame _game;

  @override
  void initState() {
    super.initState();
    _game = DriveTwoCarsGame(gameCubit: widget.gameCubit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: LayoutBuilder(
        builder: (context, constraints) {
          Widget gameWidget = GameWidget<DriveTwoCarsGame>(
            game: _game,
            // ── Overlay builders ───────────────────────────────────────────────
            overlayBuilderMap: {
              GameConstants.overlayMainMenu: (context, game) => MainMenuOverlay(game: game),
              GameConstants.overlayHud: (context, game) => const HudOverlay(),
              GameConstants.overlayGameOver: (context, game) => GameOverOverlay(game: game),
            },
            // Show main menu on first launch.
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
