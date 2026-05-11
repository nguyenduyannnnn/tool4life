import '../entities/place_entity.dart';
import '../repositories/places_repository.dart';

class CreatePlace {
  final PlacesRepository repository;

  CreatePlace(this.repository);

  Future<void> call(PlaceEntity place) => repository.createPlace(place);
}
