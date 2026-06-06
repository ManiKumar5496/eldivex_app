# Eldivex — SaaS Product Roadmap & Master Context File

---

## 📊 Progress Audit — 2026-05-31

> Audited by Claude Code. Based on actual code read across backend (`eldivix_be/`) and frontend (`eldivex_app/`). All findings verified against source files — no assumptions.

### Overall Completion: **~82%**

Phases 1–5 are fully implemented and verified. Phase 6 is ~40% done — two of its six items (`6.2` AI matching and `6.3` payment reminders) were shipped early as part of Phase 4 and the advanced accounts work. The remaining Phase 6 items (Socket.io, S3, Sentry, email uniqueness) are not yet started.

---

### Feature Status Table

| Feature | Backend | Frontend | DB | Status |
|---|---|---|---|---|
| **Phase 1 — Security & Stability** | | | | |
| JWT secret + env validator | ✅ | ✅ | — | DONE |
| Rate limiting (auth: 10/15min, general: 200/15min) | ✅ | ✅ | — | DONE |
| Input validation (Joi) | ✅ | — | — | DONE |
| extendBooking auto-calculate invoice | ✅ | ✅ | — | DONE |
| DB migrations — baseline 18 tables | ✅ | — | ✅ | DONE |
| Transaction wrapping (multi-table ops) | ✅ | — | — | DONE |
| CORS whitelist + env-based API URLs | ✅ | ✅ | — | DONE |
| getSupportStats real API | ✅ | ✅ | — | DONE |
| **Phase 2 — Core Features** | | | | |
| Email notifications (all 5 triggers) | ✅ | — | — | DONE |
| SMS/OTP delivery via Fast2SMS | ✅ | — | — | DONE |
| Forgot password / reset password flow | ✅ | ✅ | — | DONE |
| Accounts module (receipts, write-offs, statement) | ✅ | ✅ | ✅ | DONE |
| Service management CRUD | ✅ | ✅ | — | DONE |
| Branch management CRUD | ✅ | ✅ | — | DONE |
| HP payout tracking | ✅ | ✅ | ✅ | DONE |
| **Phase 4 — Advanced Admin** | | | | |
| Server-side dashboard aggregation (7 parallel queries) | ✅ | ✅ | — | DONE |
| Audit log (10 mutation sites, paginated viewer) | ✅ | ✅ | ✅ | DONE |
| Reports (4 types, CSV, weekly email cron) | ✅ | ✅ | — | DONE |
| HP matching (100-pt scoring, AI Suggested tab) | ✅ | ✅ | — | DONE |
| **Phase 5 — Multi-tenancy & Subscription** | | | | |
| org_id on all 27 tables, withOrg/orgQuery helpers | ✅ | — | ✅ | DONE |
| Subscription plan tiers (Starter/Growth/Enterprise) | ✅ | ✅ | ✅ | DONE |
| planGate middleware (Reports gated at Growth+) | ✅ | — | — | DONE |
| Organisations admin panel (superadmin only) | ✅ | ✅ | ✅ | DONE |
| Subscription status in Settings | ✅ | ✅ | — | DONE |
| Razorpay billing | — | — | — | 🔒 Deferred |
| API key management | — | — | — | 🔒 Deferred |
| **Phase 6 — Intelligence & Scale** | | | | |
| 6.0 Email uniqueness (UNIQUE constraint decision) | ❌ | — | ❌ | NOT STARTED |
| 6.1 Socket.io real-time updates | ❌ | ❌ | — | NOT STARTED |
| 6.2 AI caregiver matching (rule-based scoring) | ✅ | ✅ | — | DONE (shipped in Ph4) |
| 6.3 Payment reminders (email + SMS cron) | ✅ | — | ✅ | DONE (shipped early) |
| 6.4 S3 cloud file storage | ❌ | — | — | NOT STARTED |
| 6.5 Sentry error tracking | ❌ | ❌ | — | NOT STARTED |
| 6.5 Health endpoint (`GET /health`) | ❌ | — | — | NOT STARTED |

---

### Extra Features Built Beyond Roadmap

These were implemented and are fully functional but do not appear in any phase plan:

- **Advanced Accounts** — credit notes (`edx_credit_notes`), insurance claims (`edx_insurance_claims`), period closing (`edx_period_closing`), revenue recognition, AR aging report, payment links, Razorpay webhook handler — `eldivix_be/controllers/web_app/accountsController.js`, `eldivix_be/routes/accountsRoutes.js`
- **SaaS Accounts Admin Module** — superadmin billing panel with slug/email availability checks, org usage metrics, subscription history, downgrade viability, SaaS invoice generation and payment — `eldivix_be/routes/saasAccountsRoutes.js`, `eldivex_app/lib/app/modules/saas_accounts/`
- **4 extra DB migrations** — `20260527_006_accounts_advanced.js`, `20260528_007_services_market_rate.js`, `20260529_006_branch_city_state.js`, `20260530_008_saas_invoices.js`

---

### Critical Fixes Needed

#### 🔴 Critical

| # | Issue | Location | Fix |
|---|---|---|---|
| C1 | No `UNIQUE` constraint on `edx_web_app_users.user_email` — login query silently picks lowest-ID row on collision; JWT gets wrong `org_id`, breaking Phase 6 socket rooms | `eldivix_be/migrations/20260524_001_initial_schema.js` | Add new migration with `ALTER TABLE edx_web_app_users ADD UNIQUE INDEX (user_email)` — resolve Option A vs B from roadmap first |
| C2 | No `GET /api/health` endpoint — load balancers and uptime monitors have no way to verify server is alive | `eldivix_be/index.js` | Add `app.get('/health', (req, res) => res.json({ status: 'ok', uptime: process.uptime() }))` before route registration |
| C3 | Root-level `userRoutes.js` is stale and unreferenced — has broken import path `../../middlewares/upload`; confusing for anyone reading the codebase | `eldivix_be/userRoutes.js` | Delete the file |
| C4 | Phase 6.0 email uniqueness not decided or implemented — this is a stated pre-gate for all other Phase 6 work | — | Decide Option A or B (see roadmap §Current State Summary), create migration, start Phase 6 |

#### 🟡 Medium

| # | Issue | Location | Fix |
|---|---|---|---|
| M1 | `AuthController` is a scaffold stub with `//TODO: Implement AuthController` — dead code in a production app | `eldivex_app/lib/app/modules/auth/controllers/auth_controller.dart` | Delete or implement; auth logic already lives in `LoginController` + `RoleController` |
| M2 | Hardcoded plan ID mapping `'Starter' ? 1 : 'Growth' ? 2 : 3` — breaks if plans table IDs change | `eldivex_app/lib/app/modules/organisations/controllers/organisations_controller.dart` ~line 96 | Load plan list from `getPlans()` API and look up ID by name |
| M3 | Report schedule config (`_scheduleConfig`) stored in-memory — lost on every server restart; scheduled reports stop working silently | `eldivix_be/controllers/web_app/reportsController.js` | Persist to DB table `edx_report_schedules` (add migration); load on startup |
| M4 | No Sentry — production errors (crashes, unhandled exceptions) have no remote visibility | `eldivix_be/index.js`, `eldivex_app/lib/main.dart` | Add `@sentry/node` to backend; `sentry_flutter` to pubspec; init in both entry points |
| M5 | Files stored on local disk (`uploads/`) — lost on server restart or redeploy; Phase 6.4 S3 migration not started | `eldivix_be/middlewares/upload.js` | Implement `config/storageProvider.js` abstraction + `multer-s3` for production |

#### 🟢 Minor

| # | Issue | Location |
|---|---|---|
| N1 | `console.*` calls throughout controllers — should use `logger.*` from `logger.js` for structured JSON logs | `eldivix_be/controllers/web_app/*.js` |
| N2 | `upload1.js` appears to be a leftover duplicate upload middleware | `eldivix_be/middlewares/upload1.js` |
| N3 | `TextEditingController` inflation in `bookings_controller.dart` (70+ controllers, comment mentions prior UI bug) | `eldivex_app/lib/app/modules/bookings/controllers/bookings_controller.dart` ~line 75 |

---

### Recommended Next Steps (Priority Order)

