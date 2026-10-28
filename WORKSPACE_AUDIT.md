# Eldivex Workspace Audit

**Date:** 2026-10-07
**Scope:** all 5 repos in the workspace. This was a read-only static audit: no code was changed and nothing was run against a database.
**Purpose:** a single shared understanding of what exists, what works, what's broken and what's in flight, so that feature work can start from a known baseline.

> **How to read this.** Findings come from reading the code at the current working-tree state, which includes uncommitted changes. File:line references are approximate where files are still being edited. Nothing here was exercised at runtime. Items marked **verified** were re-checked directly; the rest come from module-by-module review.

---

## 1. System at a glance

Eldivex is a **multi-tenant home-care / health-services SaaS**.

- **Organisations** (tenants, also called "orgs") run care agencies.
- Each agency has:
  - **staff**, who use the admin app;
  - **health professionals / caregivers** (HP or CG), who get a self-service portal;
  - **clients**, the families of elders, who get a web portal and a mobile app.
- A **platform owner** runs all orgs, plans and SaaS billing.

```
                    ┌────────────────────────────┐
                    │  eldivex_website (Flutter) │──► Firestore `leads_website`
                    │  marketing / Book-Demo     │    (project caresaas-f4c23)
                    └────────────────────────────┘
┌──────────────────────┐ ┌──────────────────────┐ ┌──────────────────────┐
│ eldivex_app (web)    │ │ owner_platform (web) │ │ eldivex_client       │
│ • Admin shell /main  │ │ super-admin portal   │ │ (Android / iOS)      │
│ • HP portal  /hp     │ │ /ownerLogin          │ │ client mobile app    │
│ • Client portal      │ │                      │ │                      │
│   /client            │ │                      │ │                      │
└─────────┬────────────┘ └─────────┬────────────┘ └─────────┬────────────┘
          │  Bearer JWT            │                        │
          ▼                        ▼                        ▼
      ┌─────────────────────────────────────────────────────────┐
      │ eldivix_be: Node / Express 5 / knex / MySQL             │
      │ single DB, `org_id` column tenancy                      │
      │ 4 in-process node-cron jobs                             │
      │ self-managed EC2 Windows box, manual deploy             │
      └─────────────────────────────────────────────────────────┘
```

### Repos

| Repo | Stack | Purpose | Hosting | Default API URL |
|---|---|---|---|---|
| `eldivex_app` | Flutter web, GetX, Dio, GetStorage | Tenant admin app, plus the HP portal and client portal in the same bundle | Firebase Hosting (`.firebaserc` says `eldivexweb-e58aa`; `firebase_options.dart` says `eldivexweb`, which is a **mismatch**) | `http://43.204.68.253:5004/api` (QA, plain HTTP, can be overridden by `--dart-define=API_BASE_URL`) |
| `eldivix_be` | Node, Express 5.1, knex 3 + mysql2, Joi, JWT, node-cron, nodemailer, Fast2SMS | API for every app | EC2 Windows, manual deploy (Railway retired 2026-06-20) | n/a |
| `owner_platform` | Flutter web, GetX | Platform-owner console: orgs, plans, SaaS billing, cross-org audit | Firebase site `eldivex-owner` | same QA IP; prod is documented as `http://65.2.74.114:4000/api` |
| `eldivex_client` | Flutter mobile, GetX, Firebase phone auth, Razorpay, PhonePe | Client mobile app (ported from ThriveWell) | Play Store / App Store (not yet) | hard-coded `http://43.204.68.253:5004/api` |
| `eldivex_website` | Flutter web, Riverpod, go_router | Marketing landing page with lead capture | Firebase site `eldivex`, project `caresaas-f4c23` | none (writes to Firestore only) |

### Glossary

| Term | Meaning |
|---|---|
| org / tenant | `edx_organizations` row. Has `org_id` (numeric) and, for new orgs, a public `org_code` `XXX-NNNNNN`. |
| owner | Platform super-admin. Has no DB user; credentials come from `OWNER_EMAIL` and `OWNER_PASSWORD_HASH`. The JWT carries `is_owner:true, org_id:1`. |
| staff / employee | `edx_web_app_users`. Logs in through `/loginWeb`. Has a role in `edx_web_emp_roles`. |
| HP / CG | Caregiver. `edx_hp_registration`, keyed by `hp_reg_id` and `hp_unique_id`. |
| client | `edx_client_app_users` (the end customer / family). Patients are kept in `edx_patient`. |
| booking | `edx_bookings`. `status` is a VARCHAR `'1'`..`'7'`. HP assignment is in `edx_booking_hp`, keyed by `bkng_id`. |

---

## 2. Backend (`eldivix_be`)

### 2.1 Boot sequence (`index.js`)

1. dotenv, then `config/envValidator.js`, which exits the process on bad config.
2. `trust proxy 1`, then the body parsers.
3. CORS whitelist, then an HTTPS redirect in production.
4. `generalLimiter` (200 requests per 15 minutes) on `/api`.
5. `/uploads` is served as **public static files**.
6. `orgStatusGate` runs on `/api`.
7. Route groups are mounted on `/api`.
8. The 4 crons start.
9. `errorHandler`, then `listen(PORT || 4000)`.

