import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/shimmer_loader.dart';
import '../../controllers/credit_note_controller.dart';
import '../../models/credit_note_model.dart';
import '../accounts_format.dart';

class CreditNoteListView extends GetView<CreditNoteController> {
  const CreditNoteListView({super.key});

  Color _statusColor(String status) => accountsStatusColor(status);

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'service_adjustment':
        return Colors.teal;
      case 'billing_error':
        return Colors.red.shade700;
      case 'goodwill':
        return Colors.purple;
      case 'advance_credit':
        return Colors.blue;
      case 'cancellation':
        return Colors.orange;
      case 'hold':
        return Colors.blue;
      case 'overpayment':
        return Colors.teal;
      default:
        return AppColor.fontColorGrey;
    }
  }

  String _typeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'SERVICE_ADJUSTMENT':
        return 'Svc Adj';
      case 'BILLING_ERROR':
        return 'Bill Error';
      case 'GOODWILL':
        return 'Goodwill';
      case 'ADVANCE_CREDIT':
        return 'Advance';
      case 'CANCELLATION':
        return 'Cancellation';
      default:
        return type;
    }
  }

  void _openDetail(CreditNoteModel note) => Get.toNamed(
        Routes.CREDIT_NOTE_DETAIL,
        arguments: note,
        parameters: {'id': '${note.id}'},
      );

  void _openApply(CreditNoteModel note) => Get.toNamed(
        Routes.APPLY_CREDIT_NOTE,
        arguments: note,
        parameters: {'id': '${note.id}'},
      );

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    if (!Get.isRegistered<CreditNoteController>()) {
      Get.put(CreditNoteController());
    }
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        title: Text(
          'Credit Notes',
          style: TextStyle(
            fontSize: SizeConfig.fontH2,
            fontWeight: FontWeight.w600,
            color: AppColor.cPrimaryHeadingColor,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: SizeConfig.spacingMD),
            child: SizeConfig.isMobile
                ? IconButton(
                    onPressed: () =>
                        Get.toNamed(Routes.CREATE_CREDIT_NOTE),
                    icon: Icon(Icons.add,
                        color: AppColor.cPrimaryButtonColor,
                        size: SizeConfig.iconMD),
                    tooltip: 'New Credit Note',
                  )
                : ElevatedButton.icon(
                    onPressed: () =>
                        Get.toNamed(Routes.CREATE_CREDIT_NOTE),
                    icon: Icon(Icons.add, size: SizeConfig.iconSM, color: AppColor.buttonTextWhite),
                    label: Text('New Credit Note',
                        style: TextStyle(
                            color: AppColor.buttonTextWhite, fontSize: SizeConfig.fontBody)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.cPrimaryButtonColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(SizeConfig.radiusSM)),
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.spacingMD,
                          vertical: SizeConfig.spacingSM),
                    ),
                  ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColor.divColor),
        ),
      ),
      body: Column(
        children: [
          _buildToolbar(),
          _buildStatusFilters(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(SizeConfig.pagePadding.left,
          SizeConfig.spacingMD, SizeConfig.pagePadding.right, 0),
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
                onChanged: controller.searchCreditNotes,
                style: TextStyle(fontSize: SizeConfig.fontBody),
                decoration: InputDecoration(
                  hintText: 'Search by booking, client, type...',
                  hintStyle: TextStyle(
                      color: AppColor.fontColorGrey,
                      fontSize: SizeConfig.fontBody),
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
              onTap: () => controller.loadCreditNotes(),
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
    // getCreditNotes filters on edx_credit_notes.status.
    final filters = ['All', 'Pending', 'Approved', 'Rejected'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.pagePadding.left, vertical: SizeConfig.spacingSM),
      child: Row(
        children: filters.map((f) {
          return _FilterChipItem(
            label: f,
            filterList: filters,
            controller: controller,
            statusColorFn: _statusColor,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const ShimmerLoader.table();
      }
      final notes = controller.filteredCreditNotes;
      if (notes.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.note_alt_outlined,
                  size: 64, color: AppColor.lightGrey),
              SizedBox(height: SizeConfig.spacingSM),
              Text('No credit notes found', style: AppTextStyles.regular16Gre),
              SizedBox(height: SizeConfig.spacingXS),
              Text(
                'Create a credit note using the "New Credit Note" button above.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: SizeConfig.fontBody, color: AppColor.fontColorGrey),
              ),
            ],
          ),
        );
      }
      return SizeConfig.adaptiveLayout(
        mobile: _buildMobileCreditNoteList(notes),
        tablet: _buildScrollableTable(notes),
        desktop: _buildScrollableTable(notes),
      );
    });
  }

  Widget _buildMobileCreditNoteList(List notes) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.pagePadding.left, vertical: SizeConfig.spacingXS),
      itemCount: notes.length,
      itemBuilder: (_, i) {
        final note = notes[i];
        if (note is CreditNoteModel) {
          return _buildMobileCreditNoteCard(note);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMobileCreditNoteCard(CreditNoteModel note) {
    final statusColor = _statusColor(note.displayStatus);
    final typeColor = _typeColor(note.creditType);
    final double amount = note.amount;
    final double remaining = note.available;
    final double progress = amount > 0
        ? ((amount - remaining) / amount).clamp(0.0, 1.0)
        : 0.0;

    return InkWell(
      onTap: () => _openDetail(note),
      borderRadius: BorderRadius.circular(SizeConfig.radiusMD),
      child: Container(
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
                Text('CN-${note.id}',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: SizeConfig.fontBody,
                        color: AppColor.cPrimaryButtonColor)),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.spacingSM,
                      vertical: SizeConfig.spacingXS),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(humanizeStatus(note.displayStatus),
                      style: TextStyle(
                          color: statusColor,
                          fontSize: SizeConfig.fontCaption,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            Divider(height: SizeConfig.spacingLG, color: AppColor.divColor),

            // Row 2: Type chip + Booking # + Date
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.spacingSM, vertical: 3),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: typeColor.withValues(alpha: 0.25)),
                  ),
                  child: Text(_typeLabel(note.creditType),
                      style: TextStyle(
                          color: typeColor,
                          fontSize: SizeConfig.fontCaption,
                          fontWeight: FontWeight.w500)),
                ),
                SizedBox(width: SizeConfig.spacingXS),
                Flexible(
                  child: Text(
                      '#${note.bookingId}${note.clientName != null ? ' · ${note.clientName}' : ''}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: SizeConfig.fontBodySmall,
                          color: AppColor.fontColorGrey)),
                ),
                const Spacer(),
                Text(_formatDateStr(note.creditDate),
                    style: TextStyle(
                        fontSize: SizeConfig.fontCaption,
                        color: AppColor.fontColorGrey)),
              ],
            ),
            SizedBox(height: SizeConfig.spacingSM),

            // Row 3: Amount
            Text(
              _formatCurrency(amount),
              style: TextStyle(
                  fontSize: SizeConfig.fontH3,
                  fontWeight: FontWeight.w700,
                  color: Colors.teal),
            ),
            SizedBox(height: SizeConfig.spacingSM),

            // Row 4: Remaining label + Progress bar
            Text(
              'Remaining: ${_formatCurrency(remaining)} / ${_formatCurrency(amount)}',
              style: TextStyle(
                  fontSize: SizeConfig.fontBodySmall,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(height: SizeConfig.spacingXS),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColor.divColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0 ? Colors.blue : Colors.green,
                ),
              ),
            ),

            if (note.status == 'Pending') ...[
              SizedBox(height: SizeConfig.spacingMD),
              _approvalButtons(note),
            ],

            // Bottom: Apply button if applicable
            if (note.canApply) ...[
              SizedBox(height: SizeConfig.spacingMD),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () => _openApply(note),
                  icon: Icon(Icons.check_circle_outline,
                      size: SizeConfig.iconSM, color: AppColor.buttonTextWhite),
                  label: Text('Apply Credit Note',
                      style: TextStyle(
                          color: AppColor.buttonTextWhite,
                          fontSize: SizeConfig.fontBody,
                          fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(SizeConfig.radiusSM)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableTable(List notes) {
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
        child: horizontalTable(DataTable(
            headingRowColor: WidgetStateProperty.all(AppColor.cAppBackgroundColor),
            headingTextStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: SizeConfig.fontBodySmall,
              color: AppColor.cPrimaryHeadingColor,
            ),
            dataTextStyle: TextStyle(fontSize: SizeConfig.fontBodySmall),
            columnSpacing: SizeConfig.spacingMD,
            horizontalMargin: SizeConfig.spacingMD,
            columns: const [
              DataColumn(label: Text('Credit Note #')),
              DataColumn(label: Text('Client / Booking')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Amount')),
              DataColumn(label: Text('Remaining')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Actions')),
            ],
            rows: notes.map((note) {
              if (note is CreditNoteModel) {
                return _buildRow(note);
              }
              return const DataRow(cells: [
                DataCell(Text('-')), DataCell(Text('-')), DataCell(Text('-')),
                DataCell(Text('-')), DataCell(Text('-')), DataCell(Text('-')),
                DataCell(Text('-')), DataCell(Text('-')),
              ]);
            }).toList(),
        )),
      ),
    );
  }

  DataRow _buildRow(CreditNoteModel note) {
    final statusColor = _statusColor(note.displayStatus);
    final typeColor = _typeColor(note.creditType);
    final double amount = note.amount;
    final double remaining = note.available;
    final double used = amount - remaining;
    final double progress = amount > 0 ? (used / amount).clamp(0.0, 1.0) : 0.0;

    return DataRow(
      onSelectChanged: (_) => _openDetail(note),
      cells: [
        DataCell(Text(
          'CN-${note.id}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: SizeConfig.fontBodySmall,
            color: AppColor.cPrimaryButtonColor,
          ),
        )),
        DataCell(Text(
            note.clientName != null
                ? '${note.clientName} · #${note.bookingId}'
                : '#${note.bookingId}',
            style: TextStyle(fontSize: SizeConfig.fontBodySmall))),
        DataCell(Container(
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.spacingSM, vertical: 3),
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: typeColor.withValues(alpha: 0.25)),
          ),
          child: Text(_typeLabel(note.creditType),
              style: TextStyle(
                  color: typeColor,
                  fontSize: SizeConfig.fontCaption,
                  fontWeight: FontWeight.w500)),
        )),
        DataCell(Text(_formatCurrency(amount),
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.teal))),
        DataCell(SizedBox(
          width: 130,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_formatCurrency(remaining)} / ${_formatCurrency(amount)}',
                style: TextStyle(
                    fontSize: SizeConfig.fontBodySmall,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(height: SizeConfig.spacingXS),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: AppColor.divColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0 ? Colors.blue : Colors.green,
                  ),
                ),
              ),
            ],
          ),
        )),
        DataCell(Container(
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.spacingSM, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(humanizeStatus(note.displayStatus),
              style: TextStyle(
                  color: statusColor,
                  fontSize: SizeConfig.fontCaption,
                  fontWeight: FontWeight.w500)),
        )),
        DataCell(Text(_formatDateStr(note.creditDate ?? note.createdOn),
            style: TextStyle(
                fontSize: SizeConfig.fontBodySmall,
                color: AppColor.fontColorGrey))),
        DataCell(_buildActions(note)),
      ],
    );
  }

  Widget _buildActions(CreditNoteModel note) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'View Details',
          child: InkWell(
            onTap: () => _openDetail(note),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: EdgeInsets.all(SizeConfig.spacingSM),
              decoration: BoxDecoration(
                color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.visibility_outlined,
                  size: SizeConfig.iconSM, color: AppColor.cPrimaryButtonColor),
            ),
          ),
        ),
        if (note.status == 'Pending') ...[
          SizedBox(width: SizeConfig.spacingXS),
          _approvalButtons(note, compact: true),
        ],
        if (note.canApply) ...[
          SizedBox(width: SizeConfig.spacingXS),
          Tooltip(
            message: 'Apply',
            child: InkWell(
              onTap: () => _openApply(note),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.spacingSM,
                    vertical: SizeConfig.spacingXS),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border:
                      Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Text('Apply',
                    style: TextStyle(
                        fontSize: SizeConfig.fontBodySmall,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Approve / Reject buttons for a Pending credit note
  /// (PATCH /updateCreditNoteStatus).
  Widget _approvalButtons(CreditNoteModel note, {bool compact = false}) {
    return Obx(() {
      final busy = controller.isSubmitting.value;
      Widget btn(String label, Color color, String action) => compact
          ? Tooltip(
              message: label,
              child: InkWell(
                onTap: busy ? null : () => controller.confirmAndUpdateStatus(note, action),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.spacingSM,
                      vertical: SizeConfig.spacingXS),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Text(label,
                      style: TextStyle(
                          fontSize: SizeConfig.fontBodySmall,
                          fontWeight: FontWeight.w600,
                          color: color)),
                ),
              ),
            )
          : Expanded(
              child: OutlinedButton(
                onPressed: busy ? null : () => controller.confirmAndUpdateStatus(note, action),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color.withValues(alpha: 0.5)),
                ),
                child: Text(label),
              ),
            );
      return Row(
        mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
        children: [
          btn('Approve', Colors.green.shade700, 'Approved'),
          SizedBox(width: SizeConfig.spacingXS),
          btn('Reject', Colors.red.shade700, 'Rejected'),
        ],
      );
    });
  }

  String _formatCurrency(double amount) => formatInr(amount);

  String _formatDateStr(String? s) => formatAccDate(s, pattern: 'dd-MMM-yyyy');
}

class _FilterChipItem extends StatefulWidget {
  final String label;
  final List<String> filterList;
  final CreditNoteController controller;
  final Color Function(String) statusColorFn;

  const _FilterChipItem({
    required this.label,
    required this.filterList,
    required this.controller,
    required this.statusColorFn,
  });

  @override
  State<_FilterChipItem> createState() => _FilterChipItemState();
}

class _FilterChipItemState extends State<_FilterChipItem> {
  RxString get _selected => widget.controller.statusFilter;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = _selected.value == widget.label;
      return Padding(
        padding: EdgeInsets.only(right: SizeConfig.spacingSM),
        child: FilterChip(
          label: Text(widget.label),
          selected: isSelected,
          onSelected: (_) {
            _selected.value = widget.label;
            widget.controller.loadCreditNotes();
          },
          backgroundColor: AppColor.whiteColor,
          selectedColor: AppColor.cPrimaryButtonColor.withValues(alpha: 0.1),
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
    });
  }
}
