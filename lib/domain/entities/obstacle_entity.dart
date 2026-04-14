import 'package:equatable/equatable.dart';

/// The two kinds of obstacle that can appear on each road half.
///
/// - [circle] — collectable: awards points on contact.
/// - [square] — danger: triggers game-over on contact.
enum ObstacleType { circle, square }

/// Pure domain entity describing a single obstacle instance.
///
/// Position values are in logical pixels relative to the top-left
/// of the half-screen the obstacle belongs to.
class ObstacleEntity extends Equatable {
  const ObstacleEntity({
    required this.type,
    required this.laneNormX,
    required this.yPosition,
    required this.speed,
  });

  /// Whether this obstacle collects points or ends the game.
  final ObstacleType type;

  /// Normalised X position within the half-screen (0.0 = left edge, 1.0 = right edge).
  /// Maps to one of the two lane positions defined in [GameConstants].
  final double laneNormX;

  /// Current Y position in logical pixels from the top of the half-screen.
  final double yPosition;

  /// Downward fall speed in pixels per second.
  final double speed;

  @override
  List<Object?> get props => [type, laneNormX, yPosition, speed];
}
