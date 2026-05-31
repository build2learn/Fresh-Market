import 'package:equatable/equatable.dart';

class RoleEntity extends Equatable {
  final String id;
  final String name;
  final List<String> permissions;
  final String? description;

  const RoleEntity({
    required this.id,
    required this.name,
    this.permissions = const [],
    this.description,
  });

  @override
  List<Object?> get props => [id, name, permissions, description];

  RoleEntity copyWith({
    String? id,
    String? name,
    List<String>? permissions,
    String? description,
  }) {
    return RoleEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      permissions: permissions ?? this.permissions,
      description: description ?? this.description,
    );
  }
}
