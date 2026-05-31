import 'package:equatable/equatable.dart';
import '../../core/enums/setting_type.dart';

class SettingEntity extends Equatable {
  final String id;
  final dynamic value;
  final SettingType type;
  final String? description;
  final DateTime updatedAt;

  const SettingEntity({
    required this.id,
    required this.value,
    required this.type,
    this.description,
    required this.updatedAt,
  });

  String? get stringValue => type == SettingType.string ? value as String? : null;
  num? get numberValue => type == SettingType.number ? value as num? : null;
  bool? get boolValue => type == SettingType.bool ? value as bool? : null;
  Map<String, dynamic>? get jsonValue =>
      type == SettingType.json ? value as Map<String, dynamic>? : null;

  @override
  List<Object?> get props => [id, value, type, description, updatedAt];

  SettingEntity copyWith({
    String? id,
    dynamic value,
    SettingType? type,
    String? description,
    DateTime? updatedAt,
  }) {
    return SettingEntity(
      id: id ?? this.id,
      value: value ?? this.value,
      type: type ?? this.type,
      description: description ?? this.description,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
