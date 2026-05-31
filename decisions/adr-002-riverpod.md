# ADR-002: State Management with Riverpod

## Status
Accepted

## Context
The application requires a state management solution that supports real-time data streams from Firestore, dependency injection, compile-time safety, and a testable architecture.

## Options Considered
1. **Provider** - Mature but lacks compile-time safety, no auto-dispose.
2. **Riverpod** - Compile-time safety, auto-dispose, stream support, DI built-in.
3. **Bloc** - Powerful but verbose; more boilerplate for simple state.
4. **GetX** - Simple but lacks compile-time safety; anti-pattern concerns.

## Decision
Use Riverpod as the state management and dependency injection framework.

## Consequences

### Positive
- `StreamProvider` maps directly to Firestore real-time streams.
- No `BuildContext` dependency for accessing state.
- Auto-dispose prevents memory leaks.
- Provider overrides make testing straightforward.
- Family providers support parameterized queries (e.g., product by ID).

### Negative
- Relatively newer compared to Provider; smaller community.
- Code generation with Riverpod Generator is optional but adds build steps.
- Learning curve for `ref.watch` vs `ref.read` semantics.

## Compliance
- All state management will use Riverpod.
- No global static state.
- Providers scoped by feature.
