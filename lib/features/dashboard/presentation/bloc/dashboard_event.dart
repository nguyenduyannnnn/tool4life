import 'package:equatable/equatable.dart';

import '../../../places/domain/entities/place_entity.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {
  const LoadDashboard();
}

class RefreshDashboard extends DashboardEvent {
  const RefreshDashboard();
}

class ToggleTodoExpand extends DashboardEvent {
  const ToggleTodoExpand();
}

class OpenFinanceQuickCreate extends DashboardEvent {
  const OpenFinanceQuickCreate();
}

class OpenTodoTab extends DashboardEvent {
  const OpenTodoTab();
}

class OpenPlacesTab extends DashboardEvent {
  const OpenPlacesTab();
}

class OpenFinanceTab extends DashboardEvent {
  const OpenFinanceTab();
}

class OpenPlaceDetail extends DashboardEvent {
  final PlaceEntity place;

  const OpenPlaceDetail(this.place);

  @override
  List<Object?> get props => [place];
}
