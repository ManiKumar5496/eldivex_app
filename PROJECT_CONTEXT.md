# Eldivex Admin App (`eldivex_app`): Project Context

Working guide for developers starting on this repository. Claims come from **static inspection** of the current working tree (including uncommitted changes) of this repo and of the sibling backend `eldivix_be`. The only commands executed were read-only inspection (`git status/diff/show/ls-files`, `grep`, `find`) plus `flutter test --no-pub` and `flutter analyze --no-pub` in this repo (results in §13; `pubspec.lock` was unchanged afterwards). The app was not launched, the backend was not started, and no database or deployed environment was contacted.

Labels used below:
- **[Verified]**: confirmed by reading the cited file(s).
- **[Inferred]**: a reasonable conclusion from the code that was not confirmed at runtime.
- **[Recommendation]**: a suggestion, not a fact.

Paths are relative to the repository root unless they start with a sibling repo name (`eldivix_be/…`).

---

## 1. Executive summary

- **What it is.** A Flutter **web** app for "Eldivex", a multi-tenant home-care / health-professional (caregiver) services SaaS. One bundle serves three audiences [Verified, `lib/app/routes/app_pages.dart`]:
  - the **tenant admin/staff console** (`/login` → `/main` shell);
  - the **caregiver (HP/CG) self-service portal** (`/hp/...`);
  - the **client (customer/family) self-service portal** (`/client/...`).
- **Backend.** A separate Node/Express/MySQL REST API (sibling repo `eldivix_be`, not part of this repo) reached over Dio with Bearer JWTs. Firebase is only used for `Firebase.initializeApp` and Hosting. The app does **not** use Firebase Auth, Firestore, or Storage from Dart [Verified, `pubspec.yaml`, `lib/main.dart`].
- **Maturity.**
  - Feature-rich: about 76k lines of Dart across lib + test; the main modules are accounts, bookings, HP management, hostels, support, settings, dashboard, reports, audit log, notifications, terms, and the two portals.
  - Mid-stabilisation. `git status --short` shows **147 entries, excluding this guide and the `.agents/` review artifacts**: 132 modified, 4 deleted, and 11 untracked paths. The untracked paths are new modules and helpers (`notifications/`, `terms/`, `core/utils/`, org profile, service categories, accounts helpers) plus `WORKSPACE_AUDIT.md` and `.vscode/`. Modified files import untracked ones, so a partial commit would break the build [Verified, `git status --short`].
  - The sibling backend is in the same state: most of its security and RBAC fixes exist only as uncommitted changes in the `eldivix_be` working tree, and its committed `HEAD` still has the older, insecure behaviour (§6, §11).
  - Only model-parsing unit tests exist; all 347 pass (§13).
  - `README.md` is still the Flutter template.
- **Existing docs.**
  - `SAAS_ROADMAP.md` is older and claims roughly 82% completion.
  - `WORKSPACE_AUDIT.md` (dated 2026-10-07) covers five repos.
  - Both are partly **stale** against the current code (see §15).

## 2. Technology stack and external services

| Area | Choice | Source |
|---|---|---|
| UI | Flutter (Material), web target | `pubspec.yaml`, `web/` |
| SDK | `environment.sdk: ^3.8.1`; the lockfile needs Dart ≥3.10.3 / Flutter ≥3.38.4 | `pubspec.yaml`, `pubspec.lock` |
| State / DI / routing | GetX `get` 4.7.3 | `pubspec.lock` |
| HTTP | Dio 5.9.2, one shared instance | `lib/app/data/base_api_services.dart` |
| Local persistence | `get_storage` 2.1.1, used as the session store | everywhere (`box`) |
| Charts / tables | `syncfusion_flutter_charts`, `data_table_2` | dashboard, accounts |
| PDF | `pdf`, `printing` (HP profile PDF) | `register_cg/views/review_cg_details_view.dart` |
| Toasts | `toastification` via `HelperUi.showToast` | `lib/app/widgets/helper_ui.dart` |
| Files | `file_picker`, `image_picker` | uploads (HP docs, banners, user image) |
| Web interop | `package:web` + `dart:js_interop` (reports, notifications); legacy `dart:html` (org profile, CSV export) | see §12 |
| Other | `intl`, `logger`, `shimmer`, `toggle_switch`, `cupertino_icons`; dev: `flutter_lints` 5, `flutter_launcher_icons` | `pubspec.yaml` |
| Backend | REST API in `eldivix_be` (Express + knex + MySQL), cron jobs there | `lib/app/data/api_constant_url.dart`, sibling repo |
| Hosting | Firebase Hosting (`build/web`, SPA rewrite to `/index.html`) | `firebase.json`, `.firebaserc` |
| Firestore / Functions | Configured but unused by the app (see §10) | `firestore.rules`, `functions/src/*` |

**API base URL** (`lib/app/data/api_constant_url.dart`) [Verified]:
- It is `String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.eldivex.com/api')`.
- In the working tree the default changed from a Railway URL (HEAD) to `https://api.eldivex.com/api`. That change is **uncommitted**, like the rest of the edits in `api_constant_url.dart` (new terms, notifications, org-profile, `createClientUser`, and service-category constants) and in `base_api_services.dart`. This guide documents the working tree as it is.
- The full client-to-backend endpoint map is in **Appendix B**.
- Doc comments list QA and production examples as **plain-HTTP IP addresses**. On an HTTPS-hosted site these would be blocked as mixed content [Inferred].

## 3. Directory and file map

```
eldivex_app/
├── lib/
│   ├── main.dart                     # entry: Firebase init, GetStorage, ThemeController, RoleController, initial-route logic
│   ├── firebase_options.dart         # FlutterFire web options (throws on non-web platforms)
│   └── app/
│       ├── core/
│       │   ├── theme/                # app_palette (5 palettes), app_themes (light/dark), theme_controller, theme_state (static theme-aware colours)
│       │   ├── utils/                # jwt_utils (exp check), session_utils (admin session validity, role/org id)  [untracked]
│       │   └── values/               # color_constants (AppColor getters), text_style_constants, size_configue (SizeConfig responsive helpers), enums
│       ├── data/
│       │   ├── api_constant_url.dart # every admin endpoint path (ApiConstants)
│       │   └── base_api_services.dart# ApiService: shared Dio, auth header, 401/403 interceptors, request helpers
│       ├── initial_bindings/         # registers RoleController if missing
│       ├── middleware/               # auth (admin + login guard + unknown route), role (RBAC module key), hp_auth, client_auth
│       ├── routes/                   # app_routes.dart (Routes/_Paths, get_cli generated style), app_pages.dart (GetPage list)
│       ├── widgets/                  # shared widgets: helper_ui, shimmer_loader, dropdown_common, date_picker_common,
│       │                             #   common_textfield, common_text_form_field, elevated_button_common, common_file_upload, export_to_csv_common
│       └── modules/                  # feature modules, each with bindings/ controllers/ models/ views/ (GetX CLI layout)
│           ├── login, forgot_password, terms, auth (stub), role (RoleController + stub view)
│           ├── dashboard             # DashboardController, dashboard_view, side_menu_widget_view (ADMIN SHELL), role create/manage, stats widgets
│           ├── accounts              # receipts, statements, invoices, credit notes (legacy + new), insurance, revenue recognition,
│           │                         #   write-offs (legacy + new), refunds, internal transfers, outstanding; parse_utils, accounts_format, accounts_feedback
│           ├── bookings              # bookings list, create, edit, manage (HP pipeline), extension list, assign-CG dialog, CG review
│           ├── client_users          # create/lookup client by phone, details form, manage list
│           ├── users                 # employees (staff) list/create/edit/terminate
│           ├── register_cg           # HP registration, manage HP, attendance (mark/list), CG payments, HP payouts
│           ├── hostels               # hostels CRUD, stays, settlements
│           ├── support               # create ticket, manage tickets
│           ├── settings              # settings hub, org profile + email preview, branches, service categories, services, OTP & coupons
│           ├── banners, appearance, reports, audit_log, notifications
│           ├── hp_portal             # caregiver portal (auth controller, controller, shell + tabs, detail pages, link card, HpApi)
│           ├── client_portal         # client portal (same structure, ClientApi)
│           ├── organisations         # UNREACHABLE (no route/menu); superseded by owner_platform repo
│           └── saas_accounts         # UNREACHABLE (no route/menu); owner-only endpoints
├── test/
│   ├── widget_test.dart              # placeholder test
│   └── models/                       # 10 model fromJson/toJson test files
├── functions/src/                    # index.ts + syncLead.ts (Firestore trigger). No package.json/tsconfig.
├── web/                              # index.html, manifest.json, favicon + icons (Flutter web shell)
├── public/index.html                 # Firebase default placeholder page (hosting serves build/web, not public/)
├── assets/                           # images/ (logo, app icon, google.png), icons/ (4 PNGs), fonts/inter/ (4 TTFs)
├── firebase.json, .firebaserc, firestore.rules, firestore.indexes.json
├── pubspec.yaml, pubspec.lock, analysis_options.yaml (flutter_lints defaults)
├── README.md (template), SAAS_ROADMAP.md, WORKSPACE_AUDIT.md
├── .vscode/launch.json, .idea/, eldivex_app.iml, .metadata   # IDE / Flutter tool metadata
└── .claude/settings.local.json       # local agent permission file (git-ignored; contains sensitive data; see §11)
```

**Stray file.** `lib/app/modules/dashboard/views/lc.code-workspace` is a VS Code multi-root workspace (this repo plus `eldivix_be`, `eldivex_client`, `owner_platform`, `eldivex_website`) sitting inside the source tree [Verified].

## 4. Startup and initialisation flow

Source: `lib/main.dart`, `lib/app/middleware/*`, `lib/app/core/utils/*` [Verified].

1. **`main()`**
   - `WidgetsFlutterBinding.ensureInitialized()`
   - `Firebase.initializeApp(DefaultFirebaseOptions.currentPlatform)`. This throws `UnsupportedError` on anything except web.
   - `GetStorage.init()`
   - `Get.put(ThemeController(), permanent: true)`
   - `Get.put(RoleController(), permanent: true)`. `RoleController.onInit` calls `fetchRoleAndAccess()` if an admin session already exists.
   - `runApp(EldivexAdmin())`.
2. **`EldivexAdmin.build`** wraps `GetMaterialApp` in `ToastificationWrapper` and an `Obx` on theme mode/palette.
   - `initialBinding: InitialBindings()` registers RoleController only if it is missing.
   - `getPages: AppPages.routes`.
   - `unknownRoute`: `UnknownRouteMiddleware` sends authenticated users to `/main` (or `/terms`) and everyone else to `/login`.
3. **`_getInitialRoute()`** reads the URL hash fragment, because the app uses hash routing:
   - **Path is `/hp` or `/hp/...`** (whole-segment match, so `/hp-payouts` is not caught):
     - stores `?org_id=` in `hp_org_id_param` and `?org=` in `hp_org_slug`;
     - sets `last_portal=hp`;
     - goes to `/hp` if `hp_token` is a valid, unexpired JWT, otherwise `/hp/login`.
   - **Path is `/client...`**: the same logic with `client_*` keys.
   - **Otherwise, live portal session**: if `active_session` is `hp` or `client` and that portal's token is valid, go to that portal's home.
   - **Otherwise, valid admin session**: `isAdminAuthenticated()` requires an unexpired `user_token`, `role_id > 0`, and `org_id > 0`. If it passes, write `active_session=admin`, then go to `/main` if `terms_accepted == true`, else `/terms`.
   - **Otherwise**: go to the `last_portal` login screen, or `/login`.
4. **Route middleware**:
   - `AuthMiddleware` (priority 0): no admin session → `/login`; terms not accepted → `/terms`; otherwise writes `active_session=admin`.
   - `RoleMiddleware(key)` (priority 1): while access is still loading, it lets the page through, but `onPageBuilt` shows a spinner until the access list arrives. If the role lacks the module, it shows a toast and redirects to `/main`.
   - `HpAuthMiddleware` / `ClientAuthMiddleware` check their own token and set `active_session`.
   - The login guards bounce already-authenticated users to their home screen.
5. **First admin screen.** `/main` is `SideMenuWidgetView`, a stateful shell.
   - It registers controllers in `initState`: `UsersController` (permanent), `DashboardController`, plus fenix lazy-puts for AuditLog, Reports, Settings, WriteOff, Refund, CreditNote, InternalTransfer, and Outstanding.
   - It builds the menu from `RoleController.accessList` (see §6).
   - It restores `selected_page_index` and shows a `PageView`.

### Login flow (`modules/login/controllers/login_controller.dart`)

1. Validate the email locally.
2. `postRaw(/loginWeb, {email, password})`.
3. On 200, require `token`, `role_id > 0`, and `org_id > 0`.
4. Store `user_token`, `user_name`, `role_id`, `userId`, `user_image`, `org_id`, `org_code`, `active_session=admin`, and `terms_accepted` (from the backend).
5. `await RoleController.fetchRoleAndAccess()`.
6. `offAllNamed(/terms or /main)`.
7. Error statuses map to messages: 422 (validation details), 429 (rate limit), 401, 404, other, and no connection.

### Terms gate (`modules/terms/controllers/terms_controller.dart`)

