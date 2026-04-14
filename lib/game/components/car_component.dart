import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../../core/constants/game_constants.dart';
import '../../domain/entities/car_entity.dart';

/// Renders a single car as a neon-styled shape and handles lane switching.
///
/// The car is drawn procedurally (body, windscreen, wheels) — no sprites needed.
/// Lane switches are animated with a [MoveToEffect] for smooth sliding.
class CarComponent extends PositionComponent {
  CarComponent({
    required this.entity,
    required this.carColor,
    required this.halfWidth,
    required this.halfHeight,
  }) : super(
          size: Vector2(GameConstants.carWidth, GameConstants.carHeight),
          anchor: Anchor.center,
        );

  /// Domain entity driving lane state (updated by [toggleLane]).
  CarEntity entity;

  /// The neon colour of this car.
  final Color carColor;

  /// Width of the half-screen this car operates on.
  final double halfWidth;

  /// Height of the half-screen.
  final double halfHeight;

  // ── Lane X positions (local to the half-screen) ───────────────────────────
  double get _currentLaneX {
    final isLeft = entity.side == CarSide.left;
    final isInner = entity.lane == CarLane.inner;
    final normX = isLeft ? (isInner ? 0.75 : 0.25) : (isInner ? 0.25 : 0.75);
    final relativeX = halfWidth * normX;
    return isLeft ? relativeX : halfWidth + relativeX;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
    // Start in the correct lane immediately (no animation on first load).
    x = _currentLaneX;
    y = halfHeight * (1 - GameConstants.carBottomOffsetNorm);
  }

  /// Toggles the car's domain entity lane and animates the component to the
  /// new X position.
  void toggleLane() {
    entity = entity.toggleLane();
    // Remove any in-progress move before starting a new one.
    removeWhere((c) => c is MoveToEffect);
    add(
      MoveToEffect(
        Vector2(_currentLaneX, y),
        EffectController(duration: GameConstants.laneSwitchDuration),
      ),
    );
  }

  /// Resets the car to the inner lane immediately for a new game.
  void reset() {
    entity = CarEntity(side: entity.side, lane: CarLane.inner);
    removeWhere((c) => c is MoveToEffect);
    x = _currentLaneX;
    y = halfHeight * (1 - GameConstants.carBottomOffsetNorm);
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    final bodyPaint = Paint()..color = carColor.withValues(alpha: 0.9);
    final glowPaint = Paint()
      ..color = carColor.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    final darkPaint = Paint()..color = const Color(0xFF0D0D1A);
    final windowPaint = Paint()
      ..color = carColor.withValues(alpha: 0.25);

    // ── Glow halo ─────────────────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-4, -4, w + 8, h + 8),
        const Radius.circular(10),
      ),
      glowPaint,
    );

    // ── Car body ──────────────────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        const Radius.circular(8),
      ),
      bodyPaint,
    );

    // ── Windscreen ────────────────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h * 0.08, w * 0.76, h * 0.28),
        const Radius.circular(4),
      ),
      windowPaint,
    );

    // ── Rear window ───────────────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.18, h * 0.66, w * 0.64, h * 0.20),
        const Radius.circular(4),
      ),
      windowPaint,
    );

    // ── Wheels (4 squares) ────────────────────────────────────────────────
    final wheelPaint = Paint()..color = darkPaint.color;
    const ww = 10.0;
    const wh = 16.0;
    for (final (wx, wy) in [
      (-ww * 0.6, h * 0.1),
      (w - ww * 0.4, h * 0.1),
      (-ww * 0.6, h * 0.72),
      (w - ww * 0.4, h * 0.72),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(wx, wy, ww, wh),
          const Radius.circular(3),
        ),
        wheelPaint,
      );
    }

    // ── Headlights ────────────────────────────────────────────────────────
    final lightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(w * 0.22, h * 0.04), 4, lightPaint);
    canvas.drawCircle(Offset(w * 0.78, h * 0.04), 4, lightPaint);
  }
}
