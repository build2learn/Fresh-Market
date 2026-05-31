import 'package:fresh_market/domain/repositories/auth_repository.dart';

class SendPasswordResetUseCase {
  final AuthRepository _repository;

  SendPasswordResetUseCase(this._repository);

  Future<void> call(String email) {
    return _repository.sendPasswordReset(email);
  }
}
