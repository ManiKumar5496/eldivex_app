import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import '../../../../widgets/shimmer_loader.dart';
import '../../controllers/write_off_controller.dart';
import '../../models/write_off_model.dart';

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

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}-'
        '${_monthAbbr(dt.month)}-${dt.year}';
  }

  String _monthAbbr(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        title: Text(
          'Write-offs',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColor.cPrimaryHeadingColor,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed('/create-write-off'),
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: const Text(
                'New Write-off',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterRow(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      color: AppColor.whiteColor,
      child: Row(
        children: [
          // Status dropdown
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.textFieldBorderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _statusFilter,
                items: const ['All', 'Pending', 'Approved', 'Rejected']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 14))))
                    .toList(),
                onChanged: (v) => setState(() => _statusFilter = v ?? 'All'),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Search field
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColor.textFieldBorderColor),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search by client, booking ID...',
                  hintStyle: TextStyle(color: AppColor.fontColorGrey, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: AppColor.fontColorGrey, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (ctrl.isLoading.value) {
        return const ShimmerLoader.table();
      }

      final rows = _filtered;

      if (rows.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.money_off_outlined, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text('No write-offs found', style: AppTextStyles.regular16Gre),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColor.whiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
            headingTextStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColor.cPrimaryHeadingColor,
            ),
            dataTextStyle: const TextStyle(fontSize: 13),
            columnSpacing: 16,
            horizontalMargin: 12,
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Client')),
              DataColumn(label: Text('Booking')),
              DataColumn(label: Text('Amount')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Actions')),
            ],
            rows: rows.map((wo) {
              final statusColor = _statusColor(wo.status);
              return DataRow(cells: [
                DataCell(Text(
                  '#${wo.id}',
                  style: TextStyle(
                    color: AppColor.cPrimaryButtonColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                )),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      wo.clientName,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                    Text(
                      wo.patientName,
                      style: TextStyle(fontSize: 11, color: AppColor.fontColorGrey),
                    ),
                  ],
                )),
                DataCell(Text('#${wo.bookingId}')),
                DataCell(Text(
                  _formatCurrency(wo.writeOffAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                )),
                DataCell(_typeBadge(wo.serviceName)),
                DataCell(_statusBadge(wo.status, statusColor)),
                DataCell(Text(_formatDate(wo.writeOffDate))),
                DataCell(
                  TextButton(
                    onPressed: () => Get.toNamed(
                      '/write-off-detail',
                      arguments: {'write_off_id': wo.id},
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColor.cPrimaryButtonColor,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    ),
                    child: const Text(
                      'View',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      );
    });
  }

  Widget _statusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _typeBadge(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 11,
          color: AppColor.cPrimarySubHeadingColorGrey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
