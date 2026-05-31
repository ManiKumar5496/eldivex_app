import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/common_text_form_field.dart';
import '../../../widgets/date_picker_common.dart';
import '../../../widgets/dropdown_common.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../controllers/bookings_controller.dart';

class CreateBookingsView extends GetView<BookingsController> {
  const CreateBookingsView({super.key});
  Map<String, dynamic>? get data => Get.arguments as Map<String, dynamic>?;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<BookingsController>()) {
      Get.put(BookingsController());
    }
    final dashboardController = Get.find<DashboardController>();
    final userId = data?['userId'];
    if (userId != null) {
      controller.userIdControllerCreateBooking.text = userId.toString();
    } else {
      controller.userIdControllerCreateBooking.text = "";
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Booking'),
        backgroundColor: AppColor.cAppBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Get.back();
            } else {
              Get.offAllNamed(Routes.MAIN);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Information Section
            _buildSectionTitle('Patient Information'),
            Text(
              'Please provide accurate patient details',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            FormTextField(
              label: 'User Id',
              hint: 'User Id',
              controller: controller.userIdControllerCreateBooking,
              prefixIcon: Icons.person_outline,
              required: false,
            ),
            const SizedBox(height: 16),
            FormTextField(
              label: 'Patient Name',
              hint: 'Enter full name',
              controller: controller.patientNameController,
              prefixIcon: Icons.person_outline,
              required: true,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: FormTextField(
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
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FormTextField(
                    label: 'Weight (kg)',
                    hint: '70',
                    controller: controller.weightController,
                    keyboardType: TextInputType.number,
                    required: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            FormTextField(
              label: 'Age (auto-calculated)',
              hint: 'Calculated from year of birth',
              controller: controller.ageController,
              keyboardType: TextInputType.number,
              required: true,
              readOnly: true,
            ),
            const SizedBox(height: 16),

            Obx(
              () => _buildSegmentedButton(
                label: 'Gender',
                options: const ['Male', 'Female', 'Other'],
                selected: controller.selectedGender.value,
                onChanged: (value) => controller.selectedGender.value = value,
                required: true,
              ),
            ),

            const SizedBox(height: 16),

            Obx(() {
              if (controller.isLanguagesLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              final languages = controller.languagesList
                  .map((l) => l['name'] as String)
                  .toList();
              final opts = languages.isEmpty ? ['English'] : languages;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preferred Language *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                        selectedColor:
                            AppColor.cPrimaryButtonColor.withOpacity(0.2),
                        checkmarkColor: AppColor.cPrimaryButtonColor,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColor.cPrimaryButtonColor
                              : Colors.black87,
                          fontSize: 13,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppColor.cPrimaryButtonColor
                              : Colors.grey.shade300,
                        ),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    }).toList(),
                  )),
                ],
              );
            }),

            const SizedBox(height: 16),
            _buildDropdown<int>(
              label: 'Service Address',
              hint: 'Select address',
              value: (controller.selectedAddressId.value == 1 ||
                      controller.selectedAddressId.value == 2)
                  ? controller.selectedAddressId.value
                  : null,
              items: const [
                DropdownMenuItem(value: 1, child: Text('Home')),
                DropdownMenuItem(value: 2, child: Text('Hospital')),
              ],
              onChanged: (v) => controller.selectedAddressId.value = v ?? 0,
              required: true,
            ),
            const SizedBox(height: 16),

            Text(
              'Patient stays alone? *',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
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

            const SizedBox(height: 16),

            FormTextField(
              label: 'Phone Number',
              hint: '+1 (555) 000-0000',
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
            ),

            const SizedBox(height: 16),

            FormTextField(
              label: 'Email Address',
              hint: 'email@example.com',
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
            ),

            const SizedBox(height: 16),

            FormTextField(
              label: 'Medical Condition',
              hint: "Please describe the patient's condition",
              controller: controller.medicalConditionController,
              required: true,
              maxLines: 4,
            ),

            const SizedBox(height: 24),

            // Service Selection Section
            _buildSectionTitle('Service Information'),
            Text(
              'Select branch, category and specific service',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

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
                        child: Text(branch.brName ?? 'Unknown'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => controller.onBranchSelected(value),
                required: true,
              );
            }),

            const SizedBox(height: 16),

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
                        child: Text(category.catName ?? 'Unknown'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => controller.onCategorySelected(value),
                required: true,
              );
            }),

            const SizedBox(height: 16),

            // Service Selection
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

            const SizedBox(height: 24),

            // Service Schedule Section
            _buildSectionTitle('Service Schedule'),
            Text(
              'Choose your preferred dates and time',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => CommonDatePicker(
                      label: 'Start Date',
                      hint: 'Select start date',
                      selectedDate: controller.startDate.value,
                      onDateSelected: (date) =>
                          controller.startDate.value = date,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(
                    () => CommonDatePicker(
                      label: 'End Date',
                      hint: 'Select end date',
                      selectedDate: controller.endDate.value,
                      onDateSelected: (date) => controller.endDate.value = date,
                      firstDate: controller.startDate.value ?? DateTime.now(),
                      lastDate: DateTime(2100),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Obx(
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
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(
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
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () => _buildTimePicker(
                label: 'Preferred Time',
                hint: 'Select time',
                selectedTime: controller.preferredTime.value,
                onTap: () => controller.selectTime(context),
                required: true,
              ),
            ),

            const SizedBox(height: 16),

            FormTextField(
              label: 'Special Requirements (Optional)',
              hint: 'Any specific needs or preferences',
              controller: controller.specialRequirementsController,
              maxLines: 3,
            ),

            const SizedBox(height: 32),

            // Confirm Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isCreateBookingLoading.value
                      ? null
                      : controller.createBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    disabledBackgroundColor: const Color(
                      0xFF2563EB,
                    ).withOpacity(0.6),
                  ),
                  child: controller.isCreateBookingLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Confirm Booking',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
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
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected == option;
            return InkWell(
              onTap: () => onChanged(option),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildYesNoButton(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
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
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedTime != null ? _formatTime(selectedTime) : hint,
                  style: TextStyle(
                    color: selectedTime != null
                        ? Colors.black87
                        : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Icon(Icons.access_time, color: Colors.grey[600], size: 18),
              ],
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
        const Row(
          children: [
            Text('Select Service',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
            Text(' *', style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showServiceBottomSheet(
            controller: controller,
            dashboardController: dashboardController,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: selectedService != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(selectedService.name,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                _buildServiceTag(
                                    _liveTypeLabel(selectedService.liveType),
                                    Colors.blue),
                                _buildServiceTag(
                                    _genderLabel(selectedService.hpGender),
                                    Colors.purple),
                                _buildServiceTag(
                                    _serviceTypeLabel(
                                        selectedService.serviceType),
                                    Colors.orange),
                                _buildServiceTag(
                                    'Rs.${selectedService.serviceRate}',
                                    Colors.green),
                              ],
                            ),
                          ],
                        )
                      : Text('Choose a service',
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 14)),
                ),
                Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
              ],
            ),
          ),
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Select Service',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: services.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final service = services[index];
                  final isSelected =
                      controller.selectedServiceId.value == service.id;
                  return InkWell(
                    onTap: () {
                      controller.onServiceSelected(service.id);
                      controller.baseRate.value =
                          service.serviceRate.toString();
                      controller.baseDiscount.value =
                          service.liveType.toString();
                      Get.back();
                    },
                    child: Container(
                      color: isSelected
                          ? const Color(0xFF2563EB).withOpacity(0.05)
                          : null,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(service.name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? const Color(0xFF2563EB)
                                          : Colors.black87,
                                    )),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle,
                                    color: Color(0xFF2563EB), size: 20),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _buildServiceTag(
                                  _liveTypeLabel(service.liveType),
                                  Colors.blue),
                              _buildServiceTag(
                                  _genderLabel(service.hpGender),
                                  Colors.purple),
                              _buildServiceTag(
                                  _serviceTypeLabel(service.serviceType),
                                  Colors.orange),
                              _buildServiceTag(
                                  'Rs.${service.serviceRate}', Colors.green),
                            ],
                          ),
                          if (service.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(service.description,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
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

  Widget _buildServiceTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color.withOpacity(0.8),
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }
}