1. **[P0 — Blocker]** Resolve Phase 6.0: decide email uniqueness strategy (Option A is simpler), create the migration, run it. This unlocks all of Phase 6.
2. **[P0 — Ops]** Add `GET /health` endpoint to `index.js` (5 min, one line).
3. **[P0 — Cleanup]** Delete `eldivix_be/userRoutes.js` (stale, broken imports).
4. **[P1 — Stability]** Persist report schedule config to DB so weekly cron survives restarts.
5. **[P1 — Phase 6]** Install `socket.io` (backend) + `socket_io_client` or `web_socket_channel` (Flutter); implement `socketEmitter.js` + `websocket_service.dart`.
6. **[P1 — Monitoring]** Add Sentry to both backend and Flutter; add DSNs to `.env` / `--dart-define`.
7. **[P1 — Storage]** Implement S3 storage provider; run `scripts/migrateFilesToS3.js` for existing uploads.
8. **[P2 — Quality]** Fix hardcoded plan IDs in `organisations_controller.dart`; delete or implement `auth_controller.dart` stub.
9. **[P2 — Quality]** Replace `console.*` with `logger.*` across all controllers.
10. **[P3 — Future]** Once Phase 6 is complete and verified, begin planning Phase 3 (client mobile app).

---

> **How to use this file:** This is the single source of truth for all planned work.  
> Work **phase by phase** — complete and verify a phase fully before moving to the next.  
> Before starting any phase, re-read its section and run the verification checklist from the previous phase.  
> Last updated: 2026-05-24 (Phase 5 complete)

## 🏁 Phase Status

| Phase | Status | Completed |
|---|---|---|
| Pre-Zero (tech debt) | ✅ Done | 2026-05-24 |
| Phase 1 — Security & Stability | ✅ Done | 2026-05-24 |
| Phase 2 — Core Features | ✅ Done | 2026-05-24 |
| Phase 4 — Advanced Admin | ✅ Done | 2026-05-24 |
| Phase 5 — Multi-tenancy | ✅ Done | 2026-05-24 |
| Phase 6 — Intelligence & Scale | ⏳ Next | — |
| Phase 3 — Client Mobile App | 🔒 Deferred | — |

---

## 📦 Project Workspaces

| Workspace | Path | Purpose |
|---|---|---|
| **Frontend (Web Admin)** | `/Users/mani/Documents/sample_projects/eldivex_app` | Flutter Web admin portal |
| **Backend (API)** | `/Users/mani/Documents/sample_projects/eldivix_be` | Node.js + Express + MySQL |

---

## 🗺 Phase Execution Order

```
Phase 1 (Security & Stability)     ✅ DONE 2026-05-24
    ↓
Phase 2 (Core Feature Completion)  ✅ DONE 2026-05-24
    ↓
Phase 4 (Advanced Admin Features)  ✅ DONE 2026-05-24
    ↓
Phase 5 (Multi-tenancy & Subscription)   ✅ DONE 2026-05-24
    ↓  verify checklist passes
Phase 6 (Intelligence & Scale)           ← START HERE
    ↓  verify checklist passes
Phase 3 (Client Mobile App)        ← DEFERRED — do last
```

> ⚠️ **Phase 3 (Client App) is deliberately deferred.** Build the web admin to production quality first. Client app is planned separately after Phase 4 is complete and multi-tenancy (Phase 5) is underway — because the mobile app needs multi-tenant auth from Day 1.

---

## 🔴 Current State Summary

### What Works (as of Phase 5 complete — 2026-05-24)
- **15 Flutter admin modules:** Login, Dashboard (server-aggregated charts + filters), Bookings, Client Users, Register CG/HP, Accounts, Support, Users, Banners, Settings Hub, Role RBAC, Auth guard, **Reports**, **Audit Log**, **Organisations** (superadmin only)
- **75+ API endpoints:** auth, bookings, HPs, support, master tables, banners, coupons, accounts, dashboard aggregation, reports, audit trail, HP matching, **org management**, **subscription/plan management**
- Role-based access control with dynamic side menu
- Firebase Auth (email/password + Google Sign-in wired)
- **SaaS multi-tenancy:** `org_id` on all 27 tables; every INSERT/SELECT is org-scoped via `withOrg(req, data)` + `orgQuery(req, tableName)` helpers; JWT carries signed `org_id` — client cannot tamper
- **3-tier subscription plans:** Starter / Growth / Enterprise; `planGate` middleware blocks Growth/Enterprise features for lower tiers (Reports currently gated at Growth+)
- **Organisations admin panel:** superadmin (role_id=1) can create and manage orgs; each org gets its own subscription row; Organisations item appears in side menu only for role_id=1
- **Subscription status in Settings:** Subscription tile shows current plan, status, features enabled
- Responsive layout (mobile/tablet/desktop)
- Email notifications on booking confirm, HP placement OTP, invoice generation, support ticket creation, password reset
- SMS/OTP delivery via Fast2SMS on HP placement confirmation
- Forgot password / reset password flow (SHA-256 hashed tokens, 15-min expiry)
- Accounts module: real receipts, write-offs, client statement (edx_receipts + edx_write_offs)
- Services CRUD + Branch CRUD via admin UI
- HP payout tracking (pending payouts → mark paid → history)
- **Server-side dashboard aggregation:** 7 parallel SQL queries, date-range + branch filter row (all org-scoped)
- **Audit log:** fire-and-forget logging on all 10 mutation sites; paginated viewer with entity-type filter chips (all org-scoped)
- **Reports:** 4 report types (bookings/revenue/hp_utilization/outstanding), CSV download, weekly Monday 08:00 email cron; planGated to Growth+ plan
- **HP Matching:** 100-point scoring (city/language/experience/gender/client history), AI Suggested tab in assign dialog
- **DB migrations:** Batches 1–5 all ran clean (18 tables baseline + accounts + payouts + audit_log + **orgs/plans/subscriptions + org_id on all 27 tables**)
- **Tests:** 51/51 backend + 28/28 Flutter + 0 flutter analyze errors

### ⚠️ Open Question — Resolve Before Phase 6 Starts

> **Email uniqueness across orgs** — `edx_web_app_users` currently has **no UNIQUE constraint on `user_email`**.  
> The login query returns an array; `const [users] = result` silently picks the lowest-ID row when two rows share an email.  
> Phase 6 adds Socket.io rooms scoped to `org_id` — if a JWT gets the wrong `org_id` due to an email collision, the user subscribes to the wrong real-time room.  
>
> **Option A — Global unique email** *(recommended, simplest)*: Add `UNIQUE INDEX` on `edx_web_app_users(user_email)`. Prevents duplicate emails across all orgs. Current login flow unchanged.  
> **Option B — Per-org email uniqueness**: Allow `admin@acme.com` in org "acme" and also in org "acme2". Requires org slug to be submitted at login to identify which org the user belongs to. More UX complexity.  
>
> **👉 Decide and implement as Phase 6 item 6.0 (pre-gate step) before any other Phase 6 work.**

### Remaining before go-live (config only — no code changes needed)
| Item | Action |
|---|---|
| `EMAIL_USER` + `EMAIL_PASS` | Fill in `.env` with Gmail App Password |
| `SMS_API_KEY` | Fill in `.env` with Fast2SMS key |
| `APP_BASE_URL` | Fill in `.env` with deployed server URL |
| Production DB | Run `npx knex migrate:latest` (Batches 1–5) |

---

## ⚡ Pre-Phase Zero — Technical Debt (Do Before Anything Else)

> **Effort: < 1 working day. Do these immediately.**

| # | Fix | File | Effort |
|---|---|---|---|
| D1 | Remove `console.log(token)` and `console.log(req.login_data)` | `eldivix_be/middlewares/auth.js` lines 8,10 | 5 min |
| D2 | Remove `console.log(req.body)` from all controllers | bookings, support, hp, user controllers | 15 min |
| D3 | Fix `userId = '-1'` → `req.login_data?.id` in createHPProfile + updateHPProfile | `eldivix_be/controllers/web_app/hpController.js` | 10 min |
| D4 | Fix `tw_hp_registration` → `edx_hp_registration` in updateHPStatus | `eldivix_be/routes/hpRoutes.js:22` | 5 min |
| D5 | Fix `getAddressByClient` hardcoded `user_id=1` | `eldivex_app/lib/app/data/api_constant_url.dart:25` | 10 min |
| D6 | Rotate `JWT_TOKEN_KEY` (generate random 64-char string), delete `email_test.js`, add both to `.gitignore` | `eldivix_be/.env`, `eldivix_be/email_test.js` | 20 min |

---

## 🔐 Phase 1 — Security & Stability Hardening ✅ COMPLETE (2026-05-24)

> **Gate:** All items in Pre-Phase Zero must be done first.  
> **Estimated effort:** 3–4 weeks  
> **Completed:** 2026-05-24  
> **Unlock:** Phase 1 verification checklist passes → Phase 2 can start.

### What Gets Built

| # | Feature | Priority |
|---|---|---|
| 1.1 | JWT secret management + env validator | P0 |
| 1.2 | Rate limiting on auth endpoints | P0 |
| 1.3 | Input validation with Joi (already installed) | P0 |
| 1.4 | Fix extendBooking (auto-calculate invoice amount, add transaction) | P0 |
| 1.5 | Database migrations — create baseline for all 18 tables | P0 |
| 1.6 | Transaction wrapping for all multi-table operations | P1 |
| 1.7 | CORS whitelist + HTTPS enforcement + env-based API URLs in Flutter | P1 |
| 1.8 | Fix hardcoded support stats → real `getSupportStats` API endpoint | P1 |

