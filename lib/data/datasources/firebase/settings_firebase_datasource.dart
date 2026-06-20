import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../../core/errors/app_exception.dart';

abstract interface class SettingsFirebaseDataSource {
  Future<Map<String, dynamic>?> getSettings();
  Future<void> saveSettings(Map<String, dynamic> settings);
}

class SettingsFirebaseDataSourceImpl implements SettingsFirebaseDataSource {
  final FirebaseFirestore _firestore;

  SettingsFirebaseDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  DocumentReference<Map<String, dynamic>> get _docRef =>
      _firestore.collection(FirestoreConstants.settings).doc('app');

  @override
  Future<Map<String, dynamic>?> getSettings() async {
    try {
      final doc = await _docRef.get();
      return doc.data();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to fetch settings',
        code: e.code,
      );
    }
  }

  @override
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      await _docRef.set(settings, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to save settings',
        code: e.code,
      );
    }
  }
}
