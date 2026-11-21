# Budget_Pal
Personal Full Stack Financial Budgeting App

## No-auth MVP caveat

The API currently has no authentication layer. Endpoints that need to know "whose
data is this" (e.g. budgets, notifications) rely on a client-supplied `userId`
instead of an identity derived from a token. Ownership checks (for example,
`POST /api/notification/{id}/read`) compare the notification's owner against that
client-supplied id, which a malicious client could simply change. Real auth (JWT)
should be added, and ownership checks switched to the authenticated identity,
before connecting this API to a shared/production database such as Supabase.
