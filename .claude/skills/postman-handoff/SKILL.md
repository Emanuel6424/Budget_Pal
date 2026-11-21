---
name: postman-handoff
description: Use when adding or changing a BudgetPal backend controller endpoint, to ship Postman tests and write the backend handoff summary.
---

# Postman Testing & Handoff

Every new or changed controller endpoint ships with Postman tests so the user can verify it by hand.

*   **Collection file**: `server/postman/budgetpal.postman_collection.json` (Postman v2.1). Create on first use, then update in place. Never create a second collection.
*   **Structure**: One folder per feature (`user`, `account`, `transaction`, `category`, `budget`), plus an `auth` folder with register and login requests.
*   **Variables**: Collection variables `baseUrl` (local API URL) and `token`. The login request's test script saves the JWT into `token`. Protected requests use `Bearer {{token}}`.
*   **Test scripts**: Every request has `pm.test` assertions for status code and response shape (required fields and types).
*   **Cases per endpoint**: success, invalid body (400), missing or invalid token (401), not found (404), and accessing another user's data (must be denied).
*   **Test data**: Obvious placeholder values. No real credentials or tokens in the collection.
*   **Before finishing**: If the server can start locally, smoke-test new endpoints with `curl` and fix failures. Then tell the user which Postman requests to run and the expected result of each.
*   **Backend handoff**: End every backend session with a short summary per endpoint added or changed: method, path, auth required, request body, response body, error responses. The user uses this and the collection to start the Flutter session.
