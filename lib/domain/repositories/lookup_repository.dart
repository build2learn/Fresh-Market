import '../../core/utils/result.dart';
import '../entities/lookup.entity.dart';

abstract class LookupRepository {
  Future<Result<List<LookupEntity>>> getLookups(String lookupType);
  Stream<List<LookupEntity>> watchLookups(String lookupType);
  Future<Result<LookupEntity>> createLookup(LookupEntity lookup);
  Future<Result<LookupEntity>> updateLookup(LookupEntity lookup);
  Future<Result<void>> deleteLookup(int id);
  Future<Result<void>> reorderLookups(String lookupType, List<int> ids);
}
