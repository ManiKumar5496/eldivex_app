import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/routes/app_pages.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../widgets/dropdown_common.dart';
import '../../../widgets/helper_ui.dart';
import '../../../widgets/ui/ui.dart';
import '../controllers/client_users_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class AddClientUserDetails extends StatefulWidget {
  const AddClientUserDetails({super.key});

  @override
  State<AddClientUserDetails> createState() => _AddClientUserDetailsState();
}

class _AddClientUserDetailsState extends State<AddClientUserDetails> {
  ClientUsersController get controller =>
      Get.isRegistered<ClientUsersController>()
          ? Get.find<ClientUsersController>()
          : Get.put(ClientUsersController());

  int userId = 0;
  bool isNewUser = true;

  @override
  void initState() {
    super.initState();
    // ── Arguments from addUserClient() / editClient():
    // {userId, isNewUser, phoneNumber, countryCode?, isEdit?}
    // Read once here (not in build) so typing is never overwritten.
    final raw = Get.arguments;
    final args = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    userId = int.tryParse(args['userId']?.toString() ?? '') ?? 0;
    final flag = args['isNewUser'];
    isNewUser = flag is bool ? flag : flag?.toString() != '0' && flag?.toString() != 'false';
    controller.openDetailsForm(args);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    if (userId == 0) {
      return Scaffold(
        backgroundColor: AppColor.cAppBackgroundColor,
        body: AppEmptyState(
          icon: LucideIcons.userX,
          title: 'No client selected',
          message: 'Open a client from the client list to edit their details.',
          actionLabel: 'Back',
          actionIcon: LucideIcons.arrowLeft,
          onAction: () => HelperUi.safeBack(Routes.MAIN),
        ),
      );
    }

    final isEdit = controller.isEditMode.value;

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SingleChildScrollView(
        padding: SizeConfig.pagePadding,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Back button + Title ──────────────────────────
                AppPageHeader(
                  title: isEdit ? 'Edit Client Details' : 'Add Client Details',
                  subtitle: 'Contact details and lead information for this client',
                  breadcrumbs: ['Clients', isEdit ? 'Edit Client' : 'Add Client'],
                  onBack: () => HelperUi.safeBack(Routes.MAIN),
                ),
                const SizedBox(height: 24),

                // ── Loading indicator while fetching user details ─
                Obx(() => controller.isFetchingUserDetails.value
                    ? const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: LinearProgressIndicator(minHeight: 2),
                      )
                    : const SizedBox.shrink()),

                AppCard(
                  title: 'User Details',
                  subtitle: 'Who the client is and how to reach them',
                  icon: LucideIcons.user,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Full Name ────────────────────────────────
                      _field(
                        _buildLabel('Full Name',
                            hint: 'e.g. Irfan Ahmed', required: true),
                        _buildTextField(
                          ctrl: controller.fullNameController,
                          hint: 'Enter full name',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Phone + Email ────────────────────────────
                      _twoColumns(
                        _field(
                          _buildLabel('Phone Number', required: true),
                          _buildPhoneField(),
                        ),
                        _field(
                          _buildLabel('Email', hint: 'optional, single address'),
                          _buildTextField(
                            ctrl: controller.clientEmailController,
                            hint: 'Enter email address',
                            inputType: TextInputType.emailAddress,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                AppCard(
                  title: 'Lead Details',
                  subtitle: 'Where the enquiry came from and what it is for',
                  icon: LucideIcons.clipboardList,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Service City + Lead Source ───────────────
                      _twoColumns(
                        _field(
                          _buildLabel('Service City', required: true),
                          _buildBranchDropdown(),
                        ),
                        _field(
                          _buildLabel('Lead Source', required: true),
                          _buildDropdown(
                            obs: controller.selectedLeadSource,
                            items: controller.leadSourceList,
                            hint: 'Select lead source',
                            onChanged: (v) =>
                                controller.selectedLeadSource.value = v ?? '',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Lead Type + Enquired For ─────────────────
                      _twoColumns(
                        _field(
                          _buildLabel('Lead Type', required: true),
                          _buildDropdown(
                            obs: controller.selectedLeadType,
                            items: controller.leadTypeList,
                            hint: 'Select lead type',
                            onChanged: (v) =>
                                controller.selectedLeadType.value = v ?? '',
                            clearable: true,
                          ),
                        ),
                        _field(
                          _buildLabel('Enquired For', required: true),
                          _buildCategoryDropdown(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Internal Remarks ─────────────────────────
                      _field(
                        _buildLabel('Internal Remarks'),
                        _buildTextField(
                          ctrl: controller.internalRemarksController,
                          hint: 'Enter internal remarks...',
                          maxLines: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Actions ──────────────────────────────────────
                // userId and isNewUser read from args above and forwarded here
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () => HelperUi.safeBack(Routes.MAIN),
                      child: const Text('Cancel'),
                    ),
                    Obx(
                      () => ElevatedButton(
                        onPressed: controller.clientDetailsUpdateLoading.value
                            ? null
                            : () =>
                                controller.validateAndNext(userId, isNewUser),
                        child: controller.clientDetailsUpdateLoading.value
                            ? SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColor.textTertiary),
                              )
                            : const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Next'),
                                  SizedBox(width: 6),
                                  Icon(LucideIcons.arrowRight, size: 18),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── WIDGET HELPERS ───────────────────────────────────────────────

  /// Label above its input.
  Widget _field(Widget label, Widget input) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [label, const SizedBox(height: 8), input],
    );
  }

  /// Two fields side by side on wide cards, stacked on narrow ones.
  Widget _twoColumns(Widget left, Widget right) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 640) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [left, const SizedBox(height: 16), right],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          const SizedBox(width: 16),
          Expanded(child: right),
        ],
      );
    });
  }

  Widget _buildLabel(String label, {String? hint, bool required = false}) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
          text: label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColor.textSecondary,
          ),
        ),
        if (required)
          TextSpan(
            text: ' *',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColor.danger,
            ),
          ),
        if (hint != null)
          TextSpan(
            text: '  ($hint)',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColor.textTertiary,
            ),
          ),
      ]),
    );
  }

  Widget _buildTextField({
    required TextEditingController ctrl,
    String? hint,
    int maxLines = 1,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: inputType,
      style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
      decoration: InputDecoration(hintText: hint),
    );
  }

  /// Country code picker inside the phone input, so both share one border
  /// and focus ring.
  Widget _buildPhoneField() {
    return TextFormField(
      controller: controller.clientPhoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(15),
      ],
      style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
      decoration: InputDecoration(
        hintText: 'e.g. 9876543210',
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        prefixIcon: Container(
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.only(left: 12, right: 4),
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: AppColor.borderSubtle)),
          ),
          child: Obx(() => DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.detailsCountryCode.value,
                  isDense: true,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  dropdownColor: AppColor.whiteColor,
                  icon: Icon(LucideIcons.chevronDown,
                      size: 18, color: AppColor.textTertiary),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textPrimary),
                  items: ClientUsersController.countryCodes
                      .map((cc) => DropdownMenuItem<String>(
                            value: cc['code'],
                            child: Text('${cc['flag']} ${cc['code']}',
                                style: const TextStyle(fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) controller.detailsCountryCode.value = v;
                  },
                ),
              )),
        ),
      ),
    );
  }

  Widget _buildBranchDropdown() {
    return Obx(() {
      if (controller.dashboardController.getAllBranchesLoading.value) {
        return Container(
          height: 48,
          alignment: Alignment.center,
          child: const SizedBox(
            height: 20, width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      }
      final branches = controller.dashboardController.getAllBranches;
      final currentValue = controller.selectedServiceCityId.value;
      // Only use the value if it matches an item in the list
      final hasMatch = currentValue.isNotEmpty &&
          branches.any((b) => b.brId.toString() == currentValue);
      return AppDropdown<String>(
        hint: 'Select city',
        value: hasMatch ? currentValue : null,
        items: branches
            .map((branch) => DropdownMenuItem<String>(
                  value: branch.brId.toString(),
                  child: Text(branch.brName),
                ))
            .toList(),
        onChanged: (v) {
          controller.selectedServiceCityId.value = v ?? '';
          final selected = branches.firstWhereOrNull(
              (b) => b.brId.toString() == v);
          controller.selectedCity.value = selected?.brName ?? '';
        },
      );
    });
  }

  Widget _buildCategoryDropdown() {
    return Obx(() {
      if (controller.dashboardController.getCategoriesLoading.value) {
        return Container(
          height: 48,
          alignment: Alignment.center,
          child: const SizedBox(
            height: 20, width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      }
      final categories = controller.dashboardController.categoriesList;
      final currentValue = controller.selectedEnquiredFor.value;
      final hasMatch = currentValue.isNotEmpty &&
          categories.any((c) => c.id.toString() == currentValue);
      return AppDropdown<String>(
        hint: 'Select service',
        value: hasMatch ? currentValue : null,
        items: categories
            .map((cat) => DropdownMenuItem<String>(
                  value: cat.id.toString(),
                  child: Text(cat.catName),
                ))
            .toList(),
        onChanged: (v) {
          controller.selectedEnquiredFor.value = v ?? '';
        },
      );
    });
  }

  Widget _buildDropdown({
    required RxString obs,
    required List<String> items,
    required String hint,
    required Function(String?) onChanged,
    bool clearable = false,
  }) {
    return Obx(
      () => AppDropdown<String>(
        hint: hint,
        value: obs.value.isEmpty ? null : obs.value,
        items: items
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: onChanged,
        clearable: clearable,
        onClear: clearable ? () => obs.value = '' : null,
      ),
    );
  }
}