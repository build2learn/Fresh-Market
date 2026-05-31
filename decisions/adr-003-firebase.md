# ADR-003: Firebase as Backend Platform

## Status
Accepted

## Context
The application requires real-time data synchronization, authentication, file storage, push notifications, and scalable NoSQL storage across Android, iOS, and Web platforms.

## Options Considered
1. **Firebase** - Complete ecosystem with auth, Firestore, Storage, FCM.
2. **Supabase** - PostgreSQL-based; good alternative but less integrated real-time.
3. **Custom REST API** - Full control but requires backend development and hosting.
4. **AWS Amplify** - Powerful but complex setup; higher learning curve.

## Decision
Use Firebase as the primary backend platform.

## Consequences

### Positive
- Firestore provides real-time listeners out of the box.
- Firebase Authentication handles email/password and social auth.
- Firebase Storage for product and category images.
- FCM for push notifications (offers, product updates).
- Generous free tier for development.
- Google Cloud Functions for server-side logic when needed.
- Firebase Hosting for web deployment.

### Negative
- Tight coupling to Google Cloud ecosystem.
- NoSQL limitations for complex relational queries.
- Firestore read/write costs at scale.
- Limited query capabilities (no full-text search natively).
- Vendor lock-in concerns.

## Mitigations
- Abstract Firebase behind repository interfaces in domain layer.
- Use local caching to minimize Firestore reads.
- Consider Algolia or MeiliSearch for full-text search if needed.
- Data layer can be swapped if vendor migration is required.

## Compliance
- Firebase imports only allowed in data layer.
- Domain entities have no Firebase dependencies.
- Repository interfaces are pure Dart.
