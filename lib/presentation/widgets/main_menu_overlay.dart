import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/game_constants.dart';
import '../../game/cars_drive_game.dart';
import '../cubits/game_cubit.dart';

/// Pre-run menu: title, fuel-mode explainer and the PLAY button.
class MainMenuOverlay extends StatelessWidget {
  const MainMenuOverlay({super.key, required this.game});

  final CarsDriveGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [GameConstants.duskTop, GameConstants.duskBottom],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [GameConstants.accentAmber, Color(0xFFFF8A3D)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: GameConstants.accentAmber.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.directions_car_filled_rounded,
                  color: Color(0xFF241A2B),
                  size: 34,
                ),
              ),
              const SizedBox(height: 22),
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'CARS',
                  style: TextStyle(
                    fontSize: 62,
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 10,
                    color: GameConstants.accentAmber,
                  ),
                ),
              ),
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'DRIVE',
                  style: TextStyle(
                    fontSize: 62,
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                    color: GameConstants.laneWhite,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Two lanes. One tank. No brakes.',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: GameConstants.accentAmber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: GameConstants.accentAmber.withValues(alpha: 0.45),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: 15,
                      color: GameConstants.accentAmber,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'NEW · FUEL MODE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                        color: GameConstants.accentAmber,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 46),
              _PlayButton(
                onTap: () {
                  context.read<GameCubit>().startGame();
                  game.overlays.remove(GameConstants.overlayMainMenu);
                  game.overlays.add(GameConstants.overlayHud);
                  game.resumeEngine();
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Grab fuel cans · Dodge the cones',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 34),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _HintCard(
                    icon: Icons.touch_app_rounded,
                    label: 'TAP LEFT',
                    caption: 'left car',
                    color: GameConstants.laneWhite,
                  ),
                  SizedBox(width: 14),
                  _HintCard(
                    icon: Icons.touch_app_rounded,
                    label: 'TAP RIGHT',
                    caption: 'right car',
                    color: GameConstants.accentRed,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: const ValueKey('main_menu_play_button'),
        padding: const EdgeInsets.symmetric(horizontal: 62, vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [GameConstants.accentAmber, Color(0xFFFF8A3D)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: GameConstants.accentAmber.withValues(alpha: 0.35),
              blurRadius: 26,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Text(
          'PLAY',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 5,
            color: Color(0xFF241A2B),
          ),
        ),
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({
    required this.icon,
    required this.label,
    required this.caption,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String caption;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            style: const TextStyle(fontSize: 10, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}
