import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/constants/game_constants.dart';
import '../../domain/entities/obstacle_entity.dart';
import '../../presentation/cubits/game_cubit.dart';
import '../../presentation/cubits/game_state.dart';
import 'car_component.dart';

/// A single falling object: an amber fuel can (pickup) or a traffic cone (hazard).
class ObstacleComponent extends PositionComponent with CollisionCallbacks {
  ObstacleComponent({
    required this.entity,
    required this.gameCubit,
    required this.halfHeight,
  }) : super(anchor: Anchor.center);

  final ObstacleEntity entity;
  final GameCubit gameCubit;
  final double halfHeight;

  bool _hasCollided = false;

  bool get _isFuel => entity.type == ObstacleType.fuel;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    if (_isFuel) {
      size = Vector2(GameConstants.fuelWidth, GameConstants.fuelHeight);
      add(CircleHitbox(radius: 14, anchor: Anchor.center));
    } else {
      size = Vector2(GameConstants.coneWidth, GameConstants.coneHeight);
      add(RectangleHitbox(
        size: Vector2(GameConstants.coneWidth * 0.7, GameConstants.coneHeight * 0.55),
        anchor: Anchor.center,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    y += entity.speed * dt;
    if (y > halfHeight + 60) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (_isFuel) {
      _renderFuelCan(canvas);
    } else {
      _renderCone(canvas);
    }
  }

  // ── Fuel can ────────────────────────────────────────────────────────────

  void _renderFuelCan(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    final rect = Rect.fromLTWH(0, 0, w, h);

    canvas.drawCircle(
      Offset(w / 2, h / 2),
      w * 0.72,
      Paint()
        ..color = GameConstants.fuelColor.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Cap
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.36, 0, w * 0.28, 7),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF8A5A12),
    );

    // Handle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.22, 3, w * 0.56, 8),
        const Radius.circular(4),
      ),
      Paint()
        ..color = const Color(0xFF8A5A12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Body
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 7, w - 2, h - 9),
      const Radius.circular(5),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GameConstants.fuelColor,
            GameConstants.fuelColor.withValues(alpha: 0.75),
          ],
        ).createShader(rect),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );

    // Lightning bolt
    final bolt = Path()
      ..moveTo(w * 0.56, h * 0.30)
      ..lineTo(w * 0.36, h * 0.55)
      ..lineTo(w * 0.49, h * 0.55)
      ..lineTo(w * 0.43, h * 0.78)
      ..lineTo(w * 0.65, h * 0.50)
      ..lineTo(w * 0.51, h * 0.50)
      ..close();
    canvas.drawPath(bolt, Paint()..color = const Color(0xFF241A2B));
  }

  // ── Traffic cone ────────────────────────────────────────────────────────

  void _renderCone(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    // Base
    canvas.drawOval(
      Rect.fromLTWH(-2, h * 0.84, w + 4, h * 0.16),
      Paint()..color = const Color(0xFF241A2B),
    );
    canvas.drawOval(
      Rect.fromLTWH(-2, h * 0.84, w + 4, h * 0.16),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final body = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w * 0.96, h * 0.87)
      ..lineTo(w * 0.04, h * 0.87)
      ..close();

    canvas.drawPath(
      body,
      Paint()
        ..color = GameConstants.coneColor.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            GameConstants.coneColor.withValues(alpha: 0.98),
            GameConstants.coneColor.withValues(alpha: 0.72),
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
    canvas.drawPath(
      body,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Reflective white band
    double halfWidthAt(double y) => (y / (h * 0.87)) * (w / 2);
    final y1 = h * 0.50;
    final y2 = h * 0.64;
    final band = Path()
      ..moveTo(w / 2 - halfWidthAt(y1), y1)
      ..lineTo(w / 2 + halfWidthAt(y1), y1)
      ..lineTo(w / 2 + halfWidthAt(y2), y2)
      ..lineTo(w / 2 - halfWidthAt(y2), y2)
      ..close();
    canvas.drawPath(
      band,
      Paint()..color = GameConstants.laneWhite.withValues(alpha: 0.9),
    );
  }

  // ── Collision handling ──────────────────────────────────────────────────

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (_hasCollided || gameCubit.state is! GamePlaying) return;
    if (other is! CarComponent) return;
    _hasCollided = true;

    if (_isFuel) {
      gameCubit.incrementScore();
      removeFromParent();
    } else {
      gameCubit.triggerGameOver(reason: GameOverReason.crash);
    }
  }
}
