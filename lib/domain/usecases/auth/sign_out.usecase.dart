import 'package:fresh_market/domain/repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository _repository;

  SignOutUseCase(this._repository);

  Future<void> call() => _repository.signOut();
}
