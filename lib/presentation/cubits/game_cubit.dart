import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/use_cases/get_high_score_use_case.dart';
import '../../domain/use_cases/save_high_score_use_case.dart';
import 'game_state.dart';

/// Cubit that drives all game-status transitions.
///
/// The Flame game layer calls the mutating methods ([startGame],
/// [incrementScore], [triggerGameOver]) in response to game events.
/// Flutter overlay widgets listen to the emitted [GameState] stream.
class GameCubit extends Cubit<GameState> {
  GameCubit({
    required GetHighScoreUseCase getHighScore,
    required SaveHighScoreUseCase saveHighScore,
  })  : _getHighScore = getHighScore,
        _saveHighScore = saveHighScore,
        super(const GameInitial());

  final GetHighScoreUseCase _getHighScore;
  final SaveHighScoreUseCase _saveHighScore;

  // ── Public API called by the Flame game ───────────────────────────────────

  /// Transitions to [GamePlaying] and loads the stored high score.
  Future<void> startGame() async {
    final highScore = await _getHighScore();
    emit(GamePlaying(score: 0, highScore: highScore));
  }

  /// Transitions to [GamePaused], preserving the current score.
  void pauseGame() {
    final current = state;
    if (current is GamePlaying) {
      emit(GamePaused(score: current.score, highScore: current.highScore));
    }
  }

  /// Resumes from [GamePaused] back to [GamePlaying].
  void resumeGame() {
    final current = state;
    if (current is GamePaused) {
      emit(GamePlaying(score: current.score, highScore: current.highScore));
    }
  }

  /// Called each time the player collects a circle obstacle (+1 point).
  void incrementScore() {
    final current = state;
    if (current is GamePlaying) {
      emit(current.withIncrementedScore());
    }
  }

  /// Called when the car hits a square obstacle.
  ///
  /// Compares [finalScore] to the stored high score, saves if it's a new
  /// record, then emits [GameOver].
  Future<void> triggerGameOver() async {
    final current = state;
    if (current is! GamePlaying) return;

    final finalScore = current.score;
    var highScore = current.highScore;

    if (finalScore > highScore) {
      highScore = finalScore;
      await _saveHighScore(finalScore);
    }

    emit(GameOver(finalScore: finalScore, highScore: highScore));
  }
}
