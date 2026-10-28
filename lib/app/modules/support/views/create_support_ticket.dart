import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../widgets/common_textfield.dart';
import '../../../widgets/dropdown_common.dart';
import '../../../widgets/ui/ui.dart';
import '../controllers/support_controller.dart';
import '../models/get_support_categories.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

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
      body: SingleChildScrollView(
        padding: SizeConfig.pagePadding,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppPageHeader(
                  title: 'Create Support Ticket',
                  subtitle: 'Fill the details below to raise a support request',
                  breadcrumbs:
                      pushed ? const ['Support', 'Create Ticket'] : const [],
                  onBack: pushed ? () => _leave(context) : null,
                ),
                SizedBox(height: SizeConfig.isMobile ? 16 : 24),
                AppCard(
                  title: 'Ticket Details',
                  subtitle: 'Who it is for, what kind of request, and the issue',
                  icon: LucideIcons.headset,
                  footer: _buildActions(context, pushed),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      /// BASIC DETAILS
                      _twoFieldRow(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonTextField(
                              label: 'User Id',
                              hint: 'Client User Id',
                              isMandatory: true,
                              keyboardType: TextInputType.number,
                              controller: controller.clientUserIdTextController,
                              onChanged: controller.onUserIdChanged,
                            ),
                            Obx(_buildClientStatus),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonTextField(
                              label: 'Booking ID',
                              hint: 'Enter booking ID',
                              isMandatory: true,
                              keyboardType: TextInputType.number,
                              controller: controller.bookingIdTextController,
                              onChanged: controller.onBookingIdChanged,
                            ),
                            Obx(() => _fieldStatus(
                                  controller.bookingIdLookupError.value,
                                  isError: true,
                                )),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

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

                      const SizedBox(height: 16),

                      /// DYNAMIC FIELDS BASED ON TICKET TYPE
                      Obx(() => _buildDynamicFields()),

                      Divider(height: 24, color: AppColor.borderSubtle),
                      const SizedBox(height: 8),

                      /// SUBJECT
                      CommonTextField(
                        label: 'Subject',
                        hint: 'Enter ticket subject',
                        isMandatory: true,
                        controller: controller.subjectTextController,
                        onChanged: (v) => controller.subject.value = v,
                      ),
                      const SizedBox(height: 16),

                      /// DESCRIPTION
                      CommonTextField(
                        label: 'Description',
                        hint: 'Describe your issue in detail',
                        isMandatory: true,
                        maxLines: 4,
                        controller: controller.descriptionTextController,
                        onChanged: (v) => controller.description.value = v,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ACTION BUTTONS (card footer, bottom-right)
  Widget _buildActions(BuildContext context, bool pushed) {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton(
          onPressed: () => _leave(context),
          child: Text(pushed ? 'Cancel' : 'Clear'),
        ),
        Obx(
          () => controller.isCreateSupportLoading.value
              ? ElevatedButton.icon(
                  onPressed: null,
                  icon: SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColor.textTertiary,
                    ),
                  ),
                  label: const Text('Submit Ticket'),
                )
              : ElevatedButton.icon(
                  onPressed: () async {
                    final ok = await controller.createSupportTicket();
                    // Pushed from bookings → return there; in the shell
                    // the form was reset and the list refreshed.
                    if (ok && pushed && context.mounted) {
                      Navigator.of(context).maybePop();
                    }
                  },
                  icon: const Icon(LucideIcons.send, size: 18),
                  label: const Text('Submit Ticket'),
                ),
        ),
      ],
    );
  }

  /// Under User Id: looking up…, the client's name (and phone), or an error.
  Widget _buildClientStatus() {
    if (controller.clientLookupLoading.value) {
      return _fieldStatus('Looking up client…');
    }
    if (controller.userIdLookupError.value.isNotEmpty) {
      return _fieldStatus(controller.userIdLookupError.value, isError: true);
    }
    final name = controller.clientName.value;
    if (name.isEmpty) return const SizedBox.shrink();
    final phone = controller.clientPhone.value;
    return _fieldStatus(
      phone.isEmpty || phone == 'NA' ? name : '$name · $phone',
      icon: LucideIcons.user,
    );
  }

  /// One line of feedback under a field; empty text renders nothing.
  Widget _fieldStatus(String text, {bool isError = false, IconData? icon}) {
    if (text.isEmpty) return const SizedBox.shrink();
    final color = isError ? AppColor.danger : AppColor.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 2),
      child: Row(
        children: [
          Icon(isError ? LucideIcons.circleAlert : icon ?? LucideIcons.user,
              size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: isError ? FontWeight.w400 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
    );
  }

  Widget _buildTicketTypeDropdown() {
    return Obx(() {
      if (controller.getSupportCategoriesLoading.value) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldLabel('Ticket Type'),
            const SizedBox(height: 8),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                border: Border.all(color: AppColor.borderStrong),
                borderRadius: BorderRadius.circular(AppRadius.md),
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
          _fieldLabel('Ticket Type'),
          const SizedBox(height: 8),
          AppDropdown<SupportCategory>(
            hint: 'Select ticket type',
            value: controller.getSupportCategoriesData
                .firstWhereOrNull((c) => c == controller.selectedTicketType.value),
            items: controller.getSupportCategoriesData
                .map((SupportCategory category) {
              return DropdownMenuItem<SupportCategory>(
                value: category,
                child: Text(category.name ?? 'Unknown'),
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
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          CommonTextField(
            label: 'Replacement Reason',
            hint: 'Enter reason for replacement',
            maxLines: 2,
            controller: controller.reasonTextController,
            onChanged: (v) => controller.replacementReason.value = v,
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          CommonTextField(
            label: 'Cancellation Reason',
            hint: 'Enter reason for cancellation',
            maxLines: 2,
            controller: controller.reasonTextController,
            onChanged: (v) => controller.cancellationReason.value = v,
          ),
          const SizedBox(height: 16),
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
        _fieldLabel(label),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
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
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.borderStrong),
              borderRadius: BorderRadius.circular(AppRadius.md),
              color: AppColor.whiteColor,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? DateFormat('dd-MM-yyyy').format(selectedDate)
                        : hint,
                    style: TextStyle(
                      fontSize: 14,
                      color: selectedDate != null
                          ? AppColor.textPrimary
                          : AppColor.lightGrey,
                    ),
                  ),
                ),
                Icon(
                  LucideIcons.calendar,
                  size: 18,
                  color: AppColor.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Side by side on wide cards, stacked on phones.
  Widget _twoFieldRow(Widget left, Widget right) {
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
}