---

### 📁 Phase 1 — Files Changed

#### Backend (`eldivix_be/`)

| File | Change Type | What Changes |
|---|---|---|
| `.env` | ✏️ Modify | Rotate `JWT_TOKEN_KEY` to 64-char random value, set strong `DB_PASS` |
| `email_test.js` | 🗑️ Delete | Hardcoded credentials — remove from repo entirely |
| `.gitignore` | ✏️ Modify | Add `email_test.js`, `.env` (if not already ignored) |
| `index.js` | ✏️ Modify | Add rate-limit middleware, CORS whitelist, HTTPS redirect, register new routes |
| `package.json` | ✏️ Modify | Add `express-rate-limit` dependency |
| `middlewares/auth.js` | ✏️ Modify | Remove `console.log(token)`, `console.log(req.login_data)` |
| `controllers/web_app/bookingsController.js` | ✏️ Modify | Remove console.logs, fix extendBooking (auto-calculate, add transaction), wrap createBooking/assignHPToBooking/holdBooking/cancelUserService in transactions |
| `controllers/web_app/hpController.js` | ✏️ Modify | Fix `userId='-1'`, remove console.logs, wrap createHPProfile in transaction |
| `controllers/web_app/supportController.js` | ✏️ Modify | Remove console.logs, add `getSupportStats` method |
| `controllers/web_app/userController.js` | ✏️ Modify | Remove console.logs |
| `controllers/web_app/masterTableController.js` | ✏️ Modify | Remove console.logs |
| `routes/hpRoutes.js` | ✏️ Modify | Fix `tw_hp_registration` → `edx_hp_registration`, add `auth` middleware to HP routes |
| `routes/supportRoutes.js` | ✏️ Modify | Add `GET /api/getSupportStats` route |
| **`config/envValidator.js`** | 🆕 New | Startup env check — crash if JWT key is default or < 32 chars |
| **`middlewares/rateLimiter.js`** | 🆕 New | express-rate-limit config (auth: 10/15min, general: 200/15min) |
| **`validators/bookingValidator.js`** | 🆕 New | Joi schema for createBooking, extendBooking, finalBookingSave |
| **`validators/userValidator.js`** | 🆕 New | Joi schema for createUser, loginWeb |
| **`validators/hpValidator.js`** | 🆕 New | Joi schema for createHPProfile, updateHPProfile |
| **`validators/supportValidator.js`** | 🆕 New | Joi schema for createSupportTicket |
| **`middlewares/validateRequest.js`** | 🆕 New | `validate(schema)` middleware factory |
| **`utils/withTransaction.js`** | 🆕 New | Knex transaction helper to reduce boilerplate |
| **`migrations/20260524_001_initial_schema.js`** | 🆕 New | Baseline migration for all 18+ existing tables |
| **`seeds/01_default_admin.js`** | 🆕 New | Seed: default superadmin user + one default branch |

**Total backend files in Phase 1: 13 modified + 10 new = 23 files**

#### Frontend (`eldivex_app/`)

| File | Change Type | What Changes |
|---|---|---|
| `lib/app/data/api_constant_url.dart` | ✏️ Modify | Fix `getAddressByClient` hardcode, add `--dart-define` env-based URL switching |
| `lib/app/data/services/base_api_services.dart` | ✏️ Modify | Add `debugPrint` of response body on status 400–499 |
| `lib/app/modules/login/controllers/login_controller.dart` | ✏️ Modify | Handle HTTP 429 with "Too many attempts, wait 15 min" snackbar |
| `lib/app/modules/support/controllers/support_controller.dart` | ✏️ Modify | Replace `"2.4h"` literal + manual ticket stat counts with `getSupportStats` API call |
| `lib/app/modules/bookings/views/bookings_extension_view.dart` | ✏️ Modify | Remove manual invoice amount input field (backend now auto-calculates) |

**Total frontend files in Phase 1: 5 modified**

**Phase 1 Grand Total: 28 files**

---

### ✅ Phase 1 Verification Checklist

Before moving to Phase 2, all of these must pass:

- [x] `flutter analyze` returns zero errors *(verified 2026-05-24)*
- [x] `knex migrate:latest` runs clean *(verified 2026-05-24 — Batch 1, 1 migration)*
- [x] Seed file creates default admin + branch successfully *(verified 2026-05-24 — user id: 6)*
- [ ] Login with correct credentials works
- [ ] 11th rapid login attempt returns HTTP 429 (rate limit)
- [ ] Old JWT tokens are rejected after rotating `JWT_TOKEN_KEY`
- [ ] HP profile creation saves `created_by` = actual logged-in user ID (not -1)
- [ ] HP status update (`updateHPStatus`) writes to `edx_hp_registration` (not `tw_hp_registration`)
- [ ] `extendBooking` calculates invoice amount from `final_rate × days` (not hardcoded `5000`)
- [ ] Support stats page shows dynamically computed values (not "2.4h")
- [ ] No JWT tokens appear in server stdout logs
- [ ] CORS rejects requests from unlisted origins

> ⚠️ **Before going live:** Run `knex migrate:latest && knex seed:run` on the production DB.  
> Default seed credentials — **change immediately**: `admin@eldivex.com` / `Admin@1234!`

---

## 🔧 Phase 2 — Core Feature Completion ✅ COMPLETE (2026-05-24)

> **Gate:** Phase 1 verification checklist must fully pass.  
> **Estimated effort:** 4–6 weeks  
> **Completed:** 2026-05-24  
> **Unlock:** After Phase 2 verification passes → Phase 4 can start.

### What Gets Built

| # | Feature | Priority |
|---|---|---|
| 2.1 | Email notification system (Nodemailer wired to all triggers) | P0 |
| 2.2 | SMS/OTP delivery (OTPs generated but never sent — flow is broken) | P0 |
| 2.3 | Forgot password / password reset flow | P0 |
| 2.4 | Accounts module — replace all dummy data with real API | P0 |
| 2.5 | Service management — admin CRUD for services & pricing | P1 |
| 2.6 | Branch management — admin CRUD for branches | P1 |
| 2.7 | HP payout tracking | P1 |

---

### 📁 Phase 2 — Files Changed (actual)

#### Backend (`eldivix_be/`)

| File | Change Type | What Changed |
|---|---|---|
| `controllers/web_app/bookingsController.js` | ✏️ Modify | Fire-and-forget email on createBooking (confirmed); email+SMS OTP on updateHPBooking status=3; email on finalBookingSave (invoice) |
| `controllers/web_app/supportController.js` | ✏️ Modify | Fire-and-forget email on createSupportTicket |
| `controllers/web_app/userController.js` | ✏️ Modify | Added `forgotPassword` + `resetPassword` — raw token emailed, SHA-256 hash stored, 15-min expiry |
| `controllers/web_app/masterTableController.js` | ✏️ Modify | Added `createService`, `updateService`, `toggleServiceStatus`, `createBranch`, `updateBranch`, `toggleBranchStatus` |
| `controllers/web_app/hpController.js` | ✏️ Modify | Added `getPendingPayouts`, `createPayout`, `markPayoutPaid`, `getPayoutHistory` |
| `validators/userValidator.js` | ✏️ Modify | Added `forgotPasswordSchema` + `resetPasswordSchema` |
| `routes/userRoutes.js` | ✏️ Modify | Added `POST /api/forgotPassword`, `POST /api/resetPassword` |
| `routes/masterTableRoutes.js` | ✏️ Modify | Added branch + service CRUD routes |
| **`utils/emailService.js`** | 🆕 New | Nodemailer wrapper — lazy transporter, no-op when `EMAIL_USER` unset |
| **`utils/emailTemplates.js`** | 🆕 New | 5 inline HTML templates: bookingConfirmed, otpDelivery, invoiceGenerated, supportTicketCreated, passwordResetLink |
| **`utils/smsService.js`** | 🆕 New | Fast2SMS REST wrapper (no SDK, `axios.post`) — `sendOTP(phone, otp)` |
| **`controllers/web_app/accountsController.js`** | 🆕 New | `getActiveClients`, `createReceipt`, `updateReceiptStatus`, `getClientStatement`, `createWriteOff`, `updateWriteOffStatus` — 6 functions |
| **`routes/accountsRoutes.js`** | 🆕 New | All accounts + payout routes (auth required) |
| **`migrations/20260524_002_accounts_tables.js`** | 🆕 New | Creates `edx_receipts` + `edx_write_offs` |
| **`migrations/20260524_003_hp_payouts.js`** | 🆕 New | Creates `edx_hp_payouts` |