- `GET /getCurrentTerms`. If the backend says `accepted`, proceed immediately.
- The user must scroll to the bottom and tick the checkbox before Agree unlocks.
- Agree calls `POST /acceptTerms {terms_id}`. A `TERMS_OUTDATED` response reloads the terms.
- Decline clears the admin keys and returns to `/login`.

### Logout

- Admin: the dashboard settings popup calls `RoleController.clearAuth()` then `offAllNamed(/login)`. `clearAuth` removes `user_token`, `role_id`, `org_id`, `user`, and `selected_page_index`.
- Portals: `HpAuthController.logout()` / `ClientAuthController.logout()` remove only that portal's keys and keep `*_last_org_*` and `last_portal`.

## 5. Architecture and state-management patterns

- **GetX module layout** (`bindings/ controllers/ models/ views/`). `app_routes.dart` carries the get_cli "DO NOT EDIT" header but is hand-edited [Verified].
- **Two navigation systems** coexist:
  1. **Named GetX routes** (`Routes.*`) for login, terms, portals, the accounts sub-flows (`/accounts/...`), standalone admin pages, and settings sub-pages.
  2. The **index-based admin shell**: most admin screens are `PageView` children inside `SideMenuWidgetView`, not routes. Page indices are computed by hand in `_buildMenuStructure()`, so adding a page in the middle shifts later indices. `manage_hp_page_index` is persisted so `RegisterCgController` can jump to Manage HP after a save.
  3. In addition, **`Get.to(() => Widget(...))`** pushes untyped pages: ManageBookingView, EditBookingView, CgReviewDetailScreen, CreateSupportTicket (with arguments), hostel detail/create, and the saas account detail.
- **Controller registration is mixed** [Verified]:
  - Bindings exist for routed pages.
  - Shell pages self-register with `Get.isRegistered ? Get.find : Get.put` inside `build`/`initState` (about 58 `Get.put` call sites across views and controllers).
  - Some controllers construct others, for example `RegisterCgController` has the field `final dashboardController = Get.put(DashboardController())`.
  - `UsersController` is permanent and resets itself on a session change (`resetForNewSession`).
- **ApiService** (`lib/app/data/base_api_services.dart`) [Verified]:
  - One static shared `Dio` with 60 s timeouts.
  - The token is chosen per request from `active_session` (`user_token` / `hp_token` / `client_token`).
  - **Interceptors**:
    - 401 with a stored token, outside the login routes: clear the active session, go to its login screen, show a toast (debounced).
    - 403 `ORG_SUSPENDED`: the same, with the backend's message.
    - 403 `MODULE_FORBIDDEN`: toast only.
  - **Return contract** (inconsistent):
    - `get`, `getList`, `getRaw`, `putRaw`, `patchApi`, `patchRaw`, `postDynamic`, `post` return `null` on HTTP error or exception.
    - `postRaw`, `postForm`, `putForm`, `getBytes` return the error `Response`.
    - `delete` returns a `bool`.
    - `ApiService.lastError` holds the last backend error message, so callers of the null-returning methods can still show the real reason.
    - `getList` parses row by row and skips malformed rows instead of failing the whole list.
- **Defensive parsing**: models increasingly use `_toInt` / `_toStr` / `toIntOrNull` helpers because backend columns are loosely typed (`'NA'`, numeric strings). Shared helpers are in `modules/accounts/models/parse_utils.dart` (about 30 importers). Hard `as int?` / `as String` casts remain (§15).
- **Theming**:
  - `ThemeController` persists `app_theme_mode` and `app_palette`.
  - `ThemeState` holds static theme-aware colours read by `AppColor.*` getters.
  - The app rebuilds on palette or mode change.
  - There are 5 palettes (Blue, Teal, Violet, Emerald, and one more) in `core/theme/app_palette.dart`.
- **Responsive layout**: `SizeConfig.init(context)` plus mobile (<600), tablet (<1024), and desktop breakpoints.

## 6. User roles, RBAC and navigation

**Three session types** live in one browser and are kept apart by `active_session` [Verified]:

| Session | Login | Token key | Home | Guard |
|---|---|---|---|---|
| Admin/staff | `/login`: email + password → `/loginWeb` | `user_token` | `/main` | `AuthMiddleware` (+ `RoleMiddleware`) |
| Caregiver (HP/CG) | `/hp/login`: org (link, code `XXX-NNNNNN`, numeric id, or slug) → phone → OTP (`/hpAuth/*`) | `hp_token` | `/hp` | `HpAuthMiddleware` |
| Client | `/client/login`: the same flow via `/clientAuth/*` | `client_token` | `/client` | `ClientAuthMiddleware` |

**Admin RBAC** (client-side gating):
- `RoleController` loads `GET /getRoles?id=<role_id>`.
- It splits the `modules` field (module **names**) into `accessList`.
- Role creation (`dashboard/views/create_user_roles.dart` → `POST /createRole`) sends `access_list` as comma-separated module **IDs**.

Module keys and what they unlock in the shell (`side_menu_widget_view.dart`):

| Module key | Shell pages (menu labels) |
|---|---|
| `Home` | Dashboard |
| `Billing` | Reciepts, User Statement, Invoice List, Credit Notes (legacy), Insurance Claims, Finance Dashboard (Revenue Recognition), Write-offs, Refunds, Credit Note Mgmt, Internal Transfers, Outstanding |
| `Users` | **Client** users: Create Users, Manage Users |
| `Bookings` | Manage Bookings, Extension List |
| `HP Modules` | Register HP, Manage HP, Manage Attendance, CG Payments, Manage Hostels, Hostel Settlements |
| `Support Ticket` | Create Ticket, Manage Support |
| `Settings` | **Reports** (top level), then Organisation Profile, Manage Emp Roles, Manage **Employees**, Manage Banners, OTP & Cupon, Audit Log, Branch Management, Service Categories, Services Management |

Notes:
- "Users" means client users, while staff are managed under Settings.
- Reports and Audit Log have no key of their own.
- Dashboard cards and charts are also gated per module.
- A role with no modules sees a "No Access Assigned" screen.

**Server-side enforcement** lives in the sibling backend [Verified, `eldivix_be` working tree]:
- `eldivix_be/middlewares/auth.js` accepts only staff tokens (from `/loginWeb`) and owner tokens (`is_owner`, from `/ownerLogin`). It rejects HP and client tokens with 401. On every request (cached for 60 s) it re-checks the staff row for `user_status = '1'`, a matching `org_id`, and `tokens_valid_after`, and it loads the current DB role into `req.staff_role_id`.
- `eldivix_be/middlewares/requireStaff.js` rejects owner tokens and tokens without `role_id`/`org_id` (403).
- `eldivix_be/middlewares/requireModule.js` maps the role's `edx_web_emp_roles.access_list` (module ids) to `edx_web_module.module_name` values and passes the request if **any** listed name matches. A failure returns 403 `{code: 'MODULE_FORBIDDEN'}`, which `ApiService` turns into a toast.
- `eldivix_be/middlewares/requireOwner.js` requires `is_owner === true`. It guards `orgRoutes.js`, `saasAccountsRoutes.js`, and parts of `subscriptionRoutes.js` / `auditRoutes.js`.
- `eldivix_be/middlewares/orgStatusGate.js` is mounted globally on `/api` (`eldivix_be/index.js`). It returns 403 `ORG_SUSPENDED` for suspended orgs and fails open on DB errors.
- The route-to-guard mapping for every endpoint the app calls is in Appendix B. The server module names match the app's module keys (`Home`, `Billing`, `Users`, `Bookings`, `HP Modules`, `Support Ticket`, `Settings`). Some routes accept several modules, for example `requireModule('Users', 'Bookings')` on client-user endpoints.

**Committed vs working tree** [Verified, `git -C eldivix_be status` / `git show HEAD:…`]:
- `requireStaff.js` and `requireModule.js` are **untracked**. `auth.js` and all route files that use them are **modified, not committed**.
- In `HEAD`, no route file references `requireModule`, and `HEAD:middlewares/auth.js` has no token-kind check.
- The `WORKSPACE_AUDIT.md` §8 P0 #2–3 findings therefore still describe committed `HEAD`, and they are fixed only in the uncommitted working tree.
- **Deployed state cannot be verified** from the repository: no server access or deploy metadata was available.

## 7. End-to-end business flows

The trace for each flow is UI → controller → `ApiService` → backend endpoint. Static only.

### 7.1 Client onboarding (admin) (`modules/client_users`)

1. **Create Users** (`create_client_user.dart`) → `ClientUsersController.addUserClient()` → `POST /createClientUser {phone_number, country_code}`. The response is `{userId, isNewUser}`, and the org comes from the JWT.
2. `Get.toNamed(/addClientDetails)` → `validateAndNext` → `PUT /saveUser` (multipart). Fields include `user_name`, `user_email`, `user_location`, `user_service_city`, `user_source`, `lead_potential`, `enquired_for`, and more. The phone is sent only if it changed.
3. For a new or located client, `Get.offNamed(/bookings, arguments: {userId})` continues to booking.
4. **Manage Users** lists `GET /getUserDetails` and filters and paginates on the client side. It also shows `ClientPortalLinkCard`.

### 7.2 Bookings (`modules/bookings`, `BookingsController` ~1.9k lines)

- **Create** (`create_booking_screen.dart`):
  - Look up the client by phone (`/getUserDetails?...`), load addresses (`/getAddress?user_id=`), and optionally add one (`/addAddress`).
  - Choose branch, category, and service (`/masterServicesTypes?branch_id&service_category_id`).
  - `POST /createBooking` with `branch_id, user_id, dates/times, patient fields, languages (ids), relation, gender (1/2/3), is_stay_alone, address_id (selected), service_type_id, base_rate, base_discount_percentage`.
  - Then `PUT /updateBooking` for care notes and preferred time, followed by `Get.to(ManageBookingView)`.
- **List**: `GET /getUserBookings[?user_id=]`. Search, filters, pagination, and CSV export (`ExportToCsv`) are client-side.
- **Manage booking** (`manage_bookings.dart`): booking detail, HP pipeline tabs, rate history (`/getRateHistory`), coupons, extension (`POST /extendBooking`), and "Hold"/"Cancel" buttons. These buttons open **CreateSupportTicket** pre-filled (typeId 4 = Hold, 5 = Cancel). The controller methods `holdBooking()` / `cancelBooking()` (`/holdBooking`, `/cancelUserService`) exist but **no view calls them** [Verified by search].
- **HP assignment pipeline**:
  1. The assign dialog (`assign_cg_dialog.dart`) offers "All HPs" and "AI Suggested" (`GET /matchHP?booking_id=`) and posts `/assignHPToBooking`.
  2. Each stage transition is `PUT /updateHPBooking {booking_id, hp_unique_id, status[, interview_date]}`.
  3. HP stages: **1 Shortlisted → 2 Interview Stage → 3 Finalized → (OTP) → 4 Active → 5 Released**.
  4. From stage 3 the OTP is verified with `POST /finalBookingSave {booking_id, hp_unique_id, otp}`.
  5. Busy HPs are excluded using `GET /getHPByBooking?status=4`, and the client also filters on `status == 4`. Comments in `bookings_controller.dart` and `register_cg_controller.dart` say the backend ignores `status`. That is **stale for the backend working tree**: `getHPByBookingModel` in `eldivix_be/models/web_app/bookingsModel.js` now applies a `whereIn` on a comma-separated `status`. The client-side filter is harmless redundancy.
- **Edit** (`edit_booking_view.dart`): `PUT /update-user-client` (multipart), `/updatePatient`, `/updateAddress`, `/updateBooking`.
- **Booking status** (`edx_bookings.status`, strings): `'1'` Booking Submitted, `'2'` HP Assigned, `'3'` Booking Cancelled, `'4'` Service Started, `'5'` service on hold, `'6'` Service cancelled, `'7'` Service Suspended (`bookings_controller.dart` ~L264).

### 7.3 Caregivers / HP management (`modules/register_cg`)

- **Register HP**: `POST /createHPProfile` (multipart, ID proofs and certificates).
- **Manage HP**: `GET /getHPDetails`, with status tabs.
- **Approve, reject, terminate**: `PATCH /updateHPStatus?id&status`. HP registration statuses are 0 Inactive, 1 Pending, 2 Approved, 3 Rejected, 4 Terminated.
- **Profile PDF**: `review_cg_details_view.dart` builds a PDF (print/share) and shows `HpPortalLinkCard`.
- **Attendance**: `POST /markAttendance` and `/markAttendanceBatch`, listed with `GET /getAttendanceList`.
- **CG Payments** (`cg_payment_controller.dart`):
  - Fetches attendance and hostel stays for a period.
  - Computes pay on the client: present = full rate, half_day = 0.5 × live-in or live-out rate, minus hostel nights × rate.
  - `generatePayout()` (`cg_payment_controller.dart` ~L218–237) posts `POST /createPayout {hp_unique_id, period_from, period_to, pay_amount (net), gross_pay, hostel_deduction, payment_mode}`. `hp_unique_id` is `CgPaymentSummary.hpId`, which is set from `cg.hpRegId` (~L201). A 201 counts as success.
