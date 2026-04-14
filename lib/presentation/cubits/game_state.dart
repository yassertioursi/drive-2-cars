import 'package:equatable/equatable.dart';

/// The complete set of states the game can be in.
///
/// Uses Dart 3 sealed classes so the UI can exhaustively pattern-match
/// every state without a default branch.
sealed class GameState extends Equatable {
  const GameState();
}

/// Initial state before the player has started their first game.
final class GameInitial extends GameState {
  const GameInitial();

  @override
  List<Object?> get props => [];
}

/// The game is actively running.
final class GamePlaying extends GameState {
  const GamePlaying({required this.score, required this.highScore});

  /// Current score in this run.
  final int score;

  /// All-time high score (for the HUD).
  final int highScore;

  /// Returns a copy with an incremented [score].
  GamePlaying withIncrementedScore() =>
      GamePlaying(score: score + 1, highScore: highScore);

  @override
  List<Object?> get props => [score, highScore];
}

/// The game is paused (e.g. app backgrounded).
final class GamePaused extends GameState {
  const GamePaused({required this.score, required this.highScore});

  final int score;
  final int highScore;

  @override
  List<Object?> get props => [score, highScore];
}

/// A square obstacle was hit — the game has ended.
final class GameOver extends GameState {
  const GameOver({required this.finalScore, required this.highScore});

  /// Score at the time of collision.
  final int finalScore;

  /// Updated high score (may equal [finalScore] if it's a new record).
  final int highScore;

  @override
  List<Object?> get props => [finalScore, highScore];
}
