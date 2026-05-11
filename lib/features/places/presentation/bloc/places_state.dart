import 'package:equatable/equatable.dart';

import '../../domain/entities/lat_lng.dart';
import '../../domain/entities/place_entity.dart';

enum PlacesStatus { initial, loading, success, failure }

enum MapStatus { initial, locating, ready, locationUnavailable }

class PlacesState extends Equatable {
  final List<PlaceEntity> places;
  final PlaceEntity? selectedPlace;
  final String? selectedTag;
  final String searchKeyword;
  final LatLng? currentLocation;
  final MapStatus mapStatus;
  final PlacesStatus status;
  final String? errorMessage;

  /// Transient: lat/lng ấn giữ trên map, page consume rồi clear.
  final LatLng? pendingNewLocation;

  const PlacesState({
    this.places = const [],
    this.selectedPlace,
    this.selectedTag,
    this.searchKeyword = '',
    this.currentLocation,
    this.mapStatus = MapStatus.initial,
    this.status = PlacesStatus.initial,
    this.errorMessage,
    this.pendingNewLocation,
  });

  PlacesState copyWith({
    List<PlaceEntity>? places,
    PlaceEntity? selectedPlace,
    String? selectedTag,
    String? searchKeyword,
    LatLng? currentLocation,
    MapStatus? mapStatus,
    PlacesStatus? status,
    String? errorMessage,
    LatLng? pendingNewLocation,
    bool clearSelected = false,
    bool clearTag = false,
    bool clearError = false,
    bool clearPending = false,
  }) {
    return PlacesState(
      places: places ?? this.places,
      selectedPlace:
          clearSelected ? null : (selectedPlace ?? this.selectedPlace),
      selectedTag: clearTag ? null : (selectedTag ?? this.selectedTag),
      searchKeyword: searchKeyword ?? this.searchKeyword,
      currentLocation: currentLocation ?? this.currentLocation,
      mapStatus: mapStatus ?? this.mapStatus,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      pendingNewLocation: clearPending
          ? null
          : (pendingNewLocation ?? this.pendingNewLocation),
    );
  }

  List<PlaceEntity> get filteredPlaces {
    final keyword = searchKeyword.trim().toLowerCase();
    final list = places.where((p) {
      if (selectedTag != null && p.tag != selectedTag) return false;
      if (keyword.isNotEmpty) {
        final inName = p.name.toLowerCase().contains(keyword);
        final inDesc =
            (p.description ?? '').toLowerCase().contains(keyword);
        if (!inName && !inDesc) return false;
      }
      return true;
    }).toList();
    list.sort((a, b) => b.visitedAt.compareTo(a.visitedAt));
    return list;
  }

  @override
  List<Object?> get props => [
        places,
        selectedPlace,
        selectedTag,
        searchKeyword,
        currentLocation,
        mapStatus,
        status,
        errorMessage,
        pendingNewLocation,
      ];
}
