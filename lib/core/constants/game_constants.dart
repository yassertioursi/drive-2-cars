/// Game-wide constants used across all layers.
///
/// Centralising magic numbers here makes tuning easy and keeps
/// the rest of the codebase free of hard-coded values.
library;

class GameConstants {
  GameConstants._();

  // ── Screen layout ─────────────────────────────────────────────────────────
  /// Normalised X position of the inner lane (closer to the centre divider).
  static const double innerLaneNormX = 0.30;

  /// Normalised X position of the outer lane (closer to the screen edge).
  static const double outerLaneNormX = 0.70;

  // ── Car ───────────────────────────────────────────────────────────────────
  /// Width of each car in logical pixels.
  static const double carWidth = 44.0;

  /// Height of each car in logical pixels.
  static const double carHeight = 72.0;

  /// Duration (seconds) for the lane-switch animation.
  static const double laneSwitchDuration = 0.18;

  /// Car Y position from the bottom of each half-screen (normalised 0–1).
  static const double carBottomOffsetNorm = 0.18;

  // ── Obstacle ──────────────────────────────────────────────────────────────
  /// Radius of a circle (collectable) obstacle.
  static const double circleRadius = 16.0;

  /// Half-size of a square (danger) obstacle.
  static const double squareHalfSize = 18.0;

  /// Base fall speed of obstacles in pixels per second.
  static const double obstacleBaseSpeed = 320.0;

  /// Maximum fall speed cap.
  static const double obstacleMaxSpeed = 800.0;

  /// How much speed increases per point scored.
  static const double speedIncreasePerPoint = 3.5;

  // ── Spawner ───────────────────────────────────────────────────────────────
  /// Base spawn interval in seconds.
  static const double spawnIntervalBase = 1.6;

  /// Minimum spawn interval (fastest difficulty).
  static const double spawnIntervalMin = 0.55;

  /// Reduction in spawn interval per point scored.
  static const double spawnIntervalDecreasePerPoint = 0.012;

  // ── Road rendering ────────────────────────────────────────────────────────
  /// Number of dashed lane-divider segments visible at once.
  static const int laneDashCount = 10;

  /// Height of each dash segment in pixels.
  static const double laneDashHeight = 28.0;

  /// Gap between dash segments in pixels.
  static const double laneDashGap = 22.0;

  // ── Scoring ───────────────────────────────────────────────────────────────
  /// Points awarded for collecting a circle obstacle.
  static const int circlePoints = 1;

  // ── Overlay keys ─────────────────────────────────────────────────────────
  static const String overlayMainMenu = 'mainMenu';
  static const String overlayHud = 'hud';
  static const String overlayGameOver = 'gameOver';
}
