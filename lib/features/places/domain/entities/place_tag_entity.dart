import 'package:equatable/equatable.dart';

class PlaceTagEntity extends Equatable {
  final String id;
  final String name;
  final String icon;

  const PlaceTagEntity({
    required this.id,
    required this.name,
    required this.icon,
  });

  @override
  List<Object?> get props => [id, name, icon];

  static const List<PlaceTagEntity> defaults = [
    PlaceTagEntity(id: 'travel', name: 'Du lịch', icon: 'flight'),
    PlaceTagEntity(id: 'food', name: 'Ăn uống', icon: 'restaurant'),
    PlaceTagEntity(id: 'work', name: 'Công việc', icon: 'work'),
    PlaceTagEntity(id: 'family', name: 'Gia đình', icon: 'family'),
    PlaceTagEntity(id: 'friends', name: 'Bạn bè', icon: 'group'),
    PlaceTagEntity(id: 'other', name: 'Khác', icon: 'more_horiz'),
  ];

  static PlaceTagEntity? findById(String? id) {
    if (id == null) return null;
    for (final t in defaults) {
      if (t.id == id) return t;
    }
    return null;
  }
}
