import '../../domain/entities/order.entity.dart';
import '../dto/order.dto.dart';
import 'address_model.dart';

class OrderModel {
  static OrderEntity fromDto(OrderDto dto) {
    return OrderEntity(
      id: dto.id,
      orderNumber: dto.orderNumber,
      customerId: dto.customerId,
      customerName: dto.customerName,
      phone: dto.phone,
      address: dto.address,
      subtotal: dto.subtotal,
      deliveryFee: dto.deliveryFee,
      total: dto.total,
      status: dto.status,
      createdAt: dto.createdAt,
      userId: dto.userId,
      userEmail: dto.userEmail,
      totalAmount: dto.totalAmount,
      updatedAt: dto.updatedAt,
      items: dto.items.map((e) => _itemFromDto(e)).toList(),
      shippingAddress: dto.shippingAddress != null
          ? AddressModel.fromDto(dto.shippingAddress!)
          : null,
      couponCode: dto.couponCode,
      discountAmount: dto.discountAmount,
      loyaltyPointsEarned: dto.loyaltyPointsEarned,
      loyaltyPointsRedeemed: dto.loyaltyPointsRedeemed,
      loyaltyDiscount: dto.loyaltyDiscount,
      batchAllocations: dto.batchAllocations,
    );
  }

  static OrderDto fromEntity(OrderEntity entity) {
    return OrderDto(
      id: entity.id,
      orderNumber: entity.orderNumber,
      customerId: entity.customerId,
      customerName: entity.customerName,
      phone: entity.phone,
      address: entity.address,
      subtotal: entity.subtotal,
      deliveryFee: entity.deliveryFee,
      total: entity.total,
      status: entity.status,
      createdAt: entity.createdAt,
      userId: entity.userId,
      userEmail: entity.userEmail,
      totalAmount: entity.totalAmount,
      updatedAt: entity.updatedAt,
      items: entity.items.map((e) => _itemFromEntity(e)).toList(),
      shippingAddress: entity.shippingAddress != null
          ? AddressModel.fromEntity(entity.shippingAddress!)
          : null,
      couponCode: entity.couponCode,
      discountAmount: entity.discountAmount,
      loyaltyPointsEarned: entity.loyaltyPointsEarned,
      loyaltyPointsRedeemed: entity.loyaltyPointsRedeemed,
      loyaltyDiscount: entity.loyaltyDiscount,
      batchAllocations: entity.batchAllocations,
    );
  }

  static OrderItemEntity _itemFromDto(OrderItemDto dto) {
    return OrderItemEntity(
      productId: dto.productId,
      productName: dto.productName,
      quantity: dto.quantity,
      unitPrice: dto.unitPrice,
      totalPrice: dto.totalPrice,
      productNameAr: dto.productNameAr,
      productNameEn: dto.productNameEn,
      price: dto.price,
      imageUrl: dto.imageUrl,
      weight: dto.weight,
      weightUnitId: dto.weightUnitId,
    );
  }

  static OrderItemDto _itemFromEntity(OrderItemEntity entity) {
    return OrderItemDto(
      productId: entity.productId,
      productName: entity.productName,
      quantity: entity.quantity,
      unitPrice: entity.unitPrice,
      totalPrice: entity.totalPrice,
      productNameAr: entity.productNameAr,
      productNameEn: entity.productNameEn,
      price: entity.price,
      imageUrl: entity.imageUrl,
      weight: entity.weight,
      weightUnitId: entity.weightUnitId,
    );
  }
}
