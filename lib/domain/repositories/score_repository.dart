/// Abstract interface for persisting and retrieving the player's high score.
///
/// The domain layer depends only on this contract — it knows nothing
/// about the concrete storage mechanism (SharedPreferences, Hive, etc.).
abstract interface class ScoreRepository {
  /// Returns the stored high score, or 0 if none has been saved yet.
  Future<int> getHighScore();

  /// Persists [score] as the new high score.
  Future<void> saveHighScore(int score);
}
