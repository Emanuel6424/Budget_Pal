# CLAUDE.md (mobile_client/)
Frontend-specific guardrails. See the repo-root `CLAUDE.md` for project-wide rules.

## Frontend Guardrails (Flutter)
*   **API access**: HTTP calls go through the existing helpers in `lib/util/` (`endpoints.dart`, `https_methods.dart`). Widgets and pages never call `http` directly. Don't create a parallel HTTP approach; if moving to `lib/services/`, do it only when asked.
*   **Token storage**: Prefer `flutter_secure_storage` for the JWT, never plain `SharedPreferences`. It isn't a dependency yet; say why before adding it.
*   **Money display**: Format currency with `intl`. No float math on amounts in the UI. The server is the source of truth for totals.
*   **State**: Use the existing `provider` pattern in `lib/providers/`. Don't introduce a second state management approach.
*   **Models**: Match field names to backend responses exactly.
*   **UI hygiene**: Handle loading, empty, and error states on every screen that fetches data. Dispose controllers and subscriptions. Check `mounted` before using `BuildContext` after an `await`.
*   **Dependencies**: Don't add a package without saying why and checking for a lighter alternative.
*   **Generated files**: Don't hand-edit `ios/Pods`, `.symlinks`, or `build/`.
