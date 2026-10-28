import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/text_style_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../widgets/common_textfield.dart';
import '../../../widgets/dropdown_common.dart';
import '../controllers/support_controller.dart';
import '../models/get_support_categories.dart';

class CreateSupportTicket extends GetView<SupportController> {
  const CreateSupportTicket({super.key});

  // Registered once on first access (shell page has no route binding).
  @override
  SupportController get controller => Get.isRegistered<SupportController>()
      ? Get.find<SupportController>()
      : Get.put(SupportController());

  /// True when pushed from Manage Bookings (Get.to with {bookingId, userId});
  /// false when shown as a page inside the admin shell.
  bool _isPushed(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    return args is Map && args.containsKey('bookingId');
  }

  /// Leave the screen: pop only when pushed — inside the shell, Get.back()
  /// would pop the whole shell, so just reset the form there.
  void _leave(BuildContext context) {
    controller.clearForm();
    if (_isPushed(context)) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final pushed = _isPushed(context);

    // Pre-fill when opened from bookings via Get.to(..., arguments: {...}).
    // applyPrefillArgs ignores arguments it has already applied.
    if (pushed) {
      final args = ModalRoute.of(context)?.settings.arguments;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.applyPrefillArgs(args);
      });
    }

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      appBar: pushed ? _buildAppBar(context) : null,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create Support Ticket', style: AppTextStyles.heading),
                const SizedBox(height: 6),
                Text(
                  'Fill the details below to raise a support request',
                  style: AppTextStyles.regular14Gre,
                ),
                const SizedBox(height: 32),

                /// BASIC DETAILS
                _twoFieldRow(
                  CommonTextField(
                    label: 'User Id',
                    hint: 'Client User Id',
                    isMandatory: true,
                    keyboardType: TextInputType.number,
                    controller: controller.clientUserIdTextController,
                    onChanged: (v) => controller.clientUserId.value = v,
                  ),
                  CommonTextField(
                    label: 'Booking ID',
                    hint: 'Enter booking ID',
                    isMandatory: true,
                    controller: controller.bookingIdTextController,
                    onChanged: (v) => controller.bookingId.value = v,
                  ),
                ),

                const SizedBox(height: 20),

                /// TICKET TYPE & PRIORITY DROPDOWNS
                _twoFieldRow(
                  _buildTicketTypeDropdown(),
                  Obx(
                        () => CommonDropdown(
                      label: 'Priority',
                      hint: 'Select priority',
                      isMandatory: true,
                      value: controller.priority.value.isEmpty
                          ? null
                          : controller.priority.value,
                      items: const ['Low', 'Medium', 'High', 'Urgent'],
                      onChanged: (v) => controller.priority.value = v ?? '',
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// DYNAMIC FIELDS BASED ON TICKET TYPE
                Obx(() => _buildDynamicFields()),

                const SizedBox(height: 20),

                /// SUBJECT
                CommonTextField(
                  label: 'Subject',
                  hint: 'Enter ticket subject',
                  isMandatory: true,
                  controller: controller.subjectTextController,
                  onChanged: (v) => controller.subject.value = v,
                ),
                const SizedBox(height: 20),

                /// DESCRIPTION
                CommonTextField(
                  label: 'Description',
                  hint: 'Describe your issue in detail',
                  isMandatory: true,
                  maxLines: 4,
                  controller: controller.descriptionTextController,
                  onChanged: (v) => controller.description.value = v,
                ),

                const SizedBox(height: 40),

                /// ACTION BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => _leave(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                      ),
                      child: Text(pushed ? 'Cancel' : 'Clear'),
                    ),
                    const SizedBox(width: 12),
                    Obx(
                          () => controller.isCreateSupportLoading.value
                          ? const SizedBox(
                        height: 40,
                        width: 40,
                        child: CircularProgressIndicator(),
                      )
                          : ElevatedButton(
                        onPressed: () async {
                          final ok = await controller.createSupportTicket();
                          // Pushed from bookings → return there; in the shell
                          // the form was reset and the list refreshed.
                          if (ok && pushed && context.mounted) {
                            Navigator.of(context).maybePop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.cPrimaryButtonColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                        ),
                        child: Text(
                          'Submit Ticket',
                          style: TextStyle(color: AppColor.buttonTextWhite),
                        ),
                      ),
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

  Widget _buildTicketTypeDropdown() {
    return Obx(() {
      if (controller.getSupportCategoriesLoading.value) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ticket Type',
              style: AppTextStyles.regular14black,
            ),
            const SizedBox(height: 8),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.divColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ticket Type',
            style: AppTextStyles.regular14black,
          ),
          const SizedBox(height: 8),
          AppDropdown<SupportCategory>(
            hint: 'Select ticket type',
            value: controller.getSupportCategoriesData
                .firstWhereOrNull((c) => c == controller.selectedTicketType.value),
            items: controller.getSupportCategoriesData
                .map((SupportCategory category) {
              return DropdownMenuItem<SupportCategory>(
                value: category,
                child: Text(
                  category.name ?? 'Unknown',
                  style: AppTextStyles.regular14black,
                ),
              );
            }).toList(),
            onChanged: (SupportCategory? newValue) {
              controller.selectedTicketType.value = newValue;
              controller.resetDynamicFields();
            },
          ),
        ],
      );
    });
  }

  Widget _buildDynamicFields() {
    if (controller.selectedTicketType.value == null) {
      return const SizedBox.shrink();
    }

    final ticketTypeName = controller.selectedTicketType.value!.name?.toLowerCase() ?? '';

    // HOLD BOOKING - Show Hold Start Date & Hold End Date
    if (ticketTypeName.contains('hold')) {
      return Column(
        children: [
          _twoFieldRow(
            _buildDateField(
              label: 'Hold Start Date',
              hint: 'Select start date',
              selectedDate: controller.holdStartDate.value,
              onDateSelected: (date) => controller.holdStartDate.value = date,
            ),
            _buildDateField(
              label: 'Hold End Date',
              hint: 'Select end date',
              selectedDate: controller.holdEndDate.value,
              onDateSelected: (date) => controller.holdEndDate.value = date,
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    }

    // REPLACEMENT - Show Replacement Planned Date & Reason
    if (ticketTypeName.contains('replacement')) {
      return Column(
        children: [
          _buildDateField(
            label: 'Replacement Planned Date',
            hint: 'Select planned date',
            selectedDate: controller.replacementPlannedDate.value,
            onDateSelected: (date) => controller.replacementPlannedDate.value = date,
          ),
          const SizedBox(height: 20),
          CommonTextField(
            label: 'Replacement Reason',
            hint: 'Enter reason for replacement',
            maxLines: 2,
            controller: controller.reasonTextController,
            onChanged: (v) => controller.replacementReason.value = v,
          ),
          const SizedBox(height: 20),
        ],
      );
    }

    // CANCEL SERVICE - Show Last Service Date & Cancellation Reason
    if (ticketTypeName.contains('cancel')) {
      return Column(
        children: [
          _buildDateField(
            label: 'Last Service Date',
            hint: 'Select last service date',
            selectedDate: controller.lastServiceDate.value,
            onDateSelected: (date) => controller.lastServiceDate.value = date,
          ),
          const SizedBox(height: 20),
          CommonTextField(
            label: 'Cancellation Reason',
            hint: 'Enter reason for cancellation',
            maxLines: 2,
            controller: controller.reasonTextController,
            onChanged: (v) => controller.cancellationReason.value = v,
          ),
          const SizedBox(height: 20),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildDateField({
    required String label,
    required String hint,
    required DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.regular14black,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: Get.context!,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(DateTime.now().year + 5),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: AppColor.cPrimaryButtonColor,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.divColor),
              borderRadius: BorderRadius.circular(8),
              color: AppColor.whiteColor,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? DateFormat('dd-MM-yyyy').format(selectedDate)
                        : hint,
                    style: selectedDate != null
                        ? AppTextStyles.regular14Gre
                        : AppTextStyles.regular14Gre,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: AppColor.divColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.whiteColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColor.fontColorBlack),
        onPressed: () => _leave(context),
      ),
      title: Text(
        'Support',
        style: AppTextStyles.semiBold18.copyWith(
          color: AppColor.fontColorBlack,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColor.whiteColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColor.divColor),
    );
  }

  Widget _twoFieldRow(Widget left, Widget right) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }
}