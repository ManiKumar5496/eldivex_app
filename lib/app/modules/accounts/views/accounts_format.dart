import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../models/parse_utils.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

/// Formatting + status-colour helpers shared by every accounts screen.

/// Keys already handled per route instance (see [runOncePerRoute]).
final Expando<Set<String>> _routeOnce = Expando<Set<String>>('accountsRouteOnce');

/// Runs [action] once per visit to the current route (after the first frame).
///
/// Accounts controllers are `fenix` singletons, so their state outlives the
/// page. Detail/create pages use this to (re)load or reset per visit: a new
/// `Get.toNamed` (or a browser refresh) creates a new route, rebuilds of the
/// same route do not re-run [action]. Returns true when [action] was scheduled.
bool runOncePerRoute(BuildContext context, String key, VoidCallback action) {
  final route = ModalRoute.of(context);
  if (route == null) return false;
  final done = _routeOnce[route] ??= <String>{};
  if (!done.add(key)) return false;
  WidgetsBinding.instance.addPostFrameCallback((_) => action());
  return true;
}

/// Prepares a create screen once per visit: [reset] clears the previous
/// attempt's form state, then — when the client outstanding page's Quick
/// Actions passed `{'client_id': …}` — [selectClient] preselects that client.
/// Runs after the first frame, so later dropdown changes aren't overridden.
void prepareCreateForm(
  BuildContext context, {
  required VoidCallback reset,
  void Function(int id)? selectClient,
  void Function(Map args)? prefill,
}) {
  final route = ModalRoute.of(context);
  final args = route?.settings.arguments ?? Get.arguments;
  final id = args is Map ? toIntOrNull(args['client_id']) : null;
  runOncePerRoute(context, 'prepareCreateForm', () {
    reset();
    if (id != null && selectClient != null) selectClient(id);
    // Further arguments (booking_id, amount, …) a page knows how to apply.
    if (args is Map && prefill != null) prefill(args);
  });
}

/// True when the page is shown as its own route [routeName] (pushed with
/// `Get.toNamed` or opened by URL) rather than inside the side-menu shell.
bool accountsIsOwnRoute(BuildContext context, String routeName) {
  final name = ModalRoute.of(context)?.settings.name ?? '';
  return name == routeName || name.startsWith('$routeName?');
}

/// Calls [onOpen] every time the page is shown. The side-menu shell and the
/// AccountsView tab bar build their pages lazily (PageView / TabBarView), so
/// the page is mounted afresh each time it is opened.
class AccountsOnOpen extends StatefulWidget {
  const AccountsOnOpen({super.key, required this.onOpen, required this.child});

  final VoidCallback onOpen;
  final Widget child;

  @override
  State<AccountsOnOpen> createState() => _AccountsOnOpenState();
}

class _AccountsOnOpenState extends State<AccountsOnOpen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onOpen();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

final NumberFormat _inr = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
final NumberFormat _inrCompact =
    NumberFormat.compactCurrency(locale: 'en_IN', symbol: '₹', decimalDigits: 1);

/// Shared ₹ formatter for widgets that take a [NumberFormat].
NumberFormat get inrFormat => _inr;

/// ₹1,23,456.00
String formatInr(dynamic amount) => _inr.format(toDouble(amount));

/// ₹1.2L / ₹12.3K style, for KPI tiles.
String formatInrCompact(dynamic amount) => _inrCompact.format(toDouble(amount));

/// Formats a date (DateTime or backend string). Missing → [empty].
String formatAccDate(dynamic value,
    {String pattern = 'dd MMM yyyy', String empty = '—'}) {
  final dt = value is DateTime ? value : toDate(value);
  if (dt == null) return empty;
  return DateFormat(pattern).format(dt.toLocal());
}

/// 'PENDING_APPROVAL' → 'Pending Approval'
String humanizeStatus(String status) {
  if (status.isEmpty) return '—';
  return status
      .replaceAll('_', ' ')
      .toLowerCase()
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');
}

/// One tone for every status string used across the module
/// (receipts, invoices, write-offs, refunds, credit notes, transfers, claims).
AppTone _accountsStatusTone(String status) {
  switch (status.trim().toLowerCase().replaceAll(' ', '_')) {
    case 'approved':
    case 'active':
    case 'completed':
    case 'paid':
    case 'settled':
    case 'applied':
      return AppTone.success;
    case 'processing':
    case 'submitted':
    case 'fully_applied':
      return AppTone.info;
    case 'pending':
    case 'pending_approval':
    case 'partially_paid':
    case 'partially_applied':
    case 'on_hold':
      return AppTone.warning;
    case 'rejected':
    case 'cancelled':
    case 'overdue':
    case 'expired':
    case 'failed':
      return AppTone.danger;
    case 'reversed':
      return AppTone.violet;
    default:
      return AppTone.neutral;
  }
}

/// One colour scheme for every status string used across the module
/// (receipts, invoices, write-offs, refunds, credit notes, transfers, claims).
Color accountsStatusColor(String status) {
  switch (_accountsStatusTone(status)) {
    case AppTone.success:
      return AppColor.success;
    case AppTone.info:
      return AppColor.info;
    case AppTone.warning:
      return AppColor.warning;
    case AppTone.danger:
      return AppColor.danger;
    case AppTone.violet:
      return AppColor.violet;
    case AppTone.primary:
    case AppTone.neutral:
      return AppColor.fontColorGrey;
  }
}

/// Small status pill used by the list/detail screens. [fontSize] is kept for
/// API compatibility; the badge uses the design-system size.
Widget accountsStatusChip(String status, {double fontSize = 12}) {
  return AppStatusBadge(
    label: humanizeStatus(status),
    tone: _accountsStatusTone(status),
  );
}

