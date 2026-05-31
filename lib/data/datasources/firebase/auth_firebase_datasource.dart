import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:fresh_market/core/constants/firestore_constants.dart';

abstract interface class AuthFirebaseDataSource {
  Future<auth.UserCredential> signIn(String email, String password);
  Future<auth.UserCredential> signUp(String email, String password);
  Future<void> signOut();
  Stream<auth.User?> watchAuthState();
  auth.User? get currentUser;
  Future<Map<String, dynamic>?> getUserData(String uid);
  Future<void> createUserDocument(String uid, Map<String, dynamic> data);
  Future<void> sendPasswordReset(String email);
}

class AuthFirebaseDataSourceImpl implements AuthFirebaseDataSource {
  final auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthFirebaseDataSourceImpl({
    required auth.FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  @override
  Future<auth.UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<auth.UserCredential> signUp(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Stream<auth.User?> watchAuthState() => _auth.authStateChanges();

  @override
  auth.User? get currentUser => _auth.currentUser;

  @override
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection(FirestoreConstants.users).doc(uid).get();
    return doc.data();
  }

  @override
  Future<void> createUserDocument(String uid, Map<String, dynamic> data) async {
    await _firestore.collection(FirestoreConstants.users).doc(uid).set(data);
  }

  @override
  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }
}
