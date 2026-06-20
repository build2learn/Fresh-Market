import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/enums/user_role.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/user.entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../dto/user.dto.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;

  UserRepositoryImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _usersCol => _firestore.collection(FirestoreConstants.users);

  @override
  Future<Result<List<UserEntity>>> getUsers({required int limit, dynamic lastDoc}) async {
    try {
      Query query = _usersCol.orderBy(FirestoreConstants.createdAt, descending: true).limit(limit);
      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc as DocumentSnapshot);
      }
      final snapshot = await query.get();
      final users = snapshot.docs.map((doc) {
        final dto = UserDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        return UserModel.fromDto(dto).toEntity();
      }).toList();
      return Success(users);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> getUser(String id) async {
    try {
      final doc = await _usersCol.doc(id).get();
      if (!doc.exists) {
        return Failure(FirestoreException(message: 'User not found'));
      }
      final dto = UserDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      return Success(UserModel.fromDto(dto).toEntity());
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> updateUserRole(String userId, String role) async {
    try {
      await _usersCol.doc(userId).update({
        'role': role,
        FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
      });
      return getUser(userId);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> toggleUserActive(String userId, bool isActive) async {
    try {
      await _usersCol.doc(userId).update({
        FirestoreConstants.isActive: isActive,
        FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
      });
      return getUser(userId);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> updateProfile({
    required String userId,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    String? fcmToken,
  }) async {
    try {
      final updates = <String, dynamic>{
        FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
      };
      if (displayName != null) updates['displayName'] = displayName;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      if (fcmToken != null) updates['fcmToken'] = fcmToken;

      await _usersCol.doc(userId).update(updates);
      return getUser(userId);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> updateFcmToken(String userId, String token) async {
    try {
      await _usersCol.doc(userId).update({
        'fcmToken': token,
        FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
      });
      return getUser(userId);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> updateLoyalty(
    String userId, {
    required int loyaltyPoints,
    required int lifetimePoints,
    required String membershipLevel,
  }) async {
    try {
      await _usersCol.doc(userId).update({
        'loyaltyPoints': loyaltyPoints,
        'lifetimePoints': lifetimePoints,
        'membershipLevel': membershipLevel,
        FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
      });
      return getUser(userId);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }
}
