import '../../domain/repositories/score_repository.dart';
import '../data_sources/local_score_data_source.dart';

/// Concrete implementation of [ScoreRepository] backed by [LocalScoreDataSource].
///
/// Lives in the data layer — the domain layer only sees the abstract interface.
class ScoreRepositoryImpl implements ScoreRepository {
  const ScoreRepositoryImpl(this._dataSource);

  final LocalScoreDataSource _dataSource;

  @override
  Future<int> getHighScore() async => _dataSource.getHighScore();

  @override
  Future<void> saveHighScore(int score) => _dataSource.saveHighScore(score);
}
