import '../entities/lat_lng.dart';
import '../entities/place_entity.dart';

abstract class PlacesRepository {
  Future<List<PlaceEntity>> getAllPlaces();

  Future<List<PlaceEntity>> searchPlaces(String keyword);

  Future<List<PlaceEntity>> getPlacesByTag(String tag);

  Future<void> createPlace(PlaceEntity place);

  Future<void> updatePlace(PlaceEntity place);

  Future<void> deletePlace(String id);

  Future<LatLng?> getCurrentLocation();
}
