import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../cubits/game_cubit.dart';
import '../cubits/game_state.dart';

/// Transparent HUD rendered on top of the running game.
///
/// Shows the current score on the left and all-time high score on the right.
/// Rebuilt only when [GamePlaying] emits a new score value.
class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      buildWhen: (previous, current) => current is GamePlaying,
      builder: (context, state) {
        final score = state is GamePlaying ? state.score : 0;
        final highScore = state is GamePlaying ? state.highScore : 0;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ScoreChip(
                  id: 'hud_score',
                  label: 'SCORE',
                  value: score,
                  color: const Color(0xFF00FFFF),
                ),
                _ScoreChip(
                  id: 'hud_high_score',
                  label: 'BEST',
                  value: highScore,
                  color: const Color(0xFFFFB400),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({
    required this.id,
    required this.label,
    required this.value,
    required this.color,
  });

  final String id;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(id),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D1A).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.orbitron(
              color: color.withValues(alpha: 0.8),
              fontSize: 9,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$value',
            style: GoogleFonts.orbitron(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
