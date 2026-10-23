import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/game_constants.dart';
import '../../game/cars_drive_game.dart';
import '../cubits/game_cubit.dart';

/// Pause screen: resume the run or abandon it back to the menu.
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.game});

  final CarsDriveGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xCC120D16),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PAUSED',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8,
                  color: GameConstants.laneWhite,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'The tank is waiting.',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 44),
              _MenuButton(
                id: 'pause_resume_button',
                label: 'RESUME',
                filled: true,
                onTap: () {
                  game.overlays.remove(GameConstants.overlayPause);
                  context.read<GameCubit>().resumeGame();
                },
              ),
              const SizedBox(height: 16),
              _MenuButton(
                id: 'pause_quit_button',
                label: 'QUIT TO MENU',
                filled: false,
                onTap: () {
                  game.resetGame();
                  context.read<GameCubit>().quitToMenu();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.id,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String id;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: ValueKey(id),
        width: 230,
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled
              ? GameConstants.accentAmber
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: filled
                ? GameConstants.accentAmber
                : Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.5,
            color: filled ? const Color(0xFF241A2B) : GameConstants.laneWhite,
          ),
        ),
      ),
    );
  }
}
