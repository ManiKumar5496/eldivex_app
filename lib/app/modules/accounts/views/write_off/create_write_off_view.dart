import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/helper_ui.dart';
import '../../controllers/write_off_controller.dart';
import '../../models/active_booking_client_model.dart';
import '../../models/parse_utils.dart';
import '../accounts_format.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class CreateWriteOffView extends StatefulWidget {
  const CreateWriteOffView({super.key});

  @override
  State<CreateWriteOffView> createState() => _CreateWriteOffViewState();
}

class _CreateWriteOffViewState extends State<CreateWriteOffView> {
  late final WriteOffController ctrl;
  final _formKey = GlobalKey<FormState>();

  static const _writeOffTypes = [
    'BAD_DEBT',
    'BILLING_ERROR',
    'GOODWILL',
    'ADJUSTMENT',
  ];

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<WriteOffController>();
  }

  // Mirrors the backend's _determineApprovalLevel (≤500 L1, ≤5000 L2, else L3).
  String _approvalLevelLabel(double? amount) {
    if (amount == null || amount <= 0) return '';
    if (amount <= 500) return 'L1';
    if (amount <= 5000) return 'L2';
    return 'L3';
  }

  AppTone _approvalLevelTone(double? amount) {
    if (amount == null || amount <= 0) return AppTone.neutral;
    if (amount <= 500) return AppTone.success;
    if (amount <= 5000) return AppTone.warning;
    return AppTone.danger;
  }

  /// Client dropdown change — also used to preselect the client passed by
  /// the outstanding page's Quick Actions.
  void _selectClient(int? id) {
    ctrl.selectedClientId.value = id;
    ctrl.selectedBookingId.value = null;
    ctrl.bookingInvoices.value = [];
    ctrl.selectedInvoiceIds.clear();
  }

  @override
  Widget build(BuildContext context) {
    prepareCreateForm(context, reset: ctrl.clearForm, selectClient: _selectClient);
    final pad = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 24.0;
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      bottomNavigationBar: _buildActionBar(pad),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(pad),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppPageHeader(
                    title: 'Create Write-off',
                    subtitle: 'Write off unpaid invoice balances for a booking',
                    breadcrumbs: const ['Accounts', 'Write-offs'],
                    onBack: () => HelperUi.safeBack(Routes.MAIN),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionCard(
                    title: 'Booking Details',
                    icon: LucideIcons.calendarDays,
                    tone: AppTone.info,
                    children: [
                      _formGrid([
                        _buildClientDropdown(),
                        _buildBookingDropdown(),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    title: 'Invoice Selection',
                    subtitle: 'Invoices whose balance is being written off',
                    icon: LucideIcons.receiptText,
                    tone: AppTone.success,
                    children: [
                      _buildInvoiceList(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    title: 'Write-off Details',
                    icon: LucideIcons.banknoteX,
                    tone: AppTone.warning,
                    children: [
                      _formGrid([
                        _buildWriteOffTypeDropdown(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _formField(
                              label: 'Amount',
                              hint: 'Enter write-off amount',
                              controller: ctrl.writeOffAmountCtrl,
                              keyboardType: TextInputType.number,
                              required: true,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Amount is required';
                                if (double.tryParse(v) == null || double.parse(v) <= 0) {
                                  return 'Enter a valid amount greater than zero';
                                }
                                return null;
                              },
                            ),
                            _buildApprovalLevelBadge(),
                          ],
                        ),
                        _formField(
                          label: 'Reason',
                          hint: 'Enter reason for write-off',
                          controller: ctrl.reasonCtrl,
                          maxLines: 3,
                          required: true,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Reason is required'
                              : null,
                        ),
                        _formField(
                          label: 'Remarks',
                          hint: 'Additional remarks (optional)',
                          controller: ctrl.remarksCtrl,
                          maxLines: 3,
                        ),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Section 1: Client Dropdown ──────────────────────────────────────────────

  Widget _buildClientDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('Client', required: true),
        const SizedBox(height: 8),
        Obx(() {
          final clients = ClientOption.fromBookingRows(ctrl.activeClients);
          final selected = clients.any((c) => c.userId == ctrl.selectedClientId.value)
              ? ctrl.selectedClientId.value
              : null;
          return _dropdownFrame(
            child: DropdownButton<int>(
              isExpanded: true,
              value: selected,
              icon: const Icon(LucideIcons.chevronDown, size: 18),
              borderRadius: BorderRadius.circular(AppRadius.md),
              hint: _hint('Select active client'),
              items: clients.map((c) {
                return DropdownMenuItem<int>(
                  value: c.userId,
                  child: Text(c.label,
                      style: _itemStyle,
                      overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: _selectClient,
            ),
          );
        }),
      ],
    );
  }

  // ── Section 1: Booking Dropdown ─────────────────────────────────────────────

  Widget _buildBookingDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('Booking', required: true),
        const SizedBox(height: 8),
        Obx(() {
          final clientId = ctrl.selectedClientId.value;
          final clients = ctrl.activeClients;

          // getActiveClients returns one row per booking for the client.
          final bookings = bookingRowsForUser(clients, clientId);

          return _dropdownFrame(
            enabled: clientId != null,
            child: DropdownButton<int>(
              isExpanded: true,
              value: ctrl.selectedBookingId.value,
              icon: const Icon(LucideIcons.chevronDown, size: 18),
              borderRadius: BorderRadius.circular(AppRadius.md),
              hint: _hint(
                  clientId == null ? 'Select a client first' : 'Select booking'),
              items: bookings.map((b) {
                final bid = toInt(field(b, 'booking_id'), toInt(field(b, 'id')));
                final due = toDouble(field(b, 'outstanding_amount'));
                return DropdownMenuItem<int>(
                  value: bid,
                  child: Text('${bookingRowLabel(b)} · Due ${formatInr(due)}',
                      style: _itemStyle,
                      overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: clientId == null
                  ? null
                  : (id) {
                      ctrl.selectedBookingId.value = id;
                      ctrl.selectedInvoiceIds.clear();
                      if (id != null) ctrl.loadBookingInvoices(id);
                    },
            ),
          );
        }),
      ],
    );
  }

  // ── Section 2: Invoice List ──────────────────────────────────────────────────

  Widget _buildInvoiceList() {
    return Obx(() {
      final invoices = ctrl.bookingInvoices;
      if (ctrl.selectedBookingId.value == null) {
        return _emptyHint(LucideIcons.receipt, 'Select a booking to see invoices');
      }
      if (invoices.isEmpty) {
        return _emptyHint(LucideIcons.circleCheck, 'No invoices found for this booking');
      }
      return Column(
        children: invoices.map((inv) {
          // getInvoices: invoice_db_id = numeric PK, invoice_id = 'INV-<id>'.
          final id = toInt(field(inv, 'invoice_db_id'));
          final invoiceId = toStr(field(inv, 'invoice_id'), '#$id');
          final period = '${formatAccDate(field(inv, 'period_from'))} – ${formatAccDate(field(inv, 'period_to'))}';
          final total = toDouble(field(inv, 'total_amount'));
          final balance = toDouble(field(inv, 'balance_due'));
          final isSelected = ctrl.selectedInvoiceIds.contains(id);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColor.primarySoft : AppColor.whiteColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isSelected
                    ? AppColor.cAppPrimaryColor.withValues(alpha: 0.4)
                    : AppColor.divColor,
              ),
            ),
            child: CheckboxListTile(
              value: isSelected,
              onChanged: (_) => ctrl.toggleInvoiceSelection(id),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              title: Text(
                invoiceId,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColor.textPrimary,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(period,
                      style: TextStyle(fontSize: 13, color: AppColor.textTertiary)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _miniChip('Total', formatInr(total), AppTone.info),
                      _miniChip('Balance', formatInr(balance), AppTone.danger),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  // ── Section 3: Write-off Type Dropdown ──────────────────────────────────────

  Widget _buildWriteOffTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel('Write-off Type', required: true),
        const SizedBox(height: 8),
        Obx(() => _dropdownFrame(
              child: DropdownButton<String>(
                isExpanded: true,
                value: ctrl.writeOffType.value,
                icon: const Icon(LucideIcons.chevronDown, size: 18),
                borderRadius: BorderRadius.circular(AppRadius.md),
                items: _writeOffTypes
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(_typeLabel(t), style: _itemStyle),
                        ))
                    .toList(),
                onChanged: (v) => ctrl.writeOffType.value = v ?? 'BAD_DEBT',
              ),
            )),
      ],
    );
  }

  // ── Section 3: Approval Level Badge ─────────────────────────────────────────

  Widget _buildApprovalLevelBadge() {
    return ValueListenableBuilder<TextEditingValue>(
        valueListenable: ctrl.writeOffAmountCtrl,
        builder: (context, value, _) {
      final amount = double.tryParse(value.text.trim());
      if (amount == null || amount <= 0) return const SizedBox.shrink();
      final label = _approvalLevelLabel(amount);
      final tone = _approvalLevelTone(amount);
      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: tone.soft,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.shieldCheck, size: 16, color: tone.color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Approval Level: $label (approver required)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: tone.color,
                ),
              ),
            ),
          ],
        ),
      );
        });
  }

  // ── Bottom action bar (Cancel + Submit) ─────────────────────────────────────

  Widget _buildActionBar(double pad) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        border: Border(top: BorderSide(color: AppColor.divColor)),
      ),
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: 12),
      child: SafeArea(
        top: false,
        // heightFactor 1: inside bottomNavigationBar a plain Center grows to
        // the full screen height and squeezes the page body to nothing.
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            // Full form width (≤ 1100) so the buttons line up with the form's
            // right edge instead of centring.
            constraints: const BoxConstraints(minWidth: 1100, maxWidth: 1100),
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 12,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => HelperUi.safeBack(Routes.MAIN),
                  child: const Text('Cancel'),
                ),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Submit Button ────────────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return Obx(() => ElevatedButton.icon(
          onPressed: ctrl.isSubmitting.value
              ? null
              : () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final ok = await ctrl.createWriteOff();
                    if (ok) HelperUi.safeBack(Routes.MAIN);
                  }
                },
          icon: ctrl.isSubmitting.value
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColor.cAppPrimaryColor,
                  ),
                )
              : const Icon(LucideIcons.circleCheck, size: 18),
          label: Text(
            ctrl.isSubmitting.value ? 'Submitting...' : 'Submit Write-off',
          ),
        ));
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  TextStyle get _itemStyle =>
      TextStyle(fontSize: 14, color: AppColor.textPrimary);

  Text _hint(String text) =>
      Text(text, style: TextStyle(color: AppColor.textTertiary, fontSize: 14));

  /// Theme-styled field frame for a [DropdownButton].
  Widget _dropdownFrame({required Widget child, bool enabled = true}) {
    return InputDecorator(
      decoration: InputDecoration(
        enabled: enabled,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }

  /// Two columns when the card is wide enough, one on phones.
  Widget _formGrid(List<Widget> fields) {
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 600 ? 2 : 1;
      final w = (c.maxWidth - 20 * (cols - 1)) / cols;
      return Wrap(
        spacing: 20,
        runSpacing: 16,
        children: [for (final f in fields) SizedBox(width: w, child: f)],
      );
    });
  }

  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    required IconData icon,
    required AppTone tone,
    required List<Widget> children,
  }) {
    return AppCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconTone: tone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _fieldLabel(String label, {bool required = false}) {
    return Text.rich(
      TextSpan(text: label, children: [
        if (required)
          TextSpan(text: ' *', style: TextStyle(color: AppColor.danger)),
      ]),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColor.textSecondary,
      ),
    );
  }

  Widget _emptyHint(IconData icon, String message) {
    return AppEmptyState(icon: icon, title: message, compact: true);
  }

  Widget _miniChip(String label, String value, AppTone tone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tone.soft,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: tone.color,
            ),
          ),
        ],
      ),
    );
  }

  /// A labelled, theme-styled [TextFormField] so that [Form] validation works.
  Widget _formField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool required = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _fieldLabel(label, required: required),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(color: AppColor.textPrimary, fontSize: 14),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'BAD_DEBT':
        return 'Bad Debt';
      case 'BILLING_ERROR':
        return 'Billing Error';
      case 'GOODWILL':
        return 'Goodwill';
      case 'ADJUSTMENT':
        return 'Adjustment';
      default:
        return type;
    }
  }
}