- **Backend contract for `createPayout`** [Verified]:
  - `createPayout` in `eldivix_be/controllers/web_app/hpController.js` destructures `hp_unique_id, booking_id, period_from, period_to, pay_amount, gross_pay, hostel_deduction, payment_mode` (default `Cash`). It requires `hp_unique_id` and `pay_amount`, inserts into `edx_hp_payouts` with `status: 'Pending'`, and returns 201. All client field names match.
  - **`hp_unique_id` is the HP's `hp_reg_id`.** `edx_hp_registration` has no `hp_unique_id` column; its primary key is `hp_reg_id` (`eldivix_be/migrations/20260524_001_initial_schema.js`). `edx_hp_payouts.hp_unique_id` is commented "FK → edx_hp_registration.hp_reg_id" (`eldivix_be/migrations/20260524_003_hp_payouts.js`). `edx_booking_hp` and `edx_hp_rate` use the same convention: `createHPProfile` writes `edx_hp_rate.hp_unique_id = hp_reg_id`, and `getHPByBookingModel` joins `edx_booking_hp.hp_unique_id = edx_hp_registration.hp_reg_id`. Sending `hpRegId` as `hp_unique_id` is therefore **correct**.
  - `gross_pay` and `hostel_deduction` were added by `eldivix_be/migrations/20260610_017_payout_hostel_deduction.js`.
- **HP Payouts** (`hp_payouts_view.dart`, `hp_payouts_controller.dart`): `GET /getPendingPayouts`, `POST /createPayout` (manual form: `hp_unique_id, period_from, period_to, pay_amount, payment_mode[, booking_id]`), `PATCH /markPayoutPaid`, and `GET /getPayoutHistory`.
  - **Contract mismatch** [Verified statically]: `markPayoutPaid` sends `PATCH /markPayoutPaid?id=<id>` through `patchApi`, which has no body. The backend `markPayoutPaid` reads `id` from `req.body` only and returns 400 "id is required." when it is missing. Marking a payout paid from the app should therefore always fail with "Failed to update payout." [Inferred effect]. The committed `HEAD` of both repos has the same mismatch. Fix it on one side: send `{id}` with `patchRaw`, or make the handler accept `req.query.id`.

### 7.4 Hostels (`modules/hostels`)

- CRUD: `/createHostel`, `/updateHostel/:id`, `/toggleHostelStatus/:id`, list `/getHostels`.
- Stays: `/createHostelStay`, `/closeHostelStay/:id`, `/getHostelStays`.
- Settlement: preview `/getHostelSettlement`, generate `/createHostelSettlement`, mark paid `/markHostelSettlementPaid/:id`.
- All of these are wired from views [Verified].

### 7.5 Accounts and finance (`modules/accounts`, about 19k lines)

**Legacy `AccountsController`** (used by the shell pages Reciepts, User Statement, Invoice List, Credit Notes, Insurance, Finance Dashboard, and the legacy write-off view):

| Area | Endpoints |
|---|---|
| Active clients | `/getActiveClients` |
| Receipts | `/getReceipts`, `/createReceipt`, `PATCH /updateReceiptStatus {id, status: Approved/Cancelled}` |
| Statements | `/getClientStatements` |
| Write-offs | `/getWriteOffs`, `/createWriteOff`, `PATCH /updateWriteOffStatus` |
| Invoices | `/getInvoices`, `/createPaymentLink`, `/bulkGenerateInvoices` |
| Collections | `/getCollectionsKPIs`, `/getAgingReport` |
| Credit notes | `PATCH /updateCreditNoteStatus` |
| Insurance | `/createInsuranceClaim`, `PATCH /updateInsuranceClaim` |
| Periods | `/closePeriod`, `/getClosedPeriods` |
| Revenue | `/getRevenueRecognition` |

**Newer per-feature controllers**, reached through `/accounts/...` named routes:
- **Write-offs**: `POST /createWriteOffV2`, then `PATCH /approveWriteOff {write_off_id, action: Approved|Rejected, notes}`.
- **Refunds**: `/createRefund`, `/getRefunds`, `/getRefundById/:id`, `PATCH /approveRefund {refund_id, action, notes, dispatch_details}`. The flow is PENDING_APPROVAL → (Approved | Rejected) → APPROVED → Processing → PROCESSING → Completed.
- **Credit notes**: `/createCreditNote` (types Hold / Cancellation / Overpayment / Other), `PATCH /updateCreditNoteStatus {id, status}`, and `POST /applyCreditNote {credit_note_id, target_booking_id, target_invoice_id, amount_to_apply}`.
- **Internal transfers**: `/createInternalTransfer`, `PATCH /approveInternalTransfer {transfer_id, action}`.
- **Outstanding**: `/clientOutstanding/:id`, `/bookingOutstanding/:id`, and a paginated `/transactionLedger`.

**Cross-check against the sibling backend** (`eldivix_be/controllers/web_app/accountsController.js`, working tree):
- Field names and action values match [Verified]:
  - `approveWriteOff` reads `{write_off_id, action, notes}`.
  - `approveRefund` reads `{refund_id, action, notes, dispatch_details}`.
  - `approveInternalTransfer` reads `{transfer_id, action, notes}`.
  - `applyCreditNote` reads `{credit_note_id, target_booking_id, target_invoice_id, amount_to_apply, notes}`.
  - `updateCreditNoteStatus`, `updateReceiptStatus`, and `updateWriteOffStatus` read `{id, status}`.
  - `updateInsuranceClaim` reads `{id, status, settled_amount, remarks, settled_date}`.
  - All of them read `req.body`, which the client sends through `patchRaw` / `postRaw`.
- The backend blocks approving your own request: `_isOwnRequest` is checked when `action`/`status === 'Approved'` in the three approve handlers and in `updateWriteOffStatus`.
- Every accounts route is guarded by `auth + requireStaff + requireModule('Billing')` (`eldivix_be/routes/accountsRoutes.js`). `getRateHistory` also accepts `Bookings`.
- This contradicts `WORKSPACE_AUDIT.md` §3.3 ("approve/reject do not work anywhere"), which is stale for both working trees.
- Runtime behaviour **cannot be verified** in this pass: there was no running backend or database. The backend jest suite (`npm test` in `eldivix_be`) was not run. Its `winston-daily-rotate-file` logger (`eldivix_be/logger.js`) maintains a rotation audit file that is tracked in git, so a run could have changed that repo's git state.

**Detail screens** read `Get.arguments` with a fallback to `Get.parameters`. After a browser refresh they show `recordNotFound` when the data is missing.

**Navigation gap.** The outstanding "Issue Credit Note / Create Write-off / Process Refund" buttons (`accounts/views/outstanding/client_outstanding_detail.dart` ~L242–273) pass `{client_id, client_name}` arguments. None of `create_write_off_view.dart`, `create_refund_view.dart`, `create_credit_note_view.dart`, or any accounts controller/binding reads `Get.arguments`, so no prefill happens [Verified by search; Inferred effect].

### 7.6 Support (`modules/support`)

- **Create**: `POST /createSupportTicket {user_id, support_type_id, title, description, comments, booking_details, created_by_employee (logged-in userId), start_date/end_date for hold}`.
  - Priority and type-specific fields (hold, replacement, cancellation dates and reasons) are folded into `comments`.
  - Categories come from `/getSupportCategory`.
- **Manage**: `/getSupportTickets`, `/getSupportStats`, `PATCH /updateSupportStatus?id&status&comments` (URL-encoded).
- **Status values**: 1 Open, 2 In Progress, 3 Resolved, 0 Closed.

### 7.7 Settings and master data (`modules/settings`, `banners`, `dashboard`)

| Page | Endpoints / behaviour |
|---|---|
| Org Profile (`org_profile_controller.dart`) | `GET/PUT /orgProfile`: name, tagline, email, phone, address, website, logo_url, gstin, brand_color, payment_terms_days 1–90, invoice_notes. Email preview `/orgProfile/emailPreview` is rendered in a sandboxed iframe (`dart:html`). |
| Branches | `/getbranches`, `/createBranch`, `/updateBranch/:id`, `PATCH /toggleBranchStatus?id&status` |
| Service categories | `/getServiceCategories`, create, update, toggle |
| Services | `/getServices`, create, update, toggle |
| Coupons | `/createCoupon {coupon_name, discount_percentage, discount_upper_limit_value}`, `/getCoupons` |
| Booking OTP lookup | `/getBookingOTP?bkng_id&hp_unique_id` |
| Banners | `/getBanners`, `/createBanner` (multipart), `PATCH /disable-banner?id&status`. There is no edit or delete. |
| Roles | `/getRoles`, `/getAppModules`, `/createRole`. There is no edit or delete. |
| Employees (`UsersController`) | `/getWebEmpDetails`, `POST /createUser` (multipart incl. `user_password`, `user_role`, branch), `PUT /update-user`, `/terminate-user {id}`. CSV export. |

### 7.8 Dashboard, reports, audit, notifications

- **Dashboard**:
  - `GET /getDashboardStats?from&to&branch_id` returns totals, trends, weeklyBookings, serviceDistribution, topCgs, cityPerformance, and bookingStatusBreakdown.
  - Date presets and a custom range are available.
  - It silently refreshes every 5 minutes.
  - On init it also loads categories, roles, modules, and branches.
- **Reports**:
  - `/generateReport?type&format=json|csv` previews the data.
  - CSV download uses `getBytes` with the auth header and saves through a Blob URL.
  - The weekly schedule toggle calls `/configureReportSchedule` and `/getScheduledReports`.
  - The backend gates reports by plan (Growth and above per the roadmap).
- **Audit log**: `/getAuditTrail?page&entity_type` with server pagination (50 per page) and 11 entity-type filters.
- **Notifications**:
  - The bell in the dashboard header uses `/notifications`, polled every 60 s, skipped while the tab is hidden and refreshed when it becomes visible.
  - Actions: mark read (`PATCH /notifications/:id/read`), read all, delete (`DELETE /notifications/:id`), and clear all.
  - Updates are optimistic and roll back on failure.
  - Clicking a notification routes to Bookings, Accounts, or Support.

### 7.9 Caregiver portal (`modules/hp_portal`, `HpApi`)

- **Login**: resolve the org (`/org/byId/:ref` or `/org/bySlug/:slug`, cached as `hp_last_org_*`) → `POST /hpAuth/requestOtp {phone, org_id}` → `POST /hpAuth/verifyOtp`. In debug builds a `dev_otp` returned by the backend is shown in a toast.
- **Tabs**:
  - Home: today's earnings, plus check-in (`/hp/attendance/checkin {booking_id}`) and check-out.
  - Bookings: `/hp/bookings?filter`.
  - Attendance.
  - Earnings: `/hp/earnings/summary`.
  - More: Profile (`GET/PUT /hp/me`), Payslips (`/hp/payouts[/:id]`), Support (`/hp/support`, categories), Leave (`/hp/leave`), Logout.
- **Defined but unused**: `HpApi.bank`, `notifications`, `notificationRead`, `bookingById`.

### 7.10 Client portal (`modules/client_portal`, `ClientApi`)

- **Login**: the same pattern via `/clientAuth/*`.
- **Tabs**: Dashboard, Bookings (`/client/bookings?filter`; the detail page loads `/hp` and `/attendance` for the booking), Accounts (`/client/invoices`, `/receipts`, `/outstanding`), More (Profile `/client/me`, Patients `/client/patients[/:id]`, Support, Logout).
- The booking detail shows the service-start OTP to hand to the caregiver. Its "call" button is a no-op.

## 8. Data layer

- **No local database and no repositories layer.** Controllers call `ApiService` directly with endpoint strings from `ApiConstants`, `HpApi`, or `ClientApi`. Models are plain Dart classes with `fromJson` / `toJson`. The portals mostly keep raw `Map<String, dynamic>` values [Verified].
- **The backend tables are MySQL** (`edx_*`), named by the models' JSON keys and by the docs. They are not Firestore collections.
- **Model inventory** (by module):

| Module | Models |
|---|---|
| accounts | ActiveBookingClient/ClientOption, ApprovalHistoryModel, ClientStatement/StatementTransaction, CreditNoteApplicationModel, CreditNoteModel, InsuranceClaimModel, InternalTransferModel, InvoiceModel, OutstandingBalanceModel/AgingBucket, ProvisionalReceipt, RefundModel, TransactionEntryModel, WriteOffModel |
| bookings | GetBookingsModel, GetBookingHpModel |
| register_cg | GetCgDetails, AttendanceModel/AttendanceDetails, CgPaymentSummary/ShiftBreakdown/HostelDeductionLine |
| hostels | GetHostelsModel, HostelStayModel, HostelSettlementModel/Line |
| dashboard | GetAllBranchesModel, CategoryModel, MasterModuleList, GetMasterRoles, ServicesByCategoryModel |
| other | ClientUserModel, GetEmployeeDetails, GetAllSupportTickets, SupportCategory, GetAllBannersModel, CouponModel, OtpResponseModel, AppNotification, UserRoleAccessModel, Saas* (5) |

- **Field conventions**:
  - Backend ids are loosely typed and `'NA'` is a common placeholder.
  - Dates often arrive as strings.
  - Money is held as `double`.
  - Identifier names vary by table: `hp_reg_id` vs `hp_unique_id`, `bkng_id` vs `booking_id`, `br_id`. `hp_unique_id` is the FK name used in other tables for `edx_hp_registration.hp_reg_id`; it is the same value, not a separate id (§7.3).
