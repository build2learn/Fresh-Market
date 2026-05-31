# Security Strategy

## Overview
Security is implemented at multiple layers: Firebase Security Rules, authentication, role-based access control, and application-level guards.

## 1. Firebase Security Rules

### roles Collection
```
- Read: authenticated users
- Write: admin only
```

### users Collection
```
- Read: admin can read all; user can read own document
- Write: admin only (except user can update own fcmToken and displayName)
- Create: auth token matches requested userId
```

### categories Collection
```
- Read: any authenticated user
- Write: admin only
```

### products Collection
```
- Read: any authenticated user
- Write: admin only
```

### offers Collection
```
- Read: any authenticated user
- Write: admin only
```

### offer_products Collection
```
- Read: any authenticated user
- Write: admin only
```

### weight_units Collection
```
- Read: any authenticated user
- Write: admin only
```

### settings Collection
```
- Read: any authenticated user
- Write: admin only
```

### notifications Collection
```
- Read: user can read only own notifications (userId == auth.uid)
- Write: admin can create; system functions can create
```

## 2. Authentication Flow
- Firebase Authentication with email/password.
- On sign-in, fetch user document from Firestore `users` collection.
- Verify `role` field (string: `admin` or `customer`) and `isActive` status.
- The `role` field is a denormalized string (not a reference) to enable efficient security rules without cross-collection reads.
- Admin role allows access to admin routes.
- Customer role restricted to customer routes.

## 3. Role-Based Access Control

### Admin Role
- Full CRUD on products, categories, offers, users, settings.
- Access to admin dashboard and all admin pages.
- Can manage other users and assign roles.

### Customer Role
- Read-only access to products, categories, offers.
- Can receive notifications.
- No access to admin routes or admin API.

## 4. Application-Level Guards

### Route Guards
- `AuthGuard` - Redirects unauthenticated users to sign-in page.
- `AdminGuard` - Redirects non-admin users to home page.
- Implemented as GoRouter redirects.

### Provider Guards
- Admin providers check user role before allowing state changes.
- Use cases check admin status before executing privileged operations.

## 5. Data Validation
- All inputs validated on the client before submission.
- Server-side validation via Cloud Functions for critical operations.
- Firestore validate rules prevent malformed data writes.

## 6. Secure Storage
- Firebase Auth tokens stored securely by Firebase SDK.
- No API keys or secrets in client code.
- Firebase config fetched from remote config where sensitive.
