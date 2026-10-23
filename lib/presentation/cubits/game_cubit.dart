import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/game_constants.dart';
import '../../domain/use_cases/get_high_score_use_case.dart';
import '../../domain/use_cases/save_high_score_use_case.dart';
import 'game_state.dart';

/// Cubit that drives every game-status transition.
///
/// The Flame layer reports events (fuel burn, pickups, crashes) and the
/// Flutter overlays listen to the emitted [GameState].
class GameCubit extends Cubit<GameState> {
  GameCubit({
    required GetHighScoreUseCase getHighScore,
    required SaveHighScoreUseCase saveHighScore,
  })  : _getHighScore = getHighScore,
        _saveHighScore = saveHighScore,
        super(const GameInitial());

  final GetHighScoreUseCase _getHighScore;
  final SaveHighScoreUseCase _saveHighScore;

  // ── Called by the Flame game ──────────────────────────────────────────────

  /// Starts a fresh run with a full tank.
  Future<void> startGame() async {
    final highScore = await _getHighScore();
    emit(GamePlaying(
      score: 0,
      highScore: highScore,
      fuel: GameConstants.maxFuel,
    ));
  }

  /// Burns [amount] fuel. Emptying the tank ends the run.
  void consumeFuel(double amount) {
    final current = state;
    if (current is! GamePlaying) return;

    final remaining = current.fuel - amount;
    if (remaining <= 0) {
      emit(current.withFuel(0));
      unawaited(triggerGameOver(reason: GameOverReason.outOfFuel));
    } else {
      emit(current.withFuel(remaining));
    }
  }

  /// Called when a fuel can is collected: +1 point and a refill.
  void incrementScore() {
    final current = state;
    if (current is GamePlaying) {
      emit(current.withIncrementedScore());
    }
  }

  /// Called when a cone is hit.
  Future<void> triggerGameOver({
    GameOverReason reason = GameOverReason.crash,
  }) async {
    final current = state;
    if (current is! GamePlaying) return;

    final finalScore = current.score;
    var highScore = current.highScore;

    if (finalScore > highScore) {
      highScore = finalScore;
      await _saveHighScore(finalScore);
    }

    emit(GameOver(
      finalScore: finalScore,
      highScore: highScore,
      reason: reason,
    ));
  }

  // ── Pause / menu ──────────────────────────────────────────────────────────

  void pauseGame() {
    final current = state;
    if (current is GamePlaying) {
      emit(GamePaused(
        score: current.score,
        highScore: current.highScore,
        fuel: current.fuel,
      ));
    }
  }

  void resumeGame() {
    final current = state;
    if (current is GamePaused) {
      emit(GamePlaying(
        score: current.score,
        highScore: current.highScore,
        fuel: current.fuel,
      ));
    }
  }

  void quitToMenu() => emit(const GameInitial());
}
