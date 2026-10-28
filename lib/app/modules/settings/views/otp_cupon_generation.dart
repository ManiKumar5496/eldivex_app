import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../core/values/text_style_constants.dart';
import '../controllers/settings_controller.dart';

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
        padding: EdgeInsets.all(SizeConfig.isMobile ? 12 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 32),

            // Get OTP Section
            _buildOtpSection(),
            const SizedBox(height: 32),

            // Create Coupon Section
            _buildCouponSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text('OTP & Coupon', style: AppTextStyles.heading),
      const SizedBox(height: 4),
      Text(
        'Manage customer OTP generation and create discount coupons.',
        style: AppTextStyles.regular14Gre,
      ),
        ],
      ),
    );
  }

  Widget _buildOtpSection() {
    final bookingIdController = controller.bookingIdController;
    final healthWorkerIdController = controller.hpUniqueIdController;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.divColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock_outline,
                color: AppColor.cPrimaryButtonColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text('Get OTP:', style: AppTextStyles.bold20),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: bookingIdController,
            decoration: InputDecoration(
              hintText: 'Enter Booking ID',
              hintStyle: AppTextStyles.regular14Gre,
              filled: true,
              fillColor: AppColor.fieldColorGrey,
              prefixIcon: Icon(
                Icons.receipt_long,
                color: AppColor.cPrimaryButtonColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColor.divColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColor.divColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColor.cPrimaryButtonColor,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: healthWorkerIdController,
            decoration: InputDecoration(
              hintText: 'Enter Health Worker ID',
              hintStyle: AppTextStyles.regular14Gre,
              filled: true,
              fillColor: AppColor.fieldColorGrey,
              prefixIcon: Icon(
                Icons.receipt_long,
                color: AppColor.cPrimaryButtonColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColor.divColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColor.divColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColor.cPrimaryButtonColor,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              Obx(
                () => controller.getOtpLoading.value
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.send,
                              color: AppColor.buttonTextWhite,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Go',
                              style: AppTextStyles.regular16blue.copyWith(
                                color: AppColor.whiteColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              OutlinedButton(
                onPressed: controller.clearOtpForm,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  side: BorderSide(color: AppColor.cPrimaryButtonColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.clear,
                      color: AppColor.cPrimaryButtonColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Clear',
                      style: AppTextStyles.regular16blue.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSection() {
    final couponNameController = controller.couponNameController;
    final discountController = controller.discountPercentController;
    final maxAmountController = controller.maxDiscountController;
    final basePriceController = controller.basePriceController;
    final discountAmountController = controller.discountAmountController;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.divColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_offer_outlined,
                color: AppColor.cPrimaryButtonColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text('Create New Coupon Code', style: AppTextStyles.bold20),
            ],
          ),
          const SizedBox(height: 24),

          // Coupon Name
          _buildInputField(
            label: 'Coupon code Name:',
            controller: couponNameController,
            hintText: 'Enter Coupon code Name',
            icon: Icons.label_outline,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            label: 'Base Price:',
            controller: basePriceController,
            hintText: 'Enter Base Price',
            icon: Icons.currency_rupee,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              controller.calculateDiscount(
                basePriceController.text,
                discountController.text,
                discountAmountController,
              );
            },
          ),

          const SizedBox(height: 20),

          /// Discount Amount (Auto)
          _buildInputField(
            label: 'Discount Amount:',
            controller: discountAmountController,
            hintText: 'Enter Discount Amount',
            icon: Icons.money_off,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              controller.calculatePercentage(
                basePriceController.text,
                discountAmountController.text,
                discountController,
              );
            },
          ),

          const SizedBox(height: 20),

          // Discount Percentage
          _buildInputField(
            label: 'Percentage of discount:',
            controller: discountController,
            hintText: 'Enter % of discount',
            icon: Icons.percent,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              controller.calculateDiscount(
                basePriceController.text,
                discountController.text,
                discountAmountController,
              );
            },
          ),

          const SizedBox(height: 20),

          // Maximum discount (sent as discount_upper_limit_value)
          _buildInputField(
            label: 'Maximum discount (₹):',
            controller: maxAmountController,
            hintText: 'Cap on the discount per booking',
            icon: Icons.currency_rupee,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          Text(
            'Base price and discount amount only help you work out the %; '
            'the coupon stores the % and the maximum discount.',
            style: AppTextStyles.regular14Gre,
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isCreateCuponLoading.value
                      ? null
                      : () {
                          controller.createDiscountCoupen(
                            couponNameController.text,
                            discountController.text,
                            maxAmountController.text,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isCreateCuponLoading.value
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColor.buttonTextWhite,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_circle,
                              color: AppColor.buttonTextWhite,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Create',
                              style: AppTextStyles.regular16blue.copyWith(
                                color: AppColor.whiteColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              OutlinedButton(
                onPressed: controller.clearCouponForm,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  side: BorderSide(color: AppColor.cPrimaryButtonColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.clear,
                      color: AppColor.cPrimaryButtonColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Clear',
                      style: AppTextStyles.regular16blue.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _showCouponsDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.fontColorGrey,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.list_alt, color: AppColor.buttonTextWhite, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'View Coupons',
                      style: AppTextStyles.regular16blue.copyWith(
                        color: AppColor.whiteColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
      style: AppTextStyles.regular16blue.copyWith(
        color: AppColor.fontColorBlack,
        fontWeight: FontWeight.w500,
      ),
    );
    final field = TextField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: AppColor.fieldColorGrey,
              prefixIcon: Icon(icon, color: AppColor.cPrimaryButtonColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColor.divColor),
              ),
            ),
          );
    // Label beside the field on wide screens, above it on phones.
    if (SizeConfig.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [labelWidget, const SizedBox(height: 6), field],
      );
    }
    return Row(
      children: [
        SizedBox(width: 200, child: labelWidget),
        Expanded(child: field),
      ],
    );
  }

  void _showOtpDialog(String bookingId, String otp) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColor.whiteColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.lightGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppColor.lightGreen,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'OTP Generated Successfully',
                style: AppTextStyles.bold20.copyWith(fontSize: 22),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Booking ID
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.fieldColorGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Booking ID: ', style: AppTextStyles.regular14Gre),
                    Text(
                      bookingId,
                      style: AppTextStyles.regular16blue.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // OTP Display
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColor.cPrimaryButtonColor.withValues(alpha: 0.1),
                      AppColor.cPrimaryButtonColor.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColor.cPrimaryButtonColor,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text('Your OTP', style: AppTextStyles.regular14Gre),
                    const SizedBox(height: 8),
                    Text(
                      otp,
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 32,
                        color: AppColor.cPrimaryButtonColor,
                        letterSpacing: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const SizedBox(height: 32),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.cPrimaryButtonColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: AppTextStyles.regular16blue.copyWith(
                      color: AppColor.whiteColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCouponsDialog() {
    final searchController = controller.couponSearchController;
    searchController.clear();
    controller.filterCoupons('');

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          width: SizeConfig.isMobile ? double.infinity : 600,
          decoration: BoxDecoration(
            color: AppColor.whiteColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("All Coupons", style: AppTextStyles.bold20),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Search Field
              TextField(
                controller: searchController,
                onChanged: (value) {
                  controller.filterCoupons(value);
                },
                decoration: InputDecoration(
                  hintText: "Search Coupon",
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColor.cPrimaryButtonColor,
                  ),
                  filled: true,
                  fillColor: AppColor.fieldColorGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColor.divColor),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Coupon List
              Obx(() {
                if (controller.getAllCuponsLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  );
                }

                if (controller.filteredCoupons.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Text("No Coupons Found"),
                  );
                }

                return SizedBox(
                  height: 400,
                  child: ListView.builder(
                    itemCount: controller.filteredCoupons.length,
                    itemBuilder: (context, index) {
                      final coupon = controller.filteredCoupons[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColor.fieldColorGrey,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColor.divColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              coupon.couponName,
                              style: AppTextStyles.bold20.copyWith(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text("Discount: ${coupon.discountPercentage}%"),
                            Text(
                              "Max Amount: ₹${coupon.discountUpperLimitValue}",
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
      ),
    );
  }
}
