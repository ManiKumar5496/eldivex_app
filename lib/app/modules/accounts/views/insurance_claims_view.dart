import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../../widgets/common_textfield.dart';
import '../../../widgets/shimmer_loader.dart';
import '../controllers/accounts_controller.dart';
import '../models/insurance_claim_model.dart';
import 'accounts_format.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class InsuranceClaimsView extends GetView<AccountsController> {
  const InsuranceClaimsView({super.key});

  Color _statusColor(String status) => accountsStatusColor(status);


  List<String> _nextStatuses(String current) {
    switch (current.toLowerCase()) {
      case 'pending':
        return ['Submitted', 'Rejected'];
      case 'submitted':
        return ['Approved', 'Rejected'];
      case 'approved':
        return ['Settled'];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    if (!Get.isRegistered<AccountsController>()) {
      Get.put(AccountsController());
    }
    return SizeConfig.adaptiveLayout(
      mobile: _buildMobileLayout(context),
      tablet: _buildDesktopLayout(context),
      desktop: _buildDesktopLayout(context),
    );
  }

  Widget _pageHeader(BuildContext context) {
    if (accountsIsEmbeddedInTabs(context)) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: SizeConfig.isMobile ? 16 : 20),
      child: const AppPageHeader(
        title: 'Insurance claims',
        subtitle: 'Track TPA / insurance claims linked to bookings',
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showClaimFormSheet(context),
        icon: const Icon(LucideIcons.plus),
        label: const Text('New claim',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: accountsPagePadding(context, bottom: false),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _pageHeader(context),
            _buildToolbar(),
            _buildStatusFilter(),
            Expanded(child: _buildMobileClaimList()),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Padding(
        padding: accountsPagePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _pageHeader(context),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: AppCard(
                      expandChild: true,
                      padding: EdgeInsets.zero,
                      title: 'Claims',
                      actions: [
                        _searchField(width: 260),
                        _refreshButton(),
                      ],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildStatusFilter(),
                          Divider(height: 1, color: AppColor.borderSubtle),
                          Expanded(child: _buildDesktopClaimList()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _buildForm()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClaimFormSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.whiteColor,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.xl))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.6,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: AppColor.divColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Row(
                children: [
                  const AppIconTile(
                      icon: LucideIcons.heartPulse,
                      tone: AppTone.info,
                      size: 38),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('New insurance claim',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                                color: AppColor.textPrimary)),
                        const SizedBox(height: 2),
                        Text('Link a TPA/insurance claim to an active booking',
                            style: TextStyle(
                                fontSize: 13, color: AppColor.textTertiary)),
                      ],
                    ),
                  ),
                  IconButton(
                      tooltip: 'Close',
                      icon: Icon(LucideIcons.x,
                          size: 20, color: AppColor.textTertiary),
                      onPressed: () => Navigator.pop(ctx)),
                ],
              ),
            ),
            Divider(height: 1, color: AppColor.borderSubtle),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: _buildFormContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSearch(String q) {
    final lq = q.toLowerCase();
    if (q.isEmpty) {
      controller.filteredClaims.value =
          List.from(controller.claims);
    } else {
      controller.filteredClaims.value =
          controller.claims.where((c) {
        return (c.clientName ?? '').toLowerCase().contains(lq) ||
            (c.clientMobile ?? '').contains(q) ||
            (c.patientName ?? '').toLowerCase().contains(lq) ||
            c.bookingId.toString().contains(q) ||
            (c.tpaName ?? '').toLowerCase().contains(lq) ||
            (c.policyNumber ?? '').contains(q);
      }).toList();
    }
  }

  Widget _searchField({double? width}) {
    return AppSearchField(
      onChanged: _onSearch,
      hint: 'Search by client, TPA, policy number…',
      width: width,
    );
  }

  Widget _refreshButton() {
    return accountsToolbarIconButton(
      icon: LucideIcons.refreshCw,
      tooltip: 'Refresh',
      onPressed: () => controller.fetchInsuranceClaims(),
    );
  }

  /// Mobile toolbar: search + refresh.
  Widget _buildToolbar() {
    return Row(
      children: [
        Expanded(child: _searchField()),
        const SizedBox(width: 8),
        _refreshButton(),
      ],
    );
  }

  Widget _buildStatusFilter() {
    final statuses = [
      'All', 'Pending', 'Submitted', 'Approved', 'Settled', 'Rejected'
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: SizeConfig.isMobile
          ? const EdgeInsets.symmetric(vertical: 12)
          : const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: statuses.map((s) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(s),
              selected: false,
              onSelected: (_) {
                if (s == 'All') {
                  controller.filteredClaims.value =
                      List.from(controller.claims);
                } else {
                  controller.filteredClaims.value =
                      controller.claims.where((c) => c.status == s).toList();
                }
              },
              labelStyle:
                  TextStyle(fontSize: 13, color: AppColor.textSecondary),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileClaimList() {
    return Obx(() {
      if (controller.isLoadingClaims.value) {
        return const ShimmerLoader.table();
      }
      if (controller.filteredClaims.isEmpty) {
        return const AppEmptyState(
          icon: LucideIcons.heartPulse,
          title: 'No insurance claims found',
          message: 'Tap the button below to add a new insurance claim.',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 88),
        itemCount: controller.filteredClaims.length,
        itemBuilder: (_, i) =>
            _buildMobileClaimCard(controller.filteredClaims[i]),
      );
    });
  }

  Widget _labelValue(String label, Widget value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 12, color: AppColor.textTertiary)),
        const SizedBox(height: 2),
        value,
      ],
    );
  }

  Widget _buildMobileClaimCard(InsuranceClaimModel claim) {
    final nextList = _nextStatuses(claim.status);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Booking # + Status chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Booking #${claim.bookingId}',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColor.cPrimaryButtonColor)),
                accountsStatusChip(claim.status),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColor.borderSubtle),
            ),

            // Row 2: Client / Patient
            accountsCellStack(claim.clientName ?? '-',
                subtitle: claim.patientName ?? '-'),
            const SizedBox(height: 12),

            // Row 3: TPA + Policy #
            Row(
              children: [
                Expanded(
                  child: _labelValue(
                    'TPA',
                    Text(claim.tpaName ?? '-',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColor.textPrimary),
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _labelValue(
                    'Policy #',
                    Text(claim.policyNumber ?? '-',
                        style: TextStyle(
                            fontSize: 14, color: AppColor.textPrimary),
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 4: Claim Amount + Settled Amount
            Row(
              children: [
                Expanded(
                  child: _labelValue(
                    'Claim Amount',
                    Text(
                      claim.claimAmount != null
                          ? controller.formatCurrency(claim.claimAmount!)
                          : '-',
                      style: accountsAmountStyle(
                          fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                Expanded(
                  child: _labelValue(
                    'Settled',
                    Text(
                      claim.settledAmount != null
                          ? controller.formatCurrency(claim.settledAmount!)
                          : '-',
                      style: accountsAmountStyle(
                          fontSize: 14,
                          color: claim.settledAmount != null
                              ? AppColor.success
                              : AppColor.textTertiary),
                    ),
                  ),
                ),
              ],
            ),

            // Bottom: Status action button
            if (nextList.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _showStatusActionsSheet(claim, nextList),
                  icon: const Icon(LucideIcons.refreshCw, size: 18),
                  label: const Text('Update status'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showStatusActionsSheet(
      InsuranceClaimModel claim, List<String> nextList) {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: AppColor.whiteColor,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.xl))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: AppColor.divColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text('Update claim status',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary)),
          ),
          Divider(height: 1, color: AppColor.borderSubtle),
          const SizedBox(height: 4),
          ...nextList.map((s) => ListTile(
                leading: Icon(_statusIcon(s),
                    color: _statusColor(s), size: 20),
                title: Text(s,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(s))),
                minLeadingWidth: 28,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                onTap: () {
                  Navigator.pop(ctx);
                  if (s == 'Settled') {
                    _showSettleDialog(claim);
                  } else {
                    _confirmStatusUpdate(claim, s);
                  }
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDesktopClaimList() {
    return Obx(() {
      if (controller.isLoadingClaims.value) {
        return const ShimmerLoader.table();
      }
      if (controller.filteredClaims.isEmpty) {
        return const AppEmptyState(
          icon: LucideIcons.heartPulse,
          title: 'No insurance claims found',
          message:
              'Use the form on the right to link a TPA/insurance claim to a booking.',
        );
      }
      return SingleChildScrollView(
        child: horizontalTable(
          DataTable(
            columns: const [
              DataColumn(label: Text('Booking')),
              DataColumn(label: Text('Client / Patient')),
              DataColumn(label: Text('TPA')),
              DataColumn(label: Text('Policy #')),
              DataColumn(label: Text('Claim Amt'), numeric: true),
              DataColumn(label: Text('Settled'), numeric: true),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Action')),
            ],
            rows: controller.filteredClaims
                .map((claim) => _buildRow(claim))
                .toList(),
          ),
        ),
      );
    });
  }

  DataRow _buildRow(InsuranceClaimModel claim) {
    final nextList = _nextStatuses(claim.status);
    return DataRow(cells: [
      DataCell(Text('#${claim.bookingId}',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColor.cPrimaryButtonColor))),
      DataCell(accountsCellStack(claim.clientName ?? '-',
          subtitle: claim.patientName ?? '-')),
      DataCell(Text(claim.tpaName ?? '-')),
      DataCell(Text(claim.policyNumber ?? '-',
          style: TextStyle(color: AppColor.textSecondary))),
      DataCell(Text(
        claim.claimAmount != null
            ? controller.formatCurrency(claim.claimAmount!)
            : '-',
        style: accountsAmountStyle(),
      )),
      DataCell(Text(
        claim.settledAmount != null
            ? controller.formatCurrency(claim.settledAmount!)
            : '-',
        style: accountsAmountStyle(
            fontWeight: FontWeight.w400,
            color: claim.settledAmount != null
                ? AppColor.success
                : AppColor.textTertiary),
      )),
      DataCell(accountsStatusChip(claim.status)),
      DataCell(nextList.isEmpty
          ? Icon(LucideIcons.lock,
              size: 18, color: AppColor.lightGrey)
          : _buildStatusActions(claim, nextList)),
    ]);
  }

  Widget _buildStatusActions(InsuranceClaimModel claim, List<String> nextList) {
    return PopupMenuButton<String>(
      tooltip: 'Update status',
      icon: Icon(LucideIcons.ellipsis,
          color: AppColor.textTertiary, size: 20),
      onSelected: (newStatus) {
        if (newStatus == 'Settled') {
          _showSettleDialog(claim);
        } else {
          _confirmStatusUpdate(claim, newStatus);
        }
      },
      itemBuilder: (_) => nextList.map((s) {
        return PopupMenuItem<String>(
          value: s,
          child: Row(
            children: [
              Icon(_statusIcon(s), size: 18, color: _statusColor(s)),
              const SizedBox(width: 10),
              Text(s),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return LucideIcons.fileUp;
      case 'approved':
        return LucideIcons.badgeCheck;
      case 'rejected':
        return LucideIcons.circleX;
      case 'settled':
        return LucideIcons.badgeIndianRupee;
      default:
        return LucideIcons.circle;
    }
  }

  Future<void> _confirmStatusUpdate(
      InsuranceClaimModel claim, String newStatus) async {
    final confirmed = await showAppConfirmDialog(
      title: 'Update Claim Status',
      message: 'Mark claim for booking #${claim.bookingId} as "$newStatus"?',
      confirmLabel: newStatus,
      tone: newStatus.toLowerCase() == 'rejected'
          ? AppTone.danger
          : AppTone.primary,
      icon: _statusIcon(newStatus),
    );
    if (confirmed) {
      controller.updateClaimStatus(claim.id, newStatus);
    }
  }

  void _showSettleDialog(InsuranceClaimModel claim) {
    final amtCtrl = TextEditingController(
        text: claim.claimAmount?.toStringAsFixed(2) ?? '');
    Get.dialog(AppDialog(
      title: 'Settle Insurance Claim',
      subtitle: 'Booking #${claim.bookingId} | ${claim.tpaName ?? ''}',
      icon: LucideIcons.badgeIndianRupee,
      tone: AppTone.success,
      maxWidth: 440,
      actions: [
        OutlinedButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(amtCtrl.text);
            Get.back();
            controller.updateClaimStatus(claim.id, 'Settled',
                settledAmount: amount);
          },
          child: const Text('Mark settled'),
        ),
      ],
      child: CommonTextField(
        label: 'Settled Amount',
        hint: 'Enter final settled amount',
        controller: amtCtrl,
        keyboardType: TextInputType.number,
        isMandatory: true,
      ),
    ));
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      child: AppCard(
        title: 'New insurance claim',
        subtitle: 'Link a TPA/insurance claim to an active booking',
        icon: LucideIcons.heartPulse,
        iconTone: AppTone.info,
        child: _buildFormContent(),
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Client selector
        Obx(() {
          final client = controller.selectedClientForClaim.value;
          if (client != null) {
            return Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColor.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColor.borderSubtle),
              ),
              child: Row(
                children: [
                  AppAvatar(name: client.clientName, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(client.clientName,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColor.textPrimary)),
                        const SizedBox(height: 2),
                        Text(
                            'Booking #${client.bookingId} | ${client.patientName} | ${client.serviceName}',
                            style: TextStyle(
                                fontSize: 12.5,
                                color: AppColor.textTertiary)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Clear selection',
                    icon: Icon(LucideIcons.x,
                        size: 18, color: AppColor.textTertiary),
                    onPressed: () =>
                        controller.selectedClientForClaim.value = null,
                  ),
                ],
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              accountsFieldLabel('Booking / Client', required: true),
              accountsDropdownShell(
                child: DropdownButton<int>(
                  icon: const Icon(LucideIcons.chevronDown, size: 18),
                  isExpanded: true,
                  hint: Text('Select active booking',
                      style: TextStyle(
                          color: AppColor.textTertiary, fontSize: 14)),
                  items: controller.activeClients.map((c) {
                    return DropdownMenuItem(
                      value: c.id,
                      child: Text('${c.clientName} — #${c.bookingId}',
                          style: TextStyle(
                              fontSize: 14, color: AppColor.textPrimary)),
                    );
                  }).toList(),
                  onChanged: (id) {
                    final c = controller.activeClients
                        .firstWhereOrNull((cl) => cl.id == id);
                    if (c != null) {
                      controller.selectedClientForClaim.value = c;
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        }),

        CommonTextField(
          label: 'TPA / Insurance Company Name',
          hint: 'e.g. Medi Assist, Vidal Health',
          controller: controller.claimTpaNameController,
          isMandatory: true,
        ),
        const SizedBox(height: 16),

        CommonTextField(
          label: 'Policy Number',
          hint: 'Enter policy number',
          controller: controller.claimPolicyNumberController,
        ),
        const SizedBox(height: 16),

        CommonTextField(
          label: 'Pre-Auth / Reference Number',
          hint: 'Enter pre-authorisation number (if any)',
          controller: controller.claimPreAuthController,
        ),
        const SizedBox(height: 16),

        CommonTextField(
          label: 'Claim Amount',
          hint: 'Enter claim amount (₹)',
          controller: controller.claimAmountController,
          keyboardType: TextInputType.number,
          isMandatory: true,
        ),
        const SizedBox(height: 16),

        CommonTextField(
          label: 'Remarks',
          hint: 'Additional notes or instructions',
          controller: controller.claimRemarksController,
          maxLines: 3,
        ),
        const SizedBox(height: 24),

        Obx(() => SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: controller.isLoadingClaims.value
                    ? null
                    : controller.createInsuranceClaim,
                child: controller.isLoadingClaims.value
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: AppColor.textTertiary, strokeWidth: 2),
                      )
                    : const Text('Submit insurance claim'),
              ),
            )),
      ],
    );
  }
}