/// Tone for a booking status code ('1'..'7').
AppTone bookingStatusTone(String code) {
  switch (code.trim()) {
    case '4':
      return AppTone.success;
    case '1':
    case '2':
      return AppTone.info;
    case '5':
    case '7':
      return AppTone.warning;
    case '3':
    case '6':
      return AppTone.danger;
    default:
      return _accountsStatusTone(code);
  }
}

/// Status pill for a booking: [label] (the backend `status_label` or the
/// local code map) toned by the numeric [code].
Widget bookingStatusChip(String code, String label) {
  return AppStatusBadge(
    label: label.isEmpty ? '—' : label,
    tone: bookingStatusTone(code),
  );
}

/// Normalises a statement line type: 'Write-off' / 'Write Off' → 'writeoff'.
String statementLineKind(String type) =>
    type.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

/// Tone for a client statement line type (Invoice, Payment, Write-off,
/// Credit Note, Refund, Transfer In, Transfer Out).
AppTone statementLineTone(String type) {
  switch (statementLineKind(type)) {
    case 'invoice':
      return AppTone.info;
    case 'payment':
    case 'receipt':
      return AppTone.success;
    case 'writeoff':
      return AppTone.warning;
    case 'creditnote':
      return AppTone.primary;
    case 'refund':
      return AppTone.violet;
    case 'transferin':
      return AppTone.success;
    case 'transferout':
      return AppTone.danger;
    default:
      return AppTone.neutral;
  }
}

/// Wraps a DataTable so it scrolls horizontally on narrow screens while
/// still filling the available width on desktop.
Widget horizontalTable(Widget table) {
  return LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: constraints.maxWidth.isFinite ? constraints.maxWidth : 0,
        ),
        child: table,
      ),
    ),
  );
}

/// Placeholder shown by detail screens opened without data (e.g. after a
/// browser refresh drops Get.arguments).
Widget recordNotFound({required String title, required VoidCallback onBack}) {
  return AppEmptyState(
    icon: LucideIcons.searchX,
    title: '$title not found',
    message: 'The record could not be loaded. Open it again from the list.',
    actionLabel: 'Back',
    actionIcon: LucideIcons.arrowLeft,
    onAction: onBack,
  );
}

// ─────────────────────────────────────────────────────────────────────────
// Presentation helpers shared by the accounts screens (design-system based).
// ─────────────────────────────────────────────────────────────────────────

/// Tabular digits so amounts line up in columns and KPI tiles.
const List<FontFeature> accountsTabularFigures = [FontFeature.tabularFigures()];

/// Text style for money values: tabular digits, semibold, primary text colour
/// unless [color] is given.
TextStyle accountsAmountStyle({
  Color? color,
  double fontSize = 13.5,
  FontWeight fontWeight = FontWeight.w600,
}) {
  return TextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color ?? AppColor.textPrimary,
    fontFeatures: accountsTabularFigures,
  );
}

/// Two-line table cell: a primary line with an optional muted second line.
Widget accountsCellStack(
  String title, {
  String? subtitle,
  Color? titleColor,
  FontWeight titleWeight = FontWeight.w600,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: titleWeight,
          color: titleColor ?? AppColor.textPrimary,
        ),
      ),
      if (subtitle != null && subtitle.isNotEmpty) ...[
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: AppColor.textTertiary),
        ),
      ],
    ],
  );
}

/// Label above a form control; matches CommonTextField's label.
Widget accountsFieldLabel(String label, {bool required = false}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text.rich(
      TextSpan(
        text: label,
        children: [
          if (required)
            TextSpan(text: ' *', style: TextStyle(color: AppColor.danger)),
        ],
      ),
      style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
    ),
  );
}

/// Bordered shell around a bare [DropdownButton] so it matches the inputs.
Widget accountsDropdownShell({required Widget child, double height = 44}) {
  return Container(
    height: height,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: AppColor.whiteColor,
      borderRadius: BorderRadius.circular(AppRadius.md),
      border: Border.all(color: AppColor.borderStrong),
    ),
    child: DropdownButtonHideUnderline(child: child),
  );
}

/// Compact tinted icon action for table rows (approve, reject, …).
Widget accountsIconAction({
  required IconData icon,
  required String tooltip,
  required VoidCallback? onPressed,
  AppTone tone = AppTone.neutral,
}) {
  final radius = BorderRadius.circular(AppRadius.sm);
  return Tooltip(
    message: tooltip,
    child: Material(
      color: tone.soft,
      borderRadius: radius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 18, color: tone.color),
        ),
      ),
    ),
  );
}

/// 40px square outlined icon button for toolbars (refresh, filters, …).
Widget accountsToolbarIconButton({
  required IconData icon,
  required String tooltip,
  required VoidCallback? onPressed,
}) {
  return Tooltip(
    message: tooltip,
    child: SizedBox(
      width: 40,
      height: 40,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(40, 40),
        ),
        child: Icon(icon, size: 18),
      ),
    ),
  );
}

/// Whether the screen is hosted inside the AccountsView tab bar (which shows
/// its own page header), as opposed to being a page of the side-menu shell.
bool accountsIsEmbeddedInTabs(BuildContext context) =>
    DefaultTabController.maybeOf(context) != null;

/// Page padding for an accounts screen: the standard page padding, with a
/// tighter top when the screen sits under the AccountsView tab bar.
EdgeInsets accountsPagePadding(BuildContext context, {bool bottom = true}) {
  final narrow = MediaQuery.sizeOf(context).width < 600;
  final h = narrow ? 16.0 : 24.0;
  final top = accountsIsEmbeddedInTabs(context) ? 16.0 : (narrow ? 16.0 : 24.0);
  return EdgeInsets.fromLTRB(h, top, h, bottom ? h : 0);
}
