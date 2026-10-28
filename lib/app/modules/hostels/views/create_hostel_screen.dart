import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../../../core/values/size_configue.dart';
import '../controllers/hostels_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class CreateHostelScreen extends StatelessWidget {
  const CreateHostelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final c = Get.find<HostelsController>();
    final isEdit = c.editingHostelId.value != null;

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
                AppPageHeader(
                  title: isEdit ? 'Edit Hostel' : 'New Hostel',
                  subtitle: 'Hostel details, daily rate and contact person',
                  breadcrumbs: ['Hostels', isEdit ? 'Edit Hostel' : 'New Hostel'],
                  // Same as the AppBar's automatic back button.
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                SizedBox(height: SizeConfig.isMobile ? 16 : 24),
                _section(
                  'Hostel Information',
                  LucideIcons.building2,
                  [
                    _field('Hostel Name *', c.nameCtrl),
                    _field('Address', c.addressCtrl, maxLines: 2),
                    _twoColumns(
                      _field('City', c.cityCtrl),
                      _field('State', c.stateCtrl),
                    ),
                    _twoColumns(
                      _field('Pincode', c.pincodeCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                      _genderField(c),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _section(
                  'Capacity & Pricing',
                  LucideIcons.banknote,
                  [
                    _twoColumns(
                      _field('Rate / Day (₹) *', c.rateCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                          ]),
                      _field('Capacity (beds)', c.capacityCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _section(
                  'Contact',
                  LucideIcons.contact,
                  [
                    _field('Contact Person', c.contactPersonCtrl),
                    _twoColumns(
                      _field('Phone', c.contactPhoneCtrl,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                      _field('Email', c.contactEmailCtrl,
                          keyboardType: TextInputType.emailAddress),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Text('Cancel'),
                    ),
                    Obx(() => ElevatedButton(
                          onPressed: c.isSubmitting.value
                              ? null
                              : () async {
                                  final ok = await c.saveHostel();
                                  if (ok) Get.back();
                                },
                          child: c.isSubmitting.value
                              ? SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColor.textTertiary))
                              : Text(isEdit ? 'Save Changes' : 'Create Hostel'),
                        )),
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

  /// A titled card holding a group of fields, 16px apart.
  Widget _section(String title, IconData icon, List<Widget> fields) {
    return AppCard(
      title: title,
      icon: icon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < fields.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            fields[i],
          ],
        ],
      ),
    );
  }

  /// Two fields side by side on wide cards, stacked on narrow ones.
  Widget _twoColumns(Widget left, Widget right) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 600) {
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

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColor.textSecondary)),
      );

  Widget _field(String label, TextEditingController ctrl,
      {int maxLines = 1,
      TextInputType? keyboardType,
      List<TextInputFormatter>? inputFormatters}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _label(label),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
        ),
      ],
    );
  }

  Widget _genderField(HostelsController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _label('Gender *'),
        Obx(() => DropdownButtonFormField<String>(
icon: const Icon(LucideIcons.chevronDown, size: 18),
              initialValue: HostelsController.normalizeGenderLabel(c.gender.value),
              items: HostelsController.genders
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => c.gender.value = v ?? 'Male',
            )),
      ],
    );
  }
}