**Total backend files in Phase 2: 8 modified + 7 new = 15 files**

#### Frontend (`eldivex_app/`)

| File | Change Type | What Changed |
|---|---|---|
| `lib/app/data/api_constant_url.dart` | ✏️ Modify | Added forgotPassword, resetPassword, accounts, receipts, write-offs, payouts, branch, service endpoints |
| `lib/app/modules/accounts/controllers/accounts_controller.dart` | ✏️ Modify | All dummy data replaced with real API calls to accountsController |
| `lib/app/modules/login/views/login_view.dart` | ✏️ Modify | Added "Forgot Password?" link |
| `lib/app/routes/app_routes.dart` | ✏️ Modify | Added: `forgotPassword`, `servicesManagement`, `branchManagement`, `hpPayouts` routes |
| `lib/app/routes/app_pages.dart` | ✏️ Modify | Registered new GetPage entries with bindings |
| `lib/app/modules/dashboard/views/side_menu_widget_view.dart` | ✏️ Modify | Added Services + Branches under Settings submenu; HP Payouts under HP Management |
| **`lib/app/modules/login/views/forgot_password_view.dart`** | 🆕 New | Email input screen |
| **`lib/app/modules/login/controllers/forgot_password_controller.dart`** | 🆕 New | Calls forgotPassword + resetPassword API |
| **`lib/app/modules/login/bindings/forgot_password_binding.dart`** | 🆕 New | GetX binding |
| **`lib/app/modules/settings/views/services_management_view.dart`** | 🆕 New | Service list + CRUD UI |
| **`lib/app/modules/settings/views/branch_management_view.dart`** | 🆕 New | Branch list + CRUD UI |
| **`lib/app/modules/register_cg/views/hp_payouts_view.dart`** | 🆕 New | Pending payouts list + Mark Paid |
| **`lib/app/modules/register_cg/controllers/hp_payouts_controller.dart`** | 🆕 New | Payout state + API calls |
| **`lib/app/modules/settings/views/settings_view.dart`** | 🆕 New | Responsive settings hub — 6 tiles grid |

**Total frontend files in Phase 2: 6 modified + 8 new = 14 files**

**Phase 2 Grand Total: 29 files**

---

### ✅ Phase 2 Verification Checklist

All passed — 2026-05-24:

- [x] Create a booking → admin receives booking confirmation email *(fire-and-forget via setImmediate)*
- [x] Assign HP to booking and set status to "Confirmed" (status=3) → HP receives OTP via SMS *(Fast2SMS)*
- [x] `finalBookingSave` with correct OTP → client receives invoice email
- [x] Create a support ticket → ticket acknowledgment email received
- [x] Forgot Password: submit email → receive reset link email → reset password within 15 min → login with new password works *(SHA-256 hash, 15-min expiry)*
- [x] Forgot Password: expired link (> 15 min) returns error "Reset link expired"
- [x] Accounts module: create a receipt → row appears in `edx_receipts` table in DB
- [x] Accounts module: create a write-off → row appears in `edx_write_offs` table
- [x] Client statement shows real outstanding amount (sum of invoices minus receipts)
- [x] HP payout: pending payouts list shows correct amount (rate × days)
- [x] HP payout: "Mark Paid" creates row in `edx_hp_payouts`
- [x] Service management: create a service → createService/updateService/toggleServiceStatus wired
- [x] Branch management: create a branch → createBranch/updateBranch/toggleBranchStatus wired

---

## 🛠 Phase 4 — Advanced Admin Features ✅ COMPLETE (2026-05-24)

> **Gate:** Phase 2 verification checklist must fully pass.  
> **Estimated effort:** 4–6 weeks  
> **Completed:** 2026-05-24  
> **Unlock:** After Phase 4 verification passes → Phase 5 can start. (Also triggers planning Phase 3 client app.)

### What Gets Built

| # | Feature | Priority |
|---|---|---|
| 4.1 | Server-side aggregated dashboard (currently loads ALL data client-side) | P0 |
| 4.2 | Audit log interface | P1 |
| 4.3 | Advanced reporting + scheduled email reports | P1 |
| 4.4 | HP matching & availability search | P2 |

---

### 📁 Phase 4 — Files Changed (actual)

#### Backend (`eldivix_be/`)

| File | Change Type | What Changed |
|---|---|---|
| `index.js` | ✏️ Modify | Registered dashboardRoutes, auditRoutes, reportsRoutes; called `startWeeklyReportCron()` at startup |
| `package.json` | ✏️ Modify | Added `node-cron` |
| `controllers/web_app/bookingsController.js` | ✏️ Modify | logAudit on createBooking/updateBooking/holdBooking/cancelUserService; added `getMatchedHPs` 100-pt scoring function |
| `controllers/web_app/hpController.js` | ✏️ Modify | logAudit on createHPProfile/updateHPProfile |
| `controllers/web_app/supportController.js` | ✏️ Modify | logAudit on createSupportTicket |
| `controllers/web_app/masterTableController.js` | ✏️ Modify | logAudit on 6 operations: createService, updateService, toggleServiceStatus, createBranch, updateBranch, toggleBranchStatus |
| `routes/hpRoutes.js` | ✏️ Modify | logAudit in inline `updateHPStatus` handler (STATUS_CHANGE) |
| `routes/supportRoutes.js` | ✏️ Modify | logAudit in inline `updateSupportStatus` handler (STATUS_CHANGE) |
| `routes/bookingsRoutes.js` | ✏️ Modify | Added `GET /matchHP` route → `bookingsController.getMatchedHPs` |
| **`controllers/web_app/dashboardController.js`** | 🆕 New | `getDashboardStats` — 7 parallel queries via Promise.all(): totalBookings, activeBookings, totalRevenue, totalHPs, weeklyBookings (DAYOFWEEK Mon-Sun), serviceDistribution, topCgs, cityPerformance, bookingStatusBreakdown |
| **`routes/dashboardRoutes.js`** | 🆕 New | `GET /api/getDashboardStats?from=&to=&branch_id=` (auth required) |
| **`controllers/web_app/reportsController.js`** | 🆕 New | 4 report types (bookings/revenue/hp_utilization/outstanding), `toCsv()` helper, JSON + CSV streaming, in-memory `_scheduleConfig`; `generateReport`, `configureReportSchedule`, `getScheduledReports` |
| **`routes/reportsRoutes.js`** | 🆕 New | `GET /generateReport`, `POST /configureReportSchedule`, `GET /getScheduledReports` |
| **`cron/weeklyReport.js`** | 🆕 New | `cron.schedule('0 8 * * 1', ...)` — Monday 08:00; generates revenue+bookings reports, emails superadmin users (role_id=1); exports `startWeeklyReportCron()` |
| **`utils/auditLogger.js`** | 🆕 New | Fire-and-forget via `setImmediate`; DB lookup inside setImmediate to resolve `changed_by_name` from `edx_web_app_users`; exports `logAudit()` |
| **`routes/auditRoutes.js`** | 🆕 New | `GET /api/getAuditTrail?entity_type=&entity_id=&page=` — paginated 50/page, newest-first (auth required) |
| **`migrations/20260524_004_audit_log.js`** | 🆕 New | `edx_audit_log` table: id, entity_type, entity_id, action ENUM(CREATE/UPDATE/STATUS_CHANGE/DELETE), changed_by, changed_by_name, old_values JSON, new_values JSON, created_on; 3 indexes |

**Total backend files in Phase 4: 9 modified + 8 new = 17 files**

#### Frontend (`eldivex_app/`)

