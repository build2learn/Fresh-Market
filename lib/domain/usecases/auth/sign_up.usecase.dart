import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/user.entity.dart';
import 'package:fresh_market/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository _repository;

  SignUpUseCase(this._repository);

  Future<Result<UserEntity>> call(String email, String password, String? displayName) {
    return _repository.signUp(email, password, displayName);
  }
}
