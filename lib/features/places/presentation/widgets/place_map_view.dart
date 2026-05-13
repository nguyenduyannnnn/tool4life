import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:intl/intl.dart';

import '../../domain/entities/lat_lng.dart';
import '../../domain/entities/place_entity.dart';

class PlaceMapView extends StatefulWidget {
  final List<PlaceEntity> places;
  final LatLng? currentLocation;
  final void Function(double lat, double lng) onLongPress;
  final void Function(PlaceEntity place) onMarkerTap;

  const PlaceMapView({
    super.key,
    required this.places,
    required this.currentLocation,
    required this.onLongPress,
    required this.onMarkerTap,
  });

  @override
  State<PlaceMapView> createState() => _PlaceMapViewState();
}

class _PlaceMapViewState extends State<PlaceMapView> {
  static const gmaps.LatLng _fallback = gmaps.LatLng(16.0471, 108.2068);

  gmaps.GoogleMapController? _controller;
  LatLng? _lastAnimatedTo;

  @override
  void didUpdateWidget(covariant PlaceMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeAnimateToCurrent();
  }

  void _maybeAnimateToCurrent() {
    final loc = widget.currentLocation;
    final ctrl = _controller;
    if (loc == null || ctrl == null) return;
    if (_lastAnimatedTo == loc) return;
    _lastAnimatedTo = loc;
    ctrl.animateCamera(
      gmaps.CameraUpdate.newLatLngZoom(
        gmaps.LatLng(loc.latitude, loc.longitude),
        15,
      ),
    );
  }

  Set<gmaps.Marker> _buildMarkers() {
    return widget.places.map((p) {
      return gmaps.Marker(
        markerId: gmaps.MarkerId(p.id),
        position: gmaps.LatLng(p.latitude, p.longitude),
        infoWindow: gmaps.InfoWindow(title: p.name),
        onTap: () => widget.onMarkerTap(p),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.currentLocation;
    final initial = loc != null
        ? gmaps.LatLng(loc.latitude, loc.longitude)
        : _fallback;
    return gmaps.GoogleMap(
      initialCameraPosition: gmaps.CameraPosition(
        target: initial,
        zoom: loc != null ? 15 : 12,
      ),
      onMapCreated: (c) {
        _controller = c;
        _maybeAnimateToCurrent();
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: true,
      markers: _buildMarkers(),
      onLongPress: (latLng) =>
          widget.onLongPress(latLng.latitude, latLng.longitude),
    );
  }
}

String formatVisitedAt(DateTime d) => DateFormat('dd/MM/yyyy').format(d);
