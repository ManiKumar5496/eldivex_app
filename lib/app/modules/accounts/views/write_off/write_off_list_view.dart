import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/shimmer_loader.dart';
import '../../controllers/write_off_controller.dart';
import '../../models/write_off_model.dart';
import '../accounts_format.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class WriteOffListView extends StatefulWidget {
  const WriteOffListView({super.key});

  @override
  State<WriteOffListView> createState() => _WriteOffListViewState();
}

class _WriteOffListViewState extends State<WriteOffListView> {
  late final WriteOffController ctrl;
  String _statusFilter = 'All';
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  static const _statusOptions = ['All', 'Pending', 'Approved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<WriteOffController>();
    ctrl.loadWriteOffs();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<WriteOffModel> get _filtered {
    var list = ctrl.writeOffs.toList();
    if (_statusFilter != 'All') {
      list = list.where((w) => w.status == _statusFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list.where((w) {
        return w.clientName.toLowerCase().contains(_searchQuery) ||
            w.bookingId.toString().contains(_searchQuery) ||
            w.id.toString().contains(_searchQuery);
      }).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 24.0;
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppPageHeader(
              title: 'Write-offs',
              subtitle: 'Request and approve bad-debt and adjustment write-offs',
              actions: [
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed(Routes.CREATE_WRITE_OFF),
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text('New Write-off'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildKpis(),
            const SizedBox(height: 20),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFilterRow(),
                  Divider(height: 1, color: AppColor.borderSubtle),
                  _buildBody(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── KPI row (derived from the loaded list) ──────────────────────────────────

  Widget _buildKpis() {
    return Obx(() {
      final list = ctrl.writeOffs;
      final pending = list.where((w) => w.status == 'Pending').length;
      final approved = list
          .where((w) => w.status == 'Approved')
          .fold<double>(0, (s, w) => s + w.writeOffAmount);
      final requested = list.fold<double>(0, (s, w) => s + w.writeOffAmount);
      return AppResponsiveGrid(
        minItemWidth: 200,
        maxColumns: 4,
        children: [
          AppStatCard(
            label: 'Write-offs',
            value: '${list.length}',
            icon: LucideIcons.banknoteX,
          ),
          AppStatCard(
            label: 'Pending approval',
            value: '$pending',
            icon: LucideIcons.hourglass,
            tone: AppTone.warning,
          ),
          AppStatCard(
            label: 'Approved amount',
            value: formatInr(approved),
            icon: LucideIcons.circleCheckBig,
            tone: AppTone.success,
          ),
          AppStatCard(
            label: 'Total requested',
            value: formatInr(requested),
            icon: LucideIcons.wallet,
            tone: AppTone.danger,
          ),
        ],
      );
    });
  }

  // ── Toolbar: search + status filter ─────────────────────────────────────────

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 10,
        children: [
          // Search field
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: AppSearchField(
              controller: _searchCtrl,
              hint: 'Search by client, booking ID...',
            ),
          ),
          // Status filter
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _statusOptions.map((s) {
              final isSelected = _statusFilter == s;
              return FilterChip(
                label: Text(s),
                selected: isSelected,
                showCheckmark: false,
                onSelected: (_) => setState(() => _statusFilter = s),
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColor.cAppPrimaryColor
                      : AppColor.textSecondary,
                ),
                side: BorderSide(
                  color: isSelected
                      ? AppColor.cAppPrimaryColor.withValues(alpha: 0.45)
                      : AppColor.divColor,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (ctrl.isLoading.value) {
        return const SizedBox(height: 380, child: ShimmerLoader.table());
      }

      final rows = _filtered;

      if (rows.isEmpty) {
        return AppEmptyState(
          icon: LucideIcons.banknoteX,
          title: 'No write-offs found',
          message: _statusFilter != 'All' || _searchQuery.isNotEmpty
              ? 'Try a different search or status filter.'
              : null,
        );
      }

      return horizontalTable(DataTable(
        dataRowMinHeight: 52,
        dataRowMaxHeight: 60,
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Client')),
          DataColumn(label: Text('Booking')),
          DataColumn(label: Text('Amount'), numeric: true),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Actions')),
        ],
        rows: rows.map((wo) {
          return DataRow(cells: [
            DataCell(Text(
              '#${wo.id}',
              style: TextStyle(
                color: AppColor.cAppPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
            )),
            DataCell(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  wo.clientName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  wo.patientName,
                  style: TextStyle(fontSize: 12.5, color: AppColor.textTertiary),
                ),
              ],
            )),
            DataCell(Text('#${wo.bookingId}')),
            DataCell(Text(
              formatInr(wo.writeOffAmount),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            )),
            DataCell(_typeBadge(wo.writeOffType.isNotEmpty ? humanizeStatus(wo.writeOffType) : '—')),
            DataCell(AppStatusBadge.status(wo.status)),
            DataCell(Text(
              formatAccDate(wo.writeOffDate ?? wo.createdOn, pattern: 'dd-MMM-yyyy'),
              style: TextStyle(color: AppColor.textSecondary),
            )),
            DataCell(
              IconButton(
                tooltip: 'View',
                onPressed: () => Get.toNamed(
                  Routes.WRITE_OFF_DETAIL,
                  arguments: {'write_off_id': wo.id, 'write_off': wo},
                  parameters: {'id': '${wo.id}'},
                ),
                icon: const Icon(LucideIcons.eye, size: 18),
              ),
            ),
          ]);
        }).toList(),
      ));
    });
  }

  Widget _typeBadge(String type) {
    return AppStatusBadge(label: type, showDot: false, dense: true);
  }
}
