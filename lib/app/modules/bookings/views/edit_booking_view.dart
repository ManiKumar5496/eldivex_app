import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import 'package:eldivex_app/app/core/values/text_style_constants.dart';
import 'package:eldivex_app/app/widgets/common_textfield.dart';
import 'package:eldivex_app/app/widgets/date_picker_common.dart';
import '../../../widgets/dropdown_common.dart';
import '../../../widgets/shimmer_loader.dart';
import '../controllers/bookings_controller.dart';

class EditBookingView extends GetView<BookingsController> {
  final int bookingId;

  const EditBookingView({
    super.key,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<BookingsController>()) {
      Get.put(BookingsController());
    }
    SizeConfig.init(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadBookingForEdit(bookingId);
    });

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text('Edit Booking', style: AppTextStyles.heading),
      ),
      body: Obx(() {
        if (controller.allBookingsByBookingIdLoading.value) {
          return const ShimmerLoader.form();
        }
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.isMobile ? 12 : SizeConfig.blockSizeHorizontal * 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBookingInfo(),
                SizedBox(height: SizeConfig.blockSizeVertical * 2),
                _buildUserDetails(),
                SizedBox(height: SizeConfig.blockSizeVertical * 2),
                _buildPatientDetails(),
                SizedBox(height: SizeConfig.blockSizeVertical * 2),
                _buildHealthConditions(),
                SizedBox(height: SizeConfig.blockSizeVertical * 2),
                _buildAddressSection(),
                SizedBox(height: SizeConfig.blockSizeVertical * 2),
                _buildServiceDetails(),
                SizedBox(height: SizeConfig.blockSizeVertical * 2),
                _buildLeadDetails(),
                SizedBox(height: SizeConfig.blockSizeVertical * 3),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────
  // Sections
  // ─────────────────────────────────────────────
  Widget _buildBookingInfo() {
    final isMobile = SizeConfig.isMobile;
    return _sectionCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Booking Information',
              style: TextStyle(
                fontSize: isMobile ? 18 : SizeConfig.blockSizeHorizontal * 1.5,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1.5,
              vertical: isMobile ? 4 : SizeConfig.blockSizeVertical * 0.6,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'ID: BK-$bookingId',
              style: TextStyle(
                fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1.1,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetails() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('User Details', 'Edit User', Colors.green.shade600, _showEditUserDialog),
          SizedBox(height: SizeConfig.isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
          _responsiveFieldRow([
            CommonTextField(label: 'Name', hint: 'Name', controller: controller.detailUserNameController, enabled: false),
            CommonTextField(label: 'Phone Number', hint: 'Phone', controller: controller.detailUserMobileController, prefixIcon: Icons.phone, keyboardType: TextInputType.phone, enabled: false),
          ]),
          SizedBox(height: SizeConfig.isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
          if (SizeConfig.isMobile)
            CommonTextField(label: 'Email', hint: 'Email', controller: controller.detailUserEmailController, prefixIcon: Icons.email, keyboardType: TextInputType.emailAddress, enabled: false)
          else
            Row(
              children: [
                Expanded(child: CommonTextField(label: 'Email', hint: 'Email', controller: controller.detailUserEmailController, prefixIcon: Icons.email, keyboardType: TextInputType.emailAddress, enabled: false)),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 1.5),
                const Expanded(child: SizedBox()),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPatientDetails() {
    final isMobile = SizeConfig.isMobile;
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Patient Details', 'Edit Patient', Colors.blue.shade600,
              _showEditPatientDialog),
          SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
          _responsiveFieldRow([
            CommonTextField(label: 'Name', hint: 'Name', controller: controller.detailPatientNameController, enabled: false),
            CommonTextField(label: 'Phone Number', hint: 'Phone', controller: controller.detailPatientPhoneController, prefixIcon: Icons.phone, keyboardType: TextInputType.phone, enabled: false),
          ]),
          SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
          _responsiveFieldRow([
            CommonTextField(label: 'Email', hint: 'Email', controller: controller.detailPatientEmailController, prefixIcon: Icons.email, keyboardType: TextInputType.emailAddress, enabled: false),
            CommonTextField(label: 'Age', hint: 'Age', controller: controller.ageController, keyboardType: TextInputType.number, enabled: false),
          ]),
          SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
          _responsiveFieldRow([
            CommonTextField(label: 'Weight (kg)', hint: 'Weight', controller: controller.weightController, keyboardType: TextInputType.number, enabled: false),
            Obx(() => _buildReadonlyDropdown(label: 'Gender', value: controller.selectedGender.value)),
          ]),
        ],
      ),
    );
  }

  Widget _buildHealthConditions() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Health Conditions & Requirements', 'Edit Health Info',
              Colors.purple.shade600, _showEditHealthDialog),
          SizedBox(height: SizeConfig.blockSizeVertical * 2),
          _buildTextAreaField(
            label: 'Patient Health Conditions',
            controller: controller.medicalConditionController,
            enabled: false,
          ),
          SizedBox(height: SizeConfig.blockSizeVertical * 1.5),
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
    final isMobile = SizeConfig.isMobile;
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Address Details', 'Edit Address', Colors.blue.shade600,
              _showEditAddressDialog),
          SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
          _responsiveFieldRow([
            CommonTextField(label: 'Address Tag', hint: 'Tag', controller: controller.detailAddressTagController, enabled: false),
            CommonTextField(label: 'Country', hint: 'Country', controller: controller.detailCountryController, enabled: false),
          ]),
          SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
          _responsiveFieldRow([
            CommonTextField(label: 'State', hint: 'State', controller: controller.detailStateController, enabled: false),
            CommonTextField(label: 'City', hint: 'City', controller: controller.detailCityController, enabled: false),
          ]),
          SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
          CommonTextField(label: 'Address Line 1', hint: 'Address Line 1', controller: controller.detailAddressLine1Controller, enabled: false),
          SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
          CommonTextField(label: 'Address Line 2', hint: 'Address Line 2', controller: controller.detailAddressLine2Controller, enabled: false),
          SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
          _responsiveFieldRow([
            CommonTextField(label: 'Locality', hint: 'Locality', controller: controller.detailLocalityController, enabled: false),
            CommonTextField(label: 'Landmark', hint: 'Landmark', controller: controller.detailLandmarkController, enabled: false),
          ]),
          SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
          if (isMobile)
            CommonTextField(label: 'Pincode', hint: 'Pincode', controller: controller.detailPincodeController, enabled: false)
          else
            Row(
              children: [
                Expanded(child: CommonTextField(label: 'Pincode', hint: 'Pincode', controller: controller.detailPincodeController, enabled: false)),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 1.5),
                const Expanded(child: SizedBox()),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildServiceDetails() {
    final isMobile = SizeConfig.isMobile;
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Service Details', 'Edit Service', Colors.teal.shade600,
              _showEditServiceDialog),
          SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
          _responsiveFieldRow([
            Obx(() => _buildReadonlyDropdown(label: 'Service City', value: controller.selectedBranch.value)),
            Obx(() => _buildReadonlyDropdown(label: 'Service', value: controller.selectedService.value)),
          ]),
          SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
          _responsiveFieldRow([
            Obx(() => CommonDatePicker(label: 'Service Start Date', hint: 'Select Date', selectedDate: controller.startDate.value, onDateSelected: (_) {}, enabled: false)),
            Obx(() => CommonDatePicker(label: 'Service End Date', hint: 'Select Date', selectedDate: controller.endDate.value, onDateSelected: (_) {}, enabled: false)),
          ]),
        ],
      ),
    );
  }

  Widget _buildLeadDetails() {
    final isMobile = SizeConfig.isMobile;
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Lead Details', 'Edit Lead', Colors.orange.shade700, _showEditLeadDialog),
          SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
          _responsiveFieldRow([
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
          ]),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Edit Dialogs
  // ─────────────────────────────────────────────

  void _showEditUserDialog() {
    if (controller.bookingsByBookingId.value.isEmpty) return;
    final booking = controller.bookingsByBookingId.value.first;
    final isMobile = SizeConfig.isMobile;

    final nameCtrl = TextEditingController(text: controller.detailUserNameController.text);
    final phoneCtrl = TextEditingController(text: controller.detailUserMobileController.text);
    final emailCtrl = TextEditingController(text: controller.detailUserEmailController.text);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: isMobile ? double.infinity : SizeConfig.blockSizeHorizontal * 45,
          padding: EdgeInsets.all(isMobile ? 16 : SizeConfig.blockSizeHorizontal * 2.5),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dialogHeader('Edit User Details', Icons.person, Colors.green.shade600),
                SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
                CommonTextField(label: 'Name', hint: 'Enter Name', controller: nameCtrl),
                SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
                CommonTextField(
                  label: 'Phone Number',
                  hint: 'Enter Phone',
                  controller: phoneCtrl,
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
                CommonTextField(
                  label: 'Email',
                  hint: 'Enter Email',
                  controller: emailCtrl,
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: isMobile ? 20 : SizeConfig.blockSizeVertical * 2.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _cancelButton(),
                    SizedBox(width: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 1),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: _buttonPadding(),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: controller.isUpdateUserLoading.value
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text('Save Changes'),
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

  void _showEditPatientDialog() {
    if (controller.bookingsByBookingId.value.isEmpty) return;
    final booking = controller.bookingsByBookingId.value.first;
    final isMobile = SizeConfig.isMobile;

    final nameCtrl = TextEditingController(text: controller.detailPatientNameController.text);
    final phoneCtrl = TextEditingController(text: controller.detailPatientPhoneController.text);
    final emailCtrl = TextEditingController(text: controller.detailPatientEmailController.text);
    final ageCtrl = TextEditingController(text: controller.ageController.text);
    final yobCtrl = TextEditingController(text: controller.yearOfBirthController.text);
    final weightCtrl = TextEditingController(text: controller.weightController.text);
    final RxString tempGender = RxString(controller.selectedGender.value);
    final RxList<String> tempLanguages = RxList<String>.from(controller.selectedLanguages);
    final RxString tempRelation = RxString(controller.selectedRelation.value);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: isMobile ? double.infinity : SizeConfig.blockSizeHorizontal * 55,
          padding: EdgeInsets.all(isMobile ? 16 : SizeConfig.blockSizeHorizontal * 2.5),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dialogHeader(
                    'Edit Patient Details', Icons.person_outline, Colors.blue.shade600),
                SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
                _responsiveFieldRow([
                  CommonTextField(label: 'Name', hint: 'Enter Name', controller: nameCtrl),
                  CommonTextField(label: 'Phone', hint: 'Enter Phone', controller: phoneCtrl, prefixIcon: Icons.phone, keyboardType: TextInputType.phone),
                ]),
                SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
                _responsiveFieldRow([
                  CommonTextField(label: 'Email', hint: 'Enter Email', controller: emailCtrl, prefixIcon: Icons.email, keyboardType: TextInputType.emailAddress),
                  CommonTextField(label: 'Age', hint: 'Enter Age', controller: ageCtrl, keyboardType: TextInputType.number),
                ]),
                SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
                _responsiveFieldRow([
                  CommonTextField(label: 'Year of Birth', hint: 'YYYY', controller: yobCtrl, keyboardType: TextInputType.number),
                  CommonTextField(label: 'Weight (kg)', hint: 'Enter Weight', controller: weightCtrl, keyboardType: TextInputType.number),
                ]),
                SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
                _responsiveFieldRow([
                  Obx(() => _buildEditableDropdown(label: 'Gender', value: tempGender.value, items: ['Male', 'Female', 'Other'], onChanged: (v) => tempGender.value = v ?? 'Male')),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Language', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                      const SizedBox(height: 6),
                      Obx(() => Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: ['English', 'Telugu', 'Hindi', 'Tamil'].map((lang) {
                          final selected = tempLanguages.contains(lang);
                          return FilterChip(
                            label: Text(lang, style: TextStyle(fontSize: 12, color: selected ? Colors.blue.shade700 : Colors.black87)),
                            selected: selected,
                            onSelected: (v) {
                              if (v) tempLanguages.add(lang);
                              else tempLanguages.remove(lang);
                            },
                            selectedColor: Colors.blue.shade100,
                            checkmarkColor: Colors.blue.shade700,
                            side: BorderSide(color: selected ? Colors.blue.shade300 : Colors.grey.shade300),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          );
                        }).toList(),
                      )),
                    ],
                  ),
                ]),
                SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
                Obx(() => _buildEditableDropdown(
                  label: 'Relation',
                  value: tempRelation.value,
                  items: ['Self', 'Son', 'Daughter', 'Spouse', 'Other'],
                  onChanged: (v) => tempRelation.value = v ?? 'Self',
                )),
                SizedBox(height: isMobile ? 20 : SizeConfig.blockSizeVertical * 2.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _cancelButton(),
                    SizedBox(width: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 1),
                    Obx(() => ElevatedButton(
                      onPressed: controller.isUpdatePatientLoading.value
                          ? null
                          : () {
                        if (nameCtrl.text.trim().isEmpty) {
                          _showError('Name is required');
                          return;
                        }
                        // FIX: calls actual API
                        controller.updatePatient(
                          patientId: booking.patientId,
                          patientName: nameCtrl.text.trim(),
                          phoneNumber: phoneCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          age: ageCtrl.text.trim(),
                          yob: yobCtrl.text.trim(),
                          weight: weightCtrl.text.trim(),
                          gender: tempGender.value,
                          language: tempLanguages.join(','),
                          relation: tempRelation.value,
                          isStayAlone: '0',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: _buttonPadding(),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: controller.isUpdatePatientLoading.value
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text('Save Changes'),
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

  void _showEditHealthDialog() {
    final medCtrl = TextEditingController(text: controller.medicalConditionController.text);
    final specCtrl =
    TextEditingController(text: controller.specialRequirementsController.text);
    final isMobile = SizeConfig.isMobile;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: isMobile ? double.infinity : SizeConfig.blockSizeHorizontal * 45,
          padding: EdgeInsets.all(isMobile ? 16 : SizeConfig.blockSizeHorizontal * 2.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dialogHeader(
                  'Edit Health Information', Icons.health_and_safety, Colors.purple.shade600),
              SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
              _buildTextAreaField(label: 'Patient Health Conditions', controller: medCtrl),
              SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
              _buildTextAreaField(label: 'Special Care Requirements', controller: specCtrl),
              SizedBox(height: isMobile ? 20 : SizeConfig.blockSizeVertical * 2.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _cancelButton(),
                  SizedBox(width: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 1),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade600,
                      foregroundColor: Colors.white,
                      padding: _buttonPadding(),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ],
          ),
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
    final isMobile = SizeConfig.isMobile;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: isMobile ? double.infinity : SizeConfig.blockSizeHorizontal * 55,
          padding: EdgeInsets.all(isMobile ? 16 : SizeConfig.blockSizeHorizontal * 2.5),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dialogHeader(
                    'Edit Address Details', Icons.location_on, Colors.blue.shade600),
                SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
                CommonTextField(
                  label: 'Address Tag Name',
                  hint: 'e.g. Home, Hospital',
                  controller: tagCtrl,
                ),
                SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
                _responsiveFieldRow([
                  CommonTextField(label: 'Country', hint: 'Country', controller: countryCtrl),
                  CommonTextField(label: 'State', hint: 'State', controller: stateCtrl),
                ]),
                SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
                _responsiveFieldRow([
                  CommonTextField(label: 'City', hint: 'City', controller: cityCtrl),
                  CommonTextField(label: 'Pincode', hint: 'Pincode', controller: pincodeCtrl, keyboardType: TextInputType.number),
                ]),
                SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
                CommonTextField(
                  label: 'Address Line 1',
                  hint: 'Building/House No, Street Name',
                  controller: addr1Ctrl,
                ),
                SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
                CommonTextField(
                  label: 'Address Line 2',
                  hint: 'Area, Colony',
                  controller: addr2Ctrl,
                ),
                SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
                _responsiveFieldRow([
                  CommonTextField(label: 'Locality', hint: 'Locality', controller: localityCtrl),
                  CommonTextField(label: 'Landmark', hint: 'Nearby Landmark', controller: landmarkCtrl),
                ]),
                SizedBox(height: isMobile ? 20 : SizeConfig.blockSizeVertical * 2.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _cancelButton(),
                    SizedBox(width: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 1),
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
                        // FIX: calls proper controller method
                        controller.updateAddress(
                          bookingId: bookingId,
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: _buttonPadding(),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: controller.isUpdateAddressLoading.value
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text('Save Address'),
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

  void _showEditServiceDialog() {
    final Rx<DateTime?> tempStart = Rx<DateTime?>(controller.startDate.value);
    final Rx<DateTime?> tempEnd = Rx<DateTime?>(controller.endDate.value);
    final Rx<TimeOfDay?> tempStartTime = Rx<TimeOfDay?>(controller.serviceStartTime.value);
    final Rx<TimeOfDay?> tempEndTime = Rx<TimeOfDay?>(controller.serviceEndTime.value);
    final RxInt tempBranchId = RxInt(controller.selectedBranchId.value);
    final isMobile = SizeConfig.isMobile;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: isMobile ? double.infinity : SizeConfig.blockSizeHorizontal * 55,
          padding: EdgeInsets.all(isMobile ? 16 : SizeConfig.blockSizeHorizontal * 2.5),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dialogHeader(
                    'Edit Service Details', Icons.medical_services, Colors.teal.shade600),
                SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
                _responsiveFieldRow([
                  Obx(() => CommonDatePicker(label: 'Service Start Date', hint: 'Select Date', selectedDate: tempStart.value, onDateSelected: (d) => tempStart.value = d)),
                  Obx(() => CommonDatePicker(label: 'Service End Date', hint: 'Select Date', selectedDate: tempEnd.value, onDateSelected: (d) => tempEnd.value = d)),
                ]),
                SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
                _responsiveFieldRow([
                  _buildTimePicker('Start Time', tempStartTime),
                  _buildTimePicker('End Time', tempEndTime),
                ]),
                SizedBox(height: isMobile ? 20 : SizeConfig.blockSizeVertical * 2.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _cancelButton(),
                    SizedBox(width: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 1),
                    Obx(() => ElevatedButton(
                      onPressed: controller.isUpdateBookingLoading.value
                          ? null
                          : () {
                        if (tempStart.value == null || tempEnd.value == null) {
                          _showError('Please select both start and end dates');
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        foregroundColor: Colors.white,
                        padding: _buttonPadding(),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: controller.isUpdateBookingLoading.value
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text('Save Changes'),
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

  void _showEditLeadDialog() {
    final isMobile = SizeConfig.isMobile;
    final RxString tempLead = RxString(controller.selectedLeadType.value);
    final Rx<DateTime?> tempFollowup = Rx<DateTime?>(controller.selectedFollowupDate.value);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: isMobile ? double.infinity : SizeConfig.blockSizeHorizontal * 45,
          padding: EdgeInsets.all(isMobile ? 16 : SizeConfig.blockSizeHorizontal * 2.5),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dialogHeader('Edit Lead Details', Icons.trending_up, Colors.orange.shade700),
                SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
                Obx(() => _buildEditableDropdown(
                  label: 'Lead Potential',
                  value: tempLead.value,
                  items: ['Cold', 'Warm', 'Hot'],
                  onChanged: (v) => tempLead.value = v ?? '',
                )),
                SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
                Obx(() => CommonDatePicker(
                  label: 'Next Followup Date',
                  hint: 'Select Date (optional)',
                  selectedDate: tempFollowup.value,
                  onDateSelected: (d) => tempFollowup.value = d,
                )),
                SizedBox(height: isMobile ? 20 : SizeConfig.blockSizeVertical * 2.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _cancelButton(),
                    SizedBox(width: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 1),
                    ElevatedButton(
                      onPressed: () {
                        controller.selectedLeadType.value = tempLead.value;
                        controller.selectedFollowupDate.value = tempFollowup.value;
                        Get.back();
                        controller.updateBookingsTotal(bookingId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                        padding: _buttonPadding(),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────
  Widget _buildTimePicker(String label, Rx<TimeOfDay?> timeRx) {
    return Builder(builder: (context) {
      final isMobile = SizeConfig.isMobile;
      return Obx(() => GestureDetector(
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: timeRx.value ?? TimeOfDay.now(),
          );
          if (picked != null) timeRx.value = picked;
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: isMobile ? 14 : SizeConfig.blockSizeHorizontal * 1.1,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700)),
            SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1.5,
                vertical: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.2,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    timeRx.value != null
                        ? _fmtTime(timeRx.value!)
                        : 'Select time',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : SizeConfig.blockSizeHorizontal * 1.1,
                      color: timeRx.value != null ? Colors.black87 : Colors.grey.shade500,
                    ),
                  ),
                  Icon(Icons.access_time,
                      size: isMobile ? 20 : SizeConfig.blockSizeHorizontal * 1.5, color: Colors.grey.shade600),
                ],
              ),
            ),
          ],
        ),
      ));
    });
  }

  String _fmtTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.period == DayPeriod.am ? 'AM' : 'PM'}';
  }

  /// Helper to build a responsive row of fields: Row on desktop, Column on mobile
  Widget _responsiveFieldRow(List<Widget> fields) {
    if (SizeConfig.isMobile) {
      return Column(
        children: fields
            .expand((w) => [w, const SizedBox(height: 12)])
            .toList()
          ..removeLast(),
      );
    }
    return Row(
      children: fields
          .expand((w) => [
                Expanded(child: w),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 1.5),
              ])
          .toList()
        ..removeLast(),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: EdgeInsets.all(SizeConfig.isMobile ? 12 : SizeConfig.blockSizeHorizontal * 2),
      child: child,
    );
  }

  Widget _sectionHeader(
      String title, String btnLabel, Color btnColor, VoidCallback onTap) {
    final isMobile = SizeConfig.isMobile;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(title,
              style: TextStyle(
                  fontSize: isMobile ? 18 : SizeConfig.blockSizeHorizontal * 1.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
        ),
        ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(Icons.edit, size: isMobile ? 16 : SizeConfig.blockSizeHorizontal * 1.2),
          label: Text(isMobile ? 'Edit' : btnLabel,
              style: TextStyle(fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1.1)),
          style: ElevatedButton.styleFrom(
            backgroundColor: btnColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1.5,
              vertical: isMobile ? 10 : SizeConfig.blockSizeVertical * 1,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _dialogHeader(String title, IconData icon, Color color) {
    final isMobile = SizeConfig.isMobile;
    return Row(
      children: [
        Icon(icon, color: color, size: isMobile ? 24 : SizeConfig.blockSizeHorizontal * 2),
        SizedBox(width: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 1),
        Expanded(
          child: Text(title,
              style: TextStyle(
                  fontSize: isMobile ? 18 : SizeConfig.blockSizeHorizontal * 1.5,
                  fontWeight: FontWeight.w600)),
        ),
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close),
          iconSize: isMobile ? 22 : SizeConfig.blockSizeHorizontal * 1.5,
        ),
      ],
    );
  }

  Widget _buildReadonlyDropdown({required String label, required String value}) {
    final isMobile = SizeConfig.isMobile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: isMobile ? 14 : SizeConfig.blockSizeHorizontal * 1.1,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700)),
        SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1.5,
            vertical: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.2,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value.isEmpty ? '—' : value,
                style: TextStyle(
                    fontSize: isMobile ? 14 : SizeConfig.blockSizeHorizontal * 1.1,
                    color: value.isEmpty ? Colors.grey.shade500 : Colors.grey.shade700),
              ),
              Icon(Icons.keyboard_arrow_down,
                  size: isMobile ? 20 : SizeConfig.blockSizeHorizontal * 1.5, color: Colors.grey.shade400),
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
    final isMobile = SizeConfig.isMobile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: isMobile ? 14 : SizeConfig.blockSizeHorizontal * 1.1,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700)),
        SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
        TextField(
          controller: controller,
          maxLines: 4,
          enabled: enabled,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1.5),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            filled: !enabled,
            fillColor: enabled ? Colors.white : Colors.grey.shade50,
          ),
          style: TextStyle(
              fontSize: isMobile ? 14 : SizeConfig.blockSizeHorizontal * 1.1,
              color: enabled ? Colors.black87 : Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _cancelButton() => OutlinedButton(
    onPressed: () => Get.back(),
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.grey.shade700,
      side: BorderSide(color: Colors.grey.shade300),
      padding: _buttonPadding(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    child: Text('Cancel', style: TextStyle(fontSize: SizeConfig.isMobile ? 14 : null)),
  );

  EdgeInsetsGeometry _buttonPadding() => SizeConfig.isMobile
      ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
      : EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 2,
          vertical: SizeConfig.blockSizeVertical * 1.2,
        );

  void _showError(String msg) {
    Get.snackbar('Error', msg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900);
  }
}