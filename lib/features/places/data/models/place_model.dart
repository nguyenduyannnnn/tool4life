import 'dart:convert';

import '../../domain/entities/place_entity.dart';

class PlaceModel {
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

  const PlaceModel({
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

  factory PlaceModel.fromEntity(PlaceEntity entity) {
    return PlaceModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      latitude: entity.latitude,
      longitude: entity.longitude,
      imagePaths: entity.imagePaths,
      visitedAt: entity.visitedAt,
      tag: entity.tag,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  PlaceEntity toEntity() {
    return PlaceEntity(
      id: id,
      name: name,
      description: description,
      latitude: latitude,
      longitude: longitude,
      imagePaths: imagePaths,
      visitedAt: visitedAt,
      tag: tag,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'image_paths': jsonEncode(imagePaths),
      'visited_at': visitedAt.millisecondsSinceEpoch,
      'tag': tag,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory PlaceModel.fromMap(Map<String, Object?> map) {
    final raw = map['image_paths'] as String? ?? '[]';
    final list = (jsonDecode(raw) as List).cast<String>();
    return PlaceModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      imagePaths: list,
      visitedAt:
          DateTime.fromMillisecondsSinceEpoch(map['visited_at'] as int),
      tag: map['tag'] as String?,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: map['updated_at'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}
