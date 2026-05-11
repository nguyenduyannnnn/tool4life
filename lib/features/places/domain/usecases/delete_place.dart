import '../repositories/places_repository.dart';

class DeletePlace {
  final PlacesRepository repository;

  DeletePlace(this.repository);

  Future<void> call(String id) => repository.deletePlace(id);
}
