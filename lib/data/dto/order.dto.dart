import '../../core/constants/firestore_constants.dart';
import 'address.dto.dart';

class OrderDto {
  final String id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String phone;
  final String address;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String status;
  final DateTime createdAt;

  // Compatibility fields
  final String userId;
  final String userEmail;
  final double totalAmount;
  final DateTime updatedAt;
  final List<OrderItemDto> items;
  final AddressDto? shippingAddress;
  final String? couponCode;
  final double? discountAmount;
  final int? loyaltyPointsEarned;
  final int? loyaltyPointsRedeemed;
  final double? loyaltyDiscount;
  final Map<String, Map<String, int>>? batchAllocations;

  const OrderDto({
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

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value == null) return DateTime.now();
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      try {
        return DateTime.parse(value.toString());
      } catch (err) {
        return DateTime.now();
      }
    }
  }

  factory OrderDto.fromMap(Map<String, dynamic> map, String documentId) {
    final rawItems = map['items'] as List? ?? [];
    final itemsList = rawItems
        .map((e) => OrderItemDto.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    final shippingAddressMap = map['shippingAddress'] != null 
        ? Map<String, dynamic>.from(map['shippingAddress'] as Map) 
        : null;
    final shippingAddress = shippingAddressMap != null
        ? AddressDto.fromMap(shippingAddressMap, shippingAddressMap['id'] as String? ?? '')
        : null;

    final customerIdVal = map['customerId'] as String? ?? map['userId'] as String? ?? '';
    final totalVal = (map['total'] as num?)?.toDouble() ?? (map['totalAmount'] as num?)?.toDouble() ?? 0.0;
    final subtotalVal = (map['subtotal'] as num?)?.toDouble() ?? 0.0;
    final deliveryFeeVal = (map['deliveryFee'] as num?)?.toDouble() ?? 0.0;

    return OrderDto(
      id: documentId,
      orderNumber: map['orderNumber'] as String? ?? '',
      customerId: customerIdVal,
      customerName: map['customerName'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      address: map['address'] as String? ?? '',
      subtotal: subtotalVal,
      deliveryFee: deliveryFeeVal,
      total: totalVal,
      status: map['status'] as String? ?? 'Pending',
      createdAt: _toDateTime(map[FirestoreConstants.createdAt]),
      updatedAt: _toDateTime(map[FirestoreConstants.updatedAt]),
      userId: customerIdVal,
      userEmail: map['userEmail'] as String? ?? '',
      totalAmount: totalVal,
      items: itemsList,
      shippingAddress: shippingAddress,
      couponCode: map['couponCode'] as String?,
      discountAmount: (map['discountAmount'] as num?)?.toDouble(),
      loyaltyPointsEarned: map['loyaltyPointsEarned'] as int?,
      loyaltyPointsRedeemed: map['loyaltyPointsRedeemed'] as int?,
      loyaltyDiscount: (map['loyaltyDiscount'] as num?)?.toDouble(),
      batchAllocations: map['batchAllocations'] != null
          ? (map['batchAllocations'] as Map).map(
              (key, val) => MapEntry(
                key as String,
                (val as Map).map(
                  (k, v) => MapEntry(k as String, v as int),
                ),
              ),
            )
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderNumber': orderNumber,
      'customerId': customerId,
      'customerName': customerName,
      'phone': phone,
      'address': address,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'status': status,
      'userId': userId,
      'userEmail': userEmail,
      'totalAmount': totalAmount,
      FirestoreConstants.createdAt: createdAt.toIso8601String(),
      FirestoreConstants.updatedAt: updatedAt.toIso8601String(),
      'items': items.map((e) => e.toMap()).toList(),
      'shippingAddress': shippingAddress != null
          ? (shippingAddress!.toMap()..['id'] = shippingAddress!.id)
          : null,
      'couponCode': couponCode,
      'discountAmount': discountAmount,
      'loyaltyPointsEarned': loyaltyPointsEarned,
      'loyaltyPointsRedeemed': loyaltyPointsRedeemed,
      'loyaltyDiscount': loyaltyDiscount,
      'batchAllocations': batchAllocations,
    };
  }
}

class OrderItemDto {
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

  const OrderItemDto({
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

  factory OrderItemDto.fromMap(Map<String, dynamic> map) {
    final qty = map['quantity'] as int? ?? 1;
    final unitP = (map['unitPrice'] as num?)?.toDouble() ?? (map['price'] as num?)?.toDouble() ?? 0.0;
    final totalP = (map['totalPrice'] as num?)?.toDouble() ?? (unitP * qty);
    final prodName = map['productName'] as String? ?? map['productNameEn'] as String? ?? '';

    return OrderItemDto(
      productId: map['productId'] as String? ?? '',
      productName: prodName,
      quantity: qty,
      unitPrice: unitP,
      totalPrice: totalP,
      productNameAr: map['productNameAr'] as String? ?? '',
      productNameEn: map['productNameEn'] as String? ?? '',
      price: unitP,
      imageUrl: map['imageUrl'] as String?,
      weight: (map['weight'] as num?)?.toDouble(),
      weightUnitId: map['weightUnitId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'productNameAr': productNameAr,
      'productNameEn': productNameEn,
      'price': price,
      'imageUrl': imageUrl,
      'weight': weight,
      'weightUnitId': weightUnitId,
    };
  }
}
