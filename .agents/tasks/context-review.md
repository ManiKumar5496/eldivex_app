# Accuracy review of PROJECT_CONTEXT.md (eldivex_app working guide)

`PROJECT_CONTEXT.md` is a 667-line guide to the `eldivex_app` Flutter web admin console and its HP and client portals. I spot-checked about 40 claims against the working tree, and nearly all of them hold up. The guide's main correction to the task brief is that the app does not use Firestore, Firebase Auth, or Storage from Dart. That is confirmed: `pubspec.yaml` lists only `firebase_core`. The guide says so instead of making up Firestore collections or converters. No keys, tokens, IPs, project IDs, or emails are reproduced; it gives credential locations and risk only.

Watch for: a payload-field error in the CG payout flow (confirmed). The Firestore re-deploy risk is worded imprecisely, and the guide never mentions the `firestore` deploy block in `firebase.json` (confirmed). The file and git-change counts have drifted by one because `PROJECT_CONTEXT.md` itself is new (confirmed, cosmetic). None of these block use of the guide.

**Verdict**: APPROVED

## High-level view

Spot checks of `lib/main.dart` startup routing, the 16 Billing-guarded `/accounts/...` routes, the shared static Dio with its `lastError` contract, the 30 s JWT leeway, the booking status map `'1'`–`'7'`, the six unwired bindings, the unused `holdBooking`/`cancelBooking` methods, the 44 `poppins_regular` usages against a single declared `inter_regular` family, and the test inventory (11 files, 347 cases) all matched the code.

The Firebase section matches the files: hosting serves `build/web`, `.firebaserc` and `firebase.json` name different project IDs, the Firestore rule expired on 2026-07-01, and `functions/` has no build or deploy config. The weak spot is the deploy guidance. It doesn't say that `firebase.json` also deploys Firestore rules and indexes, and it misstates what a re-deploy would do.

Claims from the existing docs are cross-checked, not copied. Stale claims from `SAAS_ROADMAP.md` and `WORKSPACE_AUDIT.md` were checked against the code. Backend state in `eldivix_be` is labelled unverified. Runtime effects are tagged [Inferred]. The appendix states that large views were not read line by line and that nothing was built or run.

<details>
<summary>Issues (4)</summary>

1. **CG payout payload field names**: §7.3 lists `period` in the `/createPayout` body, but `cg_payment_controller.dart` sends `period_from` and `period_to`. Correct the field list.
2. **Firestore rules re-deploy wording**: §11 item 6 says "a careless re-deploy could reopen them". Re-deploying the current file keeps deny-all; the rules only reopen if someone edits the date or condition. Reword it, and note that a bare `firebase deploy` also pushes rules and indexes.
3. **`firestore` block missing from the firebase.json description**: §10 covers the hosting and auth blocks but not the `firestore` block (default database, location, rules and indexes paths). Add a line so the `--only hosting` advice in §14 has its rationale.
4. **Self-referential counts and tracking state**: Appendix A says 314 files and §1 says 147 git changes. The tree now shows 315 and 148 because `PROJECT_CONTEXT.md` is untracked. `WORKSPACE_AUDIT.md` and `.vscode/` are also untracked, which the guide doesn't say. Note "excluding this file" and flag the untracked items in §16 step 1.

</details>

<details>
<summary>Details</summary>

### CG payout payload in §7.3

The guide gives the payout body as `{hp_unique_id: <hp_reg_id>, period, pay_amount, gross_pay, hostel_deduction, payment_mode}`. `generatePayout` in `lib/app/modules/register_cg/controllers/cg_payment_controller.dart` (around L227–235) sends `period_from` and `period_to`. There is no `period` key (confirmed). The identifier claim itself is correct: `summary.hpId` is set from `cg.hpRegId` at L202, so the `hp_unique_id`/`hp_reg_id` mismatch suspicion in §15.2 stands. Developers will use this guide as a payload-contract reference, so the field list needs to be exact.

### Firestore deploy posture in §10, §11 and §14

`firestore.rules` allows all reads and writes while `request.time < timestamp.date(2026, 7, 1)`, which makes it deny-all today. Re-deploying the file unchanged keeps it that way. The real risk is someone bumping the date to "fix" denied requests, which would make the default database world-writable again (confirmed from the rule). Separately, `firebase.json` has a `firestore` block pointing at the rules and indexes files, so `firebase deploy` without `--only hosting` pushes them (confirmed). §14 recommends `--only hosting` without explaining why, and §10 doesn't mention the block. A developer who drops the flag would ship rules changes without realising it.

### Untracked files and §16 step 1

`git status --porcelain` shows `PROJECT_CONTEXT.md`, `WORKSPACE_AUDIT.md`, and `.vscode/` as untracked (`??`). §16 step 1 tells developers to commit all in-flight work together. It doesn't say these docs and the IDE folder are untracked, so a developer could miss them or commit them by accident.

</details>

<details>
<summary>File map (what was checked)</summary>

- `PROJECT_CONTEXT.md`: document under review, read in full
- `pubspec.yaml`: dependencies (no Firestore/Auth), font declarations
- `lib/main.dart`: init order, `_getInitialRoute`, `unknownRoute`
- `lib/app/data/api_constant_url.dart`: base URL default, `matchHP`, `finalBookingSave`, hold/cancel constants
- `lib/app/data/base_api_services.dart`: static shared Dio, `lastError`
- `lib/app/routes/app_pages.dart`: bindings and middleware per route
- `lib/app/modules/role/controllers/role_controller.dart`: `clearAuth` keys
- `lib/app/core/utils/jwt_utils.dart`: expiry leeway
- `lib/app/modules/bookings/controllers/bookings_controller.dart`: status labels, hold/cancel methods
- `lib/app/modules/register_cg/controllers/cg_payment_controller.dart`: payout body
- `lib/firebase_options.dart`: non-web `UnsupportedError`
- `firebase.json`, `.firebaserc`, `firestore.rules`, `firestore.indexes.json`: hosting, project mismatch, rule expiry, firestore block
- `functions/src/index.ts`, `functions/src/syncLead.ts`: trigger behaviour, missing build config
- `test/**`: per-file test counts
- `SAAS_ROADMAP.md`, `WORKSPACE_AUDIT.md`: sampled claims marked stale; seed-credential location (value not reproduced)
- `.claude/settings.local.json`: existence and global-gitignore status only (contents not read)
- Repo state: `git status --porcelain`, file enumeration

</details>