- **GetStorage keys**:
  - Admin: `user_token`, `role_id`, `org_id`, `org_code`, `userId`, `user_name`, `user_image`, `terms_accepted`, `terms_version`, `selected_page_index`, `manage_hp_page_index`.
  - Routing: `active_session`, `last_portal`.
  - HP: `hp_token`, `hp_id`, `hp_org_id`, `hp_name`, `hp_org_id_param`, `hp_org_slug`, `hp_last_org_id`, `hp_last_org_name`.
  - Client: the same set with a `client_` prefix.
  - Theme: `app_theme_mode`, `app_palette`.
  - Convention: never clear `*_last_org_*` or `last_portal` on logout.
- **Portal links**: `buildHpPortalLink` builds `<origin>/#/hp?org_id=<org_code or numeric org_id>`; the client link is analogous.

## 9. Route inventory

Defined in `lib/app/routes/app_pages.dart` and `app_routes.dart`.

| Path | View | Binding | Middleware |
|---|---|---|---|
| `/login` | LoginView | LoginBinding (fenix) | LoginGuard |
| `/forgot-password` | ForgotPasswordView | ForgotPasswordBinding | none (public) |
| `/terms` | TermsView | TermsBinding | Auth |
| `/auth` | AuthView (**stub**) | AuthBinding | Auth |
| `/main` | SideMenuWidgetView (**admin shell**) | RoleBinding | Auth |
| `/dashboard` | DashboardView | DashboardBinding | Auth + Role(Home) |
| `/users`, `/AddUser`, `/AddMasterRoles`, `/role`(**stub**), `/settings`, `/banners`, `/services-management`, `/branch-management`, `/settings/otp-coupon` | users / roles / settings views | various | Auth + Role(Settings) |
| `/bookings`, `/createBookings` | BookingsView, CreateBookingsView | BookingsBinding | Auth + Role(Bookings) |
| `/register-cg`, `/hp-payouts` | RegisterCgView, HpPayoutsView | RegisterCg / HpPayouts | Auth + Role(HP Modules) |
| `/support` | SupportView | SupportBinding | Auth + Role(Support Ticket) |
| `/accounts` + 16 `/accounts/{write-off,refund,credit-note,transfer,outstanding}[/create\|/detail\|/apply\|/client\|/booking]` | accounts views | per-feature bindings | Auth + Role(Billing) |
| `/client-users`, `/addClientDetails` | ClientUsersView, AddClientUserDetails | ClientUsersBinding | Auth + Role(Users) |
| `/settings/appearance` | AppearanceView | AppearanceBinding | Auth |
| `/hp/login`; `/hp`, `/hp/booking`, `/hp/payslips`, `/hp/profile`, `/hp/support`, `/hp/leave` | HP portal | HpAuth / Hp | HpLoginGuard / HpAuth |
| `/client/login`; `/client`, `/client/booking`, `/client/support`, `/client/profile`, `/client/patients` | Client portal | ClientAuth / Client | ClientLoginGuard / ClientAuth |
| unknown | redirect | — | UnknownRoute |

Other route notes:
- `Routes.initial` (`/initial`) is defined but has no page.
- `AppPages.initial = /login` is unused because `main.dart` computes the initial route.
- Bindings never wired to any route: `AuditLogBinding`, `ReportsBinding`, `HostelsBinding`, `CgPaymentBinding`, `OrganisationsBinding`, `SaasAccountsBinding`.

## 10. Firebase, Cloud Functions, and client/server interaction

- **`firebase.json` has four top-level blocks** [Verified]: `flutter` (FlutterFire metadata pointing at `lib/firebase_options.dart`), `hosting`, `firestore`, and `auth`.
- **Hosting** (`hosting` block): `public: build/web`, ignores dotfiles, rewrites `**` → `/index.html`. The tracked `.firebase/hosting.*.cache` is a deploy cache. `public/index.html` is the 89-line Firebase "Welcome to Firebase Hosting" placeholder, which is not served because hosting points at `build/web`.
- **Firestore deploy target** (`firestore` block): `database: (default)`, `location: asia-south1`, `rules: firestore.rules`, `indexes: firestore.indexes.json`. Because this block exists, a bare `firebase deploy` (without `--only hosting`) also deploys the Firestore rules and indexes of this directory to the target project.
- **Project ID mismatch** [Verified]: `.firebaserc`'s default project differs from the `projectId` in `firebase.json` / `lib/firebase_options.dart`. Confirm which project hosting deploys to before deploying.
- **Firestore** (`firestore.rules`): a test-mode rule that allows all reads and writes until **2026-07-01**. After that date every client request is denied. `firestore.indexes.json` is empty. The app has no `cloud_firestore` dependency, so this does not affect the app [Verified].
- **`firebase.json` auth block** configures a Google sign-in provider display name and support email. The app no longer has Google sign-in (`google_sign_in` was removed from `pubspec.yaml` in the working tree).
- **Cloud Functions** (`functions/src/index.ts`, `syncLead.ts`):
  - A v2 Firestore trigger `onDocumentCreated('leads/{leadId}')`.
  - If `api_synced !== true`, it POSTs the lead to `${API_BASE_URL ?? 'https://api.eldivex.com/api'}/leads/capture`, then marks the document `api_synced` with `backend_lead_id`.
  - **Not deployable as-is** [Verified]: there is no `functions/package.json`, no `tsconfig.json`, and no `functions` key in `firebase.json`.
  - The trigger would not fire for marketing-site leads [Verified]. The sibling `eldivex_website` writes demo requests to `collection('leads_website')` (`eldivex_website/lib/features/home/widgets/book_demo_modal.dart` ~L56), while this trigger listens on `leads/{leadId}` (`functions/src/syncLead.ts`). The website's `.firebaserc` default project and its `lib/firebase_options.dart` project also differ from both of this app's project IDs (compared programmatically; IDs not reproduced).
- **Client/server**: the app talks to the backend over REST and JWT. There is no websocket or realtime channel; notifications use polling.

## 11. Security model and concerns

**Auth model (client side)** [Verified]:
- JWTs are stored in GetStorage (browser localStorage), so any XSS on the origin can read them [Inferred].
- Expiry is checked on the client (`isJwtExpired`, 30 s leeway).
- RBAC and terms gating are UI-level. Real enforcement must be on the server.
- `org_id` is no longer sent by the users or client-users controllers; per the comments, the org comes from the JWT. The portals send `org_id` before authentication for OTP.

**Concrete concerns.** Locations only; no secret values are reproduced here.

1. **`.claude/settings.local.json`** (git-ignored through the global gitignore, but present on disk) contains allow-listed curl commands that embed a **live-looking bearer JWT** and **admin login credentials** for local and hosted backends.
   - [Recommendation] Rotate those credentials and the JWT signing key if the token is still valid, and clean the file.
2. **`SAAS_ROADMAP.md`** (tracked in git) prints the **default seed admin credentials** in plain text in the Phase 1 section. [Recommendation] Remove them and make sure the seed password is changed on every environment.
3. **`lib/firebase_options.dart`** contains the Firebase web API key and app identifiers. These are public by design for Firebase web, but they should be restricted by HTTP referrer in Google Cloud [Recommendation].
4. **Plain-HTTP IP endpoints** are documented in `api_constant_url.dart` comments. HTTPS hosting plus an HTTP API means mixed-content failures and token exposure in transit [Inferred].
5. **Debug OTP**: in `kDebugMode`, the portals display `dev_otp` when the backend returns it. Production safety depends on the backend never returning it (`NODE_ENV`).
6. **Firestore rules** (`firestore.rules`) allow everything only while `request.time < timestamp.date(2026, 7, 1)`. That date has passed, so the rule is effectively deny-all.
   - Re-deploying the file **unchanged** keeps deny-all.
   - The real risk is someone editing the date or the condition to "fix" denied requests. That would make the default database world-readable and world-writable again.
   - A bare `firebase deploy` pushes whatever is in this file, because of the `firestore` block in `firebase.json` (§10).
7. **Org-profile email preview** renders backend HTML in a `sandbox=''` iframe (`settings/views/org_profile_view.dart`), which is a reasonable mitigation.
8. **Employee create** sends `user_password` as a multipart field. HTTPS is required.

**Backend-side security** (`WORKSPACE_AUDIT.md` §8 P0) re-checked against the `eldivix_be` working tree. Every "fixed" item below is **uncommitted** in `eldivix_be`; committed `HEAD` still has the original issue where noted.

| P0 # | Audit claim | Working tree | Status |
|---|---|---|---|
| 1 | `POST /login` mints a JWT for any phone + org | `loginUsers` returns 410 (`eldivix_be/controllers/web_app/userController.js`). In `HEAD` it still takes `{phone_number, org_id}` | fixed (uncommitted) |
| 2 | HP/client tokens accepted on admin routes | `isStaffToken` check in `eldivix_be/middlewares/auth.js` | fixed (uncommitted) |
| 3 | No server-side RBAC; self-approval | `requireModule` on all tenant routes (Appendix B); `_isOwnRequest` | fixed (uncommitted) |
| 4 | Static OTP default; `dev_otp` outside production | `crypto.randomInt` OTPs. `dev_otp` and static OTPs only when `NODE_ENV=development` **and** `EXPOSE_DEV_OTP=true` (`hpAuthController.js`, `clientAuthController.js`) | fixed (uncommitted) |
| 5 | Forgeable Razorpay webhook | The secret is mandatory, and the HMAC is computed over `req.rawBody` (kept by `express.json({verify})` in `eldivix_be/index.js`) | fixed (uncommitted); replay dedup is suggested by migration `20261007_032_payment_webhook_events.js`, not traced end to end |
| 6 | `/getWebEmpDetails` returns password hashes | Explicit column list that excludes `user_password` / `password_reset_*` (`eldivix_be/models/web_app/userModel.js`) | fixed (uncommitted) |
| 7 | Public `/uploads`, no file filter | Extension allow-list + `nosniff` on `/uploads`; multer extension **and** mimetype allow-list (`eldivix_be/middlewares/upload.js`). `/uploads` is still public by design | mitigated |
| 9 | Terminated users keep access | `auth.js` re-checks `user_status` and `tokens_valid_after` (migration `20261007_041_web_users_tokens_valid_after.js`) | fixed (uncommitted) |
| 10 | `?? 1` org fallbacks | `getOrgId` returns `null`, never a default (`eldivix_be/utils/orgScope.js`) | fixed in the files checked; ~40 call sites not re-audited |
| 12 | CORS prefix match | Exact-origin matching on a parsed URL (`eldivix_be/index.js`) | fixed (uncommitted) |
| 8, 11 | Cross-org reads/writes; client-sent `org_id` | Not re-audited handler by handler. `leads/capture` now resolves the org and matches the phone within it (`leadsController.js`) | partly re-checked |

New observations [Verified statically unless marked]:
- **Portal token expiry returns 403, not 401.** `eldivix_be/middlewares/hpAuth.js` and `clientAuth.js` return 403 "Invalid or expired token". `ApiService` logs out only on 401, so a portal session whose token expires mid-page gets failing requests until the next route change re-runs `HpAuthMiddleware` / `ClientAuthMiddleware`, which check `exp` locally [Inferred effect].
- **`GET /getWebEmpDetails`** (employee list) needs only `auth + requireStaff`, with no `Settings` module gate. Any staff role can list employees, though without password fields.
- **Public catalogue endpoints.** `GET /masterServicesTypes` and `/masterServices` have no auth. The org comes from the JWT or from an `org_id`/`org_code` query parameter (`eldivix_be/controllers/client_app/masterServicesController.js`), so anyone who knows an org code can read its service catalogue and rates [Inferred risk; low]. `GET /getSupportCategory` is also public and org-scoped the same way.

## 12. Error handling, loading states, and shared utilities

- **Toasts**: `HelperUi.showToast` maps the passed colour (Material colours or theme error/primary) to a success, error, warning, or info toast.
  - `accounts_feedback.dart` adds `toastApiError`, `toastSuccess`, and `toastValidation`.
  - The portals pass `Get.theme.colorScheme.error/primary`, which are mapped correctly now.
- **Navigation helper**: `HelperUi.safeBack(fallback)` avoids a dead `Get.back()` after a web refresh. It is used throughout the accounts, users, and client-users screens.
- **Loading UI**: `ShimmerLoader` and `HelperUi().loader()`, the dashboard shimmer, `CircularProgressIndicator`. Reactive `isXLoading` RxBools sit on every controller.
- **Error banners**: the dashboard shows an error banner with retry, and terms shows a retry state.
- **Formatting**: `accounts_format.dart` provides `formatInr`, `formatInrCompact`, `formatAccDate`, `humanizeStatus`, `accountsStatusColor`/`Chip`, `horizontalTable`, and `recordNotFound`.
- **Shared form widgets**: `AppDropdown`/`AppDropdownFormField`/`CommonDropdown`, `CommonDatePicker` (dd/MM/yyyy), `CommonTextField`, `FormTextField`, `ElevatedButtonCommon`, `CommonFileUpload`.
- **CSV export**: `ExportToCsv` (`dart:html` Blob download) is used by bookings and users.
- **Logging**: `debugPrint` everywhere. `appLog = Logger()` is declared in `main.dart`. `ExportToCsv` uses `print`. There is no remote error tracking (Sentry is roadmap-only).
- **Web-only code**: `dart:html` (2 files), `dart:js_interop` + `package:web` (2 files), and `dart:ui_web`, combined with `firebase_options.dart` throwing on non-web, make the app **web-only** in practice. `common_file_upload.dart` imports `dart:io` but uses only `PlatformFile` bytes.

