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

  @override
  Widget build(BuildContext context) {
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
            // Client Section
            _buildSectionTitle('Client'),
            Text(
              'Find the client this booking is for by phone number',
              style: TextStyle(fontSize: 13, color: AppColor.fontColorGrey),
            ),
            const SizedBox(height: 16),
            _buildClientLookup(),
            const SizedBox(height: 24),

            // Patient Information Section
            _buildSectionTitle('Patient Information'),
            Text(
              'Please provide accurate patient details',
              style: TextStyle(fontSize: 13, color: AppColor.fontColorGrey),
            ),
            const SizedBox(height: 4),
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

            Obx(() => _buildAgeField(controller.ageDisplay.value)),
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
              final opts = controller.languageNames;
              if (opts.isEmpty) {
                return Text(
                  'Languages could not be loaded',
                  style: TextStyle(fontSize: 13, color: AppColor.fontColorGrey),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preferred Language',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.fontColorBlack,
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
                              : AppColor.fontColorBlack,
                          fontSize: 13,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppColor.cPrimaryButtonColor
                              : AppColor.divColor,
                        ),
                        backgroundColor: AppColor.whiteColor,
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
            _buildAddressSelector(),
            const SizedBox(height: 16),

            Text(
              'Patient stays alone? *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColor.fontColorBlack,
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
              label: 'Patient Phone Number',
              hint: '10–15 digits',
              controller: controller.patientPhoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(15),
              ],
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
              style: TextStyle(fontSize: 13, color: AppColor.fontColorGrey),
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
                        child: Text(branch.brName),
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
                        child: Text(category.catName),
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
              style: TextStyle(fontSize: 13, color: AppColor.fontColorGrey),
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
                      onDateSelected: (d) {
                        if (d != null) controller.onCreateStartDateSelected(d);
                      },
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
                label: 'Preferred Time (Optional)',
                hint: 'Select time',
                selectedTime: controller.preferredTime.value,
                onTap: () => controller.selectTime(context),
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
                    backgroundColor: AppColor.cPrimaryButtonColor,
                    foregroundColor: AppColor.buttonTextWhite,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    disabledBackgroundColor: const Color(
                      0xFF2563EB,
                    ).withOpacity(0.6),
                  ),
                  child: controller.isCreateBookingLoading.value
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColor.buttonTextWhite,
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

  Widget _buildClientLookup() {
    return Obx(() {
      final client = controller.selectedClient.value;
      if (client != null) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColor.whiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(Icons.person, color: AppColor.cPrimaryButtonColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (client['name'] as String).isEmpty
                          ? 'Client #${client['id']}'
                          : client['name'] as String,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColor.fontColorBlack,
                      ),
                    ),
                    Text(
                      'ID ${client['id']} · ${client['phone']}',
                      style: TextStyle(fontSize: 13, color: AppColor.fontColorGrey),
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
              prefixIcon: Icons.search,
              required: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: controller.isClientLookupLoading.value
                  ? null
                  : controller.lookupClientByPhone,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.cPrimaryButtonColor,
                foregroundColor: AppColor.buttonTextWhite,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: controller.isClientLookupLoading.value
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColor.buttonTextWhite,
                      ),
                    )
                  : const Text('Find'),
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
          TextButton.icon(
            onPressed: _showAddAddressDialog,
            icon: const Icon(Icons.add_location_alt_outlined, size: 18),
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
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Add Address'),
                const SizedBox(height: 16),
                FormTextField(label: 'Address Tag', hint: 'e.g. Home, Hospital', controller: tag, required: true),
                const SizedBox(height: 12),
                FormTextField(label: 'Address Line 1', hint: 'House no, street', controller: line1, required: true),
                const SizedBox(height: 12),
                FormTextField(label: 'Address Line 2', hint: 'Area, colony', controller: line2),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: FormTextField(label: 'Locality', hint: 'Locality', controller: locality)),
                  const SizedBox(width: 12),
                  Expanded(child: FormTextField(label: 'Landmark', hint: 'Landmark', controller: landmark)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: FormTextField(label: 'City', hint: 'City', controller: city, required: true)),
                  const SizedBox(width: 12),
                  Expanded(child: FormTextField(label: 'State', hint: 'State', controller: state)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
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
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                    const SizedBox(width: 8),
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.cPrimaryButtonColor,
                            foregroundColor: AppColor.buttonTextWhite,
                          ),
                          child: Text(controller.isAddAddressLoading.value
                              ? 'Saving...'
                              : 'Save Address'),
                        )),
                  ],
                ),
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
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColor.fontColorBlack,
            ),
            children: [
              TextSpan(text: 'Age (auto-calculated)'),
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColor.fieldColorGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.divColor),
          ),
          child: Text(
            value.isEmpty ? 'Calculated from year of birth' : value,
            style: TextStyle(
              color: value.isEmpty ? AppColor.lightGrey : AppColor.fontColorBlack,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColor.fontColorBlack,
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
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColor.fontColorBlack,
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
                  color: isSelected ? AppColor.cPrimaryButtonColor : AppColor.whiteColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColor.cPrimaryButtonColor
                        : AppColor.divColor,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppColor.buttonTextWhite : AppColor.fontColorBlack,
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
          color: isSelected ? AppColor.cPrimaryButtonColor : AppColor.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColor.cPrimaryButtonColor : AppColor.divColor,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColor.buttonTextWhite : AppColor.fontColorBlack,
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
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColor.fontColorBlack,
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
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColor.divColor),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedTime != null ? _formatTime(selectedTime) : hint,
                  style: TextStyle(
                    color: selectedTime != null
                        ? AppColor.fontColorBlack
                        : AppColor.fontColorGrey,
                    fontSize: 14,
                  ),
                ),
                Icon(Icons.access_time, color: AppColor.fontColorGrey, size: 18),
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
        Row(
          children: [
            Text('Select Service',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.fontColorBlack)),
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
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColor.divColor),
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
                              color: AppColor.fontColorGrey, fontSize: 14)),
                ),
                Icon(Icons.keyboard_arrow_down, color: AppColor.fontColorGrey),
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
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
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
                color: AppColor.divColor,
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
                      // liveType is a service category (Live-In/Day/Night),
                      // NOT a discount — must not be sent as base_discount_percentage.
                      controller.baseDiscount.value = '';
                      Get.back();
                    },
                    child: Container(
                      color: isSelected
                          ? AppColor.cPrimaryButtonColor.withOpacity(0.05)
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
                                          ? AppColor.cPrimaryButtonColor
                                          : AppColor.fontColorBlack,
                                    )),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle,
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
                                    fontSize: 12, color: AppColor.fontColorGrey),
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
