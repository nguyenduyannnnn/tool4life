import 'package:equatable/equatable.dart';

class LatLng extends Equatable {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);

  @override
  List<Object?> get props => [latitude, longitude];

  @override
  String toString() => 'LatLng($latitude, $longitude)';
}
