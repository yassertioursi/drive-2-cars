import 'package:equatable/equatable.dart';

import '../../core/constants/game_constants.dart';

/// The complete set of states the game can be in.
sealed class GameState extends Equatable {
  const GameState();
}

/// Initial state before the player has started their first run.
final class GameInitial extends GameState {
  const GameInitial();

  @override
  List<Object?> get props => [];
}

/// A run is in progress.
final class GamePlaying extends GameState {
  const GamePlaying({
    required this.score,
    required this.highScore,
    required this.fuel,
  });

  /// Current score in this run.
  final int score;

  /// All-time best score (shown in the HUD).
  final int highScore;

  /// Remaining fuel, 0–100.
  final double fuel;

  /// Collecting a fuel can: +1 point and a partial refill.
  GamePlaying withIncrementedScore() => GamePlaying(
        score: score + 1,
        highScore: highScore,
        fuel: (fuel + GameConstants.fuelPickupAmount)
            .clamp(0.0, GameConstants.maxFuel)
            .toDouble(),
      );

  /// Returns a copy with [fuel] clamped to the tank range.
  GamePlaying withFuel(double value) => GamePlaying(
        score: score,
        highScore: highScore,
        fuel: value.clamp(0.0, GameConstants.maxFuel).toDouble(),
      );

  @override
  List<Object?> get props => [score, highScore, fuel];
}

/// A run is paused (pause button or app lifecycle).
final class GamePaused extends GameState {
  const GamePaused({
    required this.score,
    required this.highScore,
    required this.fuel,
  });

  final int score;
  final int highScore;
  final double fuel;

  @override
  List<Object?> get props => [score, highScore, fuel];
}

/// Why the run ended.
enum GameOverReason { crash, outOfFuel }

/// The run has ended — a cone was hit or the tank ran dry.
final class GameOver extends GameState {
  const GameOver({
    required this.finalScore,
    required this.highScore,
    required this.reason,
  });

  /// Score at the time the run ended.
  final int finalScore;

  /// Updated best score (may equal [finalScore] on a new record).
  final int highScore;

  /// What ended the run.
  final GameOverReason reason;

  @override
  List<Object?> get props => [finalScore, highScore, reason];
}
