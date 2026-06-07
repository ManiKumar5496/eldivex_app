import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import '../controllers/audit_log_controller.dart';

class AuditLogView extends GetView<AuditLogController> {
  const AuditLogView({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildFilterBar(),
          Expanded(child: _buildBody()),
          _buildPagination(),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.spacingMD,
        vertical: SizeConfig.spacingMD,
      ),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        border: Border(
          bottom: BorderSide(color: AppColor.divColor.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.history, color: AppColor.cPrimaryButtonColor, size: SizeConfig.iconMD),
          SizedBox(width: SizeConfig.spacingSM),
          Text(
            'Audit Log',
            style: TextStyle(
              fontSize: SizeConfig.fontH2,
              fontWeight: FontWeight.w600,
              color: AppColor.cPrimaryHeadingColor,
            ),
          ),
          const Spacer(),
          Obx(() => Text(
            '${controller.totalCount.value} total records',
            style: TextStyle(
              fontSize: SizeConfig.fontCaption,
              color: AppColor.fontColorGrey,
            ),
          )),
          SizedBox(width: SizeConfig.spacingMD),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchAuditLog(reset: true),
            tooltip: 'Refresh',
            color: AppColor.fontColorGrey,
          ),
        ],
      ),
    );
  }

  // ── Filter bar ────────────────────────────────────────────────────────────

  Widget _buildFilterBar() {
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.spacingMD,
        vertical: SizeConfig.spacingSM,
      ),
      color: AppColor.whiteColor,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              'Filter: ',
              style: TextStyle(
                fontSize: SizeConfig.fontCaption,
                color: AppColor.fontColorGrey,
              ),
            ),
            SizedBox(width: SizeConfig.spacingXS),
            _FilterChip(
              label: 'All',
              selected: controller.filterEntityType.value.isEmpty,
              onTap: () => controller.applyEntityTypeFilter(null),
            ),
            SizedBox(width: SizeConfig.spacingXS),
            ...controller.entityTypes.map((t) => Padding(
              padding: EdgeInsets.only(right: SizeConfig.spacingXS),
              child: _FilterChip(
                label: t,
                selected: controller.filterEntityType.value == t,
                onTap: () => controller.applyEntityTypeFilter(t),
              ),
            )),
          ],
        ),
      ),
    ));
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return Obx(() {
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.entries.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history_toggle_off, size: 64, color: AppColor.lightGrey),
              SizedBox(height: SizeConfig.spacingMD),
              Text('No audit records found',
                style: TextStyle(color: AppColor.fontColorGrey, fontSize: SizeConfig.fontBody)),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        padding: SizeConfig.pagePadding,
        child: SizeConfig.isMobile
            ? Column(children: controller.entries.map(_buildCard).toList())
            : _buildTable(),
      );
    });
  }

  // ── Table (desktop/tablet) ────────────────────────────────────────────────

  Widget _buildTable() {
    const headerStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 13,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(160),  // Date
            1: FixedColumnWidth(130),  // Entity Type
            2: FixedColumnWidth(80),   // Entity ID
            3: FixedColumnWidth(120),  // Action
            4: FlexColumnWidth(),       // Changed By
            5: FlexColumnWidth(),       // Details
          },
          children: [
            // Header row
            TableRow(
              decoration: BoxDecoration(color: AppColor.cAppBackgroundColor),
              children: [
                _headerCell('Date', headerStyle),
                _headerCell('Entity', headerStyle),
                _headerCell('ID', headerStyle),
                _headerCell('Action', headerStyle),
                _headerCell('Changed By', headerStyle),
                _headerCell('Details', headerStyle),
              ],
            ),
            // Data rows
            ...controller.entries.asMap().entries.map((e) {
              final isEven = e.key.isEven;
              final entry  = e.value;
              return TableRow(
                decoration: BoxDecoration(
                  color: isEven ? AppColor.whiteColor : AppColor.cAppBackgroundColor.withValues(alpha: 0.5),
                ),
                children: [
                  _dataCell(_formatDate(entry.createdOn)),
                  _dataCell(entry.entityType),
                  _dataCell(entry.entityId?.toString() ?? '—'),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: _buildActionBadge(entry.action),
                    ),
                  ),
                  _dataCell(entry.changedByName ?? (entry.changedBy != null ? '#${entry.changedBy}' : 'System')),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: _buildChangesSummary(entry),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  TableCell _headerCell(String text, TextStyle style) => TableCell(
    verticalAlignment: TableCellVerticalAlignment.middle,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(text, style: style),
    ),
  );

  TableCell _dataCell(String text) => TableCell(
    verticalAlignment: TableCellVerticalAlignment.middle,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        style: TextStyle(fontSize: SizeConfig.fontCaption, color: AppColor.fontColorBlack),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    ),
  );

  // ── Card (mobile) ─────────────────────────────────────────────────────────

  Widget _buildCard(AuditLogEntry entry) {
    return Card(
      margin: EdgeInsets.only(bottom: SizeConfig.spacingSM),
      elevation: 0,
      color: AppColor.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColor.divColor.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${entry.entityType} #${entry.entityId ?? '—'}',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: SizeConfig.fontBody),
                ),
                _buildActionBadge(entry.action),
              ],
            ),
            SizedBox(height: SizeConfig.spacingXS),
            Text(
              _formatDate(entry.createdOn),
              style: TextStyle(color: AppColor.fontColorGrey, fontSize: SizeConfig.fontCaption),
            ),
            SizedBox(height: SizeConfig.spacingXS),
            Text(
              'By: ${entry.changedByName ?? (entry.changedBy != null ? '#${entry.changedBy}' : 'System')}',
              style: TextStyle(color: AppColor.fontColorGrey, fontSize: SizeConfig.fontCaption),
            ),
            if (entry.newValues != null) ...[
              SizedBox(height: SizeConfig.spacingXS),
              _buildChangesSummary(entry),
            ],
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildActionBadge(String action) {
    final color = controller.actionColor(action);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        action.replaceAll('_', ' '),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildChangesSummary(AuditLogEntry entry) {
    final parts = <String>[];
    if (entry.newValues != null) {
      entry.newValues!.forEach((k, v) {
        parts.add('$k: $v');
      });
    }
    if (parts.isEmpty) return const SizedBox.shrink();
    return Text(
      parts.take(3).join(' • '),
      style: TextStyle(
        fontSize: SizeConfig.fontCaption,
        color: AppColor.fontColorGrey,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}  '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  // ── Pagination ────────────────────────────────────────────────────────────

  Widget _buildPagination() {
    return Obx(() {
      final maxPage = (controller.totalCount.value / AuditLogController.pageSize).ceil();
      if (maxPage <= 1) return const SizedBox.shrink();

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.spacingMD,
          vertical: SizeConfig.spacingSM,
        ),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          border: Border(top: BorderSide(color: AppColor.divColor.withValues(alpha: 0.5))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: controller.currentPage.value > 1 ? controller.prevPage : null,
              color: AppColor.cPrimaryButtonColor,
            ),
            Text(
              'Page ${controller.currentPage.value} of $maxPage',
              style: TextStyle(fontSize: SizeConfig.fontCaption),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: controller.currentPage.value < maxPage ? controller.nextPage : null,
              color: AppColor.cPrimaryButtonColor,
            ),
          ],
        ),
      );
    });
  }
}

// ── Small helper widget ────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? AppColor.cPrimaryButtonColor
              : AppColor.cAppBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColor.cPrimaryButtonColor
                : AppColor.divColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? AppColor.buttonTextWhite : AppColor.fontColorGrey,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
