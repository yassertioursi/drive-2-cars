import 'dart:math' as math;

import 'package:flame/components.dart';

import '../../core/constants/game_constants.dart';
import '../../domain/entities/obstacle_entity.dart';
import '../../presentation/cubits/game_cubit.dart';
import '../../presentation/cubits/game_state.dart';
import 'obstacle_component.dart';

/// Periodically spawns [ObstacleComponent]s on one half of the screen.
///
/// Spawn interval and obstacle speed both increase with the player's score,
/// creating a natural difficulty ramp without external difficulty states.
class ObstacleSpawnerComponent extends Component with HasGameReference {
  ObstacleSpawnerComponent({
    required this.gameCubit,
    required this.halfWidth,
    required this.halfHeight,
    required this.isLeftSide,
    required this.parentComponent,
  });

  final GameCubit gameCubit;

  /// Width of one half-screen in logical pixels.
  final double halfWidth;

  /// Height of one full screen (= height of this half).
  final double halfHeight;

  /// Whether this spawner is for the left side.
  final bool isLeftSide;

  /// The PositionComponent that owns this spawner (obstacles are added to it).
  final PositionComponent parentComponent;

  final _rng = math.Random();
  double _elapsed = 0;

  /// Current spawn interval — shrinks as score grows.
  double get _spawnInterval {
    final score = _currentScore;
    final interval = GameConstants.spawnIntervalBase -
        score * GameConstants.spawnIntervalDecreasePerPoint;
    return interval.clamp(
      GameConstants.spawnIntervalMin,
      GameConstants.spawnIntervalBase,
    );
  }

  /// Current obstacle fall speed — grows as score grows.
  double get _obstacleSpeed {
    final score = _currentScore;
    final speed = GameConstants.obstacleBaseSpeed +
        score * GameConstants.speedIncreasePerPoint;
    return speed.clamp(
      GameConstants.obstacleBaseSpeed,
      GameConstants.obstacleMaxSpeed,
    );
  }

  int get _currentScore {
    final state = gameCubit.state;
    if (state is GamePlaying) return state.score;
    return 0;
  }

  void reset() {
    _elapsed = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Only spawn during active gameplay.
    if (gameCubit.state is! GamePlaying) return;

    _elapsed += dt;
    if (_elapsed >= _spawnInterval) {
      _elapsed = 0;
      _spawnObstacle();
    }
  }

  void _spawnObstacle() {
    // Randomly choose inner or outer lane.
    final useInner = _rng.nextBool();
    final normX = isLeftSide
        ? (useInner ? 0.75 : 0.25)
        : (useInner ? 0.25 : 0.75);

    // 30% chance of spawning a square (danger), 70% circle (points).
    final type = _rng.nextDouble() < 0.30
        ? ObstacleType.square
        : ObstacleType.circle;

    final entity = ObstacleEntity(
      type: type,
      laneNormX: normX,
      yPosition: -40,
      speed: _obstacleSpeed,
    );

    final obstacle = ObstacleComponent(
      entity: entity,
      gameCubit: gameCubit,
      halfHeight: halfHeight,
    )
      ..x = halfWidth * normX
      ..y = -40;

    parentComponent.add(obstacle);
  }
}