## 13. Test inventory

| File | Test cases | Covers |
|---|---|---|
| `test/models/approval_history_model_test.dart` | 31 | ApprovalHistoryModel |
| `test/models/credit_note_application_model_test.dart` | 42 | CreditNoteApplicationModel |
| `test/models/get_all_support_tickets_test.dart` | 13 | GetAllSupportTickets |
| `test/models/get_booking_hp_model_test.dart` | 39 | GetBookingHpModel |
| `test/models/get_bookings_model_test.dart` | 43 | GetBookingsModel |
| `test/models/get_cg_details_model_test.dart` | 14 | GetCgDetails |
| `test/models/internal_transfer_model_test.dart` | 49 | InternalTransferModel |
| `test/models/outstanding_balance_model_test.dart` | 37 | OutstandingBalanceModel |
| `test/models/refund_model_test.dart` | 43 | RefundModel |
| `test/models/transaction_entry_model_test.dart` | 35 | TransactionEntryModel |
| `test/widget_test.dart` | 1 | placeholder (Firebase init blocks widget tests) |

- **347 test cases**, all JSON-parsing unit tests (happy path, null/missing fields, type safety, round-trip).
- **Not covered**: controllers, ApiService and its interceptors, middleware and session logic, routing, views/widgets, portals, integration flows.
- **Run results** [Verified, local Flutter 3.41.7]:
  - `flutter test --no-pub`: **all 347 tests passed** (~7 s).
  - `flutter analyze --no-pub`: **142 issues, 0 errors, 4 warnings, 138 infos**.
    - The 4 warnings are an unused field in `core/values/size_configue.dart`, an unused `dart:io` import in `widgets/common_file_upload.dart`, `must_be_immutable` in `widgets/elevated_button_common.dart`, and an unused local in `widgets/export_to_csv_common.dart`.
    - Most infos are `constant_identifier_names` (74) and `deprecated_member_use` (42).
  - `--no-pub` was used so the uncommitted `pubspec.lock` was not rewritten. Its checksum was identical before and after.

## 14. Build, run, deploy

**Prerequisites**:
- Flutter and Dart versions that satisfy `pubspec.lock` (Flutter ≥3.38.4, Dart ≥3.10.3).
- A Chrome device.
- A reachable backend `API_BASE_URL`.
- The Firebase CLI for deploys.

**Platforms**:
- Only `web/` exists. `.metadata` and `.idea/modules.xml` mention android/ios, but those folders are absent.
- `firebase_options.dart` throws on other platforms.

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --dart-define=API_BASE_URL=<backend>/api      # default: https://api.eldivex.com/api
flutter build web --dart-define=API_BASE_URL=<backend>/api
firebase deploy --only hosting      # serves build/web; check .firebaserc vs firebase_options project mismatch first
```

- Keep `--only hosting`. A bare `firebase deploy` also deploys `firestore.rules` and `firestore.indexes.json` through the `firestore` block in `firebase.json` (§10, §11 item 6).
- Use `flutter pub get` only when you intend to update `pubspec.lock`. Otherwise `--no-pub` (`flutter test --no-pub`, `flutter analyze --no-pub`) leaves the lockfile untouched.

- `.vscode/launch.json` has debug, profile, and release Dart launch configs. `.idea/runConfigurations/main_dart.xml` runs `lib/main.dart`.
- `flutter_launcher_icons` is configured to generate web icons (and a mis-indented windows block) from `assets/images/e_logo.png`.
- Cloud Functions have no build or deploy configuration (§10).

## 15. Roadmap, TODOs, defects and inconsistencies

### 15.1 Verified incomplete features, stubs, and dead code

- `modules/auth` (`AuthController` with `//TODO`, `AuthView` "AuthView is working") and `role/views/role_view.dart` ("RoleView is working") are scaffolds. The routes `/auth` and `/role` are live, and the Settings hub "Roles" tile opens the stub `/role`.
- `SettingsView` hub (with the Subscription dialog) is reachable only by the `/settings` route, not from the shell menu.
- `organisations/` and `saas_accounts/` are not imported anywhere, so they are unreachable. Their endpoints are owner-only (`requireOwner`) in the backend. `organisations_controller.dart` hard-codes plan ids by name (Starter/Growth/else).
- Six bindings are unused (§9).
- Unused `ApiConstants`:
  - `getMasterServices`, `addClientUser` (`/login`), `resetPassword`, `getCancellationBilling`, `getHostelById`, `getOrgDetails`.
  - `updateBookingApi` (`/bookings/update`, which **does not exist** in the backend routes).
  - Portal constants `HpApi.bank`, `HpApi.bookingById`, `HpApi.notifications`, `HpApi.notificationRead`, and `ClientApi.bookingById`. Their backend routes exist (Appendix B).
- **No reset-password screen**: `resetPassword` is defined but there is no route or view to consume the emailed reset link [Inferred gap].
- **No-op UI**:
  - "Contact Administrator" (`login_view.dart`).
  - The dashboard "Profile" menu item (only "logout" is handled).
  - Manage HP "Export" shows a "coming soon" toast.
  - The `mark_attendance.dart` Export buttons.
  - The `attendance_list.dart` pagination ("Page 1 of 1").
  - The client booking detail "call" button.
- Booking `holdBooking` / `cancelBooking` controller methods are unused; the UI routes hold and cancel through support tickets instead.
- Outstanding → create write-off/refund/credit-note prefill arguments are ignored (§7.5).
- Role edit, delete, and pagination are missing (only create and list exist). Banners have no edit or delete.

### 15.2 Likely defects (static evidence; confirm at runtime)

- **Mark payout paid always fails** [Verified mismatch; Inferred effect]: `hp_payouts_controller.markPayoutPaid` sends `PATCH /markPayoutPaid?id=` with no body, and the backend reads `req.body.id` only, so the request gets a 400 (§7.3).
- **Portal sessions on an expired token**: the backend returns 403 rather than 401, so `ApiService` does not redirect to the portal login (§11).
- **CG payout identifier: resolved, not a defect.** `hp_unique_id` across `edx_hp_payouts`, `edx_booking_hp`, and `edx_hp_rate` is the FK to `edx_hp_registration.hp_reg_id`, so sending `cg.hpRegId` is correct (§7.3). Note that `createPayout` does not check that the HP belongs to the caller's org before inserting [Inferred; low].
- **Fonts**: 44 `fontFamily: 'poppins_regular'` usages, but `pubspec.yaml` declares only the `inter_regular` font family. Those texts fall back to the default font. The Inter Bold, SemiBold, and Black TTFs are bundled but not declared.
- **Unsafe casts remain** (crash risk on loose types):
  - `register_cg/views/mark_attendance.dart` (14)
  - saas models
  - `bookings_controller.dart` (`c['id'] as int`, `m['name'] as String`)
  - `register_cg_view.dart`, `cg_review_detail_screen.dart`, `hp_payouts_view.dart` (`payout['id'] as int`)
  - `attendance_model.dart`, `client_dashboard_tab.dart`, `organisations_controller.dart`
- `RoleController.clearAuth()` removes a `user` key that nothing writes. `userId`, `user_name`, `org_code`, and `terms_accepted` survive an admin logout (`terms_accepted` is overwritten at the next login).
- **Manual shell indices**: adding or removing a menu page shifts every later index. The persisted `selected_page_index` can then point at a different page after a role change. It is clamped only when it falls out of range.
- `/client-users` (standalone) uses `ClientUsersBinding` but its guard key is `Users`, matching the menu. `WORKSPACE_AUDIT.md`'s "guard is Bookings" claim is stale.

### 15.3 Stale or contradictory statements in existing docs

| Doc claim | Current code | Status |
|---|---|---|
| WORKSPACE_AUDIT: default API URL is a plain-HTTP QA IP | default is `https://api.eldivex.com/api` | stale |
| WORKSPACE_AUDIT: new Dio per ApiService (32 instances) | one static shared Dio | stale |
| WORKSPACE_AUDIT: `startsWith('/hp')` matches `/hp-payouts` | whole-segment `isPortal()` check | fixed |
| WORKSPACE_AUDIT: admin login never resets `active_session`; no admin JWT expiry check; terms gate skipped on cold start | login and `AuthMiddleware` write `active_session=admin`; `isAdminAuthenticated` checks exp; `main.dart`/`AuthMiddleware` enforce `terms_accepted` | fixed (terms flag is local) |
| WORKSPACE_AUDIT: many routes unguarded; RoleMiddleware fails open | all admin routes have Auth (+Role) except `/forgot-password`; RoleMiddleware waits with a spinner | fixed |
| WORKSPACE_AUDIT: Reports CSV is an `<a href>` that always gets 401 | authenticated `getBytes` + Blob | fixed |
| WORKSPACE_AUDIT: accounts approve/reject broken, wrong field names | payloads match the backend working tree (§7.5) | appears fixed |
| WORKSPACE_AUDIT: client create calls `/login` | `/createClientUser` | fixed |
| WORKSPACE_AUDIT: support hardcoded `due_date`/`created_by_employee "1"`, comments not encoded | logged-in `userId`, URL-encoded via `Uri.replace` | fixed |
| WORKSPACE_AUDIT: booking create hardcodes `address_id`; medical condition not sent | selected address; notes saved via follow-up `updateBooking` | fixed |
| WORKSPACE_AUDIT: settings toggles don't refresh; coupon max sends computed value | `applyServicesSearch()` after toggle (services verified); user-entered cap | fixed (services) |
| WORKSPACE_AUDIT: notifications no rollback; polls while hidden; audit log 5/11 filters | rollback implemented; hidden tabs skipped; 11 types | fixed |
| WORKSPACE_AUDIT: dead deps (google_sign_in etc.) | removed in the working-tree `pubspec.yaml` | fixed (uncommitted) |
| SAAS_ROADMAP: Firebase Auth + Google sign-in wired | no `firebase_auth` / `google_sign_in` dependency | stale |
| SAAS_ROADMAP: `lib/app/data/services/base_api_services.dart`, `login/controllers/forgot_password_controller.dart` | actual: `lib/app/data/base_api_services.dart`, `modules/forgot_password/...` | stale paths |
| SAAS_ROADMAP: Organisations menu item for role_id=1 | not in the shell; module unreachable | stale |
| SAAS_ROADMAP: "28/28 Flutter tests" | about 347 test cases now | stale |
| README | Flutter template | stale |

Still-open roadmap items (`SAAS_ROADMAP.md` Phase 6): email uniqueness decision, Socket.io realtime, S3 storage, Sentry and `/health`, Razorpay SaaS billing, API keys. Phase 3 (client mobile app) is deferred.

## 16. Start working

**Safest first steps**
1. Commit the in-flight work as a whole. The modified, deleted, and untracked files depend on each other.
   - Untracked items are easy to miss: `lib/app/core/utils/`, `lib/app/modules/notifications/`, `lib/app/modules/terms/`, the org-profile/service-categories/accounts helper files, `WORKSPACE_AUDIT.md`, `PROJECT_CONTEXT.md`, `.vscode/`, and `.agents/`.
   - Decide deliberately whether the docs, `.vscode/`, and `.agents/` (review artifacts) belong in git.
   - Back up `.claude/settings.local.json` separately and never commit it. It is excluded only by the global gitignore (`~/.config/git/ignore`), not by the repo's `.gitignore`.
   - Commit `eldivix_be` too. Its RBAC and security fixes are uncommitted, and this app's working tree depends on new backend routes (`/createClientUser`, `/getCurrentTerms`, `/acceptTerms`, `/notifications*`, `/orgProfile*`, service categories).
2. Get a baseline: `flutter analyze --no-pub && flutter test --no-pub`. This pass ran both: 0 analyzer errors, and all 347 tests passed (§13). Run `flutter pub get` only if you intend to refresh the lockfile.
3. Run against a known backend (`--dart-define=API_BASE_URL=...`) and smoke-test the following:
   - admin login → terms → `/main`;
   - each menu group;
   - refresh on a deep link (`/#/accounts/refund/detail`, `/#/hp-payouts`);
   - HP and client portal OTP login from a portal link;
   - 401 and suspended-org handling.
4. Rotate the exposed credentials and token (§11) and resolve the Firebase project-ID mismatch before the next deploy.

