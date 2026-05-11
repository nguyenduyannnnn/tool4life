import 'package:equatable/equatable.dart';

class PlaceEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final List<String> imagePaths;
  final DateTime visitedAt;
  final String? tag;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PlaceEntity({
    required this.id,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.imagePaths,
    required this.visitedAt,
    this.tag,
    required this.createdAt,
    this.updatedAt,
  });

  PlaceEntity copyWith({
    String? id,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    List<String>? imagePaths,
    DateTime? visitedAt,
    String? tag,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlaceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imagePaths: imagePaths ?? this.imagePaths,
      visitedAt: visitedAt ?? this.visitedAt,
      tag: tag ?? this.tag,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        latitude,
        longitude,
        imagePaths,
        visitedAt,
        tag,
        createdAt,
        updatedAt,
      ];
}
