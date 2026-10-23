import 'package:equatable/equatable.dart';

/// The two things that can appear on a lane in Cars Drive.
///
/// - [fuel] — a fuel can: awards points and refills the tank on contact.
/// - [cone] — a traffic cone: ends the run on contact.
enum ObstacleType { fuel, cone }

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

  /// Whether this obstacle is a pickup or a hazard.
  final ObstacleType type;

  /// Normalised X position within the half-screen (0.0 = left edge, 1.0 = right edge).
  final double laneNormX;

  /// Current Y position in logical pixels from the top of the half-screen.
  final double yPosition;

  /// Downward fall speed in pixels per second.
  final double speed;

  @override
  List<Object?> get props => [type, laneNormX, yPosition, speed];
}
