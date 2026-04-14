import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../core/constants/game_constants.dart';
import '../domain/entities/car_entity.dart';
import '../presentation/cubits/game_cubit.dart';
import '../presentation/cubits/game_state.dart';
import 'components/car_component.dart';
import 'components/obstacle_component.dart';
import 'components/obstacle_spawner_component.dart';
import 'components/road_component.dart';
import 'input/tap_input_handler.dart';

/// Root [FlameGame] for Drive Two Cars.
///
/// Responsibilities:
///   - Compose the two road halves, two cars, and two spawners.
///   - Delegate tap events to [TapInputHandler].
///   - Pause / resume the engine in response to [GameState] changes.
///   - Expose [resetGame] so Flutter overlays can restart a fresh run.
///
/// The game starts with the engine paused; it is resumed only when the
/// player taps "Play" from the main menu overlay.
class DriveTwoCarsGame extends FlameGame
    with TapCallbacks, HasCollisionDetection {
  DriveTwoCarsGame({required this.gameCubit});

  final GameCubit gameCubit;

  // ── Component refs kept for reset / input ─────────────────────────────────
  late CarComponent _leftCar;
  late CarComponent _rightCar;
  late RoadComponent _leftRoad;
  late RoadComponent _rightRoad;
  late ObstacleSpawnerComponent _leftSpawner;
  late ObstacleSpawnerComponent _rightSpawner;
  late TapInputHandler _tapHandler;

  // ── Half-screen dimensions (set in onLoad after size is known) ────────────
  late double _halfW;
  late double _halfH;

  @override
  Color backgroundColor() => const Color(0xFF0D0D1A);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _halfW = size.x / 2;
    _halfH = size.y;

    await _buildWorld();

    // Listen to GameState and respond with engine pause/resume.
    gameCubit.stream.listen(_onGameStateChanged);

    // Start paused — the main menu overlay will call resumeEngine().
    pauseEngine();
  }

  // ── World construction ────────────────────────────────────────────────────

  Future<void> _buildWorld() async {
    // ── Left road half ───────────────────────────────────────────────────────
    _leftRoad = RoadComponent(
      isLeftSide: true,
      roadColor: const Color(0xFF0E0E20),
      laneColor: const Color(0xFF00B4FF),
    )
      ..position = Vector2.zero()
      ..size = Vector2(_halfW, _halfH);

    // ── Right road half ──────────────────────────────────────────────────────
    _rightRoad = RoadComponent(
      isLeftSide: false,
      roadColor: const Color(0xFF1A0E0A),
      laneColor: const Color(0xFFFFB400),
    )
      ..position = Vector2(_halfW, 0)
      ..size = Vector2(_halfW, _halfH);

    // ── Cars ─────────────────────────────────────────────────────────────────
    _leftCar = CarComponent(
      entity: const CarEntity(side: CarSide.left, lane: CarLane.inner),
      carColor: const Color(0xFF00FFFF),
      halfWidth: _halfW,
      halfHeight: _halfH,
    );

    _rightCar = CarComponent(
      entity: const CarEntity(side: CarSide.right, lane: CarLane.inner),
      carColor: const Color(0xFFFF6B00),
      halfWidth: _halfW,
      halfHeight: _halfH,
    );

    // ── Spawners ─────────────────────────────────────────────────────────────
    _leftSpawner = ObstacleSpawnerComponent(
      gameCubit: gameCubit,
      halfWidth: _halfW,
      halfHeight: _halfH,
      isLeftSide: true,
      parentComponent: _leftRoad,
    );

    _rightSpawner = ObstacleSpawnerComponent(
      gameCubit: gameCubit,
      halfWidth: _halfW,
      halfHeight: _halfH,
      isLeftSide: false,
      parentComponent: _rightRoad,
    );

    // ── Centre divider ────────────────────────────────────────────────────────
    final divider = _CentreDivider(height: _halfH);

    // ── Input handler ─────────────────────────────────────────────────────────
    _tapHandler = TapInputHandler(
      leftCar: _leftCar,
      rightCar: _rightCar,
      screenWidth: size.x,
    );

    await addAll([
      _leftRoad,
      _rightRoad,
      _leftCar,
      _rightCar,
      _leftSpawner,
      _rightSpawner,
      divider,
    ]);
  }

  // ── Input ─────────────────────────────────────────────────────────────────

  @override
  void onTapDown(TapDownEvent event) {
    if (gameCubit.state is! GamePlaying) return;
    _tapHandler.handleTap(event);
  }

  // ── State listener ────────────────────────────────────────────────────────

  void _onGameStateChanged(GameState state) {
    switch (state) {
      case GamePlaying():
        resumeEngine();
        overlays.remove(GameConstants.overlayGameOver);
        overlays.remove(GameConstants.overlayMainMenu);
        if (!overlays.isActive(GameConstants.overlayHud)) {
          overlays.add(GameConstants.overlayHud);
        }
      case GamePaused():
        pauseEngine();
      case GameOver():
        pauseEngine();
        overlays.remove(GameConstants.overlayHud);
        overlays.add(GameConstants.overlayGameOver);
      case GameInitial():
        pauseEngine();
    }
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  /// Tears down and rebuilds the entire game world for a fresh run.
  ///
  /// Called by the game-over overlay before starting a new game.
  void resetGame() {
    _leftCar.reset();
    _rightCar.reset();
    _leftRoad.reset();
    _rightRoad.reset();
    _leftSpawner.reset();
    _rightSpawner.reset();
    
    // Remove existing obstacles completely.
    _leftRoad.removeWhere((c) => c is ObstacleComponent);
    _rightRoad.removeWhere((c) => c is ObstacleComponent);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Centre divider component
// ─────────────────────────────────────────────────────────────────────────────

/// Thin glowing line that visually separates the two road halves.
class _CentreDivider extends PositionComponent {
  _CentreDivider({required double height})
      : super(size: Vector2(4, height));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Will be positioned by the parent game after it knows screen size.
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    position = Vector2(gameSize.x / 2 - 2, 0);
    size = Vector2(4, gameSize.y);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()
        ..color = const Color(0xFF333355)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawRect(
      Rect.fromLTWH(1, 0, 2, size.y),
      Paint()..color = const Color(0xFF4444AA),
    );
  }
}
