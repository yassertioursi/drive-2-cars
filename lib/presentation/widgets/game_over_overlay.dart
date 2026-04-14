import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../cubits/game_cubit.dart';
import '../cubits/game_state.dart';
import '../../game/drive_two_cars_game.dart';
import '../../core/constants/game_constants.dart';

/// Overlay shown when a square obstacle collision ends the game.
///
/// Displays the final score, high score, and a "Try Again" button
/// that resets the Flame world and starts a fresh run.
class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({
    super.key,
    required this.game,
  });

  final DriveTwoCarsGame game;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      builder: (context, state) {
        final finalScore = state is GameOver ? state.finalScore : 0;
        final highScore = state is GameOver ? state.highScore : 0;
        final isNewRecord = finalScore == highScore && finalScore > 0;

        return Container(
          color: const Color(0xCC0D0D1A),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Title ──────────────────────────────────────────────────
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'GAME OVER',
                    style: GoogleFonts.orbitron(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFFF0080),
                      shadows: [
                        const Shadow(
                          color: Color(0xFFFF0080),
                          blurRadius: 28,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (isNewRecord)
                  Text(
                    '★  NEW RECORD  ★',
                    style: GoogleFonts.orbitron(
                      fontSize: 13,
                      color: const Color(0xFFFFB400),
                      letterSpacing: 3,
                    ),
                  ),
                const SizedBox(height: 40),
                // ── Scores ─────────────────────────────────────────────────
                _ResultRow(label: 'SCORE', value: finalScore, color: const Color(0xFF00FFFF)),
                const SizedBox(height: 12),
                _ResultRow(label: 'BEST', value: highScore, color: const Color(0xFFFFB400)),
                const SizedBox(height: 56),
                // ── Try Again ──────────────────────────────────────────────
                _GlowButton(
                  id: 'game_over_try_again_button',
                  label: 'TRY AGAIN',
                  color: const Color(0xFF00FFFF),
                  onTap: () async {
                    game.overlays.remove(GameConstants.overlayGameOver);
                    game.overlays.add(GameConstants.overlayHud);
                    game.resetGame();
                    await context.read<GameCubit>().startGame();
                  },
                ),
                const SizedBox(height: 20),
                TextButton(
                  key: const ValueKey('game_over_main_menu_button'),
                  onPressed: () {
                    game.overlays.remove(GameConstants.overlayGameOver);
                    game.overlays.add(GameConstants.overlayMainMenu);
                    game.resetGame();
                    game.pauseEngine();
                  },
                  child: Text(
                    'Main Menu',
                    style: GoogleFonts.orbitron(
                      color: Colors.white38,
                      fontSize: 13,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helpers
// ─────────────────────────────────────────────────────────────────────────────

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
        Text(
          '$label  ',
          style: GoogleFonts.orbitron(
            color: Colors.white38,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
        Text(
          '$value',
          style: GoogleFonts.orbitron(
            color: color,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _GlowButton extends StatelessWidget {
  const _GlowButton({
    required this.id,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String id;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: ValueKey(id),
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.orbitron(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 4,
          ),
        ),
      ),
    );
  }
}
