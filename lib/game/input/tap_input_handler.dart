import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../components/car_component.dart';

/// Pure Dart class that maps screen tap positions to car toggle commands.
///
/// Keeping this logic in a plain class (not a component or widget) makes it
/// independently testable and decoupled from both Flutter and Flame APIs.
class TapInputHandler {
  const TapInputHandler({
    required this.leftCar,
    required this.rightCar,
    required this.screenWidth,
  });

  final CarComponent leftCar;
  final CarComponent rightCar;

  /// Total screen width — halved to determine which car to toggle.
  final double screenWidth;

  /// Call from [FlameGame.onTapDown] with the raw tap event.
  void handleTap(TapDownEvent event) {
    final tapX = event.localPosition.x;
    if (tapX < screenWidth / 2) {
      leftCar.toggleLane();
    } else {
      rightCar.toggleLane();
    }
  }

  /// Convenience overload accepting a raw [Offset] (useful in tests).
  void handleTapAt(Offset position) {
    if (position.dx < screenWidth / 2) {
      leftCar.toggleLane();
    } else {
      rightCar.toggleLane();
    }
  }
}
