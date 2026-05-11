import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:changmeeting/features/places/data/datasources/location_datasource.dart';
import 'package:changmeeting/features/places/data/datasources/places_local_datasource.dart';
import 'package:changmeeting/features/places/data/repositories/places_repository_impl.dart';
import 'package:changmeeting/features/places/domain/repositories/places_repository.dart';
import 'package:changmeeting/features/places/domain/usecases/create_place.dart';
import 'package:changmeeting/features/places/domain/usecases/delete_place.dart';
import 'package:changmeeting/features/places/domain/usecases/get_all_places.dart';
import 'package:changmeeting/features/places/domain/usecases/get_current_location.dart';
import 'package:changmeeting/features/places/domain/usecases/search_places.dart';
import 'package:changmeeting/features/places/domain/usecases/update_place.dart';
import 'package:changmeeting/features/places/presentation/bloc/places_bloc.dart';
import 'package:changmeeting/features/places/presentation/pages/places_page.dart';
import 'package:changmeeting/features/todo/data/datasources/local_database_service.dart';

class PlacesScreen extends StatelessWidget {
  const PlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PlacesBloc>(
      create: (_) {
        final db = LocalDatabaseService.instance.db;
        final PlacesRepository repository = PlacesRepositoryImpl(
          localDataSource: PlacesLocalDataSourceImpl(db),
          locationDataSource: LocationDataSourceImpl(),
        );
        return PlacesBloc(
          getAllPlaces: GetAllPlaces(repository),
          createPlace: CreatePlace(repository),
          updatePlace: UpdatePlace(repository),
          deletePlace: DeletePlace(repository),
          searchPlaces: SearchPlaces(repository),
          getCurrentLocation: GetCurrentLocation(repository),
        );
      },
      child: const PlacesPage(),
    );
  }
}
