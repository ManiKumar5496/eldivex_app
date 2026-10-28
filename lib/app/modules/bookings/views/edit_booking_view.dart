import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import 'package:eldivex_app/app/widgets/common_textfield.dart';
import 'package:eldivex_app/app/widgets/date_picker_common.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../../widgets/dropdown_common.dart';
import '../../../widgets/shimmer_loader.dart';
import '../controllers/bookings_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class EditBookingView extends StatefulWidget {
  final int bookingId;

  const EditBookingView({
    super.key,
    required this.bookingId,
  });

  @override
  State<EditBookingView> createState() => _EditBookingViewState();
}

class _EditBookingViewState extends State<EditBookingView> {
  late final BookingsController controller;

  int get bookingId => widget.bookingId;

  static const double _maxWidth = 1100;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<BookingsController>()
        ? Get.find<BookingsController>()
        : Get.put(BookingsController());
    // Fill the form once for this booking, not on every frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadBookingForEdit(bookingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final pad = SizeConfig.pagePadding;

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(pad.left, pad.top, pad.right, 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxWidth),
                child: _buildBookingInfo(),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.allBookingsByBookingIdLoading.value) {
                return const ShimmerLoader.form();
              }
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(pad.left, 0, pad.right, pad.bottom),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _maxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildUserDetails(),
                        const SizedBox(height: 16),
                        _buildPatientDetails(),
                        const SizedBox(height: 16),
                        _buildHealthConditions(),
                        const SizedBox(height: 16),
                        _buildAddressSection(),
                        const SizedBox(height: 16),
                        _buildServiceDetails(),
                        const SizedBox(height: 16),
                        _buildLeadDetails(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Sections
  // ─────────────────────────────────────────────
  /// Page header: title, back, and the booking ID chip ("Booking Information").
  Widget _buildBookingInfo() {
    return AppPageHeader(
      title: 'Edit Booking',
      subtitle: 'Booking Information',
      breadcrumbs: const ['Bookings', 'Edit Booking'],
      onBack: () => Get.back(),
      titleTrailing: AppStatusBadge(
        label: 'ID: BK-$bookingId',
        tone: AppTone.info,
        showDot: false,
      ),
    );
  }

  Widget _buildUserDetails() {
    return AppCard(
      title: 'User Details',
      icon: LucideIcons.user,
      iconTone: AppTone.success,
      actions: [_editButton('Edit User', _showEditUserDialog)],
      child: _FormGrid(
        children: [
          CommonTextField(label: 'Name', hint: 'Name', controller: controller.detailUserNameController, enabled: false),
          CommonTextField(label: 'Phone Number', hint: 'Phone', controller: controller.detailUserMobileController, prefixIcon: LucideIcons.phone, keyboardType: TextInputType.phone, enabled: false),
          CommonTextField(label: 'Email', hint: 'Email', controller: controller.detailUserEmailController, prefixIcon: LucideIcons.mail, keyboardType: TextInputType.emailAddress, enabled: false),
        ],
      ),
    );
  }

  Widget _buildPatientDetails() {
    return AppCard(
      title: 'Patient Details',
      icon: LucideIcons.bandage,
      iconTone: AppTone.info,
      actions: [_editButton('Edit Patient', _showEditPatientDialog)],
      child: _FormGrid(
        children: [
          CommonTextField(label: 'Name', hint: 'Name', controller: controller.detailPatientNameController, enabled: false),
          CommonTextField(label: 'Phone Number', hint: 'Phone', controller: controller.detailPatientPhoneController, prefixIcon: LucideIcons.phone, keyboardType: TextInputType.phone, enabled: false),
          CommonTextField(label: 'Email', hint: 'Email', controller: controller.detailPatientEmailController, prefixIcon: LucideIcons.mail, keyboardType: TextInputType.emailAddress, enabled: false),
          CommonTextField(label: 'Age', hint: 'Age', controller: controller.ageController, keyboardType: TextInputType.number, enabled: false),
          CommonTextField(label: 'Weight (kg)', hint: 'Weight', controller: controller.weightController, keyboardType: TextInputType.number, enabled: false),
          Obx(() => _buildReadonlyDropdown(label: 'Gender', value: controller.selectedGender.value)),
        ],
      ),
    );
  }

  Widget _buildHealthConditions() {
    return AppCard(
      title: 'Health Conditions & Requirements',
      icon: LucideIcons.heartPulse,
      iconTone: AppTone.violet,
      actions: [_editButton('Edit Health Info', _showEditHealthDialog)],
      child: _FormGrid(
        children: [
          _buildTextAreaField(
            label: 'Patient Health Conditions',
            controller: controller.medicalConditionController,
            enabled: false,
          ),
          _buildTextAreaField(
            label: 'Special Care Requirements',
            controller: controller.specialRequirementsController,
            enabled: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return AppCard(
      title: 'Address Details',
      icon: LucideIcons.mapPin,
      iconTone: AppTone.info,
      actions: [_editButton('Edit Address', _showEditAddressDialog)],
      child: _FormGrid(
        children: [
          CommonTextField(label: 'Address Tag', hint: 'Tag', controller: controller.detailAddressTagController, enabled: false),
          CommonTextField(label: 'Country', hint: 'Country', controller: controller.detailCountryController, enabled: false),
          CommonTextField(label: 'State', hint: 'State', controller: controller.detailStateController, enabled: false),
          CommonTextField(label: 'City', hint: 'City', controller: controller.detailCityController, enabled: false),
          _Full(CommonTextField(label: 'Address Line 1', hint: 'Address Line 1', controller: controller.detailAddressLine1Controller, enabled: false)),
          _Full(CommonTextField(label: 'Address Line 2', hint: 'Address Line 2', controller: controller.detailAddressLine2Controller, enabled: false)),
          CommonTextField(label: 'Locality', hint: 'Locality', controller: controller.detailLocalityController, enabled: false),
          CommonTextField(label: 'Landmark', hint: 'Landmark', controller: controller.detailLandmarkController, enabled: false),
          CommonTextField(label: 'Pincode', hint: 'Pincode', controller: controller.detailPincodeController, enabled: false),
        ],
      ),
    );
  }

  Widget _buildServiceDetails() {
    return AppCard(
      title: 'Service Details',
      icon: LucideIcons.stethoscope,
      iconTone: AppTone.success,
      actions: [_editButton('Edit Service', _showEditServiceDialog)],
      child: _FormGrid(
        children: [
          Obx(() => _buildReadonlyDropdown(
              label: 'Service City',
              value: controller.bookingsByBookingId.value.firstOrNull?.branchName ?? '')),
          Obx(() => _buildReadonlyDropdown(
              label: 'Service',
              value: controller.bookingsByBookingId.value.firstOrNull?.serviceName ?? '')),
          Obx(() => CommonDatePicker(label: 'Service Start Date', hint: 'Select Date', selectedDate: controller.startDate.value, onDateSelected: (_) {}, enabled: false)),
          Obx(() => CommonDatePicker(label: 'Service End Date', hint: 'Select Date', selectedDate: controller.endDate.value, onDateSelected: (_) {}, enabled: false)),
        ],
      ),
    );
  }

  Widget _buildLeadDetails() {
    return AppCard(
      title: 'Lead Details',
      icon: LucideIcons.trendingUp,
      iconTone: AppTone.warning,
      actions: [_editButton('Edit Lead', _showEditLeadDialog)],
      child: _FormGrid(
        children: [
          Obx(() => _buildReadonlyDropdown(
            label: 'Lead Potential',
            value: controller.selectedLeadType.value,
          )),
          Obx(() => CommonDatePicker(
            label: 'Next Followup Date',
            hint: 'Not set',
            selectedDate: controller.selectedFollowupDate.value,
            onDateSelected: (_) {},
            enabled: false,
          )),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Edit Dialogs
  // ─────────────────────────────────────────────

  void _showEditUserDialog() {
    final booking = controller.bookingsByBookingId.value.firstOrNull;
    if (booking == null) return;

    final nameCtrl = TextEditingController(text: controller.detailUserNameController.text);
    final phoneCtrl = TextEditingController(text: controller.detailUserMobileController.text);
    final emailCtrl = TextEditingController(text: controller.detailUserEmailController.text);

    Get.dialog(
      AppDialog(
        title: 'Edit User Details',
        icon: LucideIcons.user,
        tone: AppTone.success,
        maxWidth: 520,
        onClose: () => Get.back(),
        actions: [
          _cancelButton(),
          // FIX: calls actual API
          Obx(() => ElevatedButton(
            onPressed: controller.isUpdateUserLoading.value
                ? null
                : () {
              if (nameCtrl.text.trim().isEmpty) {
                _showError('Name is required');
                return;
              }
              if (phoneCtrl.text.trim().isEmpty) {
                _showError('Phone number is required');
                return;
              }
              if (emailCtrl.text.trim().isEmpty ||
                  !GetUtils.isEmail(emailCtrl.text)) {
                _showError('Valid email is required');
                return;
              }
              controller.updateUser(
                userId: booking.userId,
                name: nameCtrl.text.trim(),
                phoneNumber: phoneCtrl.text.trim(),
                email: emailCtrl.text.trim(),
              );
            },
            child: controller.isUpdateUserLoading.value
                ? _buttonSpinner()
                : const Text('Save Changes'),
          )),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonTextField(label: 'Name', hint: 'Enter Name', controller: nameCtrl),
            const SizedBox(height: 16),
            CommonTextField(
              label: 'Phone Number',
              hint: 'Enter Phone',
              controller: phoneCtrl,
              prefixIcon: LucideIcons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            CommonTextField(
              label: 'Email',
              hint: 'Enter Email',
              controller: emailCtrl,
              prefixIcon: LucideIcons.mail,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPatientDialog() {
    final booking = controller.bookingsByBookingId.value.firstOrNull;
    if (booking == null) return;

    final nameCtrl = TextEditingController(text: controller.detailPatientNameController.text);
    final phoneCtrl = TextEditingController(text: controller.detailPatientPhoneController.text);
    final emailCtrl = TextEditingController(text: controller.detailPatientEmailController.text);
    final ageCtrl = TextEditingController(text: controller.ageController.text);
    final yobCtrl = TextEditingController(text: controller.yearOfBirthController.text);
    final weightCtrl = TextEditingController(text: controller.weightController.text);
    final RxString tempGender = RxString(controller.selectedGender.value);
    final RxList<String> tempLanguages = RxList<String>.from(controller.selectedLanguages);
    final RxString tempRelation = RxString(controller.selectedRelation.value);
    final Rx<bool?> tempStaysAlone = Rx<bool?>(controller.patientStaysAlone.value);
    if (controller.languagesList.isEmpty) controller.fetchLanguages();

    Get.dialog(
      AppDialog(
        title: 'Edit Patient Details',
        icon: LucideIcons.bandage,
        tone: AppTone.info,
        maxWidth: 680,
        onClose: () => Get.back(),
        actions: [
          _cancelButton(),
          Obx(() => ElevatedButton(
            onPressed: controller.isUpdatePatientLoading.value
                ? null
                : () {
              if (nameCtrl.text.trim().isEmpty) {
                _showError('Name is required');
                return;
              }
              // updatePatient overwrites every column, so the
              // languages and stays-alone flag must be real values.
              if (tempLanguages.isEmpty) {
                _showError('Select at least one language');
                return;
              }
              if (tempStaysAlone.value == null) {
                _showError('Select whether the patient stays alone');
                return;
              }
              controller.updatePatient(
                patientId: booking.patientId,
                patientName: nameCtrl.text.trim(),
                phoneNumber: phoneCtrl.text.trim(),
                email: emailCtrl.text.trim(),
                age: ageCtrl.text.trim(),
                yob: yobCtrl.text.trim(),
                weight: weightCtrl.text.trim(),
                gender: tempGender.value,
                languages: tempLanguages.toList(),
                relation: tempRelation.value,
                isStayAlone: tempStaysAlone.value!,
              );
            },
            child: controller.isUpdatePatientLoading.value
                ? _buttonSpinner()
                : const Text('Save Changes'),
          )),
        ],
        child: _FormGrid(
          children: [
            CommonTextField(label: 'Name', hint: 'Enter Name', controller: nameCtrl),
            CommonTextField(label: 'Phone', hint: 'Enter Phone', controller: phoneCtrl, prefixIcon: LucideIcons.phone, keyboardType: TextInputType.phone),
            CommonTextField(label: 'Email', hint: 'Enter Email', controller: emailCtrl, prefixIcon: LucideIcons.mail, keyboardType: TextInputType.emailAddress),
            CommonTextField(label: 'Age', hint: 'Enter Age', controller: ageCtrl, keyboardType: TextInputType.number),
            CommonTextField(label: 'Year of Birth', hint: 'YYYY', controller: yobCtrl, keyboardType: TextInputType.number),
            CommonTextField(label: 'Weight (kg)', hint: 'Enter Weight', controller: weightCtrl, keyboardType: TextInputType.number),
            Obx(() => _buildEditableDropdown(label: 'Gender', value: tempGender.value, items: ['Male', 'Female', 'Other'], onChanged: (v) => tempGender.value = v ?? 'Male')),
            Obx(() => _buildEditableDropdown(
              label: 'Relation',
              value: tempRelation.value,
              items: {'Self', 'Son', 'Daughter', 'Spouse', 'Other', tempRelation.value}.toList(),
              onChanged: (v) => tempRelation.value = v ?? 'Self',
            )),
            _Full(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Language'),
                  Obx(() => Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: controller.languageNames.map((lang) {
                      final selected = tempLanguages.contains(lang);
                      return FilterChip(
                        label: Text(lang, style: TextStyle(fontSize: 12.5, fontWeight: selected ? FontWeight.w600 : FontWeight.w400, color: selected ? AppColor.cPrimaryButtonColor : AppColor.textPrimary)),
                        selected: selected,
                        onSelected: (v) {
                          if (v) {
                            tempLanguages.add(lang);
                          } else {
                            tempLanguages.remove(lang);
                          }
                        },
                        selectedColor: AppColor.primarySoft,
                        checkmarkColor: AppColor.cPrimaryButtonColor,
                        side: BorderSide(color: selected ? AppColor.cPrimaryButtonColor.withValues(alpha: 0.5) : AppColor.borderStrong),
                      );
                    }).toList(),
                  )),
                ],
              ),
            ),
            _Full(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Patient stays alone?'),
                  Obx(() => Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Yes'),
                        selected: tempStaysAlone.value == true,
                        onSelected: (_) => tempStaysAlone.value = true,
                      ),
                      ChoiceChip(
                        label: const Text('No'),
                        selected: tempStaysAlone.value == false,
                        onSelected: (_) => tempStaysAlone.value = false,
                      ),
                    ],
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditHealthDialog() {
    final medCtrl = TextEditingController(text: controller.medicalConditionController.text);
    final specCtrl =
    TextEditingController(text: controller.specialRequirementsController.text);

    Get.dialog(
      AppDialog(
        title: 'Edit Health Information',
        icon: LucideIcons.heartPulse,
        tone: AppTone.violet,
        maxWidth: 560,
        onClose: () => Get.back(),
        actions: [
          _cancelButton(),
          ElevatedButton(
            // NOTE: health/notes are part of the booking update payload.
            // Update local controllers then call booking update.
            onPressed: () {
              controller.medicalConditionController.text = medCtrl.text;
              controller.specialRequirementsController.text = specCtrl.text;
              Get.back();
              // Persist via updateBookingsTotal
              controller.updateBookingsTotal(bookingId);
            },
            child: const Text('Save Changes'),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextAreaField(label: 'Patient Health Conditions', controller: medCtrl),
            const SizedBox(height: 16),
            _buildTextAreaField(label: 'Special Care Requirements', controller: specCtrl),
          ],
        ),
      ),
    );
  }

  void _showEditAddressDialog() {
    final tagCtrl = TextEditingController(text: controller.detailAddressTagController.text);
    final countryCtrl = TextEditingController(text: controller.detailCountryController.text);
    final stateCtrl = TextEditingController(text: controller.detailStateController.text);
    final cityCtrl = TextEditingController(text: controller.detailCityController.text);
    final addr1Ctrl = TextEditingController(text: controller.detailAddressLine1Controller.text);
    final addr2Ctrl = TextEditingController(text: controller.detailAddressLine2Controller.text);
    final landmarkCtrl = TextEditingController(text: controller.detailLandmarkController.text);
    final localityCtrl = TextEditingController(text: controller.detailLocalityController.text);
    final pincodeCtrl = TextEditingController(text: controller.detailPincodeController.text);

    Get.dialog(
      AppDialog(
        title: 'Edit Address Details',
        icon: LucideIcons.mapPin,
        tone: AppTone.info,
        maxWidth: 680,
        onClose: () => Get.back(),
        actions: [
          _cancelButton(),
          Obx(() => ElevatedButton(
            onPressed: controller.isUpdateAddressLoading.value
                ? null
                : () {
              if (tagCtrl.text.trim().isEmpty) {
                _showError('Address tag name is required');
                return;
              }
              if (addr1Ctrl.text.trim().isEmpty) {
                _showError('Address line 1 is required');
                return;
              }
              if (pincodeCtrl.text.trim().isEmpty) {
                _showError('Pincode is required');
                return;
              }
              final bk = controller.bookingsByBookingId.value.firstOrNull;
              if (bk == null || bk.userId <= 0) {
                _showError('Booking client could not be determined');
                return;
              }
              controller.updateAddress(
                bookingId: bookingId,
                clientUserId: bk.userId,
                addressTagName: tagCtrl.text.trim(),
                country: countryCtrl.text.trim(),
                state: stateCtrl.text.trim(),
                city: cityCtrl.text.trim(),
                addressLine1: addr1Ctrl.text.trim(),
                addressLine2: addr2Ctrl.text.trim(),
                landmark: landmarkCtrl.text.trim(),
                locality: localityCtrl.text.trim(),
                pincode: pincodeCtrl.text.trim(),
              );
            },
            child: controller.isUpdateAddressLoading.value
                ? _buttonSpinner()
                : const Text('Save Address'),
          )),
        ],
        child: _FormGrid(
          children: [
            _Full(CommonTextField(
              label: 'Address Tag Name',
              hint: 'e.g. Home, Hospital',
              controller: tagCtrl,
            )),
            CommonTextField(label: 'Country', hint: 'Country', controller: countryCtrl),
            CommonTextField(label: 'State', hint: 'State', controller: stateCtrl),
            CommonTextField(label: 'City', hint: 'City', controller: cityCtrl),
            CommonTextField(label: 'Pincode', hint: 'Pincode', controller: pincodeCtrl, keyboardType: TextInputType.number),
            _Full(CommonTextField(
              label: 'Address Line 1',
              hint: 'Building/House No, Street Name',
              controller: addr1Ctrl,
            )),
            _Full(CommonTextField(
              label: 'Address Line 2',
              hint: 'Area, Colony',
              controller: addr2Ctrl,
            )),
            CommonTextField(label: 'Locality', hint: 'Locality', controller: localityCtrl),
            CommonTextField(label: 'Landmark', hint: 'Nearby Landmark', controller: landmarkCtrl),
          ],
        ),
      ),
    );
  }

  void _showEditServiceDialog() {
    final Rx<DateTime?> tempStart = Rx<DateTime?>(controller.startDate.value);
    final Rx<DateTime?> tempEnd = Rx<DateTime?>(controller.endDate.value);
    final Rx<TimeOfDay?> tempStartTime = Rx<TimeOfDay?>(controller.serviceStartTime.value);
    final Rx<TimeOfDay?> tempEndTime = Rx<TimeOfDay?>(controller.serviceEndTime.value);
    final RxInt tempBranchId = RxInt(controller.selectedBranchId.value);

    Get.dialog(
      AppDialog(
        title: 'Edit Service Details',
        icon: LucideIcons.stethoscope,
        tone: AppTone.success,
        maxWidth: 640,
        onClose: () => Get.back(),
        actions: [
          _cancelButton(),
          Obx(() => ElevatedButton(
            onPressed: controller.isUpdateBookingLoading.value
                ? null
                : () {
              if (tempStart.value == null || tempEnd.value == null) {
                _showError('Please select both start and end dates');
                return;
              }
              if (tempEnd.value!.isBefore(tempStart.value!)) {
                _showError('End date cannot be before the start date');
                return;
              }
              if (tempStartTime.value == null || tempEndTime.value == null) {
                _showError('Please select both start and end times');
                return;
              }
              // FIX: calls actual API
              controller.updateBooking(
                bookingId: bookingId,
                branchId: tempBranchId.value,
                serviceStartDate: tempStart.value!,
                serviceEndDate: tempEnd.value!,
                serviceStartTime: tempStartTime.value!,
                serviceEndTime: tempEndTime.value!,
                addressId: controller.selectedAddressId.value,
              );
            },
            child: controller.isUpdateBookingLoading.value
                ? _buttonSpinner()
                : const Text('Save Changes'),
          )),
        ],
        child: _FormGrid(
          children: [
            Obx(() => CommonDatePicker(label: 'Service Start Date', hint: 'Select Date', selectedDate: tempStart.value, onDateSelected: (d) => tempStart.value = d)),
            Obx(() => CommonDatePicker(label: 'Service End Date', hint: 'Select Date', selectedDate: tempEnd.value, onDateSelected: (d) => tempEnd.value = d)),
            _buildTimePicker('Start Time', tempStartTime),
            _buildTimePicker('End Time', tempEndTime),
          ],
        ),
      ),
    );
  }

  void _showEditLeadDialog() {
    final RxString tempLead = RxString(controller.selectedLeadType.value);
    final Rx<DateTime?> tempFollowup = Rx<DateTime?>(controller.selectedFollowupDate.value);

    Get.dialog(
      AppDialog(
        title: 'Edit Lead Details',
        icon: LucideIcons.trendingUp,
        tone: AppTone.warning,
        maxWidth: 520,
        onClose: () => Get.back(),
        actions: [
          _cancelButton(),
          ElevatedButton(
            onPressed: () {
              controller.selectedLeadType.value = tempLead.value;
              controller.selectedFollowupDate.value = tempFollowup.value;
              Get.back();
              controller.updateBookingsTotal(bookingId);
            },
            child: const Text('Save Changes'),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => _buildEditableDropdown(
              label: 'Lead Potential',
              value: tempLead.value,
              items: ['Cold', 'Warm', 'Hot'],
              onChanged: (v) => tempLead.value = v ?? '',
            )),
            const SizedBox(height: 16),
            Obx(() => CommonDatePicker(
              label: 'Next Followup Date',
              hint: 'Select Date (optional)',
              selectedDate: tempFollowup.value,
              onDateSelected: (d) => tempFollowup.value = d,
            )),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────
  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
        ),
      );

  Widget _editButton(String btnLabel, VoidCallback onTap) {
    final isMobile = SizeConfig.isMobile;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(LucideIcons.pencil, size: 18),
      label: Text(isMobile ? 'Edit' : btnLabel),
    );
  }

  Widget _buttonSpinner() => SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColor.cPrimaryButtonColor),
        ),
      );

  Widget _buildTimePicker(String label, Rx<TimeOfDay?> timeRx) {
    return Builder(builder: (context) {
      final radius = BorderRadius.circular(AppRadius.md);
      return Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          Material(
            color: AppColor.whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(color: AppColor.borderStrong),
            ),
            child: InkWell(
              borderRadius: radius,
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: timeRx.value ?? TimeOfDay.now(),
                );
                if (picked != null) timeRx.value = picked;
              },
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        timeRx.value != null
                            ? _fmtTime(timeRx.value!)
                            : 'Select time',
                        style: TextStyle(
                          fontSize: 14,
                          color: timeRx.value != null ? AppColor.textPrimary : AppColor.textTertiary,
                        ),
                      ),
                    ),
                    Icon(LucideIcons.clock,
                        size: 18, color: AppColor.textTertiary),
                  ],
                ),
              ),
            ),
          ),
        ],
      ));
    });
  }

  String _fmtTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.period == DayPeriod.am ? 'AM' : 'PM'}';
  }

  Widget _buildReadonlyDropdown({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColor.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColor.borderSubtle),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value.isEmpty ? '—' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 14,
                      color: AppColor.textSecondary),
                ),
              ),
              Icon(LucideIcons.chevronDown,
                  size: 20, color: AppColor.lightGrey),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return AppDropdownFormField<String>(
      label: label,
      hint: label,
      value: value.isEmpty ? null : value,
      items: items
          .map((e) => DropdownMenuItem<String>(
                value: e,
                child: Text(e),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTextAreaField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        TextField(
          controller: controller,
          maxLines: 4,
          enabled: enabled,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? AppColor.whiteColor : AppColor.surfaceMuted,
          ),
          style: TextStyle(
              fontSize: 14,
              color: enabled ? AppColor.textPrimary : AppColor.textSecondary),
        ),
      ],
    );
  }

  Widget _cancelButton() => OutlinedButton(
    onPressed: () => Get.back(),
    child: const Text('Cancel'),
  );

  void _showError(String msg) {
    Get.snackbar('Error', msg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColor.danger,
        colorText: AppColor.pureWhite);
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
      final twoCol = width >= 520;
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
