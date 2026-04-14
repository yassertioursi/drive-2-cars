import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../cubits/game_cubit.dart';
import '../../game/drive_two_cars_game.dart';
import '../../core/constants/game_constants.dart';

/// Full-screen main menu shown before the first game starts.
///
/// Tapping "Play" calls [GameCubit.startGame] and removes this overlay.
class MainMenuOverlay extends StatelessWidget {
  const MainMenuOverlay({
    super.key,
    required this.game,
  });

  final DriveTwoCarsGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D0D1A), Color(0xFF111130)],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Logo ────────────────────────────────────────────────────────
            FittedBox(
              fit: BoxFit.scaleDown,
              child: _NeonText('DRIVE', color: const Color(0xFF00FFFF), size: 56),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: _NeonText('TWO CARS', color: const Color(0xFFFF6B00), size: 56),
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Tap left · Tap right · Don\'t crash!',
                style: GoogleFonts.orbitron(
                  color: Colors.white54,
                  fontSize: 13,
                  letterSpacing: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 64),
            // ── Play button ─────────────────────────────────────────────────
            _GlowButton(
              id: 'main_menu_play_button',
              label: 'PLAY',
              color: const Color(0xFF00FFFF),
              onTap: () {
                context.read<GameCubit>().startGame();
                game.overlays.remove(GameConstants.overlayMainMenu);
                game.overlays.add(GameConstants.overlayHud);
                game.resumeEngine();
              },
            ),
            const SizedBox(height: 32),
            // ── Controls hint ───────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _HintBox(color: const Color(0xFF00FFFF), label: 'LEFT CAR'),
                const SizedBox(width: 32),
                _HintBox(color: const Color(0xFFFF6B00), label: 'RIGHT CAR'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _NeonText extends StatelessWidget {
  const _NeonText(this.text, {required this.color, required this.size});
  final String text;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.orbitron(
        fontSize: size,
        fontWeight: FontWeight.w900,
        color: color,
        shadows: [
          Shadow(color: color.withValues(alpha: 0.9), blurRadius: 20),
          Shadow(color: color.withValues(alpha: 0.5), blurRadius: 40),
        ],
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 18),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 24, spreadRadius: 2),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.orbitron(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 4,
          ),
        ),
      ),
    );
  }
}

class _HintBox extends StatelessWidget {
  const _HintBox({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(6),
            color: color.withValues(alpha: 0.1),
          ),
          child: Icon(Icons.touch_app, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.orbitron(
            color: color,
            fontSize: 10,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}
