import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/constants/game_constants.dart';

/// One half of the dusk motorway.
///
/// Renders a vertical dusk gradient with a warm horizon glow, painted edge
/// lines, scrolling centre dashes and amber lane reflectors. All procedural —
/// no image assets.
class RoadComponent extends PositionComponent {
  RoadComponent({
    required this.isLeftSide,
    required this.topColor,
    required this.laneColor,
  });

  final bool isLeftSide;
  final Color topColor;
  final Color laneColor;

  double _dashOffset = 0;
  double scrollSpeed = GameConstants.obstacleBaseSpeed * 0.3;

  void reset() {
    _dashOffset = 0;
    scrollSpeed = GameConstants.obstacleBaseSpeed * 0.3;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _dashOffset = (_dashOffset + scrollSpeed * dt) %
        (GameConstants.laneDashHeight + GameConstants.laneDashGap);
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    final rect = Rect.fromLTWH(0, 0, w, h);

    // ── Dusk asphalt gradient ─────────────────────────────────────────────
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topColor, GameConstants.asphalt],
          stops: const [0, 0.85],
        ).createShader(rect),
    );

    // ── Warm horizon glow ─────────────────────────────────────────────────
    final glowRect = Rect.fromLTWH(0, 0, w, h * 0.24);
    canvas.drawRect(
      glowRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            GameConstants.laneAmber.withValues(alpha: 0.18),
            Colors.transparent,
          ],
        ).createShader(glowRect),
    );

    // ── Painted edge line (outer edge of the screen) ──────────────────────
    final edgeX = isLeftSide ? w - 3.0 : 3.0;
    canvas.drawLine(
      Offset(edgeX, 0),
      Offset(edgeX, h),
      Paint()
        ..color = GameConstants.laneWhite.withValues(alpha: 0.10)
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawLine(
      Offset(edgeX, 0),
      Offset(edgeX, h),
      Paint()
        ..color = GameConstants.laneWhite.withValues(alpha: 0.55)
        ..strokeWidth = 3,
    );

    // ── Centre dashes inside this half ────────────────────────────────────
    final dashPaint = Paint()
      ..color = laneColor.withValues(alpha: 0.55)
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

    // ── Amber lane reflectors (scroll to sell speed) ──────────────────────
    final reflector = Paint()
      ..color = GameConstants.laneAmber.withValues(alpha: 0.85)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    const spacing = 84.0;
    final offset = _dashOffset * 1.7 % spacing;
    for (var y = -spacing + offset; y < h + spacing; y += spacing) {
      for (final x in [9.0, w - 9.0]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x - 1.5, y, 3, 12),
            const Radius.circular(1.5),
          ),
          reflector,
        );
      }
    }

    // ── Faint asphalt streaks ─────────────────────────────────────────────
    final streak = Paint()..color = Colors.white.withValues(alpha: 0.025);
    for (var i = 0; i < 4; i++) {
      final y = (i * h / 4 + _dashOffset) % h;
      canvas.drawRect(Rect.fromLTWH(w * 0.12, y, w * 0.06, 40), streak);
      canvas.drawRect(Rect.fromLTWH(w * 0.78, y, w * 0.06, 40), streak);
    }
  }
}