**High-priority work areas** [Recommendation]
- Fix the `markPayoutPaid` id contract (§7.3). Smoke-test the payout and accounts approval flows end to end against a real backend.
- Treat backend 403 "Invalid or expired token" from `hpAuth`/`clientAuth` as a logout in `ApiService`, or change those guards to return 401 (§11).
- Replace the remaining `as` casts with the `parse_utils` helpers.
- Unify the `ApiService` error contract (a result type rather than `null` plus `lastError`).
- Replace the index-based shell with named nested routes, or at least a page registry keyed by id.
- Remove or finish the stubs: `/auth`, `/role`, the unreachable organisations/saas modules, and the unused bindings and constants.
- Add a reset-password route, outstanding → create prefill, and real attendance export and pagination.
- Fix the font declarations (`poppins_regular`).
- Add controller and middleware tests; start with `session_utils`, `jwt_utils`, `RoleMiddleware`, and the ApiService interceptors.

**Where to make common changes**

| Change | Where |
|---|---|
| New endpoint | `lib/app/data/api_constant_url.dart` (portals: `hp_api_constants.dart` / `client_api_constants.dart`) |
| New routed page | `app_routes.dart` (`Routes` + `_Paths`) → `app_pages.dart` with a binding and `[AuthMiddleware(), RoleMiddleware('<key>')]` |
| New shell menu page | `side_menu_widget_view.dart` `_buildMenuStructure()` (keep the index arithmetic consistent) |
| Permissions | module names in backend `edx_web_module`; keys checked via `RoleController.hasAccess` |
| HTTP behaviour (auth, 401/403) | `lib/app/data/base_api_services.dart` |
| Session and startup | `lib/main.dart`, `lib/app/core/utils/session_utils.dart`, `lib/app/middleware/*` |
| Colours, theme | `core/theme/*`, `core/values/color_constants.dart` (use `AppColor.*`, `buttonTextWhite` on brand colours) |
| Model parsing | `modules/accounts/models/parse_utils.dart` helpers; add a test in `test/models/` |

## 17. Glossary

| Term | Meaning |
|---|---|
| Org / tenant | A care agency using Eldivex. Numeric `org_id` plus a public `org_code` (`XXX-NNNNNN`) for newer orgs. Also resolvable by slug. |
| Owner / platform | Super-admin who runs all orgs (separate `owner_platform` repo). |
| Staff / employee | Admin app user (`/loginWeb`) with a role (`edx_web_emp_roles`). |
| HP / CG | Health Professional / Caregiver (`edx_hp_registration`, ids `hp_reg_id`, `hp_unique_id`). |
| Client / user | End customer or family (`edx_client_app_users`). "Users" in the admin menu means clients. |
| Patient | Person receiving care, attached to a booking. |
| Booking | Service engagement (`edx_bookings`, `bkng_id` / `booking_id`). Statuses `'1'`–`'7'`. |
| HP stage | HP-to-booking pipeline: Shortlisted, Interview, Finalized, Active, Released (1–5). |
| Live-in / live-out | Shift types with separate HP pay rates. |
| Hold / extension / cancellation | Booking lifecycle requests (support ticket types 4/5; extension via `/extendBooking`). |
| Receipt / invoice / credit note / write-off / refund / internal transfer | Accounts documents; approvals use `Approved` / `Rejected` actions. |
| Outstanding / aging | Billed minus paid per client or booking; aging buckets. |
| Payout / payslip | HP payment record from attendance minus hostel deduction. |
| Hostel stay / settlement | HP accommodation and the periodic settlement of its cost. |
| Module key | RBAC access string such as `Billing`, `HP Modules`, `Settings`. |
| `active_session` | Storage flag (`admin` / `hp` / `client`) that selects which token ApiService sends. |
| Terms gate | Mandatory Terms & Conditions acceptance before the admin shell. |

## Appendix A: audit scope

**Enumeration.**
- A recursive listing of the repository (`find . -type f`) found **314 files**. Excluded from that count: `.git/`, `build/`, `.dart_tool/`, `node_modules/` (none present), `.DS_Store`, this guide, and the `.agents/` review artifacts.
- `git ls-files` reports 294 tracked files. The difference has three parts:
  - 4 tracked files are deleted in the working tree.
  - 16 untracked files are present.
  - 8 git-ignored local files are present: `eldivex_app.iml`, `.flutter-plugins-dependencies`, `.claude/settings.local.json`, and 5 files under `.idea/`.

**Inspected** (content read in full or by targeted extraction):

| Category | Count | Depth |
|---|---|---|
| Dart under `lib/` | ~259 files (~76k lines incl. tests) | **Read fully**: `main.dart`, `firebase_options.dart`, routes, all middleware, `initial_bindings`, `core/utils`, `data/*`, role, auth, login/forgot/terms controllers, dashboard controller, side menu shell, notifications controller, hp auth controller, reports controller (download/schedule), key accounts/bookings/support/users/client-users/cg-payment sections. **Every other file**: method signatures, API calls, payload keys, navigation, `Get.put` sites, casts, TODO/no-op handlers, and class/import reachability via repository-wide searches. Large views (e.g. 1–1.6k-line booking and HP screens) were **not read line by line**. |
| Dart tests | 11 | test counts, groups, targets |
| Docs | 3 (`README.md`, `SAAS_ROADMAP.md`, `WORKSPACE_AUDIT.md`) | read fully |
| Build/config | `pubspec.yaml`, `pubspec.lock` (versions only), `analysis_options.yaml`, `firebase.json`, `.firebaserc`, `firestore.rules`, `firestore.indexes.json`, `.gitignore`, `.metadata`, `.vscode/launch.json`, `.idea/*` (5), `eldivex_app.iml`, `lc.code-workspace` | read |
| Functions | `functions/src/index.ts`, `syncLead.ts` | read fully |
| Web | `web/index.html`, `web/manifest.json`, `public/index.html` | read (`public/index.html` is the stock 89-line Firebase Hosting welcome page) |
| Local agent config | `.claude/settings.local.json` | read (sensitive; values not reproduced) |
| Cross-repo check | All 20 `eldivix_be/routes/*.js` (parsed for every `router.<verb>(…)`), `eldivix_be/index.js` mounts, `eldivix_be/middlewares/{auth,requireStaff,requireModule,requireOwner,hpAuth,clientAuth,orgStatusGate}.js`, the payout handlers in `hpController.js`, the approval/status handlers in `accountsController.js`, the toggle handlers in `masterTableController.js`, the hostel handlers, `bookingsModel.js` (`getHPByBookingModel`), payout and HP migrations, and `git status` / `git show HEAD:` for committed-vs-working-tree comparison. Plus `eldivex_website` (lead collection, Firebase project comparison) | Used to build Appendix B and §11. Deployed state could not be verified. The backend was not run |

**Excluded**:
- Binary assets (16): 4 Inter fonts, 7 images/icons in `assets/`, 5 web icons/favicon. Noted in the inventory only.
- `.flutter-plugins-dependencies`: generated.
- `.firebase/hosting.*.cache`: deploy cache, identified only.
- `pubspec.lock` internals beyond key versions.
- `build/`, `.dart_tool/`, `.git/`.

**Unreadable files**: none.

**Runtime verification**:
- `flutter test --no-pub` and `flutter analyze --no-pub` were run (§13).
- The app was not built or launched. The backend, its jest suite, and the database were not run.
- Every claim about runtime effects is therefore marked [Inferred].

**Still unverifiable from the repository**:
- What is deployed on the hosted backend and on Firebase Hosting.
- Whether a Firestore database exists in either project.
- Actual DB contents, for example whether `edx_web_module.module_name` values match the app's module keys exactly.
- The runtime behaviour of the flows in §7.

## Appendix B: backend API contract (client endpoint → `eldivix_be` route)

**How this was produced** [Verified, static]:
- Every endpoint constant in `lib/app/data/api_constant_url.dart` (`ApiConstants`, 147), `lib/app/modules/hp_portal/hp_api_constants.dart` (`HpApi`, 19), and `lib/app/modules/client_portal/client_api_constants.dart` (`ClientApi`, 16) was matched to a `router.<verb>('<path>', …)` declaration in `eldivix_be/routes/*.js`.
- The HTTP method comes from the `ApiService` helper used at each call site (`lib/app/data/base_api_services.dart`): `get*`/`getBytes` → GET, `post*` → POST, `put*` → PUT, `patch*` → PATCH, `delete` → DELETE. The portal controllers' `_get` helpers use `getRaw`.
- All routers are mounted under `/api` in `eldivix_be/index.js`, after the global `generalLimiter` and `orgStatusGate`.

**Uncommitted files.** Both sides are uncommitted working-tree state:
- In this repo: `api_constant_url.dart`, `base_api_services.dart`, and `lib/app/middleware/{auth,client_auth,hp_auth,role}_middleware.dart`.
- In `eldivix_be`: all route files and middleware, with `requireStaff.js`, `requireModule.js`, `notificationsRoutes.js`, `orgProfileRoutes.js`, and `termsRoutes.js` untracked.

**Guard legend**:
- `staff` = `auth + requireStaff`.
- `module(A\|B)` = `auth + requireStaff + requireModule('A', 'B')`, where any one listed module passes.
- `owner` = `auth + requireOwner`.
- `hpAuth` / `clientAuth` = portal JWT guards.
- `authLimiter` = login rate limiter.
- `validate` = Joi schema validation.
- `planGate(...)` = subscription-plan gate.
- `hpFiles` / upload routes accept multipart files.
- "inline (routes file)" means the handler is written directly in the route file.

**Summary of findings**:
- **182 client constants. 181 map to an existing backend path.** For all 170 constants the app actually calls, the HTTP method at every call site matches the backend route. No method mismatches were found.
- **One client URL has no backend route**: `ApiConstants.updateBookingApi` (`/bookings/update`). It is unused.
- **12 constants are unused** by the app: `addClientUser` (`/login`, now 410), `getCancellationBilling`, `getHostelById`, `getMasterServices`, `getOrgDetails`, `resetPassword`, `updateBookingApi`, `ClientApi.bookingById`, `HpApi.bank`, `HpApi.bookingById`, `HpApi.notifications`, and `HpApi.notificationRead`.
- **16 constants are called only from the unreachable `organisations/` / `saas_accounts/` modules.** All of them are owner-only (`requireOwner`), except the public `GET /getPlans`, so a tenant staff token would get 403 from them anyway.
- **Parameter-location mismatch**: `PATCH /markPayoutPaid` (client query `?id=`, server `req.body.id`); see §7.3. The other `patchApi` (no-body) calls were checked against their handlers and read the query or path as sent: `updateHPStatus`, `disable-banner`, `updateSupportStatus`, `toggleBranchStatus`, `toggleServiceStatus`, `toggleServiceCategoryStatus`, and the notification read routes. `toggleBranchStatus` / `toggleServiceStatus` ignore the client's `status` and flip the stored value on the server.
- **Backend routes the app does not call** (not exhaustive): `PUT /updateHPProfile`, `PUT /hp/bank`, `GET/POST /client/addresses`, `POST /client/bookings`, `POST /ownerLogin`, `POST /razorpay/webhook` (server-to-server), `POST /leads/capture` (Cloud Function/website), and the owner-only `saas/*`, plan, and audit routes.
- The method, guard, and handler columns below are taken from the route files. Payload fields were verified only for the flows cited in §7.3, §7.5, and §11.

**No backend route**

| Client constant | Method + path | Guard | Handler | Notes |
|---|---|---|---|---|
| `ApiConstants.updateBookingApi` | n/a `/bookings/update` | — | — | unused; **no backend route** |

**`eldivix_be/routes/accountsRoutes.js`**

