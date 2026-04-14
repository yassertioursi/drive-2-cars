import '../repositories/score_repository.dart';

/// Use case: persist a new high score to storage.
///
/// The caller is responsible for only invoking this when [score] actually
/// beats the previous high score — this use case does not perform that check.
class SaveHighScoreUseCase {
  const SaveHighScoreUseCase(this._repository);

  final ScoreRepository _repository;

  /// Executes the use case, saving [score] as the current high score.
  Future<void> call(int score) => _repository.saveHighScore(score);
}
