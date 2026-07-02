import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_market/core/enums/user_role.dart';

// Simulated database representation of a user document
class MockUserDoc {
  final String uid;
  final UserRole role;
  MockUserDoc(this.uid, this.role);
}

// Simulated request context
class SecurityRequest {
  final MockUserDoc? auth;
  final Map<String, dynamic> resourceData;
  SecurityRequest({this.auth, required this.resourceData});
}

// Simulated existing document context
class SecurityResource {
  final Map<String, dynamic> data;
  SecurityResource(this.data);
}

// Evaluates security rules assertions in pure Dart for programmatic validation
class SecurityRulesEvaluator {
  static bool isAuthenticated(SecurityRequest request) {
    return request.auth != null;
  }

  static bool isOwner(SecurityRequest request, String userId) {
    return isAuthenticated(request) && request.auth!.uid == userId;
  }

  static bool isStaffUser(MockUserDoc? authUser) {
    return authUser != null && authUser.role != UserRole.customer;
  }

  // Categories Write Rule Evaluation
  static bool canWriteCategory(SecurityRequest request) {
    if (!isAuthenticated(request)) return false;
    final user = request.auth!;
    return isStaffUser(user) && (user.role == UserRole.admin || user.role == UserRole.manager);
  }

  // Orders Create Rule Evaluation
  static bool canCreateOrder(SecurityRequest request) {
    if (!isAuthenticated(request)) return false;
    final userId = request.resourceData['userId'] as String?;
    final customerId = request.resourceData['customerId'] as String?;
    return isOwner(request, userId ?? '') || isOwner(request, customerId ?? '');
  }

  // Orders Read Rule Evaluation
  static bool canReadOrder(SecurityRequest request, SecurityResource resource) {
    if (!isAuthenticated(request)) return false;
    final userId = resource.data['userId'] as String?;
    final customerId = resource.data['customerId'] as String?;
    return isOwner(request, userId ?? '') || 
           isOwner(request, customerId ?? '') || 
           isStaffUser(request.auth);
  }

  // Orders Update Rule Evaluation
  static bool canUpdateOrder(SecurityRequest request, SecurityResource resource) {
    if (!isAuthenticated(request)) return false;
    if (isStaffUser(request.auth)) return true;

    final userId = resource.data['userId'] as String?;
    final customerId = resource.data['customerId'] as String?;
    final isOwnOrder = isOwner(request, userId ?? '') || isOwner(request, customerId ?? '');

    final newStatus = request.resourceData['status'] as String?;
    final oldStatus = resource.data['status'] as String?;
    final newCustId = request.resourceData['customerId'] as String?;
    final oldCustId = resource.data['customerId'] as String?;
    final newUserId = request.resourceData['userId'] as String?;
    final oldUserId = resource.data['userId'] as String?;
    final newTotal = request.resourceData['total'] as num?;
    final oldTotal = resource.data['total'] as num?;

    return isOwnOrder &&
           newStatus == 'Cancelled' &&
           oldStatus == 'Pending' &&
           newCustId == oldCustId &&
           newUserId == oldUserId &&
           newTotal == oldTotal;
  }

  // Storage Rule Evaluation: Category/Product images upload
  static bool canUploadProductImage(SecurityRequest request) {
    return isAuthenticated(request) && isStaffUser(request.auth);
  }

  // Storage Rule Evaluation: User profile upload
  static bool canUploadUserProfile(SecurityRequest request, String targetUserId) {
    return isAuthenticated(request) && request.auth!.uid == targetUserId;
  }
}

