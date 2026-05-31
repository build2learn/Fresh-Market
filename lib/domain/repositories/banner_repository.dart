import 'dart:async';
import '../entities/banner.entity.dart';
import '../../core/utils/result.dart';

abstract interface class BannerRepository {
  Future<Result<List<BannerEntity>>> getBanners();
  Future<Result<List<BannerEntity>>> getActiveBanners();
  Stream<List<BannerEntity>> watchActiveBanners();
  Future<Result<BannerEntity>> createBanner(BannerEntity banner, {String? imagePath});
  Future<Result<BannerEntity>> updateBanner(BannerEntity banner, {String? imagePath});
  Future<Result<void>> reorderBanners(List<String> bannerIds);
  Future<Result<void>> deleteBanner(String bannerId);
}
