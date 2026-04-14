import '../repositories/score_repository.dart';

/// Use case: retrieve the stored high score.
///
/// Encapsulates the single business rule: "read the high score from storage."
/// Callers receive the value without caring how or where it is stored.
class GetHighScoreUseCase {
  const GetHighScoreUseCase(this._repository);

  final ScoreRepository _repository;

  /// Executes the use case and returns the current high score.
  Future<int> call() => _repository.getHighScore();
}
