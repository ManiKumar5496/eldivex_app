import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import '../../../widgets/ui/ui.dart';
import '../controllers/audit_log_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

/// Below this card width the log switches from a table to a feed.
const double _kFeedBreakpoint = 760;

/// Minimum table width; narrower cards scroll horizontally.
const double _kTableMinWidth = 960;

class AuditLogView extends GetView<AuditLogController> {
  const AuditLogView({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final pad = SizeConfig.isMobile ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Padding(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            Expanded(
              child: AppCard(
                expandChild: true,
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildFilterBar(),
                    Divider(height: 1, color: AppColor.borderSubtle),
                    Expanded(child: _buildBody()),
                    _buildPagination(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return AppPageHeader(
      title: 'Audit Log',
      subtitle: 'Who changed what across your organisation, and when.',
      actions: [
        OutlinedButton.icon(
          icon: const Icon(LucideIcons.refreshCw, size: 18),
          onPressed: () => controller.fetchAuditLog(reset: true),
          label: const Text('Refresh'),
        ),
      ],
    );
  }

  // ── Filter bar ────────────────────────────────────────────────────────────

  Widget _buildFilterBar() {
    return Obx(() => Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Icon(LucideIcons.listFilter, size: 18, color: AppColor.textTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: controller.filterEntityType.value.isEmpty,
                    onTap: () => controller.applyEntityTypeFilter(null),
                  ),
                  const SizedBox(width: 6),
                  ...controller.entityTypes.map((t) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _FilterChip(
                      label: _entityLabel(t),
                      selected: controller.filterEntityType.value == t,
                      onTap: () => controller.applyEntityTypeFilter(t),
                    ),
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${controller.totalCount.value} total records',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColor.textTertiary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    ));
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return Obx(() {
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.loadError.value.isNotEmpty) {
        return AppEmptyState(
          icon: LucideIcons.circleAlert,
          tone: AppTone.danger,
          title: "Couldn't load the audit log",
          message: controller.loadError.value,
          actionLabel: 'Retry',
          actionIcon: LucideIcons.refreshCw,
          onAction: () => controller.fetchAuditLog(),
        );
      }
      if (controller.entries.isEmpty) {
        return const AppEmptyState(
          icon: LucideIcons.history,
          title: 'No audit records found',
          message: 'Changes made in the app will be recorded here.',
        );
      }

      final entries = controller.entries.toList();
      return LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < _kFeedBreakpoint) {
          return ListView.separated(
            itemCount: entries.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: AppColor.borderSubtle),
            itemBuilder: (_, i) => _buildCard(entries[i]),
          );
        }
        final width = constraints.maxWidth < _kTableMinWidth
            ? _kTableMinWidth
            : constraints.maxWidth;
        final table = SizedBox(
          width: width,
          height: constraints.maxHeight,
          child: _buildTable(entries),
        );
        if (width == constraints.maxWidth) return table;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: table,
        );
      });
    });
  }

  // ── Table (desktop/tablet) ────────────────────────────────────────────────

  Widget _buildTable(List<AuditLogEntry> entries) {
    final headerStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 12.5,
      color: AppColor.textTertiary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header row
        Container(
          color: AppColor.surfaceMuted,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text('Changed By', style: headerStyle)),
              SizedBox(width: 140, child: Text('Action', style: headerStyle)),
              SizedBox(width: 170, child: Text('Entity', style: headerStyle)),
              SizedBox(width: 80, child: Text('ID', style: headerStyle)),
              Expanded(flex: 4, child: Text('Details', style: headerStyle)),
              SizedBox(
                width: 150,
                child: Text('Date', style: headerStyle, textAlign: TextAlign.right),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: AppColor.borderSubtle),
        // Data rows
        Expanded(
          child: ListView.separated(
            itemCount: entries.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: AppColor.borderSubtle),
            itemBuilder: (_, i) {
              final entry = entries[i];
              return _HoverRow(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: _buildActor(entry)),
                      SizedBox(
                        width: 140,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildActionBadge(entry.action),
                        ),
                      ),
                      SizedBox(
                        width: 170,
                        child: _cellText(_entityLabel(entry.entityType),
                            color: AppColor.textPrimary),
                      ),
                      SizedBox(
                        width: 80,
                        child: _cellText(entry.entityId?.toString() ?? '—',
                            mono: true),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _buildChangesSummary(entry),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: _cellText(_formatDate(entry.createdOn),
                            align: TextAlign.right, mono: true),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _cellText(String text,
      {Color? color, TextAlign? align, bool mono = false}) {
    return Text(
      text,
      textAlign: align,
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
      style: TextStyle(
        fontSize: 13,
        color: color ?? AppColor.textSecondary,
        fontFeatures: mono ? const [FontFeature.tabularFigures()] : null,
      ),
    );
  }

  String _actorName(AuditLogEntry entry) =>
      entry.changedByName ??
      (entry.changedBy != null ? '#${entry.changedBy}' : 'System');

  Widget _buildActor(AuditLogEntry entry) {
    final name = _actorName(entry);
    final avatar = entry.changedByName != null
        ? AppAvatar(name: name, size: 28)
        : AppIconTile(
            icon: entry.changedBy != null
                ? LucideIcons.user
                : LucideIcons.settings2,
            tone: AppTone.neutral,
            size: 28,
          );
    return Row(
      children: [
        avatar,
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColor.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ── Card (mobile) ─────────────────────────────────────────────────────────

  Widget _buildCard(AuditLogEntry entry) {
    final name = _actorName(entry);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          entry.changedByName != null
              ? AppAvatar(name: name, size: 32)
              : AppIconTile(
                  icon: entry.changedBy != null
                      ? LucideIcons.user
                      : LucideIcons.settings2,
                  tone: AppTone.neutral,
                  size: 32,
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    _buildActionBadge(entry.action),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_entityLabel(entry.entityType)} #${entry.entityId ?? '—'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColor.textSecondary,
                  ),
                ),
                if (entry.newValues != null && entry.newValues!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _buildChangesSummary(entry),
                ],
                const SizedBox(height: 6),
                Text(
                  _formatDate(entry.createdOn),
                  style: TextStyle(
                    color: AppColor.textTertiary,
                    fontSize: 12,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Same action → colour mapping as [AuditLogController.actionColor], but
  /// through theme-aware tones so it reads in dark mode too.
  AppTone _toneForAction(String action) {
    switch (action) {
      case 'CREATE':        return AppTone.success;
      case 'UPDATE':        return AppTone.primary;
      case 'STATUS_CHANGE': return AppTone.warning;
      case 'DELETE':        return AppTone.danger;
      default:              return AppTone.neutral;
    }
  }

  Widget _buildActionBadge(String action) {
    return AppStatusBadge(
      label: humanizeLabel(action),
      tone: _toneForAction(action),
      dense: true,
    );
  }

  Widget _buildChangesSummary(AuditLogEntry entry) {
    final parts = <String>[];
    if (entry.newValues != null) {
      entry.newValues!.forEach((k, v) {
        parts.add('$k: $v');
      });
    }
    if (parts.isEmpty) {
      return Text('—',
          style: TextStyle(fontSize: 13, color: AppColor.textTertiary));
    }
    return Text(
      parts.take(3).join(' • '),
      style: TextStyle(
        fontSize: 12.5,
        height: 1.4,
        color: AppColor.textTertiary,
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
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColor.borderSubtle)),
        ),
        child: Row(
          children: [
            Text(
              'Page ${controller.currentPage.value} of $maxPage',
              style: TextStyle(fontSize: 13, color: AppColor.textSecondary),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Previous page',
              icon: const Icon(LucideIcons.chevronLeft, size: 20),
              onPressed: controller.currentPage.value > 1 ? controller.prevPage : null,
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Next page',
              icon: const Icon(LucideIcons.chevronRight, size: 20),
              onPressed: controller.currentPage.value < maxPage ? controller.nextPage : null,
            ),
          ],
        ),
      );
    });
  }
}

/// 'SUPPORT_TICKET' → 'Support Ticket', 'HP' stays 'HP'.
String _entityLabel(String raw) {
  return raw
      .split('_')
      .where((w) => w.isNotEmpty)
      .map((w) => w.length <= 2
          ? w.toUpperCase()
          : w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');
}

// ── Small helper widgets ───────────────────────────────────────────────────────

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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColor.primarySoft : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: selected
                  ? AppColor.cPrimaryButtonColor.withValues(alpha: 0.4)
                  : AppColor.borderSubtle,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              color: selected ? AppColor.cAppPrimaryColor : AppColor.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

/// Table row background that tints on mouse hover.
class _HoverRow extends StatefulWidget {
  const _HoverRow({required this.child});
  final Widget child;

  @override
  State<_HoverRow> createState() => _HoverRowState();
}

class _HoverRowState extends State<_HoverRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: ColoredBox(
        color: _hover ? AppColor.surfaceMuted : Colors.transparent,
        child: widget.child,
      ),
    );
  }
}
