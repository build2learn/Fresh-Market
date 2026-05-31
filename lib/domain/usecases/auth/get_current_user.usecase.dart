import 'dart:async';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/user.entity.dart';
import 'package:fresh_market/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<Result<UserEntity?>> call() {
    return _repository.getCurrentUser();
  }
}

class WatchAuthStateUseCase {
  final AuthRepository _repository;

  WatchAuthStateUseCase(this._repository);

  Stream<UserEntity?> call() {
    return _repository.watchAuthState();
  }
}
