import '../entities/lat_lng.dart';
import '../repositories/places_repository.dart';

class GetCurrentLocation {
  final PlacesRepository repository;

  GetCurrentLocation(this.repository);

  Future<LatLng?> call() => repository.getCurrentLocation();
}
