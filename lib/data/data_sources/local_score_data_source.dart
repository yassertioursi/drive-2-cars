import 'package:shared_preferences/shared_preferences.dart';

/// Local data source that reads/writes the high score using SharedPreferences.
///
/// This is the only class that knows about the storage key and the
/// SharedPreferences API — all other layers interact with [ScoreRepository].
class LocalScoreDataSource {
  LocalScoreDataSource(this._prefs);

  static const _kHighScoreKey = 'high_score';

  final SharedPreferences _prefs;

  /// Returns the stored high score, defaulting to 0 if absent.
  int getHighScore() => _prefs.getInt(_kHighScoreKey) ?? 0;

  /// Writes [score] to persistent storage.
  Future<void> saveHighScore(int score) =>
      _prefs.setInt(_kHighScoreKey, score);
}
