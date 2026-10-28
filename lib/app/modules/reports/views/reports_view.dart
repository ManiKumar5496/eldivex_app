import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import '../../../widgets/ui/ui.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../controllers/reports_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final pad = SizeConfig.isMobile ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildConfigCard(context),
            const SizedBox(height: 20),
            _buildPreviewCard(),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return AppPageHeader(
      title: 'Reports',
      subtitle: 'Preview operational reports and export them as CSV.',
      actions: [
        // ── Schedule weekly toggle ─────────────────────────────────────────
        Obx(() => Container(
          height: 40,
          padding: const EdgeInsets.only(left: 12, right: 4),
          decoration: BoxDecoration(
            color: AppColor.whiteColor,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColor.borderStrong),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.clock, size: 16, color: AppColor.textTertiary),
              const SizedBox(width: 6),
              Text(
                'Weekly email',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
              controller.scheduleLoading.value
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : Transform.scale(
                      scale: 0.85,
                      child: Switch(
                        value: controller.scheduleEnabled.value,
                        onChanged: controller.toggleSchedule,
                      ),
                    ),
            ],
          ),
        )),
      ],
    );
  }

  // ── Config card ───────────────────────────────────────────────────────────

  Widget _buildConfigCard(BuildContext context) {
    return AppCard(
      icon: LucideIcons.slidersHorizontal,
      title: 'Configure Report',
      subtitle: 'Pick a report, branch and date range, then generate a preview.',
      footer: Wrap(
        alignment: WrapAlignment.end,
        spacing: 8,
        runSpacing: 8,
        children: [
          // Download CSV
          Obx(() => OutlinedButton.icon(
            onPressed: controller.reportData.isEmpty || controller.downloading.value
                ? null
                : controller.downloadCsv,
            icon: controller.downloading.value
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(LucideIcons.download, size: 18),
            label: const Text('Download CSV'),
          )),

          // Generate (preview)
          Obx(() => ElevatedButton.icon(
            onPressed: controller.loading.value ? null : controller.fetchReport,
            icon: controller.loading.value
                ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColor.buttonTextWhite))
                : const Icon(LucideIcons.play, size: 18),
            label: const Text('Generate Preview'),
          )),
        ],
      ),
      // ── Filters (responsive grid) ──────────────────────────────────────
      child: AppResponsiveGrid(
        minItemWidth: 200,
        maxColumns: 4,
        children: _buildFilterWidgets(context),
      ),
    );
  }

  List<Widget> _buildFilterWidgets(BuildContext context) {
    return [
      // Report type selector
      Obx(() => _buildDropdownField<String>(
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
      )),

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

  Widget _fieldLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColor.textSecondary,
      ),
    ),
  );

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _fieldLabel(label),
        InputDecorator(
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          ),
          child: DropdownButton<T>(
            value: value,
            underline: const SizedBox.shrink(),
            isDense: true,
            isExpanded: true,
            borderRadius: BorderRadius.circular(AppRadius.md),
            icon: Icon(LucideIcons.chevronDown,
                size: 18, color: AppColor.textTertiary),
            style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
            items: items,
            onChanged: onChanged,
          ),
        ),
      ],
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
              colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: AppColor.cPrimaryButtonColor,
                onPrimary: AppColor.buttonTextWhite,
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
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _fieldLabel(label),
            InputDecorator(
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                suffixIcon: Icon(LucideIcons.calendar,
                    size: 16, color: AppColor.textTertiary),
                suffixIconConstraints:
                    const BoxConstraints(minWidth: 40, minHeight: 20),
              ),
              child: Text(
                value.isNotEmpty ? value : 'Select date',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: value.isNotEmpty ? AppColor.textPrimary : AppColor.textTertiary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Preview table ─────────────────────────────────────────────────────────

  /// Stat-tile values: 1,284 below ten thousand, compact (12.9K) above.
  static String _fmtCount(int n) => n >= 10000
      ? NumberFormat.compact().format(n)
      : NumberFormat('#,##0').format(n);

  Widget _buildPreviewCard() {
    return Obx(() {
      if (!controller.loading.value && controller.reportData.isEmpty) {
        return _buildMessageCard();
      }

      final previewCount =
          controller.reportData.length < 50 ? controller.reportData.length : 50;
      final total = controller.totalRows.value;
      final headers = controller.columnHeaders;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Summary KPIs ────────────────────────────────────────────────
          if (controller.reportData.isNotEmpty) ...[
            AppResponsiveGrid(
              minItemWidth: 200,
              maxColumns: 3,
              children: [
                AppStatCard(
                  label: 'Total records',
                  value: total > 0 ? _fmtCount(total) : '—',
                  icon: LucideIcons.table2,
                  caption: 'Matching the selected filters',
                ),
                AppStatCard(
                  label: 'Rows in preview',
                  value: _fmtCount(previewCount),
                  icon: LucideIcons.table,
                  caption: 'First $previewCount shown below',
                ),
                AppStatCard(
                  label: 'Columns',
                  value: _fmtCount(headers.length),
                  icon: LucideIcons.columns3,
                  caption: 'Fields per record',
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          AppCard(
            padding: EdgeInsets.zero,
            icon: LucideIcons.table,
            title: 'Preview (first $previewCount rows)',
            subtitle: total > 0 ? '$total total' : null,
            child: controller.loading.value
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : LayoutBuilder(builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minWidth: constraints.maxWidth),
                        child: _buildDataTable(),
                      ),
                    );
                  }),
          ),
        ],
      );
    });
  }

  /// A column is numeric when every non-empty preview value parses as a
  /// number; those cells are right-aligned with tabular figures.
  bool _isNumericColumn(String h, List<Map<String, dynamic>> rows) {
    var seen = false;
    for (final row in rows) {
      final v = row[h];
      if (v == null) continue;
      if (v is num) {
        seen = true;
        continue;
      }
      final s = v.toString().trim();
      if (s.isEmpty) continue;
      if (num.tryParse(s.replaceAll(',', '')) == null) return false;
      seen = true;
    }
    return seen;
  }

  Widget _buildDataTable() {
    final headers = controller.columnHeaders;
    if (headers.isEmpty) return const SizedBox.shrink();

    final rows = controller.reportData.take(50).toList();
    final numeric = {for (final h in headers) h: _isNumericColumn(h, rows)};

    return DataTable(
      dataRowMinHeight: 44,
      dataRowMaxHeight: 52,
      horizontalMargin: 20,
      columnSpacing: 32,
      columns: headers
          .map((h) => DataColumn(
                label: Text(humanizeLabel(h)),
                numeric: numeric[h] ?? false,
              ))
          .toList(),
      rows: rows.asMap().entries.map((e) {
        final row     = e.value;
        return DataRow(
          cells: headers
              .map((h) => DataCell(
                    Text(
                      '${row[h] ?? '—'}',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppColor.textPrimary,
                        fontFeatures: (numeric[h] ?? false)
                            ? const [FontFeature.tabularFigures()]
                            : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
        );
      }).toList(),
    );
  }

  /// Empty / error / plan-upgrade state shown instead of the preview table.
  Widget _buildMessageCard() {
    final err = controller.reportError.value;
    if (err.isEmpty) {
      return const AppCard(
        child: AppEmptyState(
          icon: LucideIcons.chartLine,
          title: 'No preview yet',
          message:
              'Choose a report and date range above, then select Generate Preview.',
          compact: true,
        ),
      );
    }
    final upgrade = controller.planBlocked.value;
    final tone = upgrade ? AppTone.warning : AppTone.neutral;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: upgrade ? tone.soft : AppColor.whiteColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: upgrade ? tone.color.withValues(alpha: 0.4) : AppColor.divColor,
        ),
      ),
      child: Row(
        children: [
          AppIconTile(
            icon: upgrade ? LucideIcons.award : LucideIcons.info,
            tone: tone,
            size: 36,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              err,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: AppColor.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