void main() {
  group('Firestore Security Rules Runtime Simulation & Attack Validation', () {
    final unauthRequest = SecurityRequest(auth: null, resourceData: {});
    
    final customer = MockUserDoc('cust_123', UserRole.customer);
    final customerRequest = SecurityRequest(auth: customer, resourceData: {});

    final admin = MockUserDoc('admin_789', UserRole.admin);
    final adminRequest = SecurityRequest(auth: admin, resourceData: {});

    test('1. Unauthenticated User Restrictions', () {
      expect(SecurityRulesEvaluator.canWriteCategory(unauthRequest), false);
      expect(SecurityRulesEvaluator.canCreateOrder(unauthRequest), false);
      expect(SecurityRulesEvaluator.canUploadProductImage(unauthRequest), false);
    });

    test('2. Customer Account Authorized Operations', () {
      final validOrderRequest = SecurityRequest(
        auth: customer,
        resourceData: {'customerId': 'cust_123', 'userId': 'cust_123', 'status': 'Pending', 'total': 150.0},
      );
      expect(SecurityRulesEvaluator.canCreateOrder(validOrderRequest), true);

      final ownResource = SecurityResource({'customerId': 'cust_123', 'userId': 'cust_123', 'status': 'Pending', 'total': 150.0});
      expect(SecurityRulesEvaluator.canReadOrder(customerRequest, ownResource), true);

      // Customer CAN cancel own Pending order
      final cancelOwnOrderRequest = SecurityRequest(
        auth: customer,
        resourceData: {'customerId': 'cust_123', 'userId': 'cust_123', 'status': 'Cancelled', 'total': 150.0},
      );
      expect(SecurityRulesEvaluator.canUpdateOrder(cancelOwnOrderRequest, ownResource), true);

      // Customer CAN upload own profile image
      expect(SecurityRulesEvaluator.canUploadUserProfile(customerRequest, 'cust_123'), true);
    });

    test('3. Customer Unauthorized Operations / Attacks', () {
      // Customer cannot write categories
      expect(SecurityRulesEvaluator.canWriteCategory(customerRequest), false);

      // Customer cannot upload product images
      expect(SecurityRulesEvaluator.canUploadProductImage(customerRequest), false);

      // Customer cannot upload another customer's profile image
      expect(SecurityRulesEvaluator.canUploadUserProfile(customerRequest, 'other_cust_456'), false);

      // Attack: Customer edits another user's order
      final otherResource = SecurityResource({'customerId': 'other_cust_456', 'userId': 'other_cust_456', 'status': 'Pending', 'total': 150.0});
      expect(SecurityRulesEvaluator.canReadOrder(customerRequest, otherResource), false);
      
      final editOtherOrderRequest = SecurityRequest(
        auth: customer,
        resourceData: {'customerId': 'other_cust_456', 'userId': 'other_cust_456', 'status': 'Cancelled', 'total': 150.0},
      );
      expect(SecurityRulesEvaluator.canUpdateOrder(editOtherOrderRequest, otherResource), false);

      // Attack: Customer changes price during cancellation
      final priceTamperRequest = SecurityRequest(
        auth: customer,
        resourceData: {'customerId': 'cust_123', 'userId': 'cust_123', 'status': 'Cancelled', 'total': 5.0}, // tampered price
      );
      final ownResource = SecurityResource({'customerId': 'cust_123', 'userId': 'cust_123', 'status': 'Pending', 'total': 150.0});
      expect(SecurityRulesEvaluator.canUpdateOrder(priceTamperRequest, ownResource), false);
    });

    test('4. Admin / Staff Authorized Operations', () {
      expect(SecurityRulesEvaluator.canWriteCategory(adminRequest), true);
      expect(SecurityRulesEvaluator.canUploadProductImage(adminRequest), true);

      final customerResource = SecurityResource({'customerId': 'cust_123', 'userId': 'cust_123', 'status': 'Pending', 'total': 150.0});
      expect(SecurityRulesEvaluator.canReadOrder(adminRequest, customerResource), true);

      // Admin can execute status change update on another user's order
      final adminStatusUpdate = SecurityRequest(
        auth: admin,
        resourceData: {'customerId': 'cust_123', 'userId': 'cust_123', 'status': 'Processing', 'total': 150.0},
      );
      expect(SecurityRulesEvaluator.canUpdateOrder(adminStatusUpdate, customerResource), true);
    });
  });
}
