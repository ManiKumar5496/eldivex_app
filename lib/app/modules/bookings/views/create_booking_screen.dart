import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/common_text_form_field.dart';
import '../../../widgets/date_picker_common.dart';
import '../../../widgets/dropdown_common.dart';
import '../../../widgets/ui/ui.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../controllers/bookings_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class CreateBookingsView extends StatefulWidget {
  const CreateBookingsView({super.key});

  @override
  State<CreateBookingsView> createState() => _CreateBookingsViewState();
}

class _CreateBookingsViewState extends State<CreateBookingsView> {
  late final BookingsController controller;
  late final DashboardController dashboardController;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<BookingsController>()
        ? Get.find<BookingsController>()
        : Get.put(BookingsController());
    dashboardController = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());
    final args = Get.arguments;
    final raw = args is Map ? args['userId'] : null;
    final userId = raw is int ? raw : int.tryParse('${raw ?? ''}');
    if (userId != null && userId > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.selectClientById(userId);
      });
    }
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Get.back();
    } else {
      Get.offAllNamed(Routes.MAIN);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final isMobile = SizeConfig.isMobile;

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SingleChildScrollView(
        padding: SizeConfig.pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppPageHeader(
                  title: 'Create Booking',
                  subtitle: 'Add a new care booking for a client',
                  breadcrumbs: const ['Bookings', 'Create Booking'],
                  onBack: _goBack,
                ),
                const SizedBox(height: 24),

                // Client Section
                AppCard(
                  title: 'Client',
                  subtitle: 'Find the client this booking is for by phone number',
                  icon: LucideIcons.userSearch,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildClientLookup(),
                      const SizedBox(height: 16),
                      _buildAddressSelector(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Patient Information Section
                AppCard(
                  title: 'Patient Information',
                  subtitle: 'Please provide accurate patient details',
                  icon: LucideIcons.bandage,
                  child: _FormGrid(
                    children: [
                      FormTextField(
                        label: 'Patient Name',
                        hint: 'Enter full name',
                        controller: controller.patientNameController,
                        prefixIcon: LucideIcons.user,
                        required: true,
                      ),
                      FormTextField(
                        label: 'Patient Phone Number',
                        hint: '10–15 digits',
                        controller: controller.patientPhoneController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: LucideIcons.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(15),
                        ],
                      ),
                      FormTextField(
                        label: 'Year of Birth',
                        hint: '1990',
                        controller: controller.yearOfBirthController,
                        keyboardType: TextInputType.number,
                        required: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                      ),
                      FormTextField(
                        label: 'Weight (kg)',
                        hint: '70',
                        controller: controller.weightController,
                        keyboardType: TextInputType.number,
                        required: true,
                      ),
                      Obx(() => _buildAgeField(controller.ageDisplay.value)),
                      Obx(
                        () => _buildSegmentedButton(
                          label: 'Gender',
                          options: const ['Male', 'Female', 'Other'],
                          selected: controller.selectedGender.value,
                          onChanged: (value) => controller.selectedGender.value = value,
                          required: true,
                        ),
                      ),
                      FormTextField(
                        label: 'Email Address',
                        hint: 'email@example.com',
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: LucideIcons.mail,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Patient stays alone?', required: true),
                          Obx(
                            () => Row(
                              children: [
                                Expanded(
                                  child: _buildYesNoButton(
                                    'Yes',
                                    controller.patientStaysAlone.value == true,
                                    () => controller.patientStaysAlone.value = true,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildYesNoButton(
                                    'No',
                                    controller.patientStaysAlone.value == false,
                                    () => controller.patientStaysAlone.value = false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      _Full(
                        Obx(() {
                          if (controller.isLanguagesLoading.value) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          }
                          final opts = controller.languageNames;
                          if (opts.isEmpty) {
                            return Text(
                              'Languages could not be loaded',
                              style: TextStyle(fontSize: 13, color: AppColor.textTertiary),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel('Preferred Language'),
                              Obx(() => Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: opts.map((lang) {
                                  final isSelected =
                                      controller.selectedLanguages.contains(lang);
                                  return FilterChip(
                                    label: Text(lang),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) {
                                        controller.selectedLanguages.add(lang);
                                      } else {
                                        controller.selectedLanguages.remove(lang);
                                      }
                                    },
                                    selectedColor: AppColor.primarySoft,
                                    checkmarkColor: AppColor.cPrimaryButtonColor,
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? AppColor.cPrimaryButtonColor
                                          : AppColor.textPrimary,
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                    side: BorderSide(
                                      color: isSelected
                                          ? AppColor.cPrimaryButtonColor
                                              .withValues(alpha: 0.5)
                                          : AppColor.borderStrong,
                                    ),
                                  );
                                }).toList(),
                              )),
                            ],
                          );
                        }),
                      ),
                      _Full(
                        FormTextField(
                          label: 'Medical Condition',
                          hint: "Please describe the patient's condition",
                          controller: controller.medicalConditionController,
                          required: true,
                          maxLines: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Service Selection Section
                AppCard(
                  title: 'Service Information',
                  subtitle: 'Select branch, category and specific service',
                  icon: LucideIcons.stethoscope,
                  child: _FormGrid(
                    children: [
                      // Branch Selection
                      Obx(() {
                        if (dashboardController.getAllBranchesLoading.value) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        return _buildDropdown(
                          label: 'Select Branch',
                          hint: 'Choose a branch',
                          value: controller.selectedBranchId.value == 0
                              ? null
                              : controller.selectedBranchId.value,
                          items: dashboardController.getAllBranches
                              .map(
                                (branch) => DropdownMenuItem<int>(
                                  value: branch.brId,
                                  child: Text(branch.brName),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => controller.onBranchSelected(value),
                          required: true,
                        );
                      }),

                      // Service Category Selection
                      Obx(() {
                        if (controller.selectedBranchId.value == 0) {
                          return _buildDisabledDropdown(
                            label: 'Service Category',
                            hint: 'Select branch first',
                          );
                        }

                        if (dashboardController.getCategoriesLoading.value) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        return _buildDropdown(
                          label: 'Service Category',
                          hint: 'Choose a category',
                          value: controller.selectedCategoryId.value == 0
                              ? null
                              : controller.selectedCategoryId.value,
                          items: dashboardController.categoriesList
                              .map(
                                (category) => DropdownMenuItem<int>(
                                  value: category.id,
                                  child: Text(category.catName),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => controller.onCategorySelected(value),
                          required: true,
                        );
                      }),

                      // Service Selection
                      _Full(
                        Obx(() {
                          if (controller.selectedCategoryId.value == 0) {
                            return _buildDisabledDropdown(
                              label: 'Select Service',
                              hint: 'Select category first',
                            );
                          }

                          if (dashboardController.getServiceListByIdLoading.value) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (dashboardController.getServicesByCityId.isEmpty) {
                            return _buildDisabledDropdown(
                              label: 'Select Service',
                              hint: 'No services available',
                            );
                          }

                          return _buildServiceSelectionField(
                            controller: controller,
                            dashboardController: dashboardController,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Service Schedule Section
                AppCard(
                  title: 'Service Schedule',
                  subtitle: 'Choose your preferred dates and time',
                  icon: LucideIcons.calendar,
                  child: _FormGrid(
                    children: [
                      Obx(
                        () => CommonDatePicker(
                          label: 'Start Date',
                          hint: 'Select start date',
                          selectedDate: controller.startDate.value,
                          onDateSelected: (d) {
                            if (d != null) controller.onCreateStartDateSelected(d);
                          },
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        ),
                      ),
                      Obx(
                        () => CommonDatePicker(
                          label: 'End Date',
                          hint: 'Select end date',
                          selectedDate: controller.endDate.value,
                          onDateSelected: (d) {
                            if (d != null) controller.onCreateEndDateSelected(d);
                          },
                          // Today rather than the start date: the shared picker
                          // opens on today when no end date is set, which must
                          // not precede firstDate.
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        ),
                      ),
                      Obx(
                        () => _buildTimePicker(
                          label: 'Start Time',
                          hint: 'Select start time',
                          selectedTime: controller.serviceStartTime.value,
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime:
                                  controller.serviceStartTime.value ??
                                  TimeOfDay.now(),
                            );
                            if (time != null) {
                              controller.serviceStartTime.value = time;
                            }
                          },
                          required: true,
                        ),
                      ),
                      Obx(
                        () => _buildTimePicker(
                          label: 'End Time',
                          hint: 'Select end time',
                          selectedTime: controller.serviceEndTime.value,
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime:
                                  controller.serviceEndTime.value ??
                                  TimeOfDay.now(),
                            );
                            if (time != null) {
                              controller.serviceEndTime.value = time;
                            }
                          },
                          required: true,
                        ),
                      ),
                      Obx(
                        () => _buildTimePicker(
                          label: 'Preferred Time (Optional)',
                          hint: 'Select time',
                          selectedTime: controller.preferredTime.value,
                          onTap: () => controller.selectTime(context),
                        ),
                      ),
                      _Full(
                        FormTextField(
                          label: 'Special Requirements (Optional)',
                          hint: 'Any specific needs or preferences',
                          controller: controller.specialRequirementsController,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Actions
                _buildFormActions(isMobile),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormActions(bool isMobile) {
    final cancel = OutlinedButton(
      onPressed: _goBack,
      child: const Text('Cancel'),
    );

    // Confirm Button
    final confirm = Obx(
      () => ElevatedButton(
        onPressed: controller.isCreateBookingLoading.value
            ? null
            : controller.createBooking,
        child: controller.isCreateBookingLoading.value
            ? SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColor.cPrimaryButtonColor,
                  ),
                ),
              )
            : const Text('Confirm Booking'),
      ),
    );

    if (isMobile) {
      return Row(
        children: [
          Expanded(child: cancel),
          const SizedBox(width: 12),
          Expanded(child: confirm),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        cancel,
        const SizedBox(width: 8),
        confirm,
      ],
    );
  }

  Widget _buildClientLookup() {
    return Obx(() {
      final client = controller.selectedClient.value;
      if (client != null) {
        final name = (client['name'] as String).isEmpty
            ? 'Client #${client['id']}'
            : client['name'] as String;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColor.primarySoft,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              AppAvatar(name: name, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID ${client['id']} · ${client['phone']}',
                      style: TextStyle(fontSize: 13, color: AppColor.textTertiary),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: controller.clearSelectedClient,
                child: const Text('Change'),
              ),
            ],
          ),
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: FormTextField(
              label: 'Client Phone Number',
              hint: 'Registered mobile number',
              controller: controller.clientLookupPhoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: LucideIcons.search,
              required: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: controller.isClientLookupLoading.value
                  ? null
                  : controller.lookupClientByPhone,
              icon: controller.isClientLookupLoading.value
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColor.cPrimaryButtonColor,
                      ),
                    )
                  : const Icon(LucideIcons.search, size: 18),
              label: const Text('Find'),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildAddressSelector() {
    return Obx(() {
      if (controller.selectedClientId <= 0) {
        return _buildDisabledDropdown(
          label: 'Service Address',
          hint: 'Select the client first',
        );
      }
      if (controller.isClientAddressesLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      }
      final addresses = controller.clientAddresses;
      final ids = addresses.map((a) => int.tryParse('${a['id']}') ?? 0).toSet();
      final selected = controller.selectedAddressId.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (addresses.isEmpty)
            _buildDisabledDropdown(
              label: 'Service Address',
              hint: 'This client has no saved address',
            )
          else
            _buildDropdown<int>(
              label: 'Service Address',
              hint: 'Select address',
              value: ids.contains(selected) ? selected : null,
              items: addresses
                  .map((a) => DropdownMenuItem<int>(
                        value: int.tryParse('${a['id']}') ?? 0,
                        child: Text(
                          BookingsController.addressLabel(a),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: (v) => controller.selectedAddressId.value = v ?? 0,
              required: true,
            ),
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: _showAddAddressDialog,
            icon: const Icon(LucideIcons.mapPinPlus, size: 18),
            label: const Text('Add new address'),
          ),
        ],
      );
    });
  }

  void _showAddAddressDialog() {
    final tag = TextEditingController();
    final line1 = TextEditingController();
    final line2 = TextEditingController();
    final locality = TextEditingController();
    final landmark = TextEditingController();
    final city = TextEditingController();
    final state = TextEditingController();
    final country = TextEditingController(text: 'India');
    final pincode = TextEditingController();

    Get.dialog(
      AppDialog(
        title: 'Add Address',
        subtitle: 'Save a new service address for this client',
        icon: LucideIcons.mapPinPlus,
        maxWidth: 560,
        onClose: () => Get.back(),
        actions: [
          OutlinedButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          Obx(() => ElevatedButton(
                onPressed: controller.isAddAddressLoading.value
                    ? null
                    : () async {
                        if (tag.text.trim().isEmpty ||
                            line1.text.trim().isEmpty ||
                            city.text.trim().isEmpty ||
                            pincode.text.trim().isEmpty) {
                          Get.snackbar('Validation Error',
                              'Tag, address line 1, city and pincode are required');
                          return;
                        }
                        final ok = await controller.addClientAddress(
                          addressTagName: tag.text.trim(),
                          country: country.text.trim(),
                          state: state.text.trim(),
                          city: city.text.trim(),
                          addressLine1: line1.text.trim(),
                          addressLine2: line2.text.trim(),
                          landmark: landmark.text.trim(),
                          locality: locality.text.trim(),
                          pincode: pincode.text.trim(),
                        );
                        if (ok) Get.back();
                      },
                child: Text(controller.isAddAddressLoading.value
                    ? 'Saving...'
                    : 'Save Address'),
              )),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormTextField(label: 'Address Tag', hint: 'e.g. Home, Hospital', controller: tag, required: true),
            const SizedBox(height: 16),
            FormTextField(label: 'Address Line 1', hint: 'House no, street', controller: line1, required: true),
            const SizedBox(height: 16),
            FormTextField(label: 'Address Line 2', hint: 'Area, colony', controller: line2),
            const SizedBox(height: 16),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: FormTextField(label: 'Locality', hint: 'Locality', controller: locality)),
              const SizedBox(width: 12),
              Expanded(child: FormTextField(label: 'Landmark', hint: 'Landmark', controller: landmark)),
            ]),
            const SizedBox(height: 16),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: FormTextField(label: 'City', hint: 'City', controller: city, required: true)),
              const SizedBox(width: 12),
              Expanded(child: FormTextField(label: 'State', hint: 'State', controller: state)),
            ]),
            const SizedBox(height: 16),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: FormTextField(label: 'Country', hint: 'Country', controller: country)),
              const SizedBox(width: 12),
              Expanded(
                child: FormTextField(
                  label: 'Pincode',
                  hint: 'Pincode',
                  controller: pincode,
                  required: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  /// Field label matching [FormTextField]'s label style.
  Widget _fieldLabel(String label, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColor.textPrimary,
          ),
          children: [
            TextSpan(text: label),
            if (required)
              TextSpan(
                text: ' *',
                style: TextStyle(color: AppColor.danger),
              ),
          ],
        ),
      ),
    );
  }

  /// Bordered, tappable field shell for the custom pickers.
  Widget _pickerShell({
    required Widget child,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final radius = BorderRadius.circular(AppRadius.md);
    return Material(
      color: AppColor.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: AppColor.borderStrong),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(child: child),
                if (trailing != null) ...[const SizedBox(width: 8), trailing],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgeField(String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Age (auto-calculated)', required: true),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 48),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColor.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColor.borderSubtle),
          ),
          child: Text(
            value.isEmpty ? 'Calculated from year of birth' : value,
            style: TextStyle(
              color: value.isEmpty ? AppColor.textTertiary : AppColor.textPrimary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedButton({
    required String label,
    required List<String> options,
    required String selected,
    required Function(String) onChanged,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label, required: required),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected == option;
            return _ChoiceTile(
              label: option,
              selected: isSelected,
              onTap: () => onChanged(option),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildYesNoButton(String label, bool isSelected, VoidCallback onTap) {
    return _ChoiceTile(
      label: label,
      selected: isSelected,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 13),
      center: true,
    );
  }

  Widget _buildTimePicker({
    required String label,
    required String hint,
    required TimeOfDay? selectedTime,
    required VoidCallback onTap,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label, required: required),
        _pickerShell(
          onTap: onTap,
          trailing: Icon(LucideIcons.clock, color: AppColor.textTertiary, size: 18),
          child: Text(
            selectedTime != null ? _formatTime(selectedTime) : hint,
            style: TextStyle(
              color: selectedTime != null
                  ? AppColor.textPrimary
                  : AppColor.textTertiary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
    bool required = false,
  }) {
    return AppDropdown<T>(
      label: label,
      hint: hint,
      value: value,
      items: items,
      onChanged: onChanged,
      isMandatory: required,
    );
  }

  Widget _buildDisabledDropdown({required String label, required String hint}) {
    return AppDropdown<String>(
      label: label,
      hint: hint,
      items: const [],
      enabled: false,
    );
  }

  Widget _buildServiceSelectionField({
    required BookingsController controller,
    required DashboardController dashboardController,
  }) {
    final services = dashboardController.getServicesByCityId;
    final selectedId = controller.selectedServiceId.value;
    final selectedService = selectedId != 0
        ? services.firstWhereOrNull((s) => s.id == selectedId)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Select Service', required: true),
        _pickerShell(
          onTap: () => _showServiceBottomSheet(
            controller: controller,
            dashboardController: dashboardController,
          ),
          trailing: Icon(LucideIcons.chevronDown, color: AppColor.textTertiary),
          child: selectedService != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(selectedService.name,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColor.textPrimary)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildServiceTag(
                            _liveTypeLabel(selectedService.liveType),
                            AppTone.info),
                        _buildServiceTag(
                            _genderLabel(selectedService.hpGender),
                            AppTone.violet),
                        _buildServiceTag(
                            _serviceTypeLabel(
                                selectedService.serviceType),
                            AppTone.warning),
                        _buildServiceTag(
                            'Rs.${selectedService.serviceRate}',
                            AppTone.success),
                      ],
                    ),
                  ],
                )
              : Text('Choose a service',
                  style: TextStyle(
                      color: AppColor.textTertiary, fontSize: 14)),
        ),
      ],
    );
  }

  void _showServiceBottomSheet({
    required BookingsController controller,
    required DashboardController dashboardController,
  }) {
    final services = dashboardController.getServicesByCityId;
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: Get.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColor.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              child: Text('Select Service',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  )),
            ),
            Divider(height: 1, color: AppColor.borderSubtle),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: services.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: AppColor.borderSubtle),
                itemBuilder: (context, index) {
                  final service = services[index];
                  final isSelected =
                      controller.selectedServiceId.value == service.id;
                  return InkWell(
                    onTap: () {
                      controller.onServiceSelected(service.id);
                      controller.baseRate.value =
                          service.serviceRate.toString();
                      // liveType is a service category (Live-In/Day/Night),
                      // NOT a discount — must not be sent as base_discount_percentage.
                      controller.baseDiscount.value = '';
                      Get.back();
                    },
                    child: Container(
                      color: isSelected ? AppColor.primarySoft : null,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(service.name,
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? AppColor.cPrimaryButtonColor
                                          : AppColor.textPrimary,
                                    )),
                              ),
                              if (isSelected)
                                Icon(LucideIcons.circleCheck,
                                    color: AppColor.cPrimaryButtonColor, size: 20),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _buildServiceTag(
                                  _liveTypeLabel(service.liveType),
                                  AppTone.info),
                              _buildServiceTag(
                                  _genderLabel(service.hpGender),
                                  AppTone.violet),
                              _buildServiceTag(
                                  _serviceTypeLabel(service.serviceType),
                                  AppTone.warning),
                              _buildServiceTag(
                                  'Rs.${service.serviceRate}', AppTone.success),
                            ],
                          ),
                          if (service.description.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(service.description,
                                style: TextStyle(
                                    fontSize: 12.5, color: AppColor.textTertiary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  String _liveTypeLabel(int type) => switch (type) {
        1 => 'Live-In',
        2 => 'Liveout-Day',
        3 => 'Liveout-Night',
        _ => 'N/A',
      };

  String _genderLabel(int gender) => switch (gender) {
        1 => 'Male',
        2 => 'Female',
        _ => 'Any',
      };

  String _serviceTypeLabel(int type) => switch (type) {
        1 => 'Normal',
        2 => 'Premium',
        _ => 'N/A',
      };

  Widget _buildServiceTag(String label, AppTone tone) {
    return AppStatusBadge(label: label, tone: tone, showDot: false, dense: true);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }
}

// ─────────────────────────────────────────────
// Private layout helpers
// ─────────────────────────────────────────────

/// Marks a [_FormGrid] child that should span both columns.
class _Full extends StatelessWidget {
  const _Full(this.child);
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// Two-column form grid (one column when narrow). Wrap a child in [_Full] to
/// make it span the full width.
class _FormGrid extends StatelessWidget {
  const _FormGrid({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const gap = 16.0;
      final width = constraints.maxWidth;
      final twoCol = width >= 560;
      final half = twoCol ? (width - gap) / 2 : width;
      return Wrap(
        spacing: gap,
        runSpacing: 16,
        children: [
          for (final c in children)
            SizedBox(width: c is _Full ? width : half, child: c),
        ],
      );
    });
  }
}

/// Selectable option tile used for gender and yes/no choices.
class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.padding,
    this.center = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.md);
    final text = Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        color: selected ? AppColor.cPrimaryButtonColor : AppColor.textPrimary,
      ),
    );
    return Material(
      color: selected ? AppColor.primarySoft : AppColor.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: selected
              ? AppColor.cPrimaryButtonColor.withValues(alpha: 0.6)
              : AppColor.borderStrong,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: padding,
          child: center ? Center(child: text) : text,
        ),
      ),
    );
  }
}
