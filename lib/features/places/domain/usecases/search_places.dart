import '../entities/place_entity.dart';
import '../repositories/places_repository.dart';

class SearchPlaces {
  final PlacesRepository repository;

  SearchPlaces(this.repository);

  Future<List<PlaceEntity>> call(String keyword) =>
      repository.searchPlaces(keyword);
}
