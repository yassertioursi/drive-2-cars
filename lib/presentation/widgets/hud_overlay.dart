import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/game_constants.dart';
import '../cubits/game_cubit.dart';
import '../cubits/game_state.dart';

/// In-run HUD: score, live fuel gauge, best score and pause control.
class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      buildWhen: (previous, current) =>
          current is GamePlaying || current is GamePaused,
      builder: (context, state) {
        final score = switch (state) {
          GamePlaying(:final score) => score,
          GamePaused(:final score) => score,
          _ => 0,
        };
        final highScore = switch (state) {
          GamePlaying(:final highScore) => highScore,
          GamePaused(:final highScore) => highScore,
          _ => 0,
        };
        final fuel = switch (state) {
          GamePlaying(:final fuel) => fuel,
          GamePaused(:final fuel) => fuel,
          _ => 0.0,
        };

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Row(
              children: [
                _ScoreChip(
                  id: 'hud_score',
                  label: 'SCORE',
                  value: score,
                  color: GameConstants.laneWhite,
                ),
                const SizedBox(width: 10),
                Expanded(child: _FuelGauge(fuel: fuel)),
                const SizedBox(width: 10),
                _ScoreChip(
                  id: 'hud_high_score',
                  label: 'BEST',
                  value: highScore,
                  color: GameConstants.accentAmber,
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  key: const ValueKey('hud_pause_button'),
                  onTap: () => context.read<GameCubit>().pauseGame(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: const Icon(
                      Icons.pause_rounded,
                      color: GameConstants.laneWhite,
                      size: 20,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.7),
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
            ),
          ),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 20,
              height: 1.1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _FuelGauge extends StatelessWidget {
  const _FuelGauge({required this.fuel});

  final double fuel;

  @override
  Widget build(BuildContext context) {
    final ratio = (fuel / GameConstants.maxFuel).clamp(0.0, 1.0);
    final low = ratio < 0.25;
    final color = low ? GameConstants.accentRed : GameConstants.fuelColor;

    return Container(
      key: const ValueKey('hud_fuel_gauge'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.local_gas_station_rounded, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                low ? 'LOW FUEL' : 'FUEL',
                style: TextStyle(
                  color: color,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                '${ratio * 100 ~/ 1}%',
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 7,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: ratio == 0 ? 0.001 : ratio,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.85), color],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
