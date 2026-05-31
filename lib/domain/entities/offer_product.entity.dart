import 'package:equatable/equatable.dart';

class OfferProductEntity extends Equatable {
  final String id;
  final String offerId;
  final String productId;
  final DateTime createdAt;

  const OfferProductEntity({
    required this.id,
    required this.offerId,
    required this.productId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, offerId, productId, createdAt];

  OfferProductEntity copyWith({
    String? id,
    String? offerId,
    String? productId,
    DateTime? createdAt,
  }) {
    return OfferProductEntity(
      id: id ?? this.id,
      offerId: offerId ?? this.offerId,
      productId: productId ?? this.productId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
