import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:eldivex_app/app/widgets/helper_ui.dart';
import '../../../core/values/color_constants.dart';
import '../../../core/values/size_configue.dart';
import '../../../core/values/text_style_constants.dart';
import '../controllers/settings_controller.dart';

class OtpCouponGeneration extends GetView<SettingsController> {
  const OtpCouponGeneration({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    SizeConfig.init(context);

    final bookingIdController = TextEditingController();
    final healthWorkerIdController = TextEditingController();
    final couponNameController = TextEditingController();
    final discountController = TextEditingController();
    final maxAmountController = TextEditingController();
    final basePriceController = TextEditingController();
    final discountAmountController = TextEditingController();
    // final finalPriceController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 32),

            // Get OTP Section
            _buildOtpSection(bookingIdController, healthWorkerIdController),
            const SizedBox(height: 32),

            // Create Coupon Section
            _buildCouponSection(
              couponNameController,
              discountController,
              maxAmountController,
              basePriceController,
              discountAmountController,
            ),

            /// Base Price
            const SizedBox(height: 20),

            // /// Final Price
            // _buildInputField(
            //   label: 'Final Price:',
            //   controller: finalPriceController,
            //   hintText: 'Auto Calculated',
            //   icon: Icons.price_check,
            //   readOnly: true,
            // ),
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

  Widget _buildOtpSection(
    TextEditingController bookingIdController,
    TextEditingController healthWorkerIdController,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.divColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
          Row(
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

                          if (controller.getOtpData.value?.data == null) {
                            HelperUi.showToast(
                              message:
                                  "Failed to generate OTP. Please check the details and try again.",
                            );
                          } else {
                            final otp = controller.getOtpData.value!.data!.otp;
                            _showOtpDialog(
                              bookingIdController.text,
                              healthWorkerIdController.text,
                              otp.toString(),
                            );
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
                          children: [
                            const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Go',
                              style: AppTextStyles.regular16blue.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () {
                  bookingIdController.clear();
                  healthWorkerIdController.clear();
                },
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

  Widget _buildCouponSection(
    TextEditingController couponNameController,
    TextEditingController discountController,
    TextEditingController maxAmountController,
    TextEditingController basePriceController,
    TextEditingController discountAmountController,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.divColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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

          // const SizedBox(height: 20),
          //
          // // Maximum Amount
          // _buildInputField(
          //   label: 'Maximum amount:',
          //   controller: maxAmountController,
          //   hintText: 'Enter Maximum amount',
          //   icon: Icons.attach_money,
          //   keyboardType: TextInputType.number,
          // ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isCreateCuponLoading.value
                      ? null
                      : () {
                          controller.createDiscountCoupen(
                            couponNameController.text,
                            discountController.text,
                            discountAmountController.text,
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
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          children: [
                            const Icon(
                              Icons.add_circle,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Create',
                              style: AppTextStyles.regular16blue.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () {
                  couponNameController.clear();
                  discountController.clear();
                  maxAmountController.clear();
                },
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
                  children: [
                    Icon(
                      Icons.clear,
                      color: AppColor.cPrimaryButtonColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'clear',
                      style: AppTextStyles.regular16blue.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => _showCouponsDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
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
                  children: [
                    const Icon(Icons.list_alt, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'View Coupons',
                      style: AppTextStyles.regular16blue.copyWith(
                        color: Colors.white,
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
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: Text(
            label,
            style: AppTextStyles.regular16blue.copyWith(
              color: AppColor.blackColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: TextField(
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
          ),
        ),
      ],
    );
  }

  void _showOtpDialog(String bookingId, String healthWorkerId, String otpData) {
    if (bookingId.isEmpty || healthWorkerId.isEmpty) {
      HelperUi.showToast(message: "Please enter below details");
      return;
    }

    // Generate mock OTP
    final otp = otpData;

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
                  color: AppColor.lightGreen.withOpacity(0.1),
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
                      AppColor.cPrimaryButtonColor.withOpacity(0.1),
                      AppColor.cPrimaryButtonColor.withOpacity(0.2),
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

              // Validity Info
              // Container(
              //   padding: const EdgeInsets.all(12),
              //   decoration: BoxDecoration(
              //     color: Colors.orange.withOpacity(0.1),
              //     borderRadius: BorderRadius.circular(8),
              //     border: Border.all(color: Colors.orange.withOpacity(0.3)),
              //   ),
              //   child: Row(
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       const Icon(
              //         Icons.access_time,
              //         color: Colors.orange,
              //         size: 20,
              //       ),
              //       const SizedBox(width: 8),
              //       Text(
              //         'Valid for 10 minutes',
              //         style: AppTextStyles.regular14black.copyWith(
              //           color: Colors.orange[800],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
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
                      color: Colors.white,
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

  Widget _buildCouponDetail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.regular14Gre),
        Text(
          value,
          style: AppTextStyles.regular16blue.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showCouponsDialog() {
    final searchController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          width: 600,
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
