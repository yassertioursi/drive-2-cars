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

/// Root [FlameGame] for Cars Drive.
///
/// Composes the two dusk road halves, two cars and two spawners, drains fuel
/// while playing, and maps [GameState] transitions to engine pause/resume.
class CarsDriveGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  CarsDriveGame({required this.gameCubit});

  final GameCubit gameCubit;

  late CarComponent _leftCar;
  late CarComponent _rightCar;
  late RoadComponent _leftRoad;
  late RoadComponent _rightRoad;
  late ObstacleSpawnerComponent _leftSpawner;
  late ObstacleSpawnerComponent _rightSpawner;
  late TapInputHandler _tapHandler;

  late double _halfW;
  late double _halfH;

  @override
  Color backgroundColor() => GameConstants.asphalt;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _halfW = size.x / 2;
    _halfH = size.y;

    await _buildWorld();

    gameCubit.stream.listen(_onGameStateChanged);
    pauseEngine();
  }

  Future<void> _buildWorld() async {
    _leftRoad = RoadComponent(
      isLeftSide: true,
      topColor: const Color(0xFF2E1A3A),
      laneColor: GameConstants.laneWhite,
    )
      ..position = Vector2.zero()
      ..size = Vector2(_halfW, _halfH);

    _rightRoad = RoadComponent(
      isLeftSide: false,
      topColor: const Color(0xFF371B31),
      laneColor: GameConstants.laneWhite,
    )
      ..position = Vector2(_halfW, 0)
      ..size = Vector2(_halfW, _halfH);

    _leftCar = CarComponent(
      entity: const CarEntity(side: CarSide.left, lane: CarLane.inner),
      bodyColor: const Color(0xFFF2E9E4),
      accentColor: GameConstants.accentRed,
      halfWidth: _halfW,
      halfHeight: _halfH,
    );

    _rightCar = CarComponent(
      entity: const CarEntity(side: CarSide.right, lane: CarLane.inner),
      bodyColor: const Color(0xFFE23A3A),
      accentColor: const Color(0xFFF2E9E4),
      halfWidth: _halfW,
      halfHeight: _halfH,
    );

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

    final divider = _CentreDivider();

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

  @override
  void update(double dt) {
    super.update(dt);

    // Fuel only burns while the run is live (the engine is paused otherwise).
    final state = gameCubit.state;
    if (state is GamePlaying) {
      gameCubit.consumeFuel(GameConstants.fuelDrainPerSecond * dt);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (gameCubit.state is! GamePlaying) return;
    _tapHandler.handleTap(event);
  }

  void _onGameStateChanged(GameState state) {
    switch (state) {
      case GamePlaying():
        resumeEngine();
        overlays.remove(GameConstants.overlayPause);
        overlays.remove(GameConstants.overlayGameOver);
        overlays.remove(GameConstants.overlayMainMenu);
        if (!overlays.isActive(GameConstants.overlayHud)) {
          overlays.add(GameConstants.overlayHud);
        }
      case GamePaused():
        pauseEngine();
        overlays.add(GameConstants.overlayPause);
      case GameOver():
        pauseEngine();
        overlays.remove(GameConstants.overlayHud);
        overlays.remove(GameConstants.overlayPause);
        overlays.add(GameConstants.overlayGameOver);
      case GameInitial():
        pauseEngine();
        overlays.remove(GameConstants.overlayHud);
        overlays.remove(GameConstants.overlayPause);
        overlays.remove(GameConstants.overlayGameOver);
        if (!overlays.isActive(GameConstants.overlayMainMenu)) {
          overlays.add(GameConstants.overlayMainMenu);
        }
    }
  }

  /// Rebuilds the world for a fresh run (called by the overlays).
  void resetGame() {
    _leftCar.reset();
    _rightCar.reset();
    _leftRoad.reset();
    _rightRoad.reset();
    _leftSpawner.reset();
    _rightSpawner.reset();

    _leftRoad.removeWhere((c) => c is ObstacleComponent);
    _rightRoad.removeWhere((c) => c is ObstacleComponent);
  }
}

/// Concrete median with painted edges, separating the two carriageways.
class _CentreDivider extends PositionComponent {
  _CentreDivider() : super(size: Vector2(12, 0));

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = Vector2(12, gameSize.y);
    position = Vector2(gameSize.x / 2 - 6, 0);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = GameConstants.divider,
    );
    final edge = Paint()
      ..color = GameConstants.laneWhite.withValues(alpha: 0.65)
      ..strokeWidth = 2;
    canvas.drawLine(const Offset(1, 0), Offset(1, size.y), edge);
    canvas.drawLine(
      Offset(size.x - 1, 0),
      Offset(size.x - 1, size.y),
      edge,
    );
    canvas.drawLine(
      Offset(size.x / 2, 0),
      Offset(size.x / 2, size.y),
      Paint()
        ..color = GameConstants.laneAmber.withValues(alpha: 0.35)
        ..strokeWidth = 2,
    );
  }
}
