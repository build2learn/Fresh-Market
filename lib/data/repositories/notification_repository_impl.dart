import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/enums/notification_type.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/notification.entity.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepositoryImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _notificationsCol => _firestore.collection(FirestoreConstants.notifications);

  @override
  Future<Result<List<NotificationEntity>>> getNotifications(String userId, {int limit = 50}) async {
    try {
      final snapshot = await _notificationsCol
          .where('userId', whereIn: [userId, 'all'])
          .orderBy(FirestoreConstants.createdAt, descending: true)
          .limit(limit)
          .get();

      final list = snapshot.docs.map((doc) {
        return _mapToEntity(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
      return Success(list);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Stream<List<NotificationEntity>> watchNotifications(String userId) {
    return _notificationsCol
        .where('userId', whereIn: [userId, 'all'])
        .orderBy(FirestoreConstants.createdAt, descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => _mapToEntity(doc.id, doc.data() as Map<String, dynamic>)).toList();
        });
  }

  @override
  Future<Result<void>> markAsRead(String notificationId) async {
    try {
      await _notificationsCol.doc(notificationId).update({
        FirestoreConstants.isRead: true,
      });
      return const Success(null);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _notificationsCol
          .where('userId', isEqualTo: userId)
          .where(FirestoreConstants.isRead, isEqualTo: false)
          .get();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {FirestoreConstants.isRead: true});
      }
      await batch.commit();
      return const Success(null);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<NotificationEntity>> createNotification(NotificationEntity notification) async {
    try {
      final docRef = _notificationsCol.doc();
      final data = {
        'userId': notification.userId,
        'title': notification.title,
        'body': notification.body,
        'type': notification.type.value,
        FirestoreConstants.isRead: notification.isRead,
        FirestoreConstants.createdAt: FieldValue.serverTimestamp(),
        if (notification.data != null) 'data': notification.data,
      };
      await docRef.set(data);
      
      // Fetch the created doc to ensure correct creation timestamp
      final createdDoc = await docRef.get();
      final createdData = createdDoc.data() as Map<String, dynamic>;
      
      return Success(_mapToEntity(docRef.id, createdData));
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  NotificationEntity _mapToEntity(String id, Map<String, dynamic> map) {
    DateTime createdAtVal;
    final rawCreated = map[FirestoreConstants.createdAt];
    if (rawCreated is Timestamp) {
      createdAtVal = rawCreated.toDate();
    } else if (rawCreated is String) {
      createdAtVal = DateTime.tryParse(rawCreated) ?? DateTime.now();
    } else {
      createdAtVal = DateTime.now();
    }

    return NotificationEntity(
      id: id,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      type: NotificationType.fromString(map['type'] as String? ?? 'system'),
      data: map['data'] as Map<String, dynamic>?,
      isRead: map[FirestoreConstants.isRead] as bool? ?? false,
      createdAt: createdAtVal,
    );
  }
}