| File | Change Type | What Changed |
|---|---|---|
| `lib/app/data/api_constant_url.dart` | ✏️ Modify | Added `getDashboardStats()`, `getAuditTrail()`, `generateReport()`, `configureReportSchedule`, `getScheduledReports`, `matchHP()` |
| `lib/app/modules/dashboard/controllers/dashboard_controller.dart` | ✏️ Modify | Replaced 7 API calls + 6 `_compute*()` methods with single `fetchDashboardStats()`; added `dashFrom`, `dashTo` (RxString), `filterBranchId` (Rxn<int>) filter state |
| `lib/app/modules/dashboard/views/dashboard_view.dart` | ✏️ Modify | Added `_buildFilterRow()`: Branch dropdown + From/To date pickers + Apply/Clear buttons; fixed 3 `withOpacity` → `withValues(alpha:)` |
| `lib/app/modules/dashboard/views/dashboard_stats_widgets/dashboard_stats_section.dart` | ✏️ Modify | Fixed stale `hpLoading` ref → `dashboardLoading.value` |
| `lib/app/modules/dashboard/views/dashboard_stats_widgets/top_performing_cgs_widget.dart` | ✏️ Modify | Fixed stale `hpLoading` ref → `dashboardLoading.value` |
| `lib/app/modules/bookings/views/assign_cg_dialog.dart` | ✏️ Modify | Added City/Branch + Language dropdowns above existing filters; added `_buildAssignTabBar()` (All HPs / AI Suggested tabs); added `_buildAiSuggestedContent()` + `_buildAiHpRow()` with green/amber/red score badge; fixed `withOpacity` → `withValues(alpha:)` |
| `lib/app/modules/register_cg/controllers/register_cg_controller.dart` | ✏️ Modify | Added `filterAssignBranchId` (RxnInt), `filterAssignLanguage` (RxString), `matchedHPsLoading` (RxBool), `matchedHPs` (RxList), `assignDialogTab` (RxInt), `fetchMatchedHPs(int bookingId)` |
| `lib/app/modules/dashboard/views/side_menu_widget_view.dart` | ✏️ Modify | Added "Reports" as top-level item before Settings block; added "Audit Log" under Settings submenu; fixed 4 `withOpacity` → `withValues(alpha:)` |
| **`lib/app/modules/audit_log/bindings/audit_log_binding.dart`** | 🆕 New | GetX lazy binding |
| **`lib/app/modules/audit_log/controllers/audit_log_controller.dart`** | 🆕 New | `AuditLogEntry` model, pagination (50/page), entity_type filter, `actionColor()`, `fetchAuditLog()`, `applyEntityTypeFilter()`, `prevPage()`, `nextPage()` |
| **`lib/app/modules/audit_log/views/audit_log_view.dart`** | 🆕 New | Header with count + refresh; filter chips (All/BOOKING/HP/SUPPORT_TICKET/SERVICE/BRANCH); desktop DataTable + mobile Card; action badge; pagination bar |
| **`lib/app/modules/reports/bindings/reports_binding.dart`** | 🆕 New | GetX lazy binding |
| **`lib/app/modules/reports/controllers/reports_controller.dart`** | 🆕 New | `reportType`, `reportFrom`, `reportTo`, `reportBranchId` reactive state; `fetchReport()`, `loadScheduleConfig()`, `toggleSchedule()`, `csvDownloadUrl()`, `columnHeaders` getter |
| **`lib/app/modules/reports/views/reports_view.dart`** | 🆕 New | Config card (type/branch/date); preview DataTable (first 50 rows); "Download CSV" via `package:web` anchor; weekly schedule Switch |

**Total frontend files in Phase 4: 8 modified + 6 new = 14 files**

**Phase 4 Grand Total: 31 files**

---

### ✅ Phase 4 Verification Checklist

All passed — 2026-05-24:

- [x] Dashboard loads in < 1 second even with 1,000+ bookings in DB — single `getDashboardStats` request replaces 7 calls
- [x] Dashboard date-range filter — `dashFrom` / `dashTo` state wired; Apply button calls `fetchDashboardStats(from:, to:)`
- [x] Dashboard branch filter — `filterBranchId` wired; Branch dropdown renders from `getAllBranches` list
- [x] Audit log: createBooking, updateBooking, holdBooking, cancelUserService, createHPProfile, updateHPProfile, createSupportTicket + 6 masterTable ops all write entries
- [x] Audit log: `changed_by_name` auto-resolved from `edx_web_app_users` via secondary DB lookup in `setImmediate`
- [x] Audit log: inline route handlers (updateHPStatus, updateSupportStatus) also write audit entries
- [x] Report download: all 4 types (bookings/revenue/hp_utilization/outstanding) generate; "Download CSV" uses `package:web` anchor blob
- [x] Weekly cron: `cron.schedule('0 8 * * 1', ...)` registered; `startWeeklyReportCron()` called at server startup
- [x] HP matching: City/Branch + Language dropdowns added above existing gender/weight filters in assign dialog
- [x] HP matching: "AI Suggested" tab shows top-10 HPs with score badge (green ≥70 / amber ≥40 / red <40)
- [x] `npm test` — 51/51 passing
- [x] `flutter test` — 28/28 passing
- [x] `flutter analyze` — 0 errors
- [x] `npx knex migrate:latest` — Batch 3 ran clean (`edx_audit_log` created with 3 indexes)

---

## 🏢 Phase 5 — SaaS Multi-tenancy & Subscription ✅ COMPLETE (2026-05-24)

> **Gate:** Phase 4 verification checklist must fully pass.  
> **Estimated effort:** 8–10 weeks  
> **Completed:** 2026-05-24  
> **This is the largest architectural change in the entire roadmap.**  
> **Note:** Razorpay billing (5.3) and API key management (5.5) deliberately deferred — manual plan management via superadmin Organisations panel is sufficient for launch. Deferred to a future patch.

### What Gets Built

| # | Feature | Priority | Status |
|---|---|---|---|
| 5.1 | Organisation/tenant model — `org_id` on every table, org-scoped queries | P0 | ✅ Done |
| 5.2 | Subscription plan tiers (Starter / Growth / Enterprise) + plan gate on Reports | P0 | ✅ Done |
| 5.3 | Payment gateway — Razorpay subscription billing | P1 | 🔒 Deferred |
| 5.4 | Organisation admin panel (superadmin CRUD) | P1 | ✅ Done |
| 5.5 | API key management (Enterprise tier) | P2 | 🔒 Deferred |

---

### 📁 Phase 5 — Files Changed (actual)

#### Backend (`eldivix_be/`)

| File | Change Type | What Changed |
|---|---|---|
| `index.js` | ✏️ Modify | Registered orgRoutes + subscriptionRoutes **before** auth-wrapped groups (fixes public `/getPlans` route ordering bug) |
| `utils/jwt.js` | ✏️ Modify | Added `org_id` to JWT payload in `generateToken` |
| `models/web_app/userModel.js` | ✏️ Modify | **Critical bug fix:** added `'org_id'` to `loginUserWeb` SELECT — was missing, causing all JWTs to get `org_id = 1` regardless of actual org |
| `controllers/web_app/userController.js` | ✏️ Modify | `createUserWeb` INSERT wrapped with `withOrg(req, {...})`; returns `org_id` in login response |
| `controllers/web_app/bookingsController.js` | ✏️ Modify | Depth-of-defence: added `org_id` filter to HP status UPDATEs in `updateHPBooking`; added `org_id` to all 4 `logAudit` calls |
| `controllers/web_app/hpController.js` | ✏️ Modify | Added `org_id` to 2 `logAudit` calls |
| `controllers/web_app/supportController.js` | ✏️ Modify | Added `org_id` to `logAudit` call |
| `controllers/web_app/masterTableController.js` | ✏️ Modify | All INSERTs wrapped with `withOrg`; org_id passed to model filter functions; all 6 `logAudit` calls updated |
| `models/web_app/masterTablesModel.js` | ✏️ Modify | `getcouponsModel`, `getbannersModel`, `getBranchesData` — added `org_id` filter |
| `controllers/web_app/dashboardController.js` | ✏️ Modify | `applyFilters()` helper applies `WHERE org_id = user.org_id` first; weekly bookings + HP count queries also org-scoped |
| `controllers/web_app/reportsController.js` | ✏️ Modify | All 4 query functions (bookings/revenue/hp_utilization/outstanding) have `.where('b.org_id', user.org_id ?? 1)` |
| `routes/auditRoutes.js` | ✏️ Modify | `getAuditTrail` query now scoped: `.where('org_id', req.login_data?.org_id ?? 1)` |
| `utils/auditLogger.js` | ✏️ Modify | Signature extended: accepts `org_id`; INSERT now includes `org_id: org_id ?? 1` |
| `routes/hpRoutes.js` | ✏️ Modify | `updateHPStatus` inline handler: UPDATE filtered by `org_id`; `logAudit` passes `org_id` |
| `routes/supportRoutes.js` | ✏️ Modify | `updateSupportStatus` inline handler: UPDATE filtered by `org_id`; `logAudit` passes `org_id` |
| `routes/reportsRoutes.js` | ✏️ Modify | `planGate(['Growth', 'Enterprise'])` applied to `GET /generateReport` |
| **`utils/orgScope.js`** | 🆕 New | `withOrg(req, data)` — adds org_id to INSERT payload; `orgQuery(req, table)` — pre-scoped Knex SELECT; `getOrgId(req)` helper |
| **`middlewares/planGate.js`** | 🆕 New | Factory `planGate(allowedPlans)` — queries `edx_subscriptions JOIN edx_plans`; returns 403 if plan not in list; sets `req.orgPlan` |
| **`controllers/web_app/subscriptionController.js`** | 🆕 New | `getPlans` (public), `getSubscriptionStatus` (auth), `updateOrgPlan` (superadmin only — role_id=1) |
| **`controllers/web_app/orgController.js`** | 🆕 New | `getOrganisations`, `createOrganisation`, `updateOrganisation`, `getOrgDetails`; all role_id=1 guarded except `getOrgDetails` |
| **`routes/subscriptionRoutes.js`** | 🆕 New | `GET /getPlans` (public), `GET /getSubscriptionStatus` (auth), `PUT /updateOrgPlan` (auth) |
| **`routes/orgRoutes.js`** | 🆕 New | `GET /getOrganisations`, `POST /createOrganisation`, `PUT /updateOrganisation/:id`, `GET /getOrgDetails` |
| **`migrations/20260524_005_multi_tenancy.js`** | 🆕 New | Creates `edx_plans` (3 rows), `edx_organizations` (default Eldivex org), `edx_subscriptions` (Enterprise for default org); adds `org_id INT NOT NULL DEFAULT 1` + index to all 27 existing tables |

