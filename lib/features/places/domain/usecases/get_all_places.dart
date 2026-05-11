import '../entities/place_entity.dart';
import '../repositories/places_repository.dart';

class GetAllPlaces {
  final PlacesRepository repository;

  GetAllPlaces(this.repository);

  Future<List<PlaceEntity>> call() => repository.getAllPlaces();
}
