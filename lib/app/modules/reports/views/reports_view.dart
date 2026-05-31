import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../controllers/reports_controller.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    // Pre-load schedule config on first render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadScheduleConfig();
    });

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: SizeConfig.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConfigCard(context),
                  SizedBox(height: SizeConfig.spacingLG),
                  _buildPreviewCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.spacingMD,
        vertical:   SizeConfig.spacingMD,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColor.divColor.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.bar_chart, color: AppColor.cPrimaryButtonColor, size: SizeConfig.iconMD),
          SizedBox(width: SizeConfig.spacingSM),
          Text(
            'Reports',
            style: TextStyle(
              fontSize: SizeConfig.fontH2,
              fontWeight: FontWeight.w600,
              color: AppColor.cPrimaryHeadingColor,
            ),
          ),
          const Spacer(),
          // ── Schedule weekly toggle ─────────────────────────────────────────
          Obx(() => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule, size: 16, color: AppColor.fontColorGrey),
              SizedBox(width: 4),
              Text(
                'Weekly email',
                style: TextStyle(fontSize: SizeConfig.fontCaption, color: AppColor.fontColorGrey),
              ),
              SizedBox(width: 6),
              controller.scheduleLoading.value
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : Switch(
                      value: controller.scheduleEnabled.value,
                      onChanged: controller.toggleSchedule,
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColor.cPrimaryButtonColor,
                    ),
            ],
          )),
        ],
      ),
    );
  }

  // ── Config card ───────────────────────────────────────────────────────────

  Widget _buildConfigCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SizeConfig.spacingLG),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configure Report',
            style: TextStyle(
              fontSize: SizeConfig.fontBodyLarge,
              fontWeight: FontWeight.w600,
              color: AppColor.cPrimaryHeadingColor,
            ),
          ),
          SizedBox(height: SizeConfig.spacingMD),

          // ── Filters row (responsive) ─────────────────────────────────────
          SizeConfig.isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildFilterWidgets(context),
                )
              : Wrap(
                  spacing: SizeConfig.spacingMD,
                  runSpacing: SizeConfig.spacingMD,
                  children: _buildFilterWidgets(context),
                ),

          SizedBox(height: SizeConfig.spacingLG),

          // ── Action buttons ───────────────────────────────────────────────
          Wrap(
            spacing: SizeConfig.spacingMD,
            runSpacing: SizeConfig.spacingSM,
            children: [
              // Generate (preview)
              Obx(() => SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: controller.loading.value ? null : controller.fetchReport,
                  icon: controller.loading.value
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.search, size: 18),
                  label: const Text('Generate Preview'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.cPrimaryButtonColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
              )),

              // Download CSV
              Obx(() => SizedBox(
                height: 40,
                child: OutlinedButton.icon(
                  onPressed: controller.reportData.isEmpty
                      ? null
                      : () => _downloadCsv(),
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Download CSV'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.cPrimaryButtonColor,
                    side: BorderSide(color: AppColor.cPrimaryButtonColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilterWidgets(BuildContext context) {
    return [
      // Report type selector
      _buildDropdownField<String>(
        label: 'Report Type',
        value: controller.reportType.value,
        items: ReportsController.reportTypes
            .map((t) => DropdownMenuItem<String>(
                  value: t['value'],
                  child: Text(t['label']!),
                ))
            .toList(),
        onChanged: (v) {
          if (v != null) controller.reportType.value = v;
        },
        width: 180,
      ),

      // Branch dropdown
      Obx(() {
        final dashCtrl = Get.find<DashboardController>();
        return _buildDropdownField<int?>(
          label: 'Branch',
          value: controller.reportBranchId.value,
          items: [
            const DropdownMenuItem<int?>(value: null, child: Text('All Branches')),
            ...dashCtrl.getAllBranches.map((b) => DropdownMenuItem<int?>(
                  value: b.brId,
                  child: Text(b.brName),
                )),
          ],
          onChanged: (v) => controller.reportBranchId.value = v,
          width: 200,
        );
      }),

      // From date
      Obx(() => _buildDatePickerField(
        context: context,
        label: 'From',
        value: controller.reportFrom.value,
        onPicked: (d) => controller.reportFrom.value = d,
      )),

      // To date
      Obx(() => _buildDatePickerField(
        context: context,
        label: 'To',
        value: controller.reportTo.value,
        onPicked: (d) => controller.reportTo.value = d,
      )),
    ];
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    double width = 160,
  }) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: SizeConfig.fontCaption, color: AppColor.fontColorGrey)),
          SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.divColor),
              borderRadius: BorderRadius.circular(8),
              color: AppColor.cAppBackgroundColor,
            ),
            child: DropdownButton<T>(
              value: value,
              underline: const SizedBox.shrink(),
              isDense: true,
              isExpanded: true,
              items: items,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField({
    required BuildContext context,
    required String label,
    required String value,
    required ValueChanged<String> onPicked,
  }) {
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        DateTime initial = now;
        if (value.isNotEmpty) {
          try { initial = DateTime.parse(value); } catch (_) {}
        }
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(2020),
          lastDate: now,
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColor.cPrimaryButtonColor,
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          onPicked('${picked.year}-'
              '${picked.month.toString().padLeft(2, '0')}-'
              '${picked.day.toString().padLeft(2, '0')}');
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: SizeConfig.fontCaption, color: AppColor.fontColorGrey)),
          SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.divColor),
              borderRadius: BorderRadius.circular(8),
              color: AppColor.cAppBackgroundColor,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value.isNotEmpty ? value : 'Select date',
                  style: TextStyle(
                    fontSize: SizeConfig.fontCaption,
                    color: value.isNotEmpty ? AppColor.fontColorBlack : AppColor.lightGrey,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.calendar_today_outlined, size: 14, color: AppColor.fontColorGrey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Preview table ─────────────────────────────────────────────────────────

  Widget _buildPreviewCard() {
    return Obx(() {
      if (!controller.loading.value && controller.reportData.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header
            Padding(
              padding: EdgeInsets.all(SizeConfig.spacingMD),
              child: Row(
                children: [
                  Text(
                    'Preview (first ${controller.reportData.length} rows)',
                    style: TextStyle(
                      fontSize: SizeConfig.fontBodyLarge,
                      fontWeight: FontWeight.w600,
                      color: AppColor.cPrimaryHeadingColor,
                    ),
                  ),
                  const Spacer(),
                  if (controller.totalRows.value > 0)
                    Text(
                      '${controller.totalRows.value} total',
                      style: TextStyle(
                          fontSize: SizeConfig.fontCaption, color: AppColor.fontColorGrey),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),

            if (controller.loading.value)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft:  Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _buildDataTable(),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildDataTable() {
    final headers = controller.columnHeaders;
    if (headers.isEmpty) return const SizedBox.shrink();

    return DataTable(
      headingRowColor: WidgetStateProperty.all(AppColor.cAppBackgroundColor),
      dataRowMinHeight: 40,
      dataRowMaxHeight: 52,
      headingTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: SizeConfig.fontCaption,
        color: AppColor.cPrimaryHeadingColor,
      ),
      columns: headers
          .map((h) => DataColumn(
                label: Text(h.replaceAll('_', ' ').toUpperCase()),
              ))
          .toList(),
      rows: controller.reportData.take(50).toList().asMap().entries.map((e) {
        final row     = e.value;
        final isEven  = e.key.isEven;
        return DataRow(
          color: WidgetStateProperty.all(
            isEven ? Colors.white : AppColor.cAppBackgroundColor.withValues(alpha: 0.5),
          ),
          cells: headers
              .map((h) => DataCell(
                    Text(
                      '${row[h] ?? '—'}',
                      style: TextStyle(
                          fontSize: SizeConfig.fontCaption,
                          color: AppColor.fontColorBlack),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
        );
      }).toList(),
    );
  }

  // ── CSV download ──────────────────────────────────────────────────────────

  void _downloadCsv() {
    final url = controller.csvDownloadUrl();
    final a   = web.document.createElement('a') as web.HTMLAnchorElement;
    a.href     = url;
    a.download = '${controller.reportType.value}_report.csv';
    a.click();
  }
}
