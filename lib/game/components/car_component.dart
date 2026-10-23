import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../../core/constants/game_constants.dart';
import '../../domain/entities/car_entity.dart';

/// A top-down race car, drawn procedurally (body, stripe, spoiler, lights).
///
/// Lane switches slide the car across its half of the road with a short
/// [MoveToEffect] tween.
class CarComponent extends PositionComponent {
  CarComponent({
    required this.entity,
    required this.bodyColor,
    required this.accentColor,
    required this.halfWidth,
    required this.halfHeight,
  }) : super(
          size: Vector2(GameConstants.carWidth, GameConstants.carHeight),
          anchor: Anchor.center,
        );

  CarEntity entity;
  final Color bodyColor;
  final Color accentColor;
  final double halfWidth;
  final double halfHeight;

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
    x = _currentLaneX;
    y = halfHeight * (1 - GameConstants.carBottomOffsetNorm);
  }

  void toggleLane() {
    entity = entity.toggleLane();
    removeWhere((c) => c is MoveToEffect);
    add(
      MoveToEffect(
        Vector2(_currentLaneX, y),
        EffectController(duration: GameConstants.laneSwitchDuration),
      ),
    );
  }

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

    // ── Accent glow halo ──────────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-5, -5, w + 10, h + 10),
        const Radius.circular(12),
      ),
      Paint()
        ..color = accentColor.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // ── Body ──────────────────────────────────────────────────────────────
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(11),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bodyColor, bodyColor.withValues(alpha: 0.82)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..color = accentColor.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // ── Racing stripe ─────────────────────────────────────────────────────
    canvas.drawRect(
      Rect.fromLTWH(w * 0.43, 0, w * 0.14, h),
      Paint()..color = accentColor.withValues(alpha: 0.9),
    );

    // ── Windscreen ────────────────────────────────────────────────────────
    final glass = Path()
      ..moveTo(w * 0.24, h * 0.15)
      ..lineTo(w * 0.76, h * 0.15)
      ..lineTo(w * 0.66, h * 0.34)
      ..lineTo(w * 0.34, h * 0.34)
      ..close();
    canvas.drawPath(glass, Paint()..color = const Color(0xFF1A1220));
    canvas.drawPath(
      glass,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // ── Rear window ───────────────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.28, h * 0.56, w * 0.44, h * 0.12),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF1A1220).withValues(alpha: 0.9),
    );

    // ── Side wheels ───────────────────────────────────────────────────────
    final wheel = Paint()..color = const Color(0xFF0B0810);
    for (final y in [h * 0.18, h * 0.66]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-2.5, y, 6, h * 0.16),
          const Radius.circular(2),
        ),
        wheel,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w - 3.5, y, 6, h * 0.16),
          const Radius.circular(2),
        ),
        wheel,
      );
    }

    // ── Rear spoiler ──────────────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-5, h - 7, w + 10, 6),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF1A1220),
    );
    canvas.drawLine(
      Offset(-4, h - 7),
      Offset(w + 4, h - 7),
      Paint()
        ..color = accentColor.withValues(alpha: 0.9)
        ..strokeWidth = 1.5,
    );

    // ── Tail lights ───────────────────────────────────────────────────────
    final tail = Paint()
      ..color = const Color(0xFFFF2D2D)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h - 13, w * 0.18, 4),
        const Radius.circular(2),
      ),
      tail,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.70, h - 13, w * 0.18, 4),
        const Radius.circular(2),
      ),
      tail,
    );

    // ── Headlights ────────────────────────────────────────────────────────
    final light = Paint()
      ..color = GameConstants.laneWhite
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.16, 1.5, w * 0.16, 3),
        const Radius.circular(1.5),
      ),
      light,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.68, 1.5, w * 0.16, 3),
        const Radius.circular(1.5),
      ),
      light,
    );
  }
}