| Client constant | Method + path | Guard | Handler | Notes |
|---|---|---|---|---|
| `ApiConstants.applyCreditNote` | POST `/applyCreditNote` | module(Billing) | `ac.applyCreditNote` |  |
| `ApiConstants.approveInternalTransfer` | PATCH `/approveInternalTransfer` | module(Billing) | `ac.approveInternalTransfer` |  |
| `ApiConstants.approveRefund` | PATCH `/approveRefund` | module(Billing) | `ac.approveRefund` |  |
| `ApiConstants.approveWriteOff` | PATCH `/approveWriteOff` | module(Billing) | `ac.approveWriteOff` |  |
| `ApiConstants.getBookingOutstanding` | GET `/bookingOutstanding/:bookingId` | module(Billing) | `ac.getBookingOutstanding` |  |
| `ApiConstants.bulkGenerateInvoices` | POST `/bulkGenerateInvoices` | module(Billing) | `ac.bulkGenerateInvoices` |  |
| `ApiConstants.getClientOutstanding` | GET `/clientOutstanding/:clientId` | module(Billing) | `ac.getClientOutstanding` |  |
| `ApiConstants.closePeriod` | POST `/closePeriod` | module(Billing) | `ac.closePeriod` |  |
| `ApiConstants.createCreditNote` | POST `/createCreditNote` | module(Billing) | `ac.createCreditNote` |  |
| `ApiConstants.createInsuranceClaim` | POST `/createInsuranceClaim` | module(Billing) | `ac.createInsuranceClaim` |  |
| `ApiConstants.createInternalTransfer` | POST `/createInternalTransfer` | module(Billing) | `ac.createInternalTransfer` |  |
| `ApiConstants.createPaymentLink` | POST `/createPaymentLink` | module(Billing) | `ac.createPaymentLink` |  |
| `ApiConstants.createReceipt` | POST `/createReceipt` | module(Billing) | `ac.createProvisionalReceipt` |  |
| `ApiConstants.createRefund` | POST `/createRefund` | module(Billing) | `ac.createRefund` |  |
| `ApiConstants.createWriteOff` | POST `/createWriteOff` | module(Billing) | `ac.createWriteOff` |  |
| `ApiConstants.createWriteOffV2` | POST `/createWriteOffV2` | module(Billing) | `ac.createWriteOffV2` |  |
| `ApiConstants.getActiveClients` | GET `/getActiveClients` | module(Billing) | `ac.getActiveClients` |  |
| `ApiConstants.getAgingReport` | GET `/getAgingReport` | module(Billing) | `ac.getAgingReport` |  |
| `ApiConstants.getCancellationBilling` | GET `/getCancellationBilling` | module(Billing) | `ac.getCancellationBilling` | unused in app |
| `ApiConstants.getClientStatements` | GET `/getClientStatements` | module(Billing) | `ac.getClientStatements` |  |
| `ApiConstants.getClosedPeriods` | GET `/getClosedPeriods` | module(Billing) | `ac.getClosedPeriods` |  |
| `ApiConstants.getCollectionsKPIs` | GET `/getCollectionsKPIs` | module(Billing) | `ac.getCollectionsKPIs` |  |
| `ApiConstants.getCreditNoteApplications` | GET `/getCreditNoteApplications` | module(Billing) | `ac.getCreditNoteApplications` |  |
| `ApiConstants.getCreditNotes` | GET `/getCreditNotes` | module(Billing) | `ac.getCreditNotes` |  |
| `ApiConstants.getInsuranceClaims` | GET `/getInsuranceClaims` | module(Billing) | `ac.getInsuranceClaims` |  |
| `ApiConstants.getInternalTransfers` | GET `/getInternalTransfers` | module(Billing) | `ac.getInternalTransfers` |  |
| `ApiConstants.getInvoices` | GET `/getInvoices` | module(Billing) | `ac.getInvoices` |  |
| `ApiConstants.getRateHistory` | GET `/getRateHistory` | [module(Billing\|Bookings)] | `ac.getRateHistory` |  |
| `ApiConstants.getReceipts` | GET `/getReceipts` | module(Billing) | `ac.getReceipts` |  |
| `ApiConstants.getRefundById` | GET `/getRefundById/:id` | module(Billing) | `ac.getRefundById` |  |
| `ApiConstants.getRefunds` | GET `/getRefunds` | module(Billing) | `ac.getRefunds` |  |
| `ApiConstants.getRevenueRecognition` | GET `/getRevenueRecognition` | module(Billing) | `ac.getRevenueRecognition` |  |
| `ApiConstants.getWriteOffs` | GET `/getWriteOffs` | module(Billing) | `ac.getWriteOffs` |  |
| `ApiConstants.updateCreditNoteStatus` | PATCH `/updateCreditNoteStatus` | module(Billing) | `ac.updateCreditNoteStatus` |  |
| `ApiConstants.updateInsuranceClaim` | PATCH `/updateInsuranceClaim` | module(Billing) | `ac.updateInsuranceClaim` |  |
| `ApiConstants.updateReceiptStatus` | PATCH `/updateReceiptStatus` | module(Billing) | `ac.updateReceiptStatus` |  |
| `ApiConstants.updateWriteOffStatus` | PATCH `/updateWriteOffStatus` | module(Billing) | `ac.updateWriteOffStatus` |  |

**`eldivix_be/routes/auditRoutes.js`**

| Client constant | Method + path | Guard | Handler | Notes |
|---|---|---|---|---|
| `ApiConstants.getAuditTrail` | GET `/getAuditTrail` | module(Settings) | `inline (routes file)` |  |

**`eldivix_be/routes/bookingsRoutes.js`**

| Client constant | Method + path | Guard | Handler | Notes |
|---|---|---|---|---|
| `ApiConstants.assignCgApi` | POST `/assignHPToBooking` | module(Bookings) | `bookingsController.assignHPToBooking` |  |
| `ApiConstants.cancelBookingApi` | POST `/cancelUserService` | module(Bookings) | `bookingsController.cancelUserService` |  |
| `ApiConstants.createBookingApi` | POST `/createBooking` | module(Bookings) + validate | `bookingsController.createBooking` |  |
| `ApiConstants.extendServiceApi` | POST `/extendBooking` | module(Bookings) + validate | `bookingsController.extendBooking` |  |
| `ApiConstants.verifyOtpApi` | POST `/finalBookingSave` | module(Bookings) + validate | `bookingsController.finalBookingSave` |  |
| `ApiConstants.getAttendanceList` | GET `/getAttendanceList` | module(Bookings\|HP Modules) | `bookingsController.getAttendanceList` |  |
| `ApiConstants.getBookingOTPApi` | GET `/getBookingOTP` | module(Bookings\|Settings) | `bookingsController.getBookingOTP` |  |
| `ApiConstants.getBookingsHpApi` | GET `/getHPByBooking` | module(Bookings\|HP Modules) | `bookingsController.getHPByBooking` | `?status=` is now honoured by the working-tree model |
| `ApiConstants.getBookingsApi` | GET `/getUserBookings` | module(Bookings) | `bookingsController.getUserBookings` |  |
| `ApiConstants.holdBookingApi` | POST `/holdBooking` | module(Bookings) | `bookingsController.holdBooking` |  |
| `ApiConstants.markCgAttendance` | POST `/markAttendance` | module(Bookings\|HP Modules) | `bookingsController.markAttendance` |  |
| `ApiConstants.markCgAttendanceBatch` | POST `/markAttendanceBatch` | module(Bookings\|HP Modules) | `bookingsController.markAttendanceBatch` |  |
| `ApiConstants.matchHP` | GET `/matchHP` | module(Bookings\|HP Modules) | `bookingsController.getMatchedHPs` |  |
| `ApiConstants.updateBookingsEditApi` | PUT `/updateBooking` | module(Bookings) | `bookingsController.updateBooking` |  |
| `ApiConstants.updateHPBookingApi` | PUT `/updateHPBooking` | module(Bookings) | `bookingsController.updateHPBooking` |  |
| `ApiConstants.updatePatientApi` | PUT `/updatePatient` | module(Bookings) | `bookingsController.updatePatient` |  |

**`eldivix_be/routes/clientPortalRoutes.js`**

| Client constant | Method + path | Guard | Handler | Notes |
|---|---|---|---|---|
| `ClientApi.bookings` | GET `/client/bookings` | clientAuth | `c.getBookings` |  |
| `ClientApi.bookingById` | GET `/client/bookings/:id` | clientAuth | `c.getBookingById` | unused in app |
| `ClientApi.bookingAttendance` | GET `/client/bookings/:id/attendance` | clientAuth | `c.getBookingAttendance` |  |
| `ClientApi.bookingHp` | GET `/client/bookings/:id/hp` | clientAuth | `c.getAssignedHp` |  |
| `ClientApi.invoices` | GET `/client/invoices` | clientAuth | `c.getInvoices` |  |
| `ClientApi.me` | GET `/client/me` | clientAuth | `c.getMe` |  |
| `ClientApi.me` | PUT `/client/me` | clientAuth | `c.updateMe` |  |
| `ClientApi.outstanding` | GET `/client/outstanding` | clientAuth | `c.getOutstanding` |  |
| `ClientApi.patients` | GET `/client/patients` | clientAuth | `c.getPatients` |  |
| `ClientApi.patientById` | PUT `/client/patients/:id` | clientAuth | `c.updatePatient` |  |
| `ClientApi.receipts` | GET `/client/receipts` | clientAuth | `c.getReceipts` |  |
| `ClientApi.support` | GET `/client/support` | clientAuth | `c.getSupport` |  |
| `ClientApi.support` | POST `/client/support` | clientAuth | `c.createSupport` |  |
| `ClientApi.supportCategories` | GET `/client/support/categories` | clientAuth | `c.getSupportCategories` |  |
| `ClientApi.requestOtp` | POST `/clientAuth/requestOtp` | authLimiter | `clientAuthCtrl.requestOtp` |  |
| `ClientApi.verifyOtp` | POST `/clientAuth/verifyOtp` | authLimiter | `clientAuthCtrl.verifyOtp` |  |

**`eldivix_be/routes/dashboardRoutes.js`**

| Client constant | Method + path | Guard | Handler | Notes |
|---|---|---|---|---|
| `ApiConstants.getDashboardStats` | GET `/getDashboardStats` | module(Home) | `getDashboardStats` |  |

**`eldivix_be/routes/hostelsRoutes.js`**

| Client constant | Method + path | Guard | Handler | Notes |
|---|---|---|---|---|
| `ApiConstants.closeHostelStay` | PUT `/closeHostelStay/:id` | module(HP Modules) + validate | `hostelsController.closeHostelStay` |  |
| `ApiConstants.createHostel` | POST `/createHostel` | module(HP Modules) + validate | `hostelsController.createHostel` |  |
| `ApiConstants.createHostelSettlement` | POST `/createHostelSettlement` | module(HP Modules) + validate | `hostelsController.createHostelSettlement` |  |
| `ApiConstants.createHostelStay` | POST `/createHostelStay` | module(HP Modules) + validate | `hostelsController.createHostelStay` |  |
| `ApiConstants.getHostelById` | GET `/getHostelById/:id` | module(HP Modules) | `hostelsController.getHostelById` | unused in app |
| `ApiConstants.getHostelSettlement` | GET `/getHostelSettlement` | module(HP Modules) | `hostelsController.getHostelSettlement` |  |
| `ApiConstants.getHostelStays` | GET `/getHostelStays` | module(HP Modules) | `hostelsController.getHostelStays` |  |
| `ApiConstants.getHostels` | GET `/getHostels` | module(HP Modules) | `hostelsController.getHostels` |  |
| `ApiConstants.markHostelSettlementPaid` | PATCH `/markHostelSettlementPaid/:id` | module(HP Modules) | `hostelsController.markHostelSettlementPaid` |  |
| `ApiConstants.toggleHostelStatus` | PATCH `/toggleHostelStatus/:id` | module(HP Modules) | `hostelsController.toggleHostelStatus` |  |
| `ApiConstants.updateHostel` | PUT `/updateHostel/:id` | module(HP Modules) + validate | `hostelsController.updateHostel` |  |

**`eldivix_be/routes/hpPortalRoutes.js`**

| Client constant | Method + path | Guard | Handler | Notes |
|---|---|---|---|---|
| `HpApi.attendance` | GET `/hp/attendance` | hpAuth | `hp.getAttendance` |  |
| `HpApi.checkIn` | POST `/hp/attendance/checkin` | hpAuth | `hp.checkIn` |  |
| `HpApi.checkOut` | POST `/hp/attendance/checkout` | hpAuth | `hp.checkOut` |  |
| `HpApi.bank` | GET `/hp/bank` | hpAuth | `hp.getBank` | unused in app |
| `HpApi.bookings` | GET `/hp/bookings` | hpAuth | `hp.getBookings` |  |
| `HpApi.bookingById` | GET `/hp/bookings/:id` | hpAuth | `hp.getBookingById` | unused in app |
| `HpApi.earningsToday` | GET `/hp/earnings/today` | hpAuth | `hp.earningsToday` |  |
| `HpApi.leave` | GET `/hp/leave` | hpAuth | `hp.getLeave` |  |
| `HpApi.leave` | POST `/hp/leave` | hpAuth | `hp.requestLeave` |  |
| `HpApi.me` | GET `/hp/me` | hpAuth | `hp.getMe` |  |
| `HpApi.me` | PUT `/hp/me` | hpAuth | `hp.updateMe` |  |
| `HpApi.notifications` | GET `/hp/notifications` | hpAuth | `hp.getNotifications` | unused in app |
| `HpApi.notificationRead` | PATCH `/hp/notifications/:id/read` | hpAuth | `hp.markNotificationRead` | unused in app |
| `HpApi.payouts` | GET `/hp/payouts` | hpAuth | `hp.getPayouts` |  |
| `HpApi.payoutById` | GET `/hp/payouts/:id` | hpAuth | `hp.getPayoutById` |  |
| `HpApi.support` | GET `/hp/support` | hpAuth | `hp.getSupport` |  |
| `HpApi.support` | POST `/hp/support` | hpAuth | `hp.createSupport` |  |
| `HpApi.supportCategories` | GET `/hp/support/categories` | hpAuth | `hp.getSupportCategories` |  |
| `HpApi.requestOtp` | POST `/hpAuth/requestOtp` | authLimiter | `hpAuthCtrl.requestOtp` |  |
| `HpApi.verifyOtp` | POST `/hpAuth/verifyOtp` | authLimiter | `hpAuthCtrl.verifyOtp` |  |
| `ClientApi.orgById` | GET `/org/byId/:id` | none (public) | `hpAuthCtrl.getOrgById` |  |
| `HpApi.orgById` | GET `/org/byId/:id` | none (public) | `hpAuthCtrl.getOrgById` |  |
| `ClientApi.orgBySlug` | GET `/org/bySlug/:slug` | none (public) | `hpAuthCtrl.getOrgBySlug` |  |
| `HpApi.orgBySlug` | GET `/org/bySlug/:slug` | none (public) | `hpAuthCtrl.getOrgBySlug` |  |

**`eldivix_be/routes/hpRoutes.js`**

