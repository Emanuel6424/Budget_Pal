# CLAUDE.md (server/)
Backend-specific guardrails. See the repo-root `CLAUDE.md` for project-wide rules.

## Backend Guardrails (Spring Boot)
*   **Secrets**: Never hardcode the JWT signing secret, DB passwords, or credentials. Use `application.yml` placeholders (e.g. `${JWT_SECRET}`) backed by `.env` / environment variables (see root CLAUDE.md section 3).
*   **Follow the existing structure**: New code goes in the matching feature package, laid out like existing features.
*   **Don't expose entities**: Don't return JPA entities from endpoints if a request/response object is already the pattern in that feature. Validate request bodies with Bean Validation.
*   **Money**: `BigDecimal` and `NUMERIC` in Postgres. Never `double` or `float`.
*   **Ownership checks**: Every query for user data is scoped to the authenticated user. Never trust a user ID from a request body or path when the JWT already identifies the user.
*   **Auth**: Passwords hashed with BCrypt. Don't log tokens, passwords, or full request bodies on auth routes. Don't loosen security config to make a request pass.
*   **Schema changes**: Add a new Liquibase changeset under `db/migration/versions/` and register it in `changelog-root.xml`. Never edit an applied changeset, and never rely on `ddl-auto=update`.
*   **Schema awareness**: Inspect migrations and entities before writing queries. Never assume a table or column exists. Tables live in the `budgetpalproject` schema.
