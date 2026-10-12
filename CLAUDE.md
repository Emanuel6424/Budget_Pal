# CLAUDE.md
Project intent, architecture map, stack rules, and workflow guardrails for BudgetPal.

---

## 1. Project Overview & Tech Stack
*   **Description**: BudgetPal is a full-stack personal budget management app. Users manage accounts, record transactions, organize spending by category, and set budgets.
*   **Backend (`server/`)**: Spring Boot (Java), Maven, REST API
*   **Auth**: Spring Security + JWT (stateless)
*   **Database**: PostgreSQL (schema `budgetpalproject`), managed by Liquibase (with Preliquibase for pre-migration setup)
*   **Frontend (`mobile_client/`)**: Flutter (Dart). Platform folders exist for iOS, Android, macOS, web, Linux, Windows. Mobile is the primary target.
*   **Domains**: `user`, `account`, `transaction`, `category`, `budget`

## 2. Commands
Exact invocations for this repo. Don't guess at conventional defaults.

**Backend (run from `server/`)**
*   **Run API**: `mvn spring-boot:run`
*   **Build**: `mvn clean package`
*   **Test**: `mvn test`
*   **Single test class**: `mvn test -Dtest=<ClassName>`
*   There is no Maven wrapper (`mvnw`) yet. Use `mvn`. If a wrapper is added later, update these.

**Frontend (run from `mobile_client/`)**
*   **Install deps**: `flutter pub get`
*   **Run app**: `flutter run`
*   **Analyze (lint)**: `flutter analyze`
*   **Format**: `dart format .`
*   **Test**: `flutter test`

**Database**
*   **First-time setup**: `cp .env.example .env` and set `POSTGRES_PASSWORD`.
*   **Start local Postgres**: `docker compose up -d` from the repo root (uses `compose.yaml` and `.env`, container `budgetpal_postgres_dev`, volume `postgres_db`).
*   **Stop**: `docker compose down`. **Full reset (destroys local data)**: `docker compose down -v`. Ask before running a reset.

## 3. Local Environment
*   **Local-first development**: Always develop and test against the **local** database. Never connect to a production or remote database during normal dev work.
*   **Secrets and config**: All credentials come from environment variables. Locally they live in `/.env` at the repo root (git-ignored). `/.env.example` is the committed template with placeholders only. `compose.yaml` and `server/.../application.yml` read these via `${VAR}` placeholders. Never hardcode a secret, never commit `.env`, never paste real values into code, docs, or Postman.
*   **Adding a new secret**: add it to `.env` (real value) and `.env.example` (placeholder), reference it as `${NAME}` in `application.yml` (no default for secrets), and mention it in the handoff summary.
*   **Before running DB-dependent commands**: Confirm Postgres is running. If it's not, start it. Don't fall back to remote credentials to "make it work."
*   **Ports**: Postgres `5432` (local, per `compose.yaml`). Spring Boot API uses the default `8080` unless `application.yml` says otherwise.
*   **Flutter emulator networking**: The Android emulator reaches the host machine at `10.0.2.2`, not `localhost`. The iOS simulator uses `localhost`. API URLs are defined in `mobile_client/lib/util/endpoints.dart`, never hardcoded in widgets.

## 4. Architecture Map
Reflects what exists today. Update as the structure changes.

**Backend (`server/`)**
*   `src/main/java/budgetpal/` - Application code, organized **by feature**:
    *   `user/`, `account/`, `transaction/`, `category/`, `budget/`
    *   `SecurityConfig.java`, `BudgetPalApplication.java` at the package root
*   `src/main/resources/db/migration/` - Liquibase: `changelog-root.xml` plus `versions/`. Source of truth for schema.
*   `src/main/resources/preliquibase/` - Pre-Liquibase setup scripts
*   `target/` - Build output. Never edit, never commit.

**Frontend (`mobile_client/`)**
*   `lib/models/` - Data models
*   `lib/util/` - `endpoints.dart` (API URLs) and `https_methods.dart` (HTTP helpers). **This is where HTTP calls live today.**
*   `lib/services/` - Exists but empty. Intended home for API communication.
*   `lib/providers/` - State management (`provider` package)
*   `lib/pages/` - Screens
*   `lib/widgets/` - Reusable widgets, grouped by feature
*   `assets/` - Image and icon assets
*   `test/` - Flutter tests
*   `ios/`, `android/`, `macos/`, `web/`, `linux/`, `windows/` - Generated platform scaffolding. Don't edit unless a task requires it (permissions, app icons, native config).
*   `build/`, `.dart_tool/`, `ios/Pods/`, `.idea/` - Generated or IDE files. Never edit, never commit.

**Planned structure (do not create or restructure toward this unless asked)**
*   Backend: a `dto/` layer, a global exception handler, backend tests under `src/test/`.
*   `server/postman/` - Postman collection (created the first time an endpoint is tested, per section 11).
*   Frontend: move HTTP code from `util/` into `services/`; `flutter_secure_storage` for the JWT; possible feature-first folders as the app grows.

## 5. Working Style
*   State assumptions. If a request has multiple reasonable interpretations or something is unclear, ask instead of picking silently.
*   If a simpler approach exists, say so and push back when warranted.
*   Plan first: before touching files, output a short plan (files to change, logic, risks). For multi-step tasks use:
    ```
    1. [Step] -> verify: [check]
    2. [Step] -> verify: [check]
    ```