Other facts:

- `config/db.js` always uses the **development** knex config, whatever `NODE_ENV` is.
- No migrations run on boot. They are applied manually with the knex CLI.
- Tests: `npm test` (jest). These are unit tests that mock the DB, plus one integration test that hits the **real** DB. The integration test's mount order differs from `index.js`.

### 2.2 Auth model

One `JWT_TOKEN_KEY` signs four token types:

| Token | Issued by | Claims | TTL |
|---|---|---|---|
| Staff | `POST /loginWeb` (email + bcrypt password) | `{id, role_id, branch_access, org_id}` | 30d |
| Client (legacy mobile) | `POST /login` (**phone + org_id only, no OTP**) | same shape as staff, with `role_id:null` and `branch_access:null` | 30d |
| Owner | `POST /ownerLogin` | `{id:0, is_owner:true, org_id:1}` | 7d |
| HP | `POST /hpAuth/verifyOtp` | `{role:'caregiver', hp_id, org_id}` | 60d |
| Client portal | `POST /clientAuth/verifyOtp` | `{role:'client', user_id, org_id}` | 60d |

Middlewares:

- **`auth.js`** verifies *any* valid JWT and sets `req.login_data`. It does **no type or role check**. **Verified.**
- **`requireOwner`**: checks `is_owner`.
- **`hpAuth`**: checks `role==='caregiver'`.
- **`clientAuth`**: checks `role==='client'`.
- **`orgStatusGate`**: global. Blocks suspended orgs with a 403 `ORG_SUSPENDED` response. Uses a 60s cache and fails open.
- **`planGate`**: plan-name allow-list. Used **only** on `/generateReport`.
- **`validateRequest`**: Joi validation; returns 422.

How the request's org is decided:

- `getOrgId(req) = req.login_data?.org_id ?? 1`. The same `?? 1` fallback appears about 40 times. **Any missing org context silently becomes org 1.**
- `resolveOrgId` (`utils/orgCode.js`) accepts a numeric id or an `XXX-NNNNNN` code.
- `isOrgLoginBlocked` (`utils/orgStatus.js`) allows login only when the org is `active` or `trial`.

RBAC:

- Module access lives in `edx_web_emp_roles.access_list` as CSV module ids.
- It is **enforced only in the frontend** (menu gating).
- The server only checks that you can't assign a role broader than your own (`userController.checkRoleAssignment`).
- `applyBranchFilter` treats null or empty `branch_access` as **unrestricted**.

### 2.3 Route groups (all under `/api`, ~196 routes)

