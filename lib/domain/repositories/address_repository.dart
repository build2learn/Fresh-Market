import '../../core/utils/result.dart';
import '../entities/address.entity.dart';

abstract interface class AddressRepository {
  Future<Result<List<AddressEntity>>> getAddresses(String userId);
  Stream<List<AddressEntity>> watchAddresses(String userId);
  Future<Result<AddressEntity>> createAddress(AddressEntity address);
  Future<Result<AddressEntity>> updateAddress(AddressEntity address);
  Future<Result<void>> deleteAddress(String id);
}
