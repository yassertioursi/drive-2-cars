import 'package:equatable/equatable.dart';

/// The two playable sides of the split screen.
enum CarSide { left, right }

/// The two lanes each car can occupy within its half of the screen.
///
/// [inner] is the lane closest to the centre divider.
/// [outer] is the lane closest to the screen edge.
enum CarLane { inner, outer }

/// Pure domain entity representing the state of a single car.
///
/// This class has no Flutter or Flame dependencies — it is plain Dart
/// and can be constructed / compared in unit tests without a widget tree.
class CarEntity extends Equatable {
  const CarEntity({
    required this.side,
    required this.lane,
  });

  /// Which half of the screen this car belongs to.
  final CarSide side;

  /// The lane the car is currently in.
  final CarLane lane;

  /// Returns a copy with optional field overrides.
  CarEntity copyWith({CarLane? lane}) {
    return CarEntity(
      side: side,
      lane: lane ?? this.lane,
    );
  }

  /// Toggle between [CarLane.inner] and [CarLane.outer].
  CarEntity toggleLane() {
    return copyWith(
      lane: lane == CarLane.inner ? CarLane.outer : CarLane.inner,
    );
  }

  @override
  List<Object?> get props => [side, lane];
}
