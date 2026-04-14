import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/constants/game_constants.dart';

/// Renders one scrolling road half (left or right side of the screen).
///
/// The "road" is drawn procedurally:
///   • Dark asphalt rectangle as background.
///   • Two neon lane lines running vertically.
///   • Dashed centre divider animating downward to simulate speed.
///
/// No external image assets are required.
class RoadComponent extends PositionComponent {
  RoadComponent({
    required this.isLeftSide,
    required this.roadColor,
    required this.laneColor,
  });

  /// Whether this road occupies the left half of the screen.
  final bool isLeftSide;

  /// Main tint colour for the lane lines (cyan for left, amber for right).
  final Color laneColor;

  /// Asphalt background colour.
  final Color roadColor;

  /// Current scroll offset for the dash animation (pixels, wraps).
  double _dashOffset = 0;

  /// Current road scroll speed — updated each frame from the spawner.
  double scrollSpeed = GameConstants.obstacleBaseSpeed * 0.4;

  void reset() {
    _dashOffset = 0;
    scrollSpeed = GameConstants.obstacleBaseSpeed * 0.4;
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Advance the dash offset so the lines appear to scroll downward.
    _dashOffset = (_dashOffset + scrollSpeed * dt) %
        (GameConstants.laneDashHeight + GameConstants.laneDashGap);
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    // ── Asphalt background ─────────────────────────────────────────────────
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = roadColor,
    );

    // ── Edge glow line (outer) ─────────────────────────────────────────────
    final glowPaint = Paint()
      ..color = laneColor.withValues(alpha: 0.25)
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final solidPaint = Paint()
      ..color = laneColor.withValues(alpha: 0.7)
      ..strokeWidth = 2;

    // Left road: glow on right edge; Right road: glow on left edge.
    final edgeX = isLeftSide ? w - 1.0 : 1.0;
    canvas.drawLine(Offset(edgeX, 0), Offset(edgeX, h), glowPaint);
    canvas.drawLine(Offset(edgeX, 0), Offset(edgeX, h), solidPaint);

    // ── Dashed centre line ─────────────────────────────────────────────────
    final dashPaint = Paint()
      ..color = laneColor.withValues(alpha: 0.45)
      ..strokeWidth = 3;

    final centreX = w / 2;
    final dashTotal = GameConstants.laneDashHeight + GameConstants.laneDashGap;
    final startY = _dashOffset - dashTotal;
    final count = (h / dashTotal).ceil() + 2;

    for (var i = 0; i < count; i++) {
      final top = startY + i * dashTotal;
      canvas.drawLine(
        Offset(centreX, top),
        Offset(centreX, top + GameConstants.laneDashHeight),
        dashPaint,
      );
    }

    // ── Speed lines (subtle motion blur effect) ────────────────────────────
    final rng = math.Random(42);
    final speedPaint = Paint()
      ..color = laneColor.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    for (var i = 0; i < 6; i++) {
      final sx = rng.nextDouble() * w;
      final lineH = 60 + rng.nextDouble() * 120;
      final sy = (_dashOffset * 2.3 + i * (h / 6)) % h;
      canvas.drawLine(Offset(sx, sy), Offset(sx, sy + lineH), speedPaint);
    }
  }
}
