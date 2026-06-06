import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import '../../../../widgets/common_textfield.dart';
import '../../controllers/write_off_controller.dart';

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

  String _approvalLevelLabel(double? amount) {
    if (amount == null || amount <= 0) return '';
    if (amount <= 1000) return 'L1 — Auto Approved';
    if (amount <= 10000) return 'L2 — Finance Head Required';
    return 'L3 — Director Required';
  }

  Color _approvalLevelColor(double? amount) {
    if (amount == null || amount <= 0) return Colors.grey;
    if (amount <= 1000) return Colors.green;
    if (amount <= 10000) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: AppColor.cPrimaryHeadingColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Create Write-off',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColor.cPrimaryHeadingColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                title: 'Booking Details',
                icon: Icons.event_note_outlined,
                iconColor: Colors.blue,
                children: [
                  _buildClientDropdown(),
                  const SizedBox(height: 14),
                  _buildBookingDropdown(),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Invoice Selection',
                icon: Icons.receipt_long_outlined,
                iconColor: Colors.teal,
                children: [
                  _buildInvoiceList(),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Write-off Details',
                icon: Icons.money_off_outlined,
                iconColor: Colors.orange.shade700,
                children: [
                  _buildWriteOffTypeDropdown(),
                  const SizedBox(height: 14),
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
                  const SizedBox(height: 10),
                  _buildApprovalLevelBadge(),
                  const SizedBox(height: 14),
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
                  const SizedBox(height: 14),
                  CommonTextField(
                    label: 'Remarks',
                    hint: 'Additional remarks (optional)',
                    controller: ctrl.remarksCtrl,
                    maxLines: 2,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section 1: Client Dropdown ──────────────────────────────────────────────

  Widget _buildClientDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Client', required: true),
        const SizedBox(height: 8),
        Obx(() {
          final clients = ctrl.activeClients;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.textFieldBorderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: ctrl.selectedClientId.value,
                hint: Text(
                  'Select active client',
                  style: TextStyle(color: AppColor.fontColorGrey, fontSize: 14),
                ),
                items: clients.map((c) {
                  final id = c['id'] as int? ?? c['user_id'] as int? ?? 0;
                  final name = c['client_name']?.toString() ?? c['name']?.toString() ?? '';
                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text(name, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (id) {
                  ctrl.selectedClientId.value = id;
                  ctrl.selectedBookingId.value = null;
                  ctrl.bookingInvoices.value = [];
                  ctrl.selectedInvoiceIds.clear();
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Section 1: Booking Dropdown ─────────────────────────────────────────────

  Widget _buildBookingDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Booking', required: true),
        const SizedBox(height: 8),
        Obx(() {
          final clientId = ctrl.selectedClientId.value;
          final clients = ctrl.activeClients;

          // Collect bookings for the selected client
          final List<dynamic> bookings = clientId == null
              ? []
              : clients.where((c) {
                  final id = c['id'] as int? ?? c['user_id'] as int? ?? 0;
                  return id == clientId;
                }).expand((c) {
                  final b = c['bookings'];
                  if (b is List) return b;
                  return <dynamic>[];
                }).toList();

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: clientId == null ? Colors.grey.shade50 : AppColor.whiteColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.textFieldBorderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: ctrl.selectedBookingId.value,
                hint: Text(
                  clientId == null ? 'Select a client first' : 'Select booking',
                  style: TextStyle(color: AppColor.fontColorGrey, fontSize: 14),
                ),
                items: bookings.map((b) {
                  final bid = (b['id'] as num?)?.toInt() ?? 0;
                  final label = b['booking_id']?.toString() ?? '#$bid';
                  return DropdownMenuItem<int>(
                    value: bid,
                    child: Text(label, style: const TextStyle(fontSize: 14)),
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
        return _emptyHint(Icons.receipt_outlined, 'Select a booking to see invoices');
      }
      if (invoices.isEmpty) {
        return _emptyHint(Icons.check_circle_outline, 'No invoices found for this booking');
      }
      return Column(
        children: invoices.map((inv) {
          final id = (inv['id'] as num?)?.toInt() ?? 0;
          final invoiceId = inv['invoice_id']?.toString() ?? '#$id';
          final period = '${inv['period_from'] ?? ''} – ${inv['period_to'] ?? ''}';
          final total = (inv['total_amount'] as num?)?.toDouble() ?? 0.0;
          final balance = (inv['balance_due'] as num?)?.toDouble() ?? 0.0;
          final isSelected = ctrl.selectedInvoiceIds.contains(id);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade50 : AppColor.whiteColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? Colors.blue.shade200 : Colors.grey.shade200,
              ),
            ),
            child: CheckboxListTile(
              value: isSelected,
              onChanged: (_) => ctrl.toggleInvoiceSelection(id),
              activeColor: AppColor.cPrimaryButtonColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              title: Text(
                invoiceId,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColor.cPrimaryButtonColor,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(period, style: TextStyle(fontSize: 12, color: AppColor.fontColorGrey)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _miniChip('Total', '₹${total.toStringAsFixed(0)}', Colors.blue),
                      const SizedBox(width: 8),
                      _miniChip('Balance', '₹${balance.toStringAsFixed(0)}', Colors.red),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Write-off Type', required: true),
        const SizedBox(height: 8),
        Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColor.textFieldBorderColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: ctrl.writeOffType.value,
                  items: _writeOffTypes
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(_typeLabel(t), style: const TextStyle(fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (v) => ctrl.writeOffType.value = v ?? 'BAD_DEBT',
                ),
              ),
            )),
      ],
    );
  }

  // ── Section 3: Approval Level Badge ─────────────────────────────────────────

  Widget _buildApprovalLevelBadge() {
    return Obx(() {
      final text = ctrl.writeOffAmountCtrl.text;
      final amount = double.tryParse(text);
      if (amount == null || amount <= 0) return const SizedBox.shrink();
      final label = _approvalLevelLabel(amount);
      final color = _approvalLevelColor(amount);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(Icons.verified_user_outlined, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              'Approval Level: $label',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Submit Button ────────────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: ctrl.isSubmitting.value
                ? null
                : () {
                    if (_formKey.currentState?.validate() ?? false) {
                      ctrl.createWriteOff();
                    }
                  },
            icon: ctrl.isSubmitting.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
            label: Text(
              ctrl.isSubmitting.value ? 'Submitting...' : 'Submit Write-off',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              disabledBackgroundColor: Colors.orange.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ));
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColor.cPrimaryHeadingColor,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _fieldLabel(String label, {bool required = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColor.cPrimarySubHeadingColorGrey,
          ),
        ),
        if (required)
          const Text(' *', style: TextStyle(color: Colors.red, fontSize: 14)),
      ],
    );
  }

  Widget _emptyHint(IconData icon, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text(message, style: AppTextStyles.regular14Gre),
        ],
      ),
    );
  }

  Widget _miniChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// A validated text field that visually matches [CommonTextField] but wraps
  /// a [TextFormField] so that [Form] validation works.
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColor.cPrimarySubHeadingColorGrey,
              ),
            ),
            if (required)
              const Text(' *', style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColor.whiteColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColor.textFieldBorderColor),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            style: const TextStyle(color: Colors.black87, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColor.fontColorGrey, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              errorStyle: const TextStyle(fontSize: 12),
            ),
          ),
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
