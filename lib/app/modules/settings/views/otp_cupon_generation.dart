import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../widgets/ui/ui.dart';
import '../controllers/settings_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class OtpCouponGeneration extends GetView<SettingsController> {
  const OtpCouponGeneration({super.key});

  // Registered once on first access; the form controllers live in the
  // controller so typed input survives rebuilds.
  @override
  SettingsController get controller => Get.isRegistered<SettingsController>()
      ? Get.find<SettingsController>()
      : Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(SizeConfig.isMobile ? 16 : 24),
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 24),

                // Get OTP Section
                _buildOtpSection(),
                const SizedBox(height: 20),

                // Create Coupon Section
                _buildCouponSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const AppPageHeader(
      title: 'OTP & Coupons',
      subtitle: 'Manage customer OTP generation and create discount coupons.',
    );
  }

  Widget _buildOtpSection() {
    final bookingIdController = controller.bookingIdController;
    final healthWorkerIdController = controller.hpUniqueIdController;
    return AppCard(
      icon: LucideIcons.lock,
      title: 'Get OTP',
      subtitle: 'Retrieve the visit OTP for a booking and its health worker.',
      footer: Wrap(
        alignment: WrapAlignment.end,
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: controller.clearOtpForm,
            icon: const Icon(LucideIcons.x, size: 18),
            label: const Text('Clear'),
          ),
          Obx(() {
            final loading = controller.getOtpLoading.value;
            return ElevatedButton.icon(
              onPressed: loading
                  ? null
                  : () async {
                      await controller.getOtpForBooking(
                        bkngId: bookingIdController.text,
                        hpUniqueId: healthWorkerIdController.text,
                      );
                      // getOtpForBooking already toasts once on failure.
                      final otp = controller.getOtpData.value?.data?.otp;
                      if (otp != null) {
                        _showOtpDialog(bookingIdController.text.trim(), otp);
                      }
                    },
              icon: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(LucideIcons.send, size: 18),
              label: const Text('Go'),
            );
          }),
        ],
      ),
      child: _pair(
        _buildInputField(
          label: 'Booking ID',
          controller: bookingIdController,
          hintText: 'Enter Booking ID',
          icon: LucideIcons.receiptText,
        ),
        _buildInputField(
          label: 'Health Worker ID',
          controller: healthWorkerIdController,
          hintText: 'Enter Health Worker ID',
          icon: LucideIcons.idCard,
        ),
      ),
    );
  }

  Widget _buildCouponSection() {
    final couponNameController = controller.couponNameController;
    final discountController = controller.discountPercentController;
    final maxAmountController = controller.maxDiscountController;
    final basePriceController = controller.basePriceController;
    final discountAmountController = controller.discountAmountController;
    return AppCard(
      icon: LucideIcons.ticketPercent,
      iconTone: AppTone.violet,
      title: 'Create New Coupon Code',
      subtitle: 'Percentage discount with a per-booking cap.',
      actions: [
        OutlinedButton.icon(
          onPressed: () => _showCouponsDialog(),
          icon: const Icon(LucideIcons.list, size: 18),
          label: const Text('View Coupons'),
        ),
      ],
      footer: Wrap(
        alignment: WrapAlignment.end,
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: controller.clearCouponForm,
            icon: const Icon(LucideIcons.x, size: 18),
            label: const Text('Clear'),
          ),
          Obx(
            () => ElevatedButton.icon(
              onPressed: controller.isCreateCuponLoading.value
                  ? null
                  : () {
                      controller.createDiscountCoupen(
                        couponNameController.text,
                        discountController.text,
                        maxAmountController.text,
                      );
                    },
              icon: controller.isCreateCuponLoading.value
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(LucideIcons.plus, size: 18),
              label: const Text('Create'),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Coupon Name
          _buildInputField(
            label: 'Coupon Code Name',
            controller: couponNameController,
            hintText: 'Enter Coupon code Name',
            icon: LucideIcons.tag,
          ),
          const SizedBox(height: 16),
          _pair(
            _buildInputField(
              label: 'Base Price',
              controller: basePriceController,
              hintText: 'Enter Base Price',
              icon: LucideIcons.indianRupee,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                controller.calculateDiscount(
                  basePriceController.text,
                  discountController.text,
                  discountAmountController,
                );
              },
            ),

            /// Discount Amount (Auto)
            _buildInputField(
              label: 'Discount Amount',
              controller: discountAmountController,
              hintText: 'Enter Discount Amount',
              icon: LucideIcons.banknoteX,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                controller.calculatePercentage(
                  basePriceController.text,
                  discountAmountController.text,
                  discountController,
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _pair(
            // Discount Percentage
            _buildInputField(
              label: 'Percentage of discount',
              controller: discountController,
              hintText: 'Enter % of discount',
              icon: LucideIcons.percent,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                controller.calculateDiscount(
                  basePriceController.text,
                  discountController.text,
                  discountAmountController,
                );
              },
            ),

            // Maximum discount (sent as discount_upper_limit_value)
            _buildInputField(
              label: 'Maximum discount (₹)',
              controller: maxAmountController,
              hintText: 'Cap on the discount per booking',
              icon: LucideIcons.indianRupee,
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColor.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColor.borderSubtle),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(LucideIcons.info,
                      size: 16, color: AppColor.textTertiary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Base price and discount amount only help you work out the %; '
                    'the coupon stores the % and the maximum discount.',
                    style: TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: AppColor.textTertiary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Two fields side by side on wide cards, stacked on phones.
  Widget _pair(Widget left, Widget right) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 560) {
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    Function(String)? onChanged,
  }) {
    final labelWidget = Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColor.textSecondary,
      ),
    );
    final field = TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, size: 18),
      ),
    );
    // Label above the field.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [labelWidget, const SizedBox(height: 6), field],
    );
  }

  void _showOtpDialog(String bookingId, String otp) {
    Get.dialog(
      AppDialog(
        title: 'OTP Generated Successfully',
        subtitle: 'Share this code with the health worker to start the visit.',
        icon: LucideIcons.circleCheck,
        tone: AppTone.success,
        maxWidth: 440,
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Booking ID
            Row(
              children: [
                Text('Booking ID',
                    style: TextStyle(
                        fontSize: 13.5, color: AppColor.textTertiary)),
                const Spacer(),
                Text(
                  bookingId,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // OTP Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: AppColor.primarySoft,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: AppColor.cPrimaryButtonColor.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Your OTP',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    otp,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColor.cPrimaryButtonColor,
                      letterSpacing: 8,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCouponsDialog() {
    final searchController = controller.couponSearchController;
    searchController.clear();
    controller.filterCoupons('');

    Get.dialog(
      AppDialog(
        title: 'All Coupons',
        subtitle: 'Discount coupons available to your clients.',
        icon: LucideIcons.ticketPercent,
        tone: AppTone.violet,
        maxWidth: 600,
        onClose: () => Get.back(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// Search Field
            AppSearchField(
              controller: searchController,
              hint: 'Search Coupon',
              onChanged: (value) {
                controller.filterCoupons(value);
              },
            ),

            const SizedBox(height: 16),

            /// Coupon List
            Obx(() {
              if (controller.getAllCuponsLoading.value) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (controller.filteredCoupons.isEmpty) {
                return const AppEmptyState(
                  icon: LucideIcons.ticketPercent,
                  title: 'No Coupons Found',
                  compact: true,
                );
              }

              return Container(
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColor.divColor),
                ),
                clipBehavior: Clip.antiAlias,
                child: ListView.separated(
                  itemCount: controller.filteredCoupons.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: AppColor.borderSubtle),
                  itemBuilder: (context, index) {
                    final coupon = controller.filteredCoupons[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          const AppIconTile(
                            icon: LucideIcons.ticketPercent,
                            tone: AppTone.violet,
                            size: 34,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  coupon.couponName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Max Amount: ₹${coupon.discountUpperLimitValue}",
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      color: AppColor.textTertiary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          AppStatusBadge(
                            label: "Discount: ${coupon.discountPercentage}%",
                            tone: AppTone.success,
                            showDot: false,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
