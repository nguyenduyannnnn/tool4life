import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:changmeeting/common/theme.dart';
import 'package:changmeeting/features/dashboard/presentation/bloc/main_navigation_cubit.dart';
import '../../data/datasources/place_image_storage.dart';
import '../../domain/entities/place_entity.dart';
import '../bloc/places_bloc.dart';
import '../bloc/places_event.dart';
import '../bloc/places_state.dart';
import '../widgets/place_list_sheet.dart';
import '../widgets/place_map_view.dart';
import '../widgets/place_marker_detail_sheet.dart';
import 'place_form_bottom_sheet.dart';

class PlacesPage extends StatefulWidget {
  const PlacesPage({super.key});

  @override
  State<PlacesPage> createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage> {
  bool _autoOpenedFromDashboard = false;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<PlacesBloc>();
    bloc.add(const LoadPlaces());
    bloc.add(const GetCurrentLocationEvent());
  }

  void _maybeAutoOpenPlaceDetail(PlacesState state) {
    if (_autoOpenedFromDashboard) return;
    if (state.places.isEmpty) return;
    final nav = context.read<MainNavigationCubit>();
    final pending = nav.state.pendingPlaceDetail;
    if (pending == null) return;
    _autoOpenedFromDashboard = true;
    final fresh = state.places.firstWhere(
      (p) => p.id == pending.id,
      orElse: () => pending,
    );
    nav.consumePlaceDetail();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _onMarkerTap(fresh);
    });
  }

  Future<void> _openForm({
    PlaceEntity? initial,
    double? lat,
    double? lng,
  }) async {
    final result = await PlaceFormBottomSheet.show(
      context,
      initial: initial,
      initialLat: lat ?? initial?.latitude ?? 16.0471,
      initialLng: lng ?? initial?.longitude ?? 108.2068,
    );
    if (!mounted || result == null) return;
    if (initial == null) {
      context.read<PlacesBloc>().add(CreatePlaceEvent(result));
    } else {
      context.read<PlacesBloc>().add(UpdatePlaceEvent(result));
    }
  }

  Future<void> _confirmDelete(PlaceEntity place) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa địa điểm?'),
        content: Text('Bạn chắc chắn muốn xóa "${place.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (ok == true) {
      await PlaceImageStorage.instance.deleteAll(place.imagePaths);
      if (!mounted) return;
      context.read<PlacesBloc>().add(DeletePlaceEvent(place.id));
    }
  }

  void _onMarkerTap(PlaceEntity place) {
    PlaceMarkerDetailSheet.show(
      context,
      place: place,
      onEdit: () => _openForm(initial: place),
      onDelete: () => _confirmDelete(place),
    );
  }

  void _onLongPress(double lat, double lng) {
    _openForm(lat: lat, lng: lng);
  }

  void _openList() {
    final bloc = context.read<PlacesBloc>();
    PlaceListSheet.show(
      context,
      bloc: bloc,
      onPlaceTap: (place) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) _onMarkerTap(place);
        });
      },
    );
  }

  void _onCurrentLocationPressed() {
    final bloc = context.read<PlacesBloc>();
    bloc.add(const GetCurrentLocationEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlacesBloc, PlacesState>(
      listenWhen: (prev, curr) =>
          prev.places != curr.places || prev.status != curr.status,
      listener: (context, state) {
        _maybeAutoOpenPlaceDetail(state);
      },
      child: BlocConsumer<PlacesBloc, PlacesState>(
        listenWhen: (prev, curr) => prev.errorMessage != curr.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null &&
              (state.status == PlacesStatus.failure ||
                  state.mapStatus == MapStatus.locationUnavailable)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: Stack(
            children: [
              PlaceMapView(
                places: state.places,
                currentLocation: state.currentLocation,
                onLongPress: _onLongPress,
                onMarkerTap: _onMarkerTap,
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: _openList,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              child: Row(
                                children: [
                                  Icon(Icons.search, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Tìm địa điểm đã lưu',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        elevation: 4,
                        shape: const CircleBorder(),
                        color: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.list,
                              color: AppColors.primary),
                          onPressed: _openList,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 12,
                bottom: 96,
                child: Material(
                  elevation: 4,
                  shape: const CircleBorder(),
                  color: Colors.white,
                  child: IconButton(
                    icon: state.mapStatus == MapStatus.locating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location,
                            color: AppColors.primary),
                    onPressed: _onCurrentLocationPressed,
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: () {
              final loc = state.currentLocation;
              _openForm(
                lat: loc?.latitude,
                lng: loc?.longitude,
              );
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
        },
      ),
    );
  }
}
