import 'package:equatable/equatable.dart';
import 'address.entity.dart';

class OrderEntity extends Equatable {
  final String id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String phone;
  final String address;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String status; // Pending, Confirmed, Preparing, OutForDelivery, Delivered, Cancelled
  final DateTime createdAt;

  // Compatibility fields
  final String userId;
  final String userEmail;
  final double totalAmount;
  final DateTime updatedAt;
  final List<OrderItemEntity> items;
  final AddressEntity? shippingAddress;
  final String? couponCode;
  final double? discountAmount;
  final int? loyaltyPointsEarned;
  final int? loyaltyPointsRedeemed;
  final double? loyaltyDiscount;
  final Map<String, Map<String, int>>? batchAllocations;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.userId,
    required this.userEmail,
    required this.totalAmount,
    required this.updatedAt,
    required this.items,
    this.shippingAddress,
    this.couponCode,
    this.discountAmount,
    this.loyaltyPointsEarned,
    this.loyaltyPointsRedeemed,
    this.loyaltyDiscount,
    this.batchAllocations,
  });

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        customerId,
        customerName,
        phone,
        address,
        subtotal,
        deliveryFee,
        total,
        status,
        createdAt,
        userId,
        userEmail,
        totalAmount,
        updatedAt,
        items,
        shippingAddress,
        couponCode,
        discountAmount,
        loyaltyPointsEarned,
        loyaltyPointsRedeemed,
        loyaltyDiscount,
        batchAllocations,
      ];

  OrderEntity copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? customerName,
    String? phone,
    String? address,
    double? subtotal,
    double? deliveryFee,
    double? total,
    String? status,
    DateTime? createdAt,
    String? userId,
    String? userEmail,
    double? totalAmount,
    DateTime? updatedAt,
    List<OrderItemEntity>? items,
    AddressEntity? shippingAddress,
    String? couponCode,
    double? discountAmount,
    int? loyaltyPointsEarned,
    int? loyaltyPointsRedeemed,
    double? loyaltyDiscount,
    Map<String, Map<String, int>>? batchAllocations,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      totalAmount: totalAmount ?? this.totalAmount,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      couponCode: couponCode ?? this.couponCode,
      discountAmount: discountAmount ?? this.discountAmount,
      loyaltyPointsEarned: loyaltyPointsEarned ?? this.loyaltyPointsEarned,
      loyaltyPointsRedeemed: loyaltyPointsRedeemed ?? this.loyaltyPointsRedeemed,
      loyaltyDiscount: loyaltyDiscount ?? this.loyaltyDiscount,
      batchAllocations: batchAllocations ?? this.batchAllocations,
    );
  }
}

class OrderItemEntity extends Equatable {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  // Compatibility fields
  final String productNameAr;
  final String productNameEn;
  final double price;
  final String? imageUrl;
  final double? weight;
  final String? weightUnitId;

  const OrderItemEntity({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.productNameAr,
    required this.productNameEn,
    required this.price,
    this.imageUrl,
    this.weight,
    this.weightUnitId,
  });

  @override
  List<Object?> get props => [
        productId,
        productName,
        quantity,
        unitPrice,
        totalPrice,
        productNameAr,
        productNameEn,
        price,
        imageUrl,
        weight,
        weightUnitId,
      ];

  OrderItemEntity copyWith({
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    String? productNameAr,
    String? productNameEn,
    double? price,
    String? imageUrl,
    double? weight,
    String? weightUnitId,
  }) {
    return OrderItemEntity(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      productNameAr: productNameAr ?? this.productNameAr,
      productNameEn: productNameEn ?? this.productNameEn,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      weight: weight ?? this.weight,
      weightUnitId: weightUnitId ?? this.weightUnitId,
    );
  }
}