| Group (file) | Guard | Main endpoints |
|---|---|---|
| userRoutes | public / `auth` | loginWeb, ownerLogin, login, forgot/resetPassword, createUser, update-user, terminate-user, update-user-client, saveUser, getUserDetails, getWebEmpDetails |
| masterservicesRoutes | none (org from token or `?org_id`) | masterServices, masterServicesTypes |
| hpRoutes | `auth` | createHPProfile, updateHPProfile, getHPDetails, updateHPStatus, payouts (pending/create/markPaid/history) |
| hpPortalRoutes | public / `hpAuth` | org/bySlug, org/byId, hpAuth/requestOtp and verifyOtp, hp/me, bank, bookings, attendance check-in/out, earnings, payouts, support, leave, notifications |
| clientPortalRoutes | public / `clientAuth` | clientAuth/*, client/me, bookings (+hp, +attendance), patients, support, invoices, receipts, outstanding |
| orgRoutes | `auth` + `requireOwner` | get/create/updateOrganisation, getOrgDetails |
| subscriptionRoutes | public / `auth` / owner | getPlans (public), getSubscriptionStatus, updateOrgPlan, plan CRUD |
| orgProfileRoutes | `auth` | orgProfile GET/PUT, emailPreview |
| masterTableRoutes | **`auth` at mount** | roles, coupons, addresses, banners, modules, languages, branches, services, service categories |
| bookingsRoutes | **`auth` at mount** | create/update/extend/hold/cancel booking, patient, HP assignment, OTP final save, attendance, matchHP |
| supportRoutes | `auth` (getSupportCategory meant public) | tickets, stats, status |
| accountsRoutes | `auth` (webhook meant public) | receipts, write-offs v1/v2, invoices, credit notes and applications, aging, KPIs, bulk invoices, payment links, Razorpay webhook, insurance, period close, revenue recognition, ledger, outstanding, refunds, internal transfers |
| saasAccountsRoutes | `auth` + `requireOwner` | `/saas/*`: slug/email check, usage, history, status transition, downgrade check, SaaS invoices, health, owner dashboard |
| dashboard / audit / reports / terms / notifications / hostels | `auth` | getDashboardStats, getAuditTrail (+owner trail), generateReport (planGate), report schedule, terms, notifications, hostels/stays/settlements |
| leadsRoutes | meant public | leads/capture |

> **Mount-order bug (verified).** `index.js:113` `app.use('/api', auth, masterTables)` and `:117` (the bookings router, mounted the same way) run `auth` on **every** `/api` request that reaches them. Every group mounted later therefore needs a JWT, including the "public" `/leads/capture`, `/razorpay/webhook` and `/getSupportCategory`.

### 2.4 Business logic highlights

- **Bookings.** Create is transactional (patient plus booking).
  - The HP stage flow is Shortlisted → Interview → Finalized → OTP → Active → Released.
  - Status 3 generates a plaintext 6-digit OTP, which is emailed and texted to the HP. `finalBookingSave` verifies it and raises an invoice.
  - Hold creates a credit note. Cancel computes the billing, then creates a cancellation invoice or a write-off.
  - HP matching scores candidates out of 100 on city, language, experience, gender and history.
- **Accounts.**
  - Ledger with approval levels: L1 ≤ ₹500, L2 ≤ ₹5000, L3 above that. The levels are computed but **not enforced**.
  - Refund state machine: PENDING_APPROVAL → APPROVED → PROCESSING → COMPLETED.
  - Period closing, Razorpay payment links and the webhook, and org-branded invoice/receipt emails.
- **SaaS.**
  - Org create inserts the org, a subscription, a per-org "Super Admin" role and an admin user, **not in one transaction**.
  - Subscription transitions sync the org's status, except `updateOrgPlan`.
- **Hostels.** Gender, capacity and overlap checks on stays; monthly settlements; HP payouts can deduct hostel cost.
- **Notifications.** `utils/notify.js` writes to `edx_notifications` with a `dedupe_key`. Read state is org-wide. "Clear all" hard-deletes.

### 2.5 Database

- **MySQL.** One shared DB with `org_id` tenancy, added to 27 tables by migration 005 with `DEFAULT 1`.
- **Migrations.** 28 files, numbered 001 → 027. The number 006 is used twice.
- **Indexes and keys.** There is only one FK in the whole schema (`hp_attendance.booking_id`). Most join columns have no index.
- **Column types.** Most date columns are VARCHAR(30). CSV is stored in text columns (`access_list`, `user_branch_access`, `hp_reg_languages`). `'NA'` is written into integer FK columns.

**Table groups:**

| Group | Tables |
|---|---|
| Platform | `edx_organizations`, `edx_plans` (global), `edx_subscriptions`, `edx_saas_invoices`, `edx_terms` (global), `edx_web_user_terms_acceptance` |
| Staff & RBAC | `edx_web_app_users`, `edx_web_emp_roles`, `edx_web_module` |
| Clients | `edx_client_app_users`, `edx_client_login_otp`, `edx_patient`, `edx_user_address` |
| Masters | `edx_branches`, `edx_master_languages`, `edx_master_services_category`, `edx_master_services`, `edx_master_coupons` (**globally unique** name), `edx_master_banners` |
| HP | `edx_hp_registration`, `edx_hp_rate`, `edx_hp_login_otp`, `edx_hp_bank_details`, `edx_hp_leave`, `edx_hp_notifications` (nothing writes to it), `edx_hp_attendance`, `edx_hp_payouts` |
| Bookings | `edx_bookings`, `edx_booking_hp`, `edx_hold_booking`, `edx_extension_booking`, `edx_service_closed` |
| Accounts | `edx_invoice`, `edx_receipts`, `edx_write_offs`, `edx_credit_notes`, `edx_credit_note_applications`, `edx_refunds`, `edx_internal_transfers`, `edx_transaction_ledger`, `edx_approval_history`, `edx_insurance_claims`, `edx_rate_history`, `edx_period_closing`, `edx_payment_reminders`, `edx_payment_links` |
| Hostels | `edx_hostels`, `edx_hostel_stays`, `edx_hostel_settlements` |
| Support | `edx_support_category`, `edx_support_requests` |
| Cross-cutting | `edx_audit_log`, `edx_notifications` |

**Schema drift: code references columns or tables that no migration creates.**

| Reference in code | Reality | Breaks |
|---|---|---|
| `edx_booking_hp.booking_id` (`bookingsController.js:1617,1649`, `reportsController.js:108,115`) | the column is `bkng_id` | matchHP, the HP-utilisation report |
| `edx_hp_registration.is_active`, `count('id')` (`saasAccountsController.js:107-110,260`, `subscriptionController.js:106,299`) | no `is_active`; the PK is `hp_reg_id` | plan usage and limit checks |
| `edx_support_category.app_type` / `.status` | the table only has `id, name, org_id` | portal support categories, seed 02 |
| `edx_support_requests.created_by` / `updated_by` | the column is `created_by_employee` | portal ticket create, status update |
| `edx_web_app_users.role_id` (`cron/weeklyReport.js:82`) | the column is `user_role` | weekly report recipients |
| `edx_receipt.receipt_amount` / `receipt_status` (`reportsController.js:134`) | the table is `edx_receipts` with `total_amount` / `status` | the "outstanding" report always errors |
| seed `02_master_data.js` uses `category_name`, `category_icon` | the column is `name` | seeding a fresh DB |

> Migration 001 claims to be a "baseline of prod", yet the code relies on columns it doesn't create. **Prod has probably been altered by hand.** Run `SHOW CREATE TABLE` on QA and prod before writing any fix migration.

### 2.6 Cron jobs (in-process, no locking)

| Job | Schedule | Does | Issue |
|---|---|---|---|
| `notificationReminders` | 07:45 daily | Booking-ending, subscription-expiry (7/3/1/0 days) and follow-up notifications | Mixed status vocabulary |
| `saasBilling` | 08:00 daily | Monthly SaaS invoice per active org; flips Sent → Overdue | — |
| `paymentReminders` | 09:00 daily | Overdue invoice email/SMS at 0/3/7/15 days | **Sends to the staff user whose id equals the client id** (joins the wrong table) |
| `weeklyReport` | Mon 08:00 | Weekly report email | Config is in memory and covers org 1 only; uses `role_id`, which doesn't exist |

**Gap:** nothing expires subscriptions or suspends orgs when `expires_on` passes or invoices go overdue.

---

## 3. Admin web app (`eldivex_app`)

### 3.1 Architecture

**Startup (`main.dart`):** `Firebase.initializeApp` → `GetStorage.init` → `ThemeController` (permanent) → `RoleController` (permanent). `_getInitialRoute()` then picks the start screen:

1. If the URL hash starts with `/hp` or `/client`, go to that portal (home or login).
2. Else, if `active_session` holds a valid portal token, go to that portal's home.
3. Else, if `user_token` is set and `role_id > 0`, go to `/main`.
4. Else, go to the `last_portal` login, or `/login`.

**Admin shell:** `/main` = `SideMenuWidgetView`, a single `PageView`. Most admin screens are **pages inside it, not routes**. Page indices are calculated by hand (`side_menu_widget_view.dart:131-352`), and the current one is persisted in `selected_page_index`.

**HTTP layer (`data/base_api_services.dart`):**

- `ApiService` creates a new Dio per instance (32 instantiations).
- The token is picked by `active_session`.
- The interceptor handles 403 `ORG_SUSPENDED` and 401 by clearing the session and calling `offAllNamed(login)`.
- **Error contract is inconsistent:**
  - `get`, `getList`, `getRaw`, `putRaw`, `patch*` **swallow errors and return null**. This includes a model `fromJson` `TypeError`, so one bad row blanks the whole list.
  - `postRaw`, `postForm`, `putForm` return `e.response`.

**Theming:** `ThemeController` and `ThemeState`, with 5 palettes and light/dark mode. `AppColor.*` are theme-aware getters. `whiteColor` is the surface colour; `buttonTextWhite` is always white.

**Storage keys (GetStorage):**

| Area | Keys |
|---|---|
| Admin | `user_token`, `role_id`, `org_id`, `org_code`, `userId`, `user_name`, `user_image`, `terms_accepted`, `terms_version`, `selected_page_index` |
| Session routing | `active_session`, `last_portal` |
| HP portal | `hp_token`, `hp_id`, `hp_org_id`, `hp_name`, `hp_org_id_param`, `hp_org_slug`, `hp_last_org_id`, `hp_last_org_name` |
| Client portal | the same set with a `client_` prefix |
| Theme | `app_theme_mode`, `app_palette` |

**Rule:** never clear the `*_last_org_*` keys or `last_portal` on logout.

### 3.2 Side menu → RBAC module key → pages

| Module key | Menu pages |
|---|---|
| `Home` | Dashboard: KPI cards and charts, each card also gated per module |
| `Billing` | Receipts, User Statement, Invoice List, Credit Notes (legacy), Insurance Claims, Finance Dashboard, Write-offs, Refunds, Credit Note Mgmt (new), Internal Transfers, Outstanding |
| `Users` | Create / Manage **client** users |
| `Bookings` | Manage Bookings, Extension List |
| `HP Modules` | Register HP, Manage HP, Attendance, CG Payments, Hostels, Hostel Settlements |
| `Support Ticket` | Create Ticket, Manage Support |
| `Settings` | **Reports** (top-level); plus Org Profile, Emp Roles, Manage **Employees**, Banners, OTP & Coupon, Audit Log, Branches, Service Categories, Services |

The key names are confusing: `Users` means client users, while employees sit under `Settings`. Reports and Audit Log have no key of their own.

### 3.3 Module status

| Module | Lines | State | Biggest issues |
|---|---|---|---|
| **accounts** | ~19k | Lists and creates work (legacy screens). **Approve and reject do not work anywhere.** | v1 controller uses `postRaw` on PATCH routes (404). The newer controllers send the wrong field names and casing (`id` vs `write_off_id`, `APPROVE` vs `Approved`, `amount_applied` vs `amount_to_apply`). 7 navigation targets are undefined routes. Credit-note detail and apply views are 20-line stubs. Booking id is used as client id in Outstanding, create write-off and create refund. Malformed ledger URL (`??limit`). Duplicate legacy and new screens for credit notes and write-offs. Money held as `double`. No export. |
| **bookings** | ~10k | Create, edit and assign-HP flows exist | **Hardcoded `address_id` 1/2 on create.** Medical condition is never sent. False success toasts (errors are swallowed). Patient edit always writes English and `isStayAlone=0`. Address update sends the admin's id. Filters use mock branch/service lists. Export and pagination are fake. API calls happen inside `build()`, and the edit form refills on every frame. |
| **client_users** | 2.1k | List and create | Create calls the public **`/login`** endpoint with a client-side `org_id ?? 1`, which mints a client JWT and overwrites `user_token`. Search, Filters and Edit do nothing. Route guard is `Bookings`, menu key is `Users`. |
| **users** (employees) | 1.7k | List, create, edit, terminate | Desktop table ignores search and filters. Sends `org_id ?? 1` from the client. `int userId = box.read(...)` is set once in a permanent controller, so it goes stale. Last name and bio are dropped. Model receives `user_password`. |
| **support** | 1.6k | List, create, close | Hardcoded `due_date "2025-12-20"`, `created_by_employee "1"`. Priority is never sent. `Get.back()` pops the shell. Comments are not URL-encoded. |
| **settings** | 4.4k | Branches, service categories and services CRUD+toggle; coupons; booking OTP lookup; org profile with email preview | Status toggles update the master list but the screen renders the `filtered*` copy, so changes don't show. `as int?` casts. Fetch in `build()` loops when a list is empty. Coupon "max amount" sends the computed discount. `SettingsView` hub is orphaned. |
| **dashboard** | 4.8k | Real stats from `getDashboardStats`, auto-refresh every 5 minutes | Role edit/delete and pagination are stubs. Module-chip loading bug in create-role. `json['x'] ?? 0` int parsing. Date picker forces light mode. |
| **hostels** | 1.4k | CRUD, stays, settlement calculate and generate | No list of past settlements and no mark-paid. Gender dropdown can assert. No error states. |
| **notifications** | 0.6k | Bell, panel, read, read-all, delete, clear-all; 60s polling | Optimistic updates without rollback. Polls while the tab is hidden. No paging. |
| **reports** | 0.6k | Preview works | **CSV download is an `<a href>` with no auth header, so it always gets a 401.** Report-type dropdown isn't reactive. Schedule toggle is cosmetic (server keeps it in memory). |
| **audit_log** | 0.6k | Server-side paging, entity filter | Only 5 of 11 entity types are filterable. No error state. |
| **banners** | 0.7k | Create, list, toggle | No edit or delete. Brittle success-message match. `Get.back()` in the shell. |
| **appearance** | 0.3k | Complete | Device-global, not per user. |
| **saas_accounts**, **organisations** | 3.7k + 0.6k | **Unreachable** (no route, no menu); the live copies are in `owner_platform` | Delete these here. Note that the uncommitted diff still edits them. |
| auth, role (view), `services/`, `file_upload_single.dart` | — | Stubs / empty | Dead code |
| HP portal / client portal | — | OTP login, org resolution (code, id or slug), last-org memory, bookings, attendance, earnings, support, leave, patients, invoices | `TextEditingController`s created in `build()` (input lost on rebuild). `dev_otp` shown in a toast if the backend sends it. Error toasts render as info toasts. |

### 3.4 Cross-cutting problems in the admin app

1. **Unguarded routes.** These GetPages have no middleware at all: `/AddUser`, `/AddMasterRoles`, `/createBookings`, `/settings`, `/services-management`, `/branch-management`, `/settings/otp-coupon`, `/hp-payouts`, all **16 `/accounts/*`** sub-routes, and `/auth`.
2. **`RoleMiddleware` is weak.** It fails open while roles are loading, and a denial redirects to LOGIN, which LoginGuard then bounces to MAIN.
3. **Session mix-ups.**
   - Admin login never resets `active_session`. After an HP or client session in the same browser, admin calls carry the portal token.
   - `main.dart:39,58` uses `startsWith('/hp')` and `startsWith('/client')`. These also match `/hp-payouts` and `/client-users`, so refreshing those admin pages lands on a portal login.
4. **Admin session checks are thin.** The admin token has no JWT expiry check (the portals have one). The Terms gate is enforced only at login; a cold start with a token skips it.
5. **Google sign-in is broken.** It calls `login(email, "")` without awaiting it, before any token exists.
6. **Controller lifecycle.**
   - About 45 `Get.put(...)` calls sit inside `build()`.
   - Controllers construct other controllers.
   - `UsersController` is permanent and keeps the previous org's data after re-login.
7. **Unsafe parsing.** `as int?`, `as String?` and `json['x'] ?? 0` are still used across dashboard, settings, saas, banners and accounts models. They crash on the backend's loose types (`'NA'`, numeric strings). See the "Loosely-Typed Columns" memory.
8. **Navigation inside the shell.** `Get.back()` from a shell page can pop the whole shell. `HelperUi.safeBack` exists but isn't used consistently.
9. **Client-side filtering.** Most lists filter on the client over at most 200 rows. Server pagination exists only in audit_log and the accounts ledger.
10. **Dead dependencies.** `google_sign_in`, `easy_sidemenu`, `image_cropper`, `fluttertoast`, `loading_animation_widget`, `to_csv`, `share_plus`, `path_provider`, `url_launcher` and `dropdown_button2` are never imported. `dart:html` is used in 3 places.
11. **Misc.**
    - Firestore rules expired on 2026-07-01 (the app doesn't use Firestore anyway).
    - `functions/src/syncLead.ts` cannot be deployed.
    - Stray `lib/app/modules/dashboard/views/lc.code-workspace` is tracked in git.

---

## 4. Owner platform (`owner_platform`)

**Tabs:** Overview (MRR, invoices, health), Organisations, SaaS Accounts (list, usage, health, billing, subscriptions, create wizard), Plans, Audit Log. Every tab is wired to real `auth + requireOwner` endpoints.

**Issues:**

- **Mixed content.** The portal is served over HTTPS but its default and documented API URLs are `http://`, so the deployed site can't call the API.
- **Inconsistent owner check.** `main.dart` uses `is_owner`, but the middleware checks `role_id == 1`.
- **Login errors never reach the user.** `postRaw` swallows errors, so the 401/404/429 branches never run.
- **Stale token header.** `post<T>()` reuses the Authorization header captured when Dio was built.
- **Unsafe casts.** `as num?` on DECIMAL values sent as strings.
- **Dead weight.** About 150 unused API constants. Unused packages: firebase_auth, google_sign_in, syncfusion, pdf and others. Template title and manifest.
- **Uncommitted:** a Firebase project switch to `eldivexweb-e58aa`, an untracked `.firebaserc`, and `org_code` display.

---

## 5. Client mobile app (`eldivex_client`)

**Flow:** splash → login (org id + phone) → Firebase phone OTP on the device → `POST /login` → bottom bar (Home / Bookings / Payments / Support), onboarding, and settings.

**Real vs mock:**

| Area | State |
|---|---|
| Login, home categories and services, bookings list, onboarding upload | real |
| Payments | mock data; routes not registered |
| Support | stub |
| Language switch | no translations |

**Blockers:**

1. **Plain HTTP is blocked** on Android (no cleartext config) and iOS (no ATS exception).
2. **The onboarding redirect is reversed** (`login_controller.dart:188`). New users skip onboarding; returning users are sent to it.
3. **Booking creation always fails.** It hardcodes `branch_id`, `user_id` and `address_id` to `"1"`, and sends `service_type` where the validator needs `service_type_id` and `base_rate`, so every booking gets a 400.
4. **Insecure login.** Firebase OTP is checked on the device only. The backend `/login` trusts phone + org with no proof. It should move to `/clientAuth/requestOtp` and `/clientAuth/verifyOtp`.
5. **Release config.**
   - Razorpay **test** key is hard-coded.
   - PhonePe salts are in git history and must be rotated.
   - Release builds are signed with the debug key.
   - The Firebase project is still `thrivewell-e5dab`.
   - iOS has no `GoogleService-Info.plist`.

---

## 6. Website (`eldivex_website`)

The site is a single landing page with these sections: hero, features, dashboard mock, how it works, benefits, industries, early access, pricing, security, CTA, footer.

- **Lead capture.** Every CTA opens "Book Demo", which writes to Firestore `leads_website`.
  - The repo has no Firestore rules.
  - Nothing syncs these leads to the backend.
  - `syncLead.ts` in `eldivex_app/functions` watches a different collection (`leads`) and cannot be deployed.
- **Pricing.** Hard-coded in USD ($99/$249/$599) and not tied to `edx_plans`.
- **Dead buttons.** Nav links, Watch Demo, Explore Features and all footer links have empty `onPressed`.
- **No login or signup link** to the apps.
- **Analytics.** Only the router observer is wired. `AnalyticsService.logDemoRequested` is never called.
- **Dead code.** Models, services and providers from a planned dashboard. A `yes/index.html` placeholder. A committed `.claude/settings.json`. Package name is `test_website`.

---

## 7. Uncommitted work: commit this before starting features

| Repo | Modified | Untracked (new) | Risk |
|---|---|---|---|
| `eldivex_app` | 41 files (+1274 / −278): portal session persistence, terms gate, settings (categories, org profile, services), dashboard, defensive models, base URL → EC2 QA IP | `core/utils/jwt_utils.dart`, `modules/notifications/`, `modules/terms/`, `org_profile_controller/view`, `service_categories_view`, `.vscode/launch.json` | Modified files import the untracked ones. **A partial commit breaks the build.** |
| `eldivix_be` | 30 files, including the static-OTP removal, envValidator, jwt, bookings, accounts, crons | **Migrations 020–027**, notifications, terms and orgProfile controllers and routes, `utils/notify.js`, `utils/orgBrand.js`, `cron/notificationReminders.js`, `docs/ORG_ISOLATION_NOTES.md` | **HEAD still has `?? '123456'` static OTPs (verified).** 8 migrations and 3 features exist only on this laptop and on whatever box they were copied to. |
| `owner_platform` | 8 files | `.firebase/`, `.firebaserc` | — |
| `eldivex_client` | 4 files (base URL, org-code login, PhonePe salts → dart-define) | — | — |
| `eldivex_website` | hosting cache only | — | — |

**Unknowns to resolve first:**

1. Which backend commit or working tree is running on the EC2 QA and prod boxes?
2. Which migrations are recorded in `knex_migrations` on each DB?
3. What is `NODE_ENV` on prod? If it isn't `production`, `dev_otp` is returned and the production config checks are skipped.

---

## 8. Prioritised findings

### P0: security and tenant isolation (fix before any new feature ships)

| # | Issue | Where |
|---|---|---|
| 1 | **`POST /api/login` issues a JWT for any `{phone_number, org_id}` with no OTP or password (verified).** Because `auth.js` has no role check (verified) and null `branch_access` means "all branches", that token reads and writes **every admin endpoint of the org**. Org ids are small integers, so they can be guessed. | `userController.js:206-257`, `middlewares/auth.js`, `utils/applyBranchFilter.js:13-15` |
| 2 | HP and client portal tokens are also accepted by every admin endpoint (same `auth.js` gap). | `middlewares/auth.js` |
| 3 | No server-side RBAC. Any staff role can approve refunds, write-offs and transfers, close periods, create roles and edit the org profile. Users can approve their own requests. | all tenant routes; `accountsController.js:1760,1920` |
| 4 | Static OTP `123456` is the default in committed HEAD (verified). `dev_otp` is returned whenever `NODE_ENV !== 'production'`. | `hpAuthController.js:163`, `clientAuthController.js:88`, `:68`, `:137` |
| 5 | Razorpay webhook is forgeable. The signature check is skipped if the secret is unset; it hashes `JSON.stringify(body)` rather than the raw body; the invoice lookup is unscoped; replays aren't deduplicated. `createPaymentLink` never sets `notes.invoice_id`, so real webhooks are ignored. | `accountsController.js:1307-1430` |
| 6 | `/getWebEmpDetails` returns `user_password` and `password_reset_token` (`select *`). | `userModel.js:68` |
| 7 | `/uploads` is public, including HP ID proofs. The multer file filter is disabled and the original extension is kept, so HTML or SVG uploads allow stored XSS. | `index.js:60`, `middlewares/upload.js:18` |
| 8 | Cross-org reads and writes: `cancelUserService`, `holdBooking`, `_computeCancellationBilling`, `createWriteOff` (shows another org's balance), `assignHPToBooking`, `createCreditNote`, public `leads/capture` (overwrites any org's client by phone), support categories, and coupon uniqueness is global. | `bookingsController.js:23,62,639,744,1036-1123`, `accountsController.js:399,615`, `leadsController.js:32-56`, `supportModel.js:24` |
| 9 | Terminated users keep access for up to 30 days. `auth` never re-checks `user_status`, and a password reset doesn't revoke tokens. | `middlewares/auth.js` |
| 10 | Every `?? 1` org fallback silently targets the real org 1. | `utils/orgScope.js:14`, `jwt.js`, `hpAuth.js`, `clientAuth.js`, plus about 40 more |
| 11 | Frontends send `org_id` from the client (`users_controller`, `client_users_controller`). Per the org-isolation rule, it must come from the JWT only. | `eldivex_app/.../users_controller.dart:164,199,323`, `client_users_controller.dart:83` |
| 12 | CORS uses `startsWith('http://localhost')`, which also matches `localhost.evil.com`, and allows localhost in prod. `trust proxy 1` with no proxy allows X-Forwarded-For spoofing past rate limits. OTPs use `Math.random()`. | `index.js:27-53` |

### P1: broken functionality

**Backend**

- Mount-order bug blocks `/leads/capture`, `/razorpay/webhook` and `/getSupportCategory`.
- Schema drift (§2.5) breaks matchHP, three reports, plan usage and limits, portal support tickets, the weekly report, and seed 02.
- Customer emails (booking, support, credit note, payment reminders) look up `edx_web_app_users` by a **client id**, so mail goes to an unrelated staff member.
- Subscriptions never expire. `updateOrgPlan` doesn't sync org status. Plan limits (`booking_limit`, `hp_limit`) are never enforced.
- `applyCreditNote` accepts negative amounts and has a race condition. `approveWriteOff` has the same race.
- The report schedule lives in memory.

**Admin app**

- All accounts approval flows (see §3.3).
- Reports CSV download (401).
- Booking create uses a hardcoded address.
- False success toasts in bookings.
- Support tickets are sent with hardcoded values.
- The Users screen ignores filters on desktop.
- Settings toggles don't show their new state.
- Session mix-ups and route prefix collisions.
- Terms gate bypass.
- Google sign-in.

**ApiService error contract**

`getList` and friends swallow errors and parse failures. The UI then shows "No data" for any error.

**Owner portal and client app**

- Mixed content (HTTPS page, HTTP API) on the owner portal.
- Client app: cleartext HTTP, reversed onboarding, failing booking create.

### P2: quality and technical debt

- Duplicate legacy and new accounts screens. Index-based side-menu navigation. Unreachable `saas_accounts` and `organisations` modules in the admin app.
- `Get.put` inside `build()`. Controllers constructing other controllers. Undisposed `TextEditingController`s.
- Money held as `double`. Dates stored as VARCHAR. CSV in columns. Missing FKs and indexes on all join columns. Migration 006 numbered twice. The MariaDB-only `ADD UNIQUE INDEX IF NOT EXISTS` silently fails on MySQL.
- Duplicated helpers: `_toInt` / `_toDouble` ×5, `_statusColor` ×10, `_fmt` ×11. HP and client auth controllers are 95% the same. Session-clearing logic exists in 4 places.
- Inconsistent backend response shapes (`{message}`, `{error}`, `{status}`, `{success}`). Raw error objects leak to clients.
- Unused packages, constants and files in every Flutter repo. Template README and manifests.
- Crons run in-process with no lock, so they duplicate work if more than one instance runs.

---

## 9. Recommended implementation order

Each phase is shippable on its own. The order is a recommendation, not a decision.

**Phase 0: baseline (½–1 day)**

1. Commit the in-flight work in each repo as coherent commits. Commit `eldivex_app`'s modified and untracked files together. Commit the backend migrations 020–027 and the new controllers.
2. Record what is deployed on QA and prod (commit, `NODE_ENV`, `knex_migrations` contents), and `SHOW CREATE TABLE` the drifted tables.
3. Put the API behind HTTPS (domain + TLS on EC2, or a reverse proxy). Set `API_BASE_URL` per environment in every Flutter build.

**Phase 1: backend security (P0 1–12)**

1. Make `/api/login` OTP-only, or remove it and move the client app to `/clientAuth/*`.
2. Split `auth` into `requireStaff` / `requireHp` / `requireClient` based on the token's claims.
3. Add a `requireModule('Billing')`-style RBAC middleware, plus approval-level checks.
4. Re-check `user_status` on each request (short cache).
5. Remove the static OTP and `dev_otp` from production paths.
6. Fix the webhook: raw body, timing-safe comparison, idempotency, org scoping.
7. Stop selecting password columns. Lock down `/uploads` (authenticated download plus an extension/MIME allow-list).
8. Close the cross-org holes in §8 #8. Remove the `?? 1` fallbacks (fail closed).

**Phase 2: backend correctness**

1. Write a single migration that reconciles schema drift, or fix the code to match the real schema.
2. Fix the mount order.
3. Point client email lookups at `edx_client_app_users`.
4. Add a subscription-expiry cron, sync `updateOrgPlan`, and enforce plan limits.
5. Fix the credit-note and write-off races.
6. Persist the report schedule.

**Phase 3: admin app correctness**

1. Pick one `ApiService` error contract (return a result/error, never swallow parse errors).
2. Fix the accounts approval calls and payloads, and the missing routes.
3. Guard every route.
4. Fix `active_session` reset, the prefix matching, and the terms gate on startup.
5. Fix reports CSV (fetch with auth, then blob download).
6. Fix the bookings, support, users and settings bugs from §3.3.
7. Delete dead modules and packages.

**Phase 4: client mobile app**

1. Use HTTPS and move login to `/clientAuth` OTP.
2. Fix the onboarding flag.
3. Make booking create use real ids and the correct payload.
4. Move to the Eldivex Firebase project and set up release signing and keys.

**Phase 5: owner portal and website**

1. Owner portal: HTTPS, a consistent owner check, a working error path.
2. Website: wire the nav and footer, add a Login link, sync leads to the backend (fix the mount order first), log analytics events, and source pricing from `edx_plans`.

**Phase 6: roadmap features** (from `SAAS_ROADMAP.md`, still pending)

- Decide whether `user_email` is unique globally or per org.
- Socket.io real-time notifications.
- S3 storage for uploads.
- Sentry and a `/health` endpoint.
- Server-side pagination across lists.
- Export (CSV/PDF) using the shared `ExportToCsv` helper.
- Razorpay SaaS billing.

---

## 10. Conventions to keep while implementing

- **Org isolation.** `org_id` always comes from the JWT (`getOrgId`) and never from the client. Every tenant query is scoped. A 0-row update returns 404. Exceptions are owner-only `/saas/*` and `getOrganisations`. See `eldivix_be/docs/ORG_ISOLATION_NOTES.md`.
- **Org status.** The login rule lives only in `utils/orgStatus.js` (`isOrgLoginBlocked`). Subscription transitions must also sync org status and call `invalidateOrgStatusCache`.
- **Org codes.** New orgs get `XXX-NNNNNN` codes. Accept either form via `resolveOrgId()`.
- **Defensive parsing.** In Flutter models, parse with `_toInt` / `_toStr` / `_toDouble`. Never use `as int?` or `?? 0` on backend fields.
- **Theming.** Use `AppColor.*` getters. Use `buttonTextWhite` for text on brand colours. No hard-coded `Colors.black` / `Colors.white`.
- **GetX.** Don't `offAllNamed` from the login route back to the login route. Register controllers in bindings, not in `build()`.
- **Portal sessions.** Never clear `*_last_org_*` or `last_portal` on logout.
- **Deploy.** The backend is shipped by hand to EC2. Migrations are run by hand and must ship **before** the code that uses them. Number migrations uniquely.
- **Database changes summary.** After every piece of work, list the new or changed tables, columns, writes and reads, and any migration with where it has been run.
