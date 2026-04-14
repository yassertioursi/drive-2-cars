import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/constants/game_constants.dart';
import '../../domain/entities/obstacle_entity.dart';
import '../../presentation/cubits/game_cubit.dart';
import 'car_component.dart';

/// A single falling obstacle (circle = points, square = game-over).
///
/// Mixes in [CollisionCallbacks] so Flame's collision system can notify it
/// when it overlaps with a [CarComponent].
///
/// The component removes itself when it exits the bottom of its half-screen.
class ObstacleComponent extends PositionComponent with CollisionCallbacks {
  ObstacleComponent({
    required this.entity,
    required this.gameCubit,
    required this.halfHeight,
  }) : super(anchor: Anchor.center);

  final ObstacleEntity entity;
  final GameCubit gameCubit;
  final double halfHeight;

  /// Guards against triggering the cubit multiple times per collision.
  bool _hasCollided = false;

  // ── Colours ───────────────────────────────────────────────────────────────
  static const _circleColor = Color(0xFFAAFF00); // lime — collectable
  static const _squareColor = Color(0xFFFF0080); // hot-pink — danger

  Color get _color =>
      entity.type == ObstacleType.circle ? _circleColor : _squareColor;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add the appropriate hitbox shape.
    if (entity.type == ObstacleType.circle) {
      final r = GameConstants.circleRadius;
      size = Vector2(r * 2, r * 2);
      add(CircleHitbox(radius: r, anchor: Anchor.center));
    } else {
      final s = GameConstants.squareHalfSize * 2;
      size = Vector2(s, s);
      add(RectangleHitbox(size: Vector2.all(s), anchor: Anchor.center));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Move downward.
    y += entity.speed * dt;

    // Despawn once past the bottom of the half-screen.
    if (y > halfHeight + 60) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final glowPaint = Paint()
      ..color = _color.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final fillPaint = Paint()..color = _color.withValues(alpha: 0.85);
    final rimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    if (entity.type == ObstacleType.circle) {
      final r = GameConstants.circleRadius;
      // Glow
      canvas.drawCircle(Offset.zero, r + 6, glowPaint);
      // Fill
      canvas.drawCircle(Offset.zero, r, fillPaint);
      // Rim
      canvas.drawCircle(Offset.zero, r, rimPaint);
      // Inner highlight
      canvas.drawCircle(
        const Offset(-4, -4),
        r * 0.3,
        Paint()..color = Colors.white.withValues(alpha: 0.35),
      );
    } else {
      final s = GameConstants.squareHalfSize;
      final rect = Rect.fromCenter(center: Offset.zero, width: s * 2, height: s * 2);
      // Glow
      canvas.drawRect(
        rect.inflate(6),
        glowPaint,
      );
      // Fill
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        fillPaint,
      );
      // Rim
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        rimPaint,
      );
      // Danger X mark
      final xPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..strokeWidth = 2.5;
      canvas.drawLine(Offset(-s * 0.4, -s * 0.4), Offset(s * 0.4, s * 0.4), xPaint);
      canvas.drawLine(Offset(s * 0.4, -s * 0.4), Offset(-s * 0.4, s * 0.4), xPaint);
    }
  }

  // ── Collision handling ────────────────────────────────────────────────────

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    // Only react to car collisions and only once per obstacle.
    if (_hasCollided || other is! CarComponent) return;
    _hasCollided = true;

    if (entity.type == ObstacleType.circle) {
      gameCubit.incrementScore();
      removeFromParent();
    } else {
      gameCubit.triggerGameOver();
    }
  }
}
