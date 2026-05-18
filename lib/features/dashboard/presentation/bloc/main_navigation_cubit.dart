import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../places/domain/entities/place_entity.dart';

class MainNavigationState extends Equatable {
  final int currentIndex;
  final bool pendingFinanceCreate;
  final PlaceEntity? pendingPlaceDetail;

  const MainNavigationState({
    this.currentIndex = 0,
    this.pendingFinanceCreate = false,
    this.pendingPlaceDetail,
  });

  MainNavigationState copyWith({
    int? currentIndex,
    bool? pendingFinanceCreate,
    PlaceEntity? pendingPlaceDetail,
    bool clearPendingPlace = false,
  }) {
    return MainNavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
      pendingFinanceCreate: pendingFinanceCreate ?? this.pendingFinanceCreate,
      pendingPlaceDetail: clearPendingPlace
          ? null
          : (pendingPlaceDetail ?? this.pendingPlaceDetail),
    );
  }

  @override
  List<Object?> get props => [
        currentIndex,
        pendingFinanceCreate,
        pendingPlaceDetail,
      ];
}

class MainNavigationCubit extends Cubit<MainNavigationState> {
  static const int dashboardTab = 0;
  static const int financeTab = 1;
  static const int todoTab = 2;
  static const int placesTab = 3;
  static const int profileTab = 4;

  MainNavigationCubit() : super(const MainNavigationState());

  void changeTab(int index) {
    if (state.currentIndex == index) return;
    emit(state.copyWith(currentIndex: index));
  }

  void openTodoTab() {
    emit(state.copyWith(currentIndex: todoTab));
  }

  void openFinanceTab() {
    emit(state.copyWith(currentIndex: financeTab));
  }

  void openPlacesTab() {
    emit(state.copyWith(currentIndex: placesTab));
  }

  void openFinanceCreateForm() {
    emit(state.copyWith(
      currentIndex: financeTab,
      pendingFinanceCreate: true,
    ));
  }

  void openPlaceDetail(PlaceEntity place) {
    emit(state.copyWith(
      currentIndex: placesTab,
      pendingPlaceDetail: place,
    ));
  }

  void consumeFinanceCreate() {
    if (!state.pendingFinanceCreate) return;
    emit(state.copyWith(pendingFinanceCreate: false));
  }

  void consumePlaceDetail() {
    if (state.pendingPlaceDetail == null) return;
    emit(state.copyWith(clearPendingPlace: true));
  }
}
