import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import '../../../widgets/shimmer_loader.dart';
import '../controllers/accounts_controller.dart';
import '../models/credit_note_model.dart';

class CreditNotesView extends GetView<AccountsController> {
  const CreditNotesView({super.key});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'hold':
        return Colors.blue;
      case 'cancellation':
        return Colors.red.shade700;
      case 'overpayment':
        return Colors.purple;
      default:
        return AppColor.fontColorGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    if (!Get.isRegistered<AccountsController>()) {
      Get.put(AccountsController());
    }
    return Column(
      children: [
        _buildToolbar(),
        _buildStatusFilters(),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildToolbar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          SizeConfig.pagePadding.left, SizeConfig.spacingMD, SizeConfig.pagePadding.right, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.textFieldBorderColor),
              ),
              child: TextField(
                onChanged: (q) {
                  final lq = q.toLowerCase();
                  if (q.isEmpty) {
                    controller.filteredCreditNotes.value =
                        List.from(controller.creditNotes);
                  } else {
                    controller.filteredCreditNotes.value =
                        controller.creditNotes.where((n) {
                      return (n.clientName ?? '').toLowerCase().contains(lq) ||
                          (n.clientMobile ?? '').contains(q) ||
                          (n.patientName ?? '').toLowerCase().contains(lq) ||
                          n.bookingId.toString().contains(q) ||
                          n.creditType.toLowerCase().contains(lq);
                    }).toList();
                  }
                },
                style: TextStyle(fontSize: SizeConfig.fontBody),
                decoration: InputDecoration(
                  hintText: 'Search credit notes by client, booking, type...',
                  hintStyle:
                      TextStyle(color: AppColor.fontColorGrey, fontSize: SizeConfig.fontBody),
                  prefixIcon: Icon(Icons.search,
                      color: AppColor.fontColorGrey, size: SizeConfig.iconMD),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          SizedBox(width: SizeConfig.spacingSM),
          Tooltip(
            message: 'Refresh',
            child: InkWell(
              onTap: () => controller.fetchCreditNotes(),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColor.whiteColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColor.textFieldBorderColor),
                ),
                child: Icon(Icons.refresh,
                    color: AppColor.cPrimaryButtonColor, size: SizeConfig.iconMD),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilters() {
    final statuses = ['All', 'Pending', 'Approved', 'Rejected'];
    return Obx(() {
      final activeFilter = controller.selectedCreditNoteFilter.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.pagePadding.left, vertical: SizeConfig.spacingSM),
        child: Row(
          children: statuses.map((s) {
            final isSelected = activeFilter == s;
            return Padding(
              padding: EdgeInsets.only(right: SizeConfig.spacingSM),
              child: FilterChip(
                label: Text(s),
                selected: isSelected,
                onSelected: (_) {
                  controller.selectedCreditNoteFilter.value = s;
                  if (s == 'All') {
                    controller.filteredCreditNotes.value =
                        List.from(controller.creditNotes);
                  } else {
                    controller.filteredCreditNotes.value = controller.creditNotes
                        .where((n) => n.status == s)
                        .toList();
                  }
                },
                backgroundColor: AppColor.whiteColor,
                selectedColor:
                    AppColor.cPrimaryButtonColor.withValues(alpha: 0.1),
                labelStyle: TextStyle(
                  fontSize: SizeConfig.fontBody,
                  color: isSelected
                      ? AppColor.cPrimaryButtonColor
                      : AppColor.fontColorGrey,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? AppColor.cPrimaryButtonColor
                        : AppColor.textFieldBorderColor,
                  ),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.spacingSM, vertical: SizeConfig.spacingXS),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoadingCreditNotes.value) {
        return const ShimmerLoader.table();
      }
      if (controller.filteredCreditNotes.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.note_alt_outlined,
                  size: 64, color: AppColor.divColor),
              SizedBox(height: SizeConfig.spacingSM),
              Text('No credit notes found', style: AppTextStyles.regular16Gre),
              SizedBox(height: SizeConfig.spacingXS),
              Text(
                'Credit notes are auto-created when a booking is put\non hold or cancelled.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: SizeConfig.fontBody, color: AppColor.fontColorGrey),
              ),
            ],
          ),
        );
      }
      return SizeConfig.adaptiveLayout(
        mobile: _buildMobileCardList(),
        tablet: _buildScrollableTable(),
        desktop: _buildScrollableTable(),
      );
    });
  }

