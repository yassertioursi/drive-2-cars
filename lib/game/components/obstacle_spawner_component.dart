import 'dart:math' as math;

import 'package:flame/components.dart';

import '../../core/constants/game_constants.dart';
import '../../domain/entities/obstacle_entity.dart';
import '../../presentation/cubits/game_cubit.dart';
import '../../presentation/cubits/game_state.dart';
import 'obstacle_component.dart';

/// Spawns fuel cans and traffic cones on one half of the road.
///
/// Spawn rate and fall speed ramp up with the score, so the fuel pressure
/// grows the longer a run lasts.
class ObstacleSpawnerComponent extends Component with HasGameReference {
  ObstacleSpawnerComponent({
    required this.gameCubit,
    required this.halfWidth,
    required this.halfHeight,
    required this.isLeftSide,
    required this.parentComponent,
  });

  final GameCubit gameCubit;
  final double halfWidth;
  final double halfHeight;
  final bool isLeftSide;
  final PositionComponent parentComponent;

  final _rng = math.Random();
  double _elapsed = 0;

  double get _spawnInterval {
    final interval = GameConstants.spawnIntervalBase -
        _currentScore * GameConstants.spawnIntervalDecreasePerPoint;
    return interval.clamp(
      GameConstants.spawnIntervalMin,
      GameConstants.spawnIntervalBase,
    );
  }

  double get _obstacleSpeed {
    final speed = GameConstants.obstacleBaseSpeed +
        _currentScore * GameConstants.speedIncreasePerPoint;
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

    if (gameCubit.state is! GamePlaying) return;

    _elapsed += dt;
    if (_elapsed >= _spawnInterval) {
      _elapsed = 0;
      _spawnObstacle();
    }
  }

  void _spawnObstacle() {
    final useInner = _rng.nextBool();
    final normX = isLeftSide
        ? (useInner ? 0.75 : 0.25)
        : (useInner ? 0.25 : 0.75);

    final type = _rng.nextDouble() < GameConstants.fuelPickupChance
        ? ObstacleType.fuel
        : ObstacleType.cone;

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
