/// Game-wide constants and the Cars Drive colour palette.
library;

import 'package:flutter/material.dart';

class GameConstants {
  GameConstants._();

  // ── Car ───────────────────────────────────────────────────────────────────
  static const double carWidth = 42.0;
  static const double carHeight = 74.0;
  static const double laneSwitchDuration = 0.16;
  static const double carBottomOffsetNorm = 0.16;

  // ── Obstacles ─────────────────────────────────────────────────────────────
  static const double fuelWidth = 26.0;
  static const double fuelHeight = 30.0;
  static const double coneWidth = 30.0;
  static const double coneHeight = 34.0;

  static const double obstacleBaseSpeed = 300.0;
  static const double obstacleMaxSpeed = 780.0;
  static const double speedIncreasePerPoint = 3.2;

  // ── Spawner ───────────────────────────────────────────────────────────────
  static const double spawnIntervalBase = 1.5;
  static const double spawnIntervalMin = 0.60;
  static const double spawnIntervalDecreasePerPoint = 0.011;

  // ── Fuel mechanic (new) ───────────────────────────────────────────────────
  /// Tank capacity.
  static const double maxFuel = 100.0;

  /// Fuel burned per second while driving.
  static const double fuelDrainPerSecond = 4.0;

  /// Fuel restored by one can.
  static const double fuelPickupAmount = 14.0;

  /// Probability that a spawned obstacle is a fuel can.
  static const double fuelPickupChance = 0.45;

  // ── Road ──────────────────────────────────────────────────────────────────
  static const int laneDashCount = 10;
  static const double laneDashHeight = 30.0;
  static const double laneDashGap = 26.0;

  // ── Scoring ───────────────────────────────────────────────────────────────
  static const int fuelPoints = 1;

  // ── Overlay keys ──────────────────────────────────────────────────────────
  static const String overlayMainMenu = 'mainMenu';
  static const String overlayHud = 'hud';
  static const String overlayPause = 'pause';
  static const String overlayGameOver = 'gameOver';

  // ── Palette: dusk motorway ────────────────────────────────────────────────
  static const Color duskTop = Color(0xFF3A1B44);
  static const Color duskBottom = Color(0xFF120D16);
  static const Color asphalt = Color(0xFF120D16);
  static const Color laneWhite = Color(0xFFF6E7D8);
  static const Color laneAmber = Color(0xFFFFB347);
  static const Color accentRed = Color(0xFFFF4D4D);
  static const Color accentAmber = Color(0xFFFFC24D);
  static const Color fuelColor = Color(0xFFFFC24D);
  static const Color coneColor = Color(0xFFFF7A2F);
  static const Color divider = Color(0xFF241A2B);
}