  Widget _buildMobileCardList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.pagePadding.left, vertical: SizeConfig.spacingXS),
      itemCount: controller.filteredCreditNotes.length,
      itemBuilder: (_, i) =>
          _buildMobileCreditNoteCard(controller.filteredCreditNotes[i]),
    );
  }

  Widget _buildMobileCreditNoteCard(CreditNoteModel note) {
    final statusColor = _statusColor(note.status);
    final typeColor = _typeColor(note.creditType);
    return Container(
      margin: EdgeInsets.only(bottom: SizeConfig.spacingSM),
      padding: SizeConfig.cardPadding,
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
        border: Border.all(color: AppColor.divColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Note ID + Status chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CN-${note.id}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: SizeConfig.fontBody,
                  color: AppColor.cPrimaryButtonColor,
                ),
              ),
              _statusBadge(note.status, statusColor),
            ],
          ),
          Divider(height: SizeConfig.spacingLG, color: AppColor.fieldColorGrey),

          // Row 2: Booking badge + Type chip
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.spacingSM, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(SizeConfig.radiusSM),
                ),
                child: Text(
                  '#${note.bookingId}',
                  style: TextStyle(
                    fontSize: SizeConfig.fontCaption,
                    color: AppColor.cPrimaryButtonColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: SizeConfig.spacingSM),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.spacingSM, vertical: 3),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: typeColor.withValues(alpha: 0.25)),
                ),
                child: Text(
                  note.creditType,
                  style: TextStyle(
                    color: typeColor,
                    fontSize: SizeConfig.fontCaption,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: SizeConfig.spacingSM),

          // Row 3: Client / Patient
          Row(
            children: [
              Icon(Icons.person_outline,
                  size: SizeConfig.iconSM, color: AppColor.fontColorGrey),
              SizedBox(width: SizeConfig.spacingXS),
              Expanded(
                child: Text(
                  '${note.clientName ?? '-'} / ${note.patientName ?? '-'}',
                  style: TextStyle(
                      fontSize: SizeConfig.fontBody, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: SizeConfig.spacingSM),

          // Row 4: Amount + Date
          Row(
            children: [
              Text(
                controller.formatCurrency(note.amount),
                style: TextStyle(
                  fontSize: SizeConfig.fontH3,
                  fontWeight: FontWeight.w700,
                  color: Colors.teal,
                ),
              ),
              const Spacer(),
              Text(
                _formatDateStr(note.creditDate ?? note.createdOn),
                style: TextStyle(
                    fontSize: SizeConfig.fontCaption, color: AppColor.fontColorGrey),
              ),
            ],
          ),

          // Row 5: Reason
          if (note.reason != null && note.reason!.isNotEmpty) ...[
            SizedBox(height: SizeConfig.spacingXS),
            Text(
              note.reason!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: SizeConfig.fontBodySmall, color: AppColor.fontColorGrey),
            ),
          ],

          // Bottom: Action buttons for Pending notes
          if (note.status == 'Pending') ...[
            Divider(height: SizeConfig.spacingLG, color: AppColor.fieldColorGrey),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmAction(
                        title: 'Reject Credit Note',
                        message:
                            'Reject CN-${note.id} of ${controller.formatCurrency(note.amount)}?',
                        confirmLabel: 'Reject',
                        confirmColor: Colors.red,
                        onConfirm: () => controller.rejectCreditNote(note.id),
                      ),
                      icon: Icon(Icons.close,
                          size: SizeConfig.iconSM, color: Colors.red),
                      label: Text('Reject',
                          style: TextStyle(
                              color: Colors.red, fontSize: SizeConfig.fontBody)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(SizeConfig.radiusSM)),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: SizeConfig.spacingSM),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmAction(
                        title: 'Approve Credit Note',
                        message:
                            'Approve CN-${note.id} of ${controller.formatCurrency(note.amount)} for booking #${note.bookingId}?',
                        confirmLabel: 'Approve',
                        confirmColor: Colors.green,
                        onConfirm: () => controller.approveCreditNote(note.id),
                      ),
                      icon: Icon(Icons.check,
                          size: SizeConfig.iconSM, color: AppColor.buttonTextWhite),
                      label: Text('Approve',
                          style: TextStyle(
                              color: AppColor.buttonTextWhite, fontSize: SizeConfig.fontBody)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(SizeConfig.radiusSM)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusBadge(String status, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.spacingSM, vertical: SizeConfig.spacingXS),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
            color: color,
            fontSize: SizeConfig.fontCaption,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildScrollableTable() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.pagePadding.left, vertical: 4),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.divColor),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColor.fieldColorGrey),
            headingTextStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: SizeConfig.fontBodySmall,
              color: AppColor.cPrimaryHeadingColor,
            ),
            dataTextStyle: TextStyle(fontSize: SizeConfig.fontBodySmall),
            columnSpacing: SizeConfig.spacingMD,
            horizontalMargin: SizeConfig.spacingMD,
            columns: const [
              DataColumn(label: Text('Note ID')),
              DataColumn(label: Text('Booking')),
              DataColumn(label: Text('Client / Patient')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Amount')),
              DataColumn(label: Text('Reason')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: controller.filteredCreditNotes
                .map((note) => _buildRow(note))
                .toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(CreditNoteModel note) {
    final statusColor = _statusColor(note.status);
    final typeColor = _typeColor(note.creditType);
    return DataRow(cells: [
      DataCell(Text(
        'CN-${note.id}',
        style: TextStyle(
            fontWeight: FontWeight.w500, fontSize: SizeConfig.fontBodySmall),
      )),
      DataCell(
          Text('#${note.bookingId}', style: AppTextStyles.regular14black)),
      DataCell(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(note.clientName ?? '-',
              style: TextStyle(
                  fontWeight: FontWeight.w500, fontSize: SizeConfig.fontBodySmall)),
          Text(note.patientName ?? '-',
              style: TextStyle(
                  fontSize: SizeConfig.fontCaption, color: AppColor.fontColorGrey)),
        ],
      )),
      DataCell(Container(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.spacingSM, vertical: 3),
        decoration: BoxDecoration(
          color: typeColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: typeColor.withValues(alpha: 0.25)),
        ),
        child: Text(
          note.creditType,
          style: TextStyle(
              color: typeColor,
              fontSize: SizeConfig.fontCaption,
              fontWeight: FontWeight.w500),
        ),
      )),
      DataCell(Text(
        controller.formatCurrency(note.amount),
        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.teal),
      )),
      DataCell(SizedBox(
        width: 160,
        child: Tooltip(
          message: note.reason ?? '',
          child: Text(
            note.reason ?? '-',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: SizeConfig.fontBodySmall),
          ),
        ),
      )),
      DataCell(Text(
        _formatDateStr(note.creditDate ?? note.createdOn),
        style: TextStyle(fontSize: SizeConfig.fontBodySmall),
      )),
      DataCell(_statusBadge(note.status, statusColor)),
      DataCell(_buildActions(note)),
    ]);
  }

  Widget _buildActions(CreditNoteModel note) {
    if (note.status != 'Pending') {
      return Icon(Icons.check_circle_outline,
          size: SizeConfig.iconSM, color: AppColor.lightGrey);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'Approve',
          child: InkWell(
            onTap: () => _confirmAction(
              title: 'Approve Credit Note',
              message:
                  'Approve CN-${note.id} of ${controller.formatCurrency(note.amount)} for booking #${note.bookingId}?',
              confirmLabel: 'Approve',
              confirmColor: Colors.green,
              onConfirm: () => controller.approveCreditNote(note.id),
            ),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: EdgeInsets.all(SizeConfig.spacingSM),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.check, size: SizeConfig.iconSM, color: Colors.green),
            ),
          ),
        ),
        SizedBox(width: SizeConfig.spacingSM),
        Tooltip(
          message: 'Reject',
          child: InkWell(
            onTap: () => _confirmAction(
              title: 'Reject Credit Note',
              message:
                  'Reject CN-${note.id} of ${controller.formatCurrency(note.amount)}?',
              confirmLabel: 'Reject',
              confirmColor: Colors.red,
              onConfirm: () => controller.rejectCreditNote(note.id),
            ),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: EdgeInsets.all(SizeConfig.spacingSM),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.close, size: SizeConfig.iconSM, color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateStr(String? s) {
    if (s == null || s.isEmpty) return '-';
    try {
      final dt = DateTime.parse(s);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day.toString().padLeft(2, '0')}-${months[dt.month - 1]}-${dt.year}';
    } catch (_) {
      return s;
    }
  }

  void _confirmAction({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig.radiusMD)),
        title: Text(title,
            style: TextStyle(
                fontSize: SizeConfig.fontH3,
                fontWeight: FontWeight.w600,
                color: AppColor.cPrimaryHeadingColor)),
        content: Text(message, style: TextStyle(fontSize: SizeConfig.fontBody)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel',
                style: TextStyle(color: AppColor.fontColorGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SizeConfig.radiusSM)),
            ),
            child: Text(confirmLabel,
                style: TextStyle(color: AppColor.buttonTextWhite)),
          ),
        ],
      ),
    );
  }
}