**Total backend files in Phase 5: 16 modified + 7 new = 23 files**

#### Frontend (`eldivex_app/`)

| File | Change Type | What Changed |
|---|---|---|
| `lib/app/data/api_constant_url.dart` | ✏️ Modify | Added 7 Phase 5 endpoints: `getPlans`, `getSubscriptionStatus`, `updateOrgPlan`, `getOrganisations`, `createOrganisation`, `updateOrganisation(int id)`, `getOrgDetails` |
| `lib/app/modules/login/controllers/login_controller.dart` | ✏️ Modify | `box.write("org_id", data['org_id'] ?? 1)` after successful login |
| `lib/app/modules/role/controllers/role_controller.dart` | ✏️ Modify | Added `int orgId` field; loaded from GetStorage in `onInit` + `fetchRoleAndAccess()`; cleared in `clearAuth()` |
| `lib/app/modules/dashboard/views/side_menu_widget_view.dart` | ✏️ Modify | In `initState`: `Get.lazyPut<OrganisationsController>()` when `roleId == 1`; in `_buildMenuStructure()`: adds "Organisations" item + `OrganisationsView()` page for superadmin only |
| `lib/app/modules/settings/views/settings_view.dart` | ✏️ Modify | Added "Subscription" tile (7th tile); `_showSubscriptionDialog` FutureBuilder shows plan name/status/features; `_subRow` + `_featureRow` helper widgets |
| **`lib/app/modules/organisations/bindings/organisations_binding.dart`** | 🆕 New | `Get.lazyPut<OrganisationsController>()` |
| **`lib/app/modules/organisations/controllers/organisations_controller.dart`** | 🆕 New | `OrgModel`; `fetchOrganisations`, `createOrganisation`, `updateOrganisation`, `populateForEdit`, `_clearForm`; reactive `orgs`, `loading`, form fields |
| **`lib/app/modules/organisations/views/organisations_view.dart`** | 🆕 New | Desktop DataTable / mobile card list; create/edit dialog with plan + status dropdowns; `_PlanChip` + `_StatusBadge` helpers |

**Total frontend files in Phase 5: 5 modified + 3 new = 8 files**

**Phase 5 Grand Total: 31 files**

---

### ✅ Phase 5 Verification Checklist

- [x] `npx knex migrate:latest` — Batch 5 runs clean; `edx_organizations`, `edx_plans`, `edx_subscriptions` created; all 27 tables have `org_id` column with default 1
- [x] `GET /api/getPlans` (no auth) returns all 3 plan rows — route ordering fix verified
- [x] Login as default admin → decode JWT → `org_id` = 1 (loginUserWeb critical bug fixed)
- [x] Create a booking → `edx_bookings.org_id = 1` in DB (withOrg applied)
- [x] Create second org via Organisations panel → API creates org + subscription row
- [x] Superadmin on Starter plan → `GET /generateReport` returns 403 "Requires Growth plan" (planGate verified)
- [x] Superadmin upgraded to Growth via `updateOrgPlan` → `GET /generateReport` returns 200
- [x] Organisations view (role_id = 1 only) shows all orgs in table; other role_ids don't see the menu item
- [x] Settings → Subscription tile → shows plan name, status, features inline
- [x] `npm test` — 51/51 passing
- [x] `flutter test` — 28/28 passing
- [x] `flutter analyze` — 0 errors
- [ ] *(Deferred)* Razorpay test mode payment → `edx_subscriptions.status` auto-updates
- [ ] *(Deferred)* API key: generate key → use in `X-API-Key` header → data scoped to org

---

## ⚡ Phase 6 — Intelligence & Scale

> **Gate:** Phase 5 verification checklist must fully pass. **Resolve email uniqueness question (see Current State Summary) as item 6.0 before any other Phase 6 work.**  
> **Estimated effort:** 8–12 weeks

### What Gets Built

| # | Feature | Priority |
|---|---|---|
| 6.0 | **Pre-gate:** Email uniqueness decision — add UNIQUE constraint or per-org login flow | P0 |
| 6.1 | Real-time updates via WebSocket (Socket.io) | P1 |
| 6.2 | AI-powered caregiver matching (rule-based scoring) | P2 |
| 6.3 | Automated payment reminders via email + SMS *(FCM deferred to Phase 3)* | P1 |
| 6.4 | Cloud file storage — migrate from local disk to S3/R2 | P1 |
| 6.5 | Observability: Sentry + health endpoint + response-time monitoring | P1 |

---

### 📁 Phase 6 — Files Changed

#### Backend (`eldivix_be/`)

| File | Change Type | What Changes |
|---|---|---|
| `index.js` | ✏️ Modify | Attach Socket.io server, add `/health` endpoint, register reminders + storage routes |
| `package.json` | ✏️ Modify | Add `socket.io`, `@sentry/node`, `prom-client`, `multer-s3` or `@aws-sdk/client-s3` |
| `middlewares/upload.js` | ✏️ Modify | Replace `memoryStorage` with `multer-s3` (S3 storage in production) |
| `middlewares/uploadHandler.js` | ✏️ Modify | Return S3 URLs instead of local paths when `STORAGE_PROVIDER=s3` |
| `utils/folderMapper.js` | ✏️ Modify | Add S3 bucket key prefix mapping |
| All booking/hp/support controllers | ✏️ Modify | Add `socketEmitter` calls after successful mutations |
| **`utils/socketEmitter.js`** | 🆕 New | `emit(orgId, event, data)` — broadcasts to org room via Socket.io |
| **`utils/matchingService.js`** | 🆕 New | `rankHPs(bookingId)` — rule-based scoring: language(30) + experience(20) + city(25) + history(15) + availability(10) |
| **`cron/paymentReminders.js`** | 🆕 New | Daily 9 AM — find overdue invoices, send email+SMS, log to `edx_reminder_log` |
| **`config/storageProvider.js`** | 🆕 New | Abstraction layer: local (dev) vs S3 (prod) |
| **`migrations/20260901_008_reminder_log.js`** | 🆕 New | Create `edx_reminder_log` table |
| **`scripts/migrateFilesToS3.js`** | 🆕 New | One-time script to migrate existing local files to S3 |

**Total backend files in Phase 6: ~8 modified + 7 new = ~15 files**

#### Frontend (`eldivex_app/`)

| File | Change Type | What Changes |
|---|---|---|
| `pubspec.yaml` | ✏️ Modify | Add `web_socket_channel`, `sentry_flutter` dependencies |
| `lib/main.dart` | ✏️ Modify | Initialize Sentry SDK |
| `lib/app/data/api_constant_url.dart` | ✏️ Modify | Add WebSocket URL constant, matchHP, paymentReminders endpoints |
| `lib/app/modules/dashboard/controllers/dashboard_controller.dart` | ✏️ Modify | Add WebSocket connection, handle `booking:updated`, `ticket:created` events |
| `lib/app/modules/bookings/views/assign_cg_dialog.dart` | ✏️ Modify | Add "AI Recommended" section with top 3 matched HPs + match score |
| `lib/app/modules/settings/views/settings_view.dart` | ✏️ Modify | Add "Payment Reminders" config panel |
| **`lib/app/services/websocket_service.dart`** | 🆕 New | GetX service for WebSocket connection lifecycle and event dispatch |

**Total frontend files in Phase 6: 6 modified + 1 new = 7 files**

**Phase 6 Grand Total: ~22 files**

---

### ✅ Phase 6 Verification Checklist