*   Break up large tasks into small, reviewable steps. No massive multi-file overhauls.
*   **One side per session**: Work on either `server/` or `mobile_client/`, not both. When backend work is done, stop and hand off (section 11). If a prompt explicitly asks for both sides, ask before proceeding.

## 6. Git Workflow
*   **Feature isolation**: Before modifying code, check `git status`. Create a task-specific branch off `main` (e.g. `feature/jwt-refresh`, `bugfix/budget-total-rounding`). Skip only if the user says to work on the current branch.
*   **No direct commits to `main`.**
*   **Never commit or push unless asked.** When asked, use Conventional Commits (e.g. `feat: add monthly budget endpoint`).
*   **Clean up**: After the user merges a feature, checkout `main`, pull, and delete the local branch.

## 7. Verification
Loop until verified; don't just declare done.
*   **Backend changes**: Run `mvn clean package` from `server/`. A compile error or failing test is a blocker: read the log, fix it, repeat.
*   **Frontend changes**: Run `flutter analyze` and `flutter test` from `mobile_client/`. Zero analyzer errors. Fix warnings your change introduced.

## 8. Surgical Changes
*   Write the minimum code required. No speculative features, unrequested configs, or premature abstractions.
*   Touch only the lines required. Don't "improve" adjacent code, comments, or formatting. Match existing style.
*   Mention unrelated dead code; don't delete it unasked. Do remove imports/variables/methods that *your* change made unused.
*   Every changed line should trace to the user's request.

## 9. Backend Guardrails (Spring Boot)
*   **Secrets**: Never hardcode the JWT signing secret, DB passwords, or credentials. Use `application.yml` placeholders (e.g. `${JWT_SECRET}`) backed by `.env` / environment variables (see section 3).
*   **Follow the existing structure**: New code goes in the matching feature package, laid out like existing features.
*   **Don't expose entities**: Don't return JPA entities from endpoints if a request/response object is already the pattern in that feature. Validate request bodies with Bean Validation.
*   **Money**: `BigDecimal` and `NUMERIC` in Postgres. Never `double` or `float`.
*   **Ownership checks**: Every query for user data is scoped to the authenticated user. Never trust a user ID from a request body or path when the JWT already identifies the user.
*   **Auth**: Passwords hashed with BCrypt. Don't log tokens, passwords, or full request bodies on auth routes. Don't loosen security config to make a request pass.
*   **Schema changes**: Add a new Liquibase changeset under `db/migration/versions/` and register it in `changelog-root.xml`. Never edit an applied changeset, and never rely on `ddl-auto=update`.
*   **Schema awareness**: Inspect migrations and entities before writing queries. Never assume a table or column exists. Tables live in the `budgetpalproject` schema.

## 10. Frontend Guardrails (Flutter)
*   **API access**: HTTP calls go through the existing helpers in `lib/util/` (`endpoints.dart`, `https_methods.dart`). Widgets and pages never call `http` directly. Don't create a parallel HTTP approach; if moving to `lib/services/`, do it only when asked.
*   **Token storage**: Prefer `flutter_secure_storage` for the JWT, never plain `SharedPreferences`. It isn't a dependency yet; say why before adding it.
*   **Money display**: Format currency with `intl`. No float math on amounts in the UI. The server is the source of truth for totals.
*   **State**: Use the existing `provider` pattern in `lib/providers/`. Don't introduce a second state management approach.
*   **Models**: Match field names to backend responses exactly.
*   **UI hygiene**: Handle loading, empty, and error states on every screen that fetches data. Dispose controllers and subscriptions. Check `mounted` before using `BuildContext` after an `await`.
*   **Dependencies**: Don't add a package without saying why and checking for a lighter alternative.
*   **Generated files**: Don't hand-edit `ios/Pods`, `.symlinks`, or `build/`.

## 11. API Testing (Postman) & Handoff
Every new or changed controller endpoint ships with Postman tests so the user can verify it by hand.
*   **Collection file**: `server/postman/budgetpal.postman_collection.json` (Postman v2.1). Create on first use, then update in place. Never create a second collection.
*   **Structure**: One folder per feature (`user`, `account`, `transaction`, `category`, `budget`), plus an `auth` folder with register and login requests.
*   **Variables**: Collection variables `baseUrl` (local API URL) and `token`. The login request's test script saves the JWT into `token`. Protected requests use `Bearer {{token}}`.
*   **Test scripts**: Every request has `pm.test` assertions for status code and response shape (required fields and types).
*   **Cases per endpoint**: success, invalid body (400), missing or invalid token (401), not found (404), and accessing another user's data (must be denied).
*   **Test data**: Obvious placeholder values. No real credentials or tokens in the collection.
*   **Before finishing**: If the server can start locally, smoke-test new endpoints with `curl` and fix failures. Then tell the user which Postman requests to run and the expected result of each.
*   **Backend handoff**: End every backend session with a short summary per endpoint added or changed: method, path, auth required, request body, response body, error responses. The user uses this and the collection to start the Flutter session.

---

**This file is working if**: diffs contain fewer unnecessary changes, backend and Flutter builds stay green, and git history stays clean. When Claude repeats a mistake twice, add a line here. Prune anything stale. Keep this file under 200 lines.
