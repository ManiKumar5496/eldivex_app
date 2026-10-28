import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import '../models/parse_utils.dart';

/// Formatting + status-colour helpers shared by every accounts screen.

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

/// One colour scheme for every status string used across the module
/// (receipts, invoices, write-offs, refunds, credit notes, transfers, claims).
Color accountsStatusColor(String status) {
  switch (status.trim().toLowerCase().replaceAll(' ', '_')) {
    case 'approved':
    case 'active':
    case 'completed':
    case 'paid':
    case 'settled':
    case 'applied':
      return Colors.green;
    case 'processing':
    case 'submitted':
    case 'fully_applied':
      return Colors.blue;
    case 'pending':
    case 'pending_approval':
    case 'partially_paid':
    case 'partially_applied':
    case 'on_hold':
      return Colors.orange;
    case 'rejected':
    case 'cancelled':
    case 'overdue':
    case 'expired':
    case 'failed':
      return Colors.red;
    case 'reversed':
      return Colors.purple;
    default:
      return AppColor.fontColorGrey;
  }
}

/// Small rounded status pill used by the list/detail screens.
Widget accountsStatusChip(String status, {double fontSize = 12}) {
  final color = accountsStatusColor(status);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      humanizeStatus(status),
      style: TextStyle(
          color: color, fontSize: fontSize, fontWeight: FontWeight.w600),
    ),
  );
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
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 56, color: AppColor.fontColorGrey),
          const SizedBox(height: 12),
          Text('$title not found',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColor.cPrimaryHeadingColor)),
          const SizedBox(height: 6),
          Text('The record could not be loaded. Open it again from the list.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColor.fontColorGrey)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Back'),
          ),
        ],
      ),
    ),
  );
}
