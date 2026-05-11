import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/lat_lng.dart';
import '../../domain/usecases/create_place.dart';
import '../../domain/usecases/delete_place.dart';
import '../../domain/usecases/get_all_places.dart';
import '../../domain/usecases/get_current_location.dart';
import '../../domain/usecases/search_places.dart';
import '../../domain/usecases/update_place.dart';
import 'places_event.dart';
import 'places_state.dart';

class PlacesBloc extends Bloc<PlacesEvent, PlacesState> {
  final GetAllPlaces getAllPlaces;
  final CreatePlace createPlace;
  final UpdatePlace updatePlace;
  final DeletePlace deletePlace;
  final SearchPlaces searchPlaces;
  final GetCurrentLocation getCurrentLocation;

  PlacesBloc({
    required this.getAllPlaces,
    required this.createPlace,
    required this.updatePlace,
    required this.deletePlace,
    required this.searchPlaces,
    required this.getCurrentLocation,
  }) : super(const PlacesState()) {
    on<LoadPlaces>(_onLoad);
    on<CreatePlaceEvent>(_onCreate);
    on<UpdatePlaceEvent>(_onUpdate);
    on<DeletePlaceEvent>(_onDelete);
    on<SearchPlacesEvent>(_onSearch);
    on<FilterPlacesByTag>(_onFilterTag);
    on<GetCurrentLocationEvent>(_onGetLocation);
    on<SelectPlace>(_onSelect);
    on<ClearSelectedPlace>(_onClearSelect);
    on<AddPlaceFromMap>(_onAddFromMap);
  }

  Future<void> _onLoad(LoadPlaces event, Emitter<PlacesState> emit) async {
    emit(state.copyWith(status: PlacesStatus.loading, clearError: true));
    try {
      final places = await getAllPlaces();
      emit(state.copyWith(places: places, status: PlacesStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: PlacesStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreate(
      CreatePlaceEvent event, Emitter<PlacesState> emit) async {
    try {
      await createPlace(event.place);
      await _reload(emit);
    } catch (e) {
      emit(state.copyWith(
        status: PlacesStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdate(
      UpdatePlaceEvent event, Emitter<PlacesState> emit) async {
    try {
      await updatePlace(event.place);
      await _reload(emit);
    } catch (e) {
      emit(state.copyWith(
        status: PlacesStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDelete(
      DeletePlaceEvent event, Emitter<PlacesState> emit) async {
    try {
      await deletePlace(event.id);
      await _reload(emit);
    } catch (e) {
      emit(state.copyWith(
        status: PlacesStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSearch(SearchPlacesEvent event, Emitter<PlacesState> emit) {
    emit(state.copyWith(searchKeyword: event.keyword));
  }

  void _onFilterTag(FilterPlacesByTag event, Emitter<PlacesState> emit) {
    if (event.tag == null) {
      emit(state.copyWith(clearTag: true));
    } else {
      emit(state.copyWith(selectedTag: event.tag));
    }
  }

  Future<void> _onGetLocation(
      GetCurrentLocationEvent event, Emitter<PlacesState> emit) async {
    emit(state.copyWith(mapStatus: MapStatus.locating, clearError: true));
    try {
      final loc = await getCurrentLocation();
      if (loc == null) {
        emit(state.copyWith(
          mapStatus: MapStatus.locationUnavailable,
          errorMessage:
              'Không lấy được vị trí. Kiểm tra quyền và dịch vụ vị trí.',
        ));
      } else {
        emit(state.copyWith(
          currentLocation: loc,
          mapStatus: MapStatus.ready,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        mapStatus: MapStatus.locationUnavailable,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSelect(SelectPlace event, Emitter<PlacesState> emit) {
    emit(state.copyWith(selectedPlace: event.place));
  }

  void _onClearSelect(ClearSelectedPlace event, Emitter<PlacesState> emit) {
    emit(state.copyWith(clearSelected: true));
  }

  void _onAddFromMap(AddPlaceFromMap event, Emitter<PlacesState> emit) {
    emit(state.copyWith(
      pendingNewLocation: LatLng(event.lat, event.lng),
    ));
  }

  Future<void> _reload(Emitter<PlacesState> emit) async {
    final places = await getAllPlaces();
    emit(state.copyWith(
      places: places,
      status: PlacesStatus.success,
      clearError: true,
    ));
  }
}