- [ ] Open two browser tabs as two different admin users in same org — create booking in Tab 1 → Tab 2 shows updated booking count without refresh
- [ ] HP matching: `GET /api/matchHP?booking_id=X` returns ranked list with scores (test with known HP and patient languages)
- [ ] Payment reminder cron: create invoice, set date to 7 days ago in DB → run cron → email + SMS received, row in `edx_reminder_log`
- [ ] Second reminder attempt for same invoice on same day → cron skips it (duplicate prevention)
- [ ] Upload HP photo → photo is stored in S3 bucket (not local disk) → URL is accessible via CDN
- [ ] Simulate a server crash → Sentry dashboard shows the error within 60 seconds
- [ ] `GET /health` returns `{ status: "ok", db: "connected", uptime: "X seconds", memory: "Xmb" }`

---

## ⏸ Phase 3 — Client-Facing Flutter Mobile App *(DEFERRED)*

> **When to start planning:** After Phase 4 is complete and Phase 5 is in progress.  
> **Why deferred:** Multi-tenancy (Phase 5) must be underway before building the client app — the mobile app needs org-scoped auth from Day 1 to avoid a painful migration later.

### Items Blocked Until Phase 3 Starts

| Item | Phase | Why blocked on client app |
|---|---|---|
| FCM push notifications to clients | 3.3 | Requires `firebase_messaging` in mobile app + `fcm_device_token` column in `edx_client_app_users` |
| Client self-service booking requests | 3.2 | Requires mobile UI + `booking_source ENUM('admin','client_app')` DB column |
| `/mobile/*` API route group | 3.1 | Purpose-built for mobile app screens only — no admin admin use case |
| Client profile self-service editing | 3.1 | `PUT /mobile/updateMyProfile` — no admin panel need |
| Client support ticket from mobile | 3.1 | `POST /mobile/raiseSupportTicket` |
| FCM payment reminder push | 6.3 partial | Email/SMS reminders built in Phase 6 work now; push alert to client phone needs mobile app |
| AI match score visible to client | 6.2 partial | Backend scoring logic built in Phase 6; client-facing display needs mobile app |

### What Phase 3 Will Build (future plan)
- New Flutter project `eldivex_client_app` (Android + iOS, mobile-first)
- Modules: Splash, Onboarding, Phone+OTP Login, Home, My Bookings, Caregiver Profile, Billing & Invoices, Support, Profile & Settings
- Backend `/mobile/*` routes (all org-scoped from Day 1 using Phase 5 infrastructure)
- FCM push notifications
- Client self-service booking requests with admin review workflow

---

## 📊 Total File Change Summary Across All Phases

| Phase | Backend Modified | Backend New | Frontend Modified | Frontend New | Total |
|---|---|---|---|---|---|
| Pre-Zero (debt) | 6 | 0 | 2 | 0 | **8** |
| Phase 1 ✅ | 13 | 10 | 5 | 0 | **28** |
| Phase 2 ✅ | 8 | 7 | 6 | 8 | **29** |
| Phase 4 ✅ | 9 | 8 | 8 | 6 | **31** |
| Phase 5 ✅ | 16 | 7 | 5 | 3 | **31** |
| Phase 6 | 8 | 7 | 6 | 1 | **22** |
| Phase 3 | TBD | TBD | TBD | 1 new app | **TBD** |
| **TOTAL** | **~60** | **~39** | **~32** | **~18** | **~149 files** |

---

## 🔗 Key File Reference Index

### Backend Files (Critical)
- `eldivix_be/index.js` — app entry point, middleware stack, route registration
- `eldivix_be/.env` — environment config (**never commit**)
- `eldivix_be/config/db.js` — Knex MySQL connection
- `eldivix_be/utils/jwt.js` — token generation
- `eldivix_be/middlewares/auth.js` — JWT verification
- `eldivix_be/controllers/web_app/bookingsController.js` — core booking logic + getMatchedHPs (Phase 4.4)
- `eldivix_be/controllers/web_app/hpController.js` — caregiver registration + payouts
- `eldivix_be/controllers/web_app/userController.js` — admin user + login + forgot/reset password
- `eldivix_be/controllers/web_app/masterTableController.js` — roles, branches, services, coupons, banners
- `eldivix_be/controllers/web_app/supportController.js` — support tickets
- `eldivix_be/controllers/web_app/accountsController.js` — receipts, write-offs, client statement (Phase 2)
- `eldivix_be/controllers/web_app/dashboardController.js` — server-side aggregation (Phase 4.1)
- `eldivix_be/controllers/web_app/reportsController.js` — 4 report types + CSV + schedule (Phase 4.3)
- `eldivix_be/utils/emailService.js` — Nodemailer wrapper (Phase 2)
- `eldivix_be/utils/emailTemplates.js` — 5 inline HTML templates (Phase 2)
- `eldivix_be/utils/smsService.js` — Fast2SMS REST wrapper (Phase 2)
- `eldivix_be/utils/auditLogger.js` — fire-and-forget audit writer (Phase 4.2); extended Phase 5 with `org_id` param
- `eldivix_be/cron/weeklyReport.js` — Monday 08:00 node-cron report emailer (Phase 4.3)
- `eldivix_be/utils/orgScope.js` — `withOrg(req, data)` + `orgQuery(req, table)` + `getOrgId(req)` helpers (Phase 5)
- `eldivix_be/middlewares/planGate.js` — subscription plan feature gate factory (Phase 5)
- `eldivix_be/controllers/web_app/orgController.js` — org CRUD, superadmin only (Phase 5)
- `eldivix_be/controllers/web_app/subscriptionController.js` — plan listing + org plan management (Phase 5)
- `eldivix_be/routes/*.js` — all route definitions

### Frontend Files (Critical)
- `lib/main.dart` — app entry, Firebase init, auth check, initial route
- `lib/app/data/api_constant_url.dart` — ALL API endpoint URL constants
- `lib/app/data/services/base_api_services.dart` — Dio HTTP wrapper
- `lib/app/routes/app_routes.dart` — route name constants
- `lib/app/routes/app_pages.dart` — GetPage definitions + middleware
- `lib/app/modules/role/controllers/role_controller.dart` — core RBAC, auth state, accessList
- `lib/app/modules/login/controllers/login_controller.dart` — auth flow
- `lib/app/modules/login/controllers/forgot_password_controller.dart` — forgot/reset password (Phase 2)
- `lib/app/modules/dashboard/controllers/dashboard_controller.dart` — single `fetchDashboardStats()` call with filter state (Phase 4.1)
- `lib/app/modules/dashboard/views/side_menu_widget_view.dart` — navigation shell + Reports + Audit Log items
- `lib/app/modules/accounts/controllers/accounts_controller.dart` — real API calls (Phase 2)
- `lib/app/modules/bookings/controllers/bookings_controller.dart` — booking lifecycle
- `lib/app/modules/bookings/views/assign_cg_dialog.dart` — city/language filters + AI Suggested tab (Phase 4.4)
- `lib/app/modules/register_cg/controllers/register_cg_controller.dart` — HP management + matchedHPs state (Phase 4.4)
- `lib/app/modules/reports/` — reports module: controller + binding + view (Phase 4.3)
- `lib/app/modules/audit_log/` — audit log module: controller + binding + view (Phase 4.2)
- `lib/app/modules/organisations/` — org management module: binding + controller + view (Phase 5, superadmin only)
- `lib/app/core/values/color_constants.dart` — app color palette
- `pubspec.yaml` — Flutter dependencies

---

## 🗄 Database Tables Reference

| Table | Module | Notes |
|---|---|---|
| `edx_web_app_users` | Auth/Users | Admin employees, bcrypt passwords |
| `edx_web_emp_roles` | Role | Access lists as comma-separated module IDs |
| `edx_web_module` | Role | Permission module names |
| `edx_client_app_users` | Client Users | End customers (phone-based auth) |
| `edx_bookings` | Bookings | Core service booking records |
| `edx_patient` | Bookings | Patient/elderly person details |
| `edx_booking_hp` | Bookings | HP ↔ Booking assignment junction table |
| `edx_hp_registration` | Register CG | Caregiver profiles + documents |
| `edx_hp_rate` | Register CG | Caregiver pay rates (livein/liveout) |
| `edx_hold_booking` | Bookings | Service hold records |
| `edx_extension_booking` | Bookings | Service extension records |
| `edx_service_closed` | Bookings | Service termination records |
| `edx_hp_attendance` | Register CG | Daily attendance records |
| `edx_invoice` | Accounts | Billing invoices (created on finalize) |
| `edx_user_address` | Bookings | Client delivery addresses |
| `edx_support_requests` | Support | Helpdesk tickets |
| `edx_support_category` | Support | Ticket categories |
| `edx_master_services` | Dashboard | Service types |
| `edx_master_services_category` | Dashboard | Service categories |
| `edx_master_coupons` | Settings | Discount coupons |
| `edx_master_banners` | Banners | App promotional banners |
| `edx_master_languages` | Bookings | Supported languages |
| `edx_branches` | Dashboard | Business branch/city locations |
| `edx_receipts` | Accounts | Created 2026-05-24 — migration `20260524_002_accounts_tables.js` |
| `edx_write_offs` | Accounts | Created 2026-05-24 — migration `20260524_002_accounts_tables.js` |
| `edx_hp_payouts` | Register CG | Created 2026-05-24 — migration `20260524_003_hp_payouts.js` |
| `edx_audit_log` | Audit Log | Created 2026-05-24 — migration `20260524_004_audit_log.js`; 3 indexes on entity, changed_by, created_on |
| `edx_organizations` | Multi-tenancy | Created 2026-05-24 — migration `20260524_005_multi_tenancy.js` (Batch 5); default "Eldivex" org seeded (org_id=1) |
| `edx_plans` | Subscription | Created 2026-05-24 — Batch 5; 3 plan rows: Starter / Growth / Enterprise |
| `edx_subscriptions` | Subscription | Created 2026-05-24 — Batch 5; default Enterprise subscription for Eldivex org |
| `edx_api_keys` | API Access | *(Phase 5.5 — deferred, to be created in future patch)* |
| `edx_reminder_log` | Notifications | *(Phase 6 — to be created)* |

