import '../entities/place_entity.dart';
import '../repositories/places_repository.dart';

class UpdatePlace {
  final PlacesRepository repository;

  UpdatePlace(this.repository);

  Future<void> call(PlaceEntity place) => repository.updatePlace(place);
}
