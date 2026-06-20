import 'package:equatable/equatable.dart';

class DeliveryZoneEntity extends Equatable {
  final String id;
  final String name;
  final double deliveryFee;
  final double minimumOrder;
  final String estimatedTime;

  const DeliveryZoneEntity({
    required this.id,
    required this.name,
    required this.deliveryFee,
    required this.minimumOrder,
    required this.estimatedTime,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        deliveryFee,
        minimumOrder,
        estimatedTime,
      ];

  DeliveryZoneEntity copyWith({
    String? id,
    String? name,
    double? deliveryFee,
    double? minimumOrder,
    String? estimatedTime,
  }) {
    return DeliveryZoneEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      minimumOrder: minimumOrder ?? this.minimumOrder,
      estimatedTime: estimatedTime ?? this.estimatedTime,
    );
  }
}
