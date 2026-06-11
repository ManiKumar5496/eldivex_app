import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:eldivex_app/app/core/values/color_constants.dart';
import '../controllers/hostels_controller.dart';

class CreateHostelScreen extends StatelessWidget {
  const CreateHostelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HostelsController>();
    final isEdit = c.editingHostelId.value != null;

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Hostel' : 'New Hostel'),
        backgroundColor: AppColor.whiteColor,
        foregroundColor: AppColor.blackColor,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _section('Hostel Information'),
                _field('Hostel Name *', c.nameCtrl),
                _field('Address', c.addressCtrl, maxLines: 2),
                Row(children: [
                  Expanded(child: _field('City', c.cityCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: _field('State', c.stateCtrl)),
                ]),
                Row(children: [
                  Expanded(
                    child: _field('Pincode', c.pincodeCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _genderField(c)),
                ]),
                const SizedBox(height: 8),
                _section('Capacity & Pricing'),
                Row(children: [
                  Expanded(
                    child: _field('Rate / Day (₹) *', c.rateCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                        ]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field('Capacity (beds)', c.capacityCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                  ),
                ]),
                const SizedBox(height: 8),
                _section('Contact'),
                _field('Contact Person', c.contactPersonCtrl),
                Row(children: [
                  Expanded(
                    child: _field('Phone', c.contactPhoneCtrl,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _field('Email', c.contactEmailCtrl,
                          keyboardType: TextInputType.emailAddress)),
                ]),
                const SizedBox(height: 24),
                Obx(() => SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.cAppPrimaryColor,
                          foregroundColor: AppColor.buttonTextWhite,
                        ),
                        onPressed: c.isSubmitting.value
                            ? null
                            : () async {
                                final ok = await c.saveHostel();
                                if (ok) Get.back();
                              },
                        child: c.isSubmitting.value
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(isEdit ? 'Save Changes' : 'Create Hostel'),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        child: Text(title,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: AppColor.cAppPrimaryColor)),
      );

  Widget _field(String label, TextEditingController ctrl,
      {int maxLines = 1,
      TextInputType? keyboardType,
      List<TextInputFormatter>? inputFormatters}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColor.whiteColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _genderField(HostelsController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Obx(() => DropdownButtonFormField<String>(
            initialValue: c.gender.value,
            decoration: InputDecoration(
              labelText: 'Gender *',
              filled: true,
              fillColor: AppColor.whiteColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: HostelsController.genders
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: (v) => c.gender.value = v ?? 'Male',
          )),
    );
  }
}
