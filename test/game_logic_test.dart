import 'package:cars_drive/core/constants/game_constants.dart';
import 'package:cars_drive/domain/entities/car_entity.dart';
import 'package:cars_drive/domain/repositories/score_repository.dart';
import 'package:cars_drive/domain/use_cases/get_high_score_use_case.dart';
import 'package:cars_drive/domain/use_cases/save_high_score_use_case.dart';
import 'package:cars_drive/presentation/cubits/game_cubit.dart';
import 'package:cars_drive/presentation/cubits/game_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeScoreRepository implements ScoreRepository {
  _FakeScoreRepository([this.stored = 0]);

  int stored;

  @override
  Future<int> getHighScore() async => stored;

  @override
  Future<void> saveHighScore(int score) async => stored = score;
}

GameCubit _cubit([ScoreRepository? repository]) {
  final repo = repository ?? _FakeScoreRepository();
  return GameCubit(
    getHighScore: GetHighScoreUseCase(repo),
    saveHighScore: SaveHighScoreUseCase(repo),
  );
}

void main() {
  group('car entity', () {
    test('toggles between inner and outer lane', () {
      const car = CarEntity(side: CarSide.left, lane: CarLane.inner);
      expect(car.toggleLane().lane, CarLane.outer);
      expect(car.toggleLane().toggleLane().lane, CarLane.inner);
      expect(car.toggleLane().side, CarSide.left);
    });
  });

  group('game state', () {
    test('fuel is clamped to the tank range', () {
      const state = GamePlaying(score: 0, highScore: 0, fuel: 50);
      expect(state.withFuel(120).fuel, GameConstants.maxFuel);
      expect(state.withFuel(-5).fuel, 0);
    });

    test('collecting a can adds a point and refills the tank', () {
      const state = GamePlaying(score: 4, highScore: 9, fuel: 40);
      final next = state.withIncrementedScore();
      expect(next.score, 5);
      expect(next.highScore, 9);
      expect(next.fuel, 40 + GameConstants.fuelPickupAmount);
    });

    test('refill never exceeds capacity', () {
      const state = GamePlaying(score: 0, highScore: 0, fuel: 95);
      expect(state.withIncrementedScore().fuel, GameConstants.maxFuel);
    });
  });

  group('game cubit', () {
    test('starts with a full tank', () async {
      final cubit = _cubit();
      await cubit.startGame();
      final state = cubit.state as GamePlaying;
      expect(state.fuel, GameConstants.maxFuel);
      expect(state.score, 0);
      cubit.close();
    });

    test('fuel drains while playing', () async {
      final cubit = _cubit();
      await cubit.startGame();
      cubit.consumeFuel(30);
      expect((cubit.state as GamePlaying).fuel, 70);
      cubit.close();
    });

    test('empty tank ends the run as out of fuel', () async {
      final cubit = _cubit();
      await cubit.startGame();
      cubit.incrementScore();
      cubit.consumeFuel(500);
      expect((cubit.state as GamePlaying).fuel, 0);
      await pumpEventQueue();
      final over = cubit.state as GameOver;
      expect(over.reason, GameOverReason.outOfFuel);
      expect(over.finalScore, 1);
      cubit.close();
    });

    test('crash ends the run with the crash reason', () async {
      final cubit = _cubit();
      await cubit.startGame();
      await cubit.triggerGameOver();
      expect((cubit.state as GameOver).reason, GameOverReason.crash);
      cubit.close();
    });

    test('a new best score is persisted', () async {
      final repo = _FakeScoreRepository(3);
      final cubit = _cubit(repo);
      await cubit.startGame();
      for (var i = 0; i < 5; i++) {
        cubit.incrementScore();
      }
      await cubit.triggerGameOver();
      expect(repo.stored, 5);
      expect((cubit.state as GameOver).highScore, 5);
      cubit.close();
    });

    test('pause and resume preserve score and fuel', () async {
      final cubit = _cubit();
      await cubit.startGame();
      cubit.incrementScore();
      cubit.consumeFuel(25);
      cubit.pauseGame();
      final paused = cubit.state as GamePaused;
      expect(paused.score, 1);
      expect(paused.fuel, 75);
      cubit.resumeGame();
      final playing = cubit.state as GamePlaying;
      expect(playing.score, 1);
      expect(playing.fuel, 75);
      cubit.close();
    });

    test('quitting returns to the initial state', () async {
      final cubit = _cubit();
      await cubit.startGame();
      cubit.quitToMenu();
      expect(cubit.state, isA<GameInitial>());
      cubit.close();
    });
  });
}
