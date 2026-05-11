import 'package:equatable/equatable.dart';

import '../../domain/entities/place_entity.dart';

abstract class PlacesEvent extends Equatable {
  const PlacesEvent();

  @override
  List<Object?> get props => [];
}

class LoadPlaces extends PlacesEvent {
  const LoadPlaces();
}

class CreatePlaceEvent extends PlacesEvent {
  final PlaceEntity place;

  const CreatePlaceEvent(this.place);

  @override
  List<Object?> get props => [place];
}

class UpdatePlaceEvent extends PlacesEvent {
  final PlaceEntity place;

  const UpdatePlaceEvent(this.place);

  @override
  List<Object?> get props => [place];
}

class DeletePlaceEvent extends PlacesEvent {
  final String id;

  const DeletePlaceEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class SearchPlacesEvent extends PlacesEvent {
  final String keyword;

  const SearchPlacesEvent(this.keyword);

  @override
  List<Object?> get props => [keyword];
}

class FilterPlacesByTag extends PlacesEvent {
  final String? tag;

  const FilterPlacesByTag(this.tag);

  @override
  List<Object?> get props => [tag];
}

class GetCurrentLocationEvent extends PlacesEvent {
  const GetCurrentLocationEvent();
}

class SelectPlace extends PlacesEvent {
  final PlaceEntity place;

  const SelectPlace(this.place);

  @override
  List<Object?> get props => [place];
}

class ClearSelectedPlace extends PlacesEvent {
  const ClearSelectedPlace();
}

class AddPlaceFromMap extends PlacesEvent {
  final double lat;
  final double lng;

  const AddPlaceFromMap(this.lat, this.lng);

  @override
  List<Object?> get props => [lat, lng];
}