| Client constant | Method + path | Guard | Handler | Notes |
|---|---|---|---|---|
| `ApiConstants.createHp` | POST `/createHPProfile` | module(HP Modules) + hpFiles | `hpController.createHPProfile` |  |
| `ApiConstants.createPayout` | POST `/createPayout` | module(HP Modules) | `hpController.createPayout` | body fields match handler (see §7.3) |
| `ApiConstants.getHp` | GET `/getHPDetails` | module(HP Modules\|Bookings) | `hpController.getHPDetails` |  |
| `ApiConstants.getPayoutHistory` | GET `/getPayoutHistory` | module(HP Modules) | `hpController.getPayoutHistory` |  |
| `ApiConstants.getPendingPayouts` | GET `/getPendingPayouts` | module(HP Modules) | `hpController.getPendingPayouts` |  |
| `ApiConstants.markPayoutPaid` | PATCH `/markPayoutPaid` | module(HP Modules) | `hpController.markPayoutPaid` | **Param mismatch**: client sends `?id=` with no body; handler reads `req.body.id` → 400 |
| `ApiConstants.manageCgStatus` | PATCH `/updateHPStatus` | module(HP Modules) | `inline (routes file)` |  |

**`eldivix_be/routes/masterTableRoutes.js`**

| Client constant | Method + path | Guard | Handler | Notes |
|---|---|---|---|---|
| `ApiConstants.addAddressByClient` | POST `/addAddress` | module(Users\|Bookings) | `masterTables.saveAddress` |  |
| `ApiConstants.createBannersApi` | POST `/createBanner` | module(Settings) | `masterTables.saveBanner` |  |
| `ApiConstants.createBranch` | POST `/createBranch` | module(Settings) | `masterTables.createBranch` |  |
| `ApiConstants.createCouponApi` | POST `/createCoupon` | module(Settings) | `masterTables.createCoupons` |  |
| `ApiConstants.createEmployeeRoles` | POST `/createRole` | module(Settings) | `masterTables.createWebRoles` |  |
| `ApiConstants.createService` | POST `/createService` | module(Settings) | `masterTables.createService` |  |
| `ApiConstants.createServiceCategory` | POST `/createServiceCategory` | module(Settings) | `masterTables.createServiceCategory` |  |
| `ApiConstants.updateBannerStatus` | PATCH `/disable-banner` | module(Settings) | `inline (routes file)` |  |
| `ApiConstants.getAddressByClient` | GET `/getAddress` | staff | `masterTables.getAddress` |  |
| `ApiConstants.getMasterModules` | GET `/getAppModules` | staff | `masterTables.getAppModules` |  |
| `ApiConstants.getAllBanners` | GET `/getBanners` | staff | `masterTables.getAllBanners` |  |
| `ApiConstants.getCouponApi` | GET `/getCoupons` | staff | `masterTables.getAllCoupons` |  |
| `ApiConstants.getAccessRoles` | GET `/getRoles` | staff | `masterTables.getAllRoles` |  |
| `ApiConstants.getServiceCategories` | GET `/getServiceCategories` | staff | `masterTables.getServiceCategories` |  |
| `ApiConstants.getServices` | GET `/getServices` | staff | `masterTables.getServicesList` |  |
| `ApiConstants.getAllBranches` | GET `/getbranches` | staff | `masterTables.getBranches` |  |
| `ApiConstants.getAllLanguages` | GET `/getlanguages` | staff | `masterTables.getLangC` |  |
| `ApiConstants.getMasterLanguages` | GET `/getlanguages` | staff | `masterTables.getLangC` |  |
| `ApiConstants.toggleBranchStatus` | PATCH `/toggleBranchStatus` | module(Settings) | `masterTables.toggleBranchStatus` |  |
| `ApiConstants.toggleServiceCategoryStatus` | PATCH `/toggleServiceCategoryStatus` | module(Settings) | `masterTables.toggleServiceCategoryStatus` |  |
| `ApiConstants.toggleServiceStatus` | PATCH `/toggleServiceStatus` | module(Settings) | `masterTables.toggleServiceStatus` |  |
| `ApiConstants.updateAddressApi` | PUT `/updateAddress` | module(Users\|Bookings) | `masterTables.updateAddress` |  |
| `ApiConstants.updateBranchById` | PUT `/updateBranch/:id` | module(Settings) | `masterTables.updateBranch` |  |
| `ApiConstants.updateServiceById` | PUT `/updateService/:id` | module(Settings) | `masterTables.updateService` |  |
| `ApiConstants.updateServiceCategoryById` | PUT `/updateServiceCategory/:id` | module(Settings) | `masterTables.updateServiceCategory` |  |

**`eldivix_be/routes/masterservicesRoutes.js`**

| Client constant | Method + path | Guard | Handler | Notes |
|---|---|---|---|---|
| `ApiConstants.getMasterServices` | GET `/masterServices` | none (public) | `masterServicesController.getAllServices` | unused; public |

**`eldivix_be/routes/notificationsRoutes.js`**

| Client constant | Method + path | Guard | Handler | Notes |
|---|---|---|---|---|
| `ApiConstants.getNotificationsApi` | GET `/notifications` | staff | `notificationsController.getNotifications` |  |
| `ApiConstants.deleteNotificationApi` | DELETE `/notifications/:id` | staff | `notificationsController.deleteNotification` |  |
| `ApiConstants.readNotificationApi` | PATCH `/notifications/:id/read` | staff | `notificationsController.markNotificationRead` |  |
| `ApiConstants.clearNotificationsApi` | DELETE `/notifications/clearAll` | staff | `notificationsController.clearAllNotifications` |  |
| `ApiConstants.readAllNotificationsApi` | PATCH `/notifications/readAll` | staff | `notificationsController.markAllNotificationsRead` |  |

**`eldivix_be/routes/orgProfileRoutes.js`**

| Client constant | Method + path | Guard | Handler | Notes |
|---|---|---|---|---|
| `ApiConstants.orgProfileApi` | GET `/orgProfile` | staff | `orgProfile.getOrgProfile` |  |
| `ApiConstants.orgProfileApi` | PUT `/orgProfile` | module(Settings) | `orgProfile.updateOrgProfile` |  |
| `ApiConstants.orgEmailPreviewApi` | POST `/orgProfile/emailPreview` | module(Settings) | `orgProfile.previewEmails` |  |

**`eldivix_be/routes/orgRoutes.js`**

| Client constant | Method + path | Guard | Handler | Notes |
|---|---|---|---|---|
| `ApiConstants.createOrganisation` | POST `/createOrganisation` | owner | `orgController.createOrganisation` | only from unreachable module |
| `ApiConstants.getOrgDetails` | GET `/getOrgDetails` | owner | `orgController.getOrgDetails` | unused in app |
| `ApiConstants.getOrganisations` | GET `/getOrganisations` | owner | `orgController.getOrganisations` | only from unreachable module |
| `ApiConstants.getSaasAccounts` | GET `/getOrganisations` | owner | `orgController.getOrganisations` | only from unreachable module |
| `ApiConstants.updateOrganisation` | PUT `/updateOrganisation/:id` | owner | `orgController.updateOrganisation` | only from unreachable module |

**`eldivix_be/routes/reportsRoutes.js`**

| Client constant | Method + path | Guard | Handler | Notes |
|---|---|---|---|---|
| `ApiConstants.configureReportSchedule` | POST `/configureReportSchedule` | module(Settings) | `reportsController.configureReportSchedule` |  |
| `ApiConstants.generateReport` | GET `/generateReport` | module(Settings) + planGate(Growth\|Enterprise) | `reportsController.generateReport` |  |
| `ApiConstants.getScheduledReports` | GET `/getScheduledReports` | module(Settings) | `reportsController.getScheduledReports` |  |

**`eldivix_be/routes/saasAccountsRoutes.js`**

| Client constant | Method + path | Guard | Handler | Notes |
|---|---|---|---|---|
| `ApiConstants.checkDowngradeViability` | POST `/saas/checkDowngradeViability` | owner | `ctrl.checkDowngradeViability` | only from unreachable module |
| `ApiConstants.checkEmailAvailable` | GET `/saas/checkEmailAvailable` | owner | `ctrl.checkEmailAvailable` | only from unreachable module |
| `ApiConstants.checkSlugAvailable` | GET `/saas/checkSlugAvailable` | owner | `ctrl.checkSlugAvailable` | only from unreachable module |
| `ApiConstants.generateSaasInvoice` | POST `/saas/generateSaasInvoice` | owner | `ctrl.generateSaasInvoice` | only from unreachable module |
| `ApiConstants.getAccountHealthSummary` | GET `/saas/getAccountHealthSummary` | owner | `ctrl.getAccountHealthSummary` | only from unreachable module |
| `ApiConstants.getOrgUsage` | GET `/saas/getOrgUsage` | owner | `ctrl.getOrgUsage` | only from unreachable module |
| `ApiConstants.getSaasInvoices` | GET `/saas/getSaasInvoices` | owner | `ctrl.getSaasInvoices` | only from unreachable module |
| `ApiConstants.getSubscriptionHistory` | GET `/saas/getSubscriptionHistory` | owner | `ctrl.getSubscriptionHistory` | only from unreachable module |
| `ApiConstants.markSaasInvoicePaid` | PATCH `/saas/markSaasInvoicePaid` | owner | `ctrl.markSaasInvoicePaid` | only from unreachable module |
| `ApiConstants.transitionSubscriptionStatus` | PATCH `/saas/transitionSubscriptionStatus` | owner | `ctrl.transitionSubscriptionStatus` | only from unreachable module |

**`eldivix_be/routes/subscriptionRoutes.js`**

| Client constant | Method + path | Guard | Handler | Notes |
|---|---|---|---|---|
| `ApiConstants.getPlans` | GET `/getPlans` | none (public) | `subscriptionController.getPlans` | only from unreachable module |
| `ApiConstants.getSubscriptionStatus` | GET `/getSubscriptionStatus` | staff | `subscriptionController.getSubscriptionStatus` |  |
| `ApiConstants.updateOrgPlan` | PUT `/updateOrgPlan` | owner | `subscriptionController.updateOrgPlan` | only from unreachable module |

**`eldivix_be/routes/supportRoutes.js`**

| Client constant | Method + path | Guard | Handler | Notes |
|---|---|---|---|---|
| `ApiConstants.createSupportTicket` | POST `/createSupportTicket` | module(Support Ticket\|Bookings) + validate | `supportController.createSupportTicket` |  |
| `ApiConstants.getSupportCategories` | GET `/getSupportCategory` | none (public) | `supportController.getSupportCategory` | public; org from JWT or `org_id`/`org_code` query |
| `ApiConstants.getSupportStats` | GET `/getSupportStats` | module(Support Ticket\|Bookings) | `supportController.getSupportStats` |  |
| `ApiConstants.getSupportTicket` | GET `/getSupportTickets` | module(Support Ticket\|Bookings) | `supportController.getSupportTickets` |  |
| `ApiConstants.updateSupportTicketStatus` | PATCH `/updateSupportStatus` | module(Support Ticket\|Bookings) | `inline (routes file)` |  |

**`eldivix_be/routes/termsRoutes.js`**

| Client constant | Method + path | Guard | Handler | Notes |
|---|---|---|---|---|
| `ApiConstants.acceptTerms` | POST `/acceptTerms` | staff | `termsController.acceptTerms` |  |
| `ApiConstants.getCurrentTerms` | GET `/getCurrentTerms` | staff | `termsController.getCurrentTerms` |  |

**`eldivix_be/routes/userRoutes.js`**

| Client constant | Method + path | Guard | Handler | Notes |
|---|---|---|---|---|
| `ApiConstants.createClientUser` | POST `/createClientUser` | module(Users\|Bookings) | `userController.createClientUser` |  |
| `ApiConstants.createEmployee` | POST `/createUser` | module(Settings) | `validate(createUserSchema) → userController.createUserWeb` |  |
| `ApiConstants.forgotPassword` | POST `/forgotPassword` | validate | `userController.forgotPassword` |  |
| `ApiConstants.getClientUserDetails` | GET `/getUserDetails` | module(Users\|Bookings) | `userController.getUserDetails` |  |
| `ApiConstants.getAllEmployees` | GET `/getWebEmpDetails` | staff | `userController.getWebEmpDetails` | no module gate (any staff role) |
| `ApiConstants.addClientUser` | POST `/login` | authLimiter | `userController.loginUsers` | unused; backend returns 410 (retired) |
| `ApiConstants.loginEndPoint` | POST `/loginWeb` | authLimiter + validate | `userController.loginWebUsers` |  |
| `ApiConstants.resetPassword` | POST `/resetPassword` | validate | `userController.resetPassword` | unused in app |
| `ApiConstants.putClientUserDetails` | PUT `/saveUser` | module(Users\|Bookings) | `userController.saveUser` |  |
| `ApiConstants.terminateEmployee` | PUT `/terminate-user` | module(Settings) | `userController.terminateUserWeb` |  |
| `ApiConstants.updateEmployee` | PUT `/update-user` | module(Settings) | `userController.updateUserWeb` |  |
| `ApiConstants.updateClientUserApi` | PUT `/update-user-client` | module(Users\|Bookings) | `userController.updateUserClient` |  |