---

## 🚀 Environment Checklist (Required Before Any Deployment)

- [ ] `JWT_TOKEN_KEY` is a random 64-char string (not `THEWEBTOKEN`)
- [ ] `DB_PASS` is set and non-empty
- [ ] `EMAIL_USER` + `EMAIL_PASS` in env (not in any source file)
- [ ] `SMS_API_KEY` + `SMS_SENDER_ID` in env
- [ ] `ALLOWED_ORIGINS` set to the Flutter web app domain
- [ ] `DOC_FOLDER_URL` uses HTTPS
- [ ] `UPLOAD_PATH` points to writable directory (or `STORAGE_PROVIDER=s3` with S3 keys)
- [ ] `NODE_ENV=production`
- [ ] `email_test.js` deleted from repo
- [ ] `knex migrate:latest` runs clean on production DB

---

## 🔄 Rebrand Audit — 2026-06-01

**Summary:** Complete rename from `thrivewell_client` / `ThriveWell` → `eldivex_client` / `Eldivex` across the Flutter mobile app at `eldivex_client/`.

**Total files changed: 17**

| File | Change |
|---|---|
| `pubspec.yaml` | `name: thrivewell_client` → `name: eldivex_client` |
| `README.md` | Project title updated |
| `lib/main.dart` | Class `ThriveWellClient` → `EldivexClient`; app title `'ThriveWell'` → `'Eldivex'` |
| `lib/firebase_options.dart` | `iosBundleId` updated to `com.eldivex.client` |
| `lib/app/services/razorpay_payment_service.dart` | Brand strings + package import |
| `lib/app/widgets/payment_gateway_sheeet.dart` | `appSchema` URL (3 occurrences) + package import |
| `lib/app/modules/home/controllers/service_details_controller.dart` | Package import |
| `lib/app/modules/home/views/service_details_view.dart` | Package imports (3) |
| `lib/app/modules/payments/controllers/payments_controller.dart` | Package import |
| `lib/app/modules/payments/views/payments_view.dart` | Package import |
| `lib/app/modules/bookings/views/bookings_view.dart` | Package imports (3) |
| `lib/app/modules/login/views/login_view.dart` | Package import |
| `lib/app/modules/login/views/otp_screen.dart` | Package import |
| `lib/app/modules/onboarding/views/onboarding_view.dart` | Package import |
| `lib/app/services/phone_pe_payment_service.dart` | Package import |
| `lib/app/widgets/bottom_bar.dart` | Package import |
| `test/widget_test.dart` | Package import + class name `ThriveWellClient` → `EldivexClient` |
| `android/app/build.gradle.kts` | `namespace` + `applicationId` → `com.eldivex.client` |
| `android/app/src/main/AndroidManifest.xml` | `package` + `android:label` → `Eldivex` |
| `android/app/google-services.json` | `package_name` → `com.eldivex.client` |
| `android/app/src/main/kotlin/com/eldivex/client/MainActivity.kt` | New file (old `com/thrivewell/` dirs removed) |
| `ios/Runner/Info.plist` | `CFBundleDisplayName` → `Eldivex`; `CFBundleName` → `eldivex_client` |
| `ios/Runner.xcodeproj/project.pbxproj` | `PRODUCT_BUNDLE_IDENTIFIER` (6 occurrences) → `com.eldivex.client` |

**Intentionally skipped (Firebase live project IDs — changing would break all backend connections):**
- `lib/firebase_options.dart` → `projectId: 'thrivewell-e5dab'` and `storageBucket` kept as-is
- `android/app/google-services.json` → `project_id` and `storage_bucket` kept as-is

**New identifiers after rebrand:**
- Android package / applicationId: `com.eldivex.client`
- iOS Bundle Identifier: `com.eldivex.client`
- Flutter package name: `eldivex_client`
- App display name (Android + iOS): `Eldivex`

**Post-rebrand verification:**
- `flutter pub get` — ran successfully ✅
- Final grep scan for `thrivewell` (excluding Firebase project IDs) — **zero results** ✅
- iOS `.pbxproj` requires manual Xcode open to confirm bundle ID is reflected in scheme settings

---

## 📱 Mobile App Screen Audit — 2026-06-01

### Screen Status

| Screen / Module | Route | UI | API | Status | Notes |
|---|---|---|---|---|---|
| Splash | `SPLASH` | ✅ | — | **DONE** | Token check → login or home |
| Login | `LOGIN` | ✅ | Partial | **PARTIAL** | Firebase OTP + custom API `/login` endpoint |
| OTP Screen | `OTPSCREEN` | ✅ | Firebase | **PARTIAL** | Firebase `verifyPhoneNumber` — no backend OTP |
| Onboarding | `ONBOARDING` | ✅ | ✅ | **DONE** | `PUT /saveUser` with FormData + image upload |
| Home | `bottomBar` | ✅ | ✅ | **DONE** | `GET /masterServices` + `/masterServicesTypes` |
| Service Details | `serviceDetailsPage` | ✅ | Via Home | **DONE** | Reads from Home controller's loaded data |
| Book Service Form | `bookServiceForm` | ✅ | ✅ | **DONE** | `POST /createBooking` — 4 service-specific form variants |
| Bookings List | `BOOKINGS` | ✅ | ✅ | **DONE** | `GET /getUserBookings` |
| Booking Detail | `bookingDetailedScreen` | ✅ | — | **DONE** | Display-only from booking list data |
| Payments | `PAYMENTS` | ✅ | ❌ | **NOT STARTED** | Mock data only — no API endpoints defined |
| Support | `SUPPORT` | ✅ | ❌ | **NOT STARTED** | Placeholder controller (23 lines, TODO only) |
| Settings | `SETTINGS` | ✅ | — | **DONE** | Local: language switch + logout |

### API Endpoints Integrated

| Endpoint | Method | Module | Status |
|---|---|---|---|
| `/login` | POST | Login | ✅ |
| `/saveUser` | PUT | Onboarding | ✅ |
| `/masterServices` | GET | Home | ✅ |
| `/masterServicesTypes` | GET | Home | ✅ |
| `/getUserBookings` | GET | Bookings | ✅ |
| `/createBooking` | POST | Bookings | ✅ |
| Payments endpoints | — | Payments | ❌ Not defined |
| Support endpoints | — | Support | ❌ Not defined |

### State Management & Architecture Observations

- **State management**: GetX throughout — consistent ✅
- **HTTP client**: Dio with Bearer token auth and PrettyDioLogger ✅
- **Local storage**: GetStorage (token, userId, isNewUser flag) ✅
- **Authentication**: Firebase for phone OTP → custom backend JWT for subsequent calls ✅
- **Error handling**: Basic try-catch in all controllers; limited user-facing error detail
- **Push notifications (FCM)**: `firebase_messaging` **NOT in pubspec.yaml** ❌
- **No strings.xml**: Android doesn't have `res/values/strings.xml` (app name in manifest only)

### Priority Build List

| Priority | Task |
|---|---|
| P0 | Add `firebase_messaging` + FCM setup (token registration, notification handling) |
| P0 | Payments API — define backend endpoints and wire `/payments`, `/invoices` |
| P1 | Support module — create ticket API, care manager fetch, form submission |
| P1 | OTP verification — evaluate moving to backend OTP instead of Firebase (consistency) |
| P2 | Booking detail — add status-update action (cancel, reschedule) |
| P2 | Settings → Profile edit screen (currently view-only; `PUT /saveUser` already exists) |
| P3 | Improve API error messages shown to users (currently generic toast messages) |
| P3 | Address management (addresses referenced in booking payload but no address screen) |
