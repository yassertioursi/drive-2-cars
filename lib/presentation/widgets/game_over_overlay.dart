import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/game_constants.dart';
import '../../game/cars_drive_game.dart';
import '../cubits/game_cubit.dart';
import '../cubits/game_state.dart';

/// End-of-run screen: why it ended, score, best and retry controls.
class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key, required this.game});

  final CarsDriveGame game;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      builder: (context, state) {
        final finalScore = state is GameOver ? state.finalScore : 0;
        final highScore = state is GameOver ? state.highScore : 0;
        final reason = state is GameOver
            ? state.reason
            : GameOverReason.crash;
        final isNewRecord = finalScore == highScore && finalScore > 0;
        final crashed = reason == GameOverReason.crash;

        return Container(
          color: const Color(0xD9120D16),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      crashed
                          ? Icons.warning_amber_rounded
                          : Icons.local_gas_station_rounded,
                      size: 46,
                      color: crashed
                          ? GameConstants.accentRed
                          : GameConstants.accentAmber,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'RUN ENDED',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 5,
                        color: GameConstants.laneWhite,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: (crashed
                                ? GameConstants.accentRed
                                : GameConstants.accentAmber)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (crashed
                                  ? GameConstants.accentRed
                                  : GameConstants.accentAmber)
                              .withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        crashed ? 'CRASHED INTO A CONE' : 'OUT OF FUEL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                          color: crashed
                              ? GameConstants.accentRed
                              : GameConstants.accentAmber,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (isNewRecord)
                      const Text(
                        '★ NEW RECORD ★',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.5,
                          color: GameConstants.accentAmber,
                        ),
                      ),
                    const SizedBox(height: 34),
                    _ResultRow(
                      label: 'SCORE',
                      value: finalScore,
                      color: GameConstants.laneWhite,
                    ),
                    const SizedBox(height: 10),
                    _ResultRow(
                      label: 'BEST',
                      value: highScore,
                      color: GameConstants.accentAmber,
                    ),
                    const SizedBox(height: 44),
                    GestureDetector(
                      key: const ValueKey('game_over_try_again_button'),
                      onTap: () {
                        game.overlays.remove(GameConstants.overlayGameOver);
                        game.overlays.add(GameConstants.overlayHud);
                        game.resetGame();
                        context.read<GameCubit>().startGame();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 52,
                          vertical: 17,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              GameConstants.accentAmber,
                              Color(0xFFFF8A3D),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: GameConstants.accentAmber
                                  .withValues(alpha: 0.35),
                              blurRadius: 22,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: const Text(
                          'TRY AGAIN',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                            color: Color(0xFF241A2B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      key: const ValueKey('game_over_main_menu_button'),
                      onPressed: () {
                        game.resetGame();
                        context.read<GameCubit>().quitToMenu();
                      },
                      child: const Text(
                        'MAIN MENU',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 68,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
            ),
          ),
        ),
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 34,
            height: 1.05,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
