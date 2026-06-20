import '../dto/coupon.dto.dart';
import '../../domain/entities/coupon.entity.dart';

class CouponModel extends CouponDto {
  const CouponModel({
    required super.id,
    required super.code,
    required super.type,
    required super.discountValue,
    required super.minOrderAmount,
    required super.isActive,
    super.expiryDate,
    super.usageLimit,
    super.usedCount = 0,
  });

  factory CouponModel.fromDto(CouponDto dto) {
    return CouponModel(
      id: dto.id,
      code: dto.code,
      type: dto.type,
      discountValue: dto.discountValue,
      minOrderAmount: dto.minOrderAmount,
      isActive: dto.isActive,
      expiryDate: dto.expiryDate,
      usageLimit: dto.usageLimit,
      usedCount: dto.usedCount,
    );
  }

  factory CouponModel.fromEntity(CouponEntity entity) {
    return CouponModel(
      id: entity.id,
      code: entity.code,
      type: entity.type,
      discountValue: entity.discountValue,
      minOrderAmount: entity.minOrderAmount,
      isActive: entity.isActive,
      expiryDate: entity.expiryDate,
      usageLimit: entity.usageLimit,
      usedCount: entity.usedCount,
    );
  }

  CouponEntity toEntity() {
    return CouponEntity(
      id: id,
      code: code,
      type: type,
      discountValue: discountValue,
      minOrderAmount: minOrderAmount,
      isActive: isActive,
      expiryDate: expiryDate,
      usageLimit: usageLimit,
      usedCount: usedCount,
    );
  }
}
