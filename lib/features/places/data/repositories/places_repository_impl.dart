import '../../domain/entities/lat_lng.dart';
import '../../domain/entities/place_entity.dart';
import '../../domain/repositories/places_repository.dart';
import '../datasources/location_datasource.dart';
import '../datasources/places_local_datasource.dart';
import '../models/place_model.dart';

class PlacesRepositoryImpl implements PlacesRepository {
  final PlacesLocalDataSource localDataSource;
  final LocationDataSource locationDataSource;

  PlacesRepositoryImpl({
    required this.localDataSource,
    required this.locationDataSource,
  });

  @override
  Future<List<PlaceEntity>> getAllPlaces() async {
    final models = await localDataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<PlaceEntity>> searchPlaces(String keyword) async {
    if (keyword.trim().isEmpty) return getAllPlaces();
    final models = await localDataSource.search(keyword.trim());
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<PlaceEntity>> getPlacesByTag(String tag) async {
    final models = await localDataSource.getByTag(tag);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> createPlace(PlaceEntity place) {
    return localDataSource.upsert(PlaceModel.fromEntity(place));
  }

  @override
  Future<void> updatePlace(PlaceEntity place) {
    return localDataSource.upsert(
      PlaceModel.fromEntity(place.copyWith(updatedAt: DateTime.now())),
    );
  }

  @override
  Future<void> deletePlace(String id) {
    return localDataSource.deleteById(id);
  }

  @override
  Future<LatLng?> getCurrentLocation() {
    return locationDataSource.getCurrentLocation();
  }
}
