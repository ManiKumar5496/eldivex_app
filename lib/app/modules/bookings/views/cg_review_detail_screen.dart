import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import 'package:eldivex_app/app/widgets/ui/ui.dart';
import '../controllers/bookings_controller.dart';
import '../models/get_booking_hp_model.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

/// Status codes for HP flow:
///   1 = Shortlisted
///   2 = Interview Stage
///   3 = Finalized
///   4 = Active HP
///   5 = Released HP

class CgReviewDetailScreen extends StatefulWidget {
  final int bookingId;
  final GetBookingHpModel hp;

  const CgReviewDetailScreen({
    super.key,
    required this.bookingId,
    required this.hp,
  });

  @override
  State<CgReviewDetailScreen> createState() => _CgReviewDetailScreenState();
}

class _CgReviewDetailScreenState extends State<CgReviewDetailScreen> {
  late final BookingsController controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<BookingsController>()) {
      Get.put(BookingsController());
    }
    controller = Get.find<BookingsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getHealthProffApi(widget.bookingId);
    });
  }

  String _statusLabel(int status) {
    switch (status) {
      case 1:
        return 'Shortlisted';
      case 2:
        return 'Interview Stage';
      case 3:
        return 'Finalized';
      case 4:
        return 'Active HP';
      case 5:
        return 'Released';
      default:
        return 'Unknown';
    }
  }

  AppTone _statusTone(int status) {
    switch (status) {
      case 1:
        return AppTone.warning;
      case 2:
        return AppTone.violet;
      case 3:
        return AppTone.info;
      case 4:
        return AppTone.success;
      case 5:
        return AppTone.danger;
      default:
        return AppTone.neutral;
    }
  }

  IconData _statusIcon(int status) {
    switch (status) {
      case 1:
        return LucideIcons.star;
      case 2:
        return LucideIcons.calendar;
      case 3:
        return LucideIcons.circleCheck;
      case 4:
        return LucideIcons.user;
      case 5:
        return LucideIcons.logOut;
      default:
        return LucideIcons.circleHelp;
    }
  }

  String _nextActionLabel(int status) {
    switch (status) {
      case 1:
        return 'Schedule Interview';
      case 2:
        return 'Finalize';
      case 3:
        return 'Verify OTP';
      default:
        return '';
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColor.danger,
      colorText: AppColor.pureWhite,
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: Obx(() {
        final hpList = controller.allBookingHpData.value;
        final currentHp = hpList.firstWhereOrNull(
          (h) => h.hpUniqueId == widget.hp.hpUniqueId && h.bkngId == widget.bookingId,
        );
        final hp = currentHp ?? widget.hp;

        return SingleChildScrollView(
          padding: SizeConfig.pagePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppPageHeader(
                    title: 'Caregiver Review - HP${widget.hp.hpUniqueId}',
                    breadcrumbs: const ['Bookings', 'Manage Booking', 'Caregiver Review'],
                    onBack: () => Get.back(),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoCard(hp),
                  const SizedBox(height: 16),
                  _buildStatusTimeline(hp),
                  const SizedBox(height: 16),
                  _buildActionSection(hp),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────
  // HP Info Card
  // ─────────────────────────────────────────────
  Widget _buildInfoCard(GetBookingHpModel hp) {
    final isMobile = SizeConfig.isMobile;
    String formatDate(DateTime? date) =>
        date != null ? DateFormat('dd MMM yyyy').format(date) : '-';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppAvatar(
                name: '${hp.hpRegFirstName} ${hp.hpRegLastName}',
                size: isMobile ? 40 : 48,
                tone: _statusTone(hp.status),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HP${hp.hpRegFirstName} ${hp.hpRegLastName}',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 17,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Booking ID: ${hp.bkngId}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColor.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildStatusChip(hp.status),
            ],
          ),
          const SizedBox(height: 20),
          Divider(height: 1, color: AppColor.borderSubtle),
          const SizedBox(height: 20),
          AppResponsiveGrid(
            minItemWidth: 150,
            maxColumns: 4,
            children: [
              AppInfoRow(
                icon: LucideIcons.calendar,
                label: 'Planned Start',
                value: formatDate(hp.reportingDatePlanned),
              ),
              AppInfoRow(
                icon: LucideIcons.calendarCheck,
                label: 'Planned End',
                value: formatDate(hp.endDatePlanned),
              ),
              AppInfoRow(
                icon: LucideIcons.circlePlay,
                label: 'Actual Start',
                value: formatDate(hp.reportingDateActual),
              ),
              AppInfoRow(
                icon: LucideIcons.mic,
                label: 'Interview Date',
                value: formatDate(hp.interviewDate),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(int status) {
    return AppStatusBadge(
      label: _statusLabel(status),
      tone: _statusTone(status),
    );
  }

  // ─────────────────────────────────────────────
  // Status Timeline
  // ─────────────────────────────────────────────
  Widget _buildStatusTimeline(GetBookingHpModel hp) {
    final isMobile = SizeConfig.isMobile;
    final stages = [
      {'status': 1, 'label': 'Shortlisted'},
      {'status': 2, 'label': 'Interview Stage'},
      {'status': 3, 'label': 'Finalized'},
      {'status': 4, 'label': 'Active HP'},
    ];
    final circle = isMobile ? 28.0 : 34.0;

    Widget connector(bool active) => Expanded(
          child: Container(
            height: 2,
            color: active ? AppColor.success : AppColor.borderSubtle,
          ),
        );

    return AppCard(
      title: 'Status Flow',
      icon: LucideIcons.activity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(stages.length, (index) {
          final stage = stages[index];
          final stageStatus = stage['status'] as int;
          final isCompleted = hp.status > stageStatus;
          final isCurrent = hp.status == stageStatus;
          final isUpcoming = hp.status < stageStatus;
          final prevCompleted =
              index > 0 && hp.status > (stages[index - 1]['status'] as int);
          final tone = _statusTone(stageStatus);

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    if (index > 0)
                      connector(prevCompleted)
                    else
                      const Expanded(child: SizedBox()),
                    Container(
                      width: circle,
                      height: circle,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? AppColor.success
                            : isCurrent
                                ? tone.color
                                : AppColor.neutralSoft,
                        border: isCurrent
                            ? Border.all(
                                color: tone.color.withValues(alpha: 0.3),
                                width: 3,
                                strokeAlign: BorderSide.strokeAlignOutside,
                              )
                            : null,
                      ),
                      child: Icon(
                        isCompleted
                            ? LucideIcons.check
                            : _statusIcon(stageStatus),
                        color: isUpcoming
                            ? AppColor.textTertiary
                            : AppColor.pureWhite,
                        size: isMobile ? 14 : 17,
                      ),
                    ),
                    if (index < stages.length - 1)
                      connector(isCompleted)
                    else
                      const Expanded(child: SizedBox()),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    stage['label'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 13,
                      fontWeight:
                          isCurrent ? FontWeight.w600 : FontWeight.w400,
                      color: isUpcoming
                          ? AppColor.textTertiary
                          : AppColor.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Action Section
  // ─────────────────────────────────────────────
  Widget _buildActionSection(GetBookingHpModel hp) {
    if (hp.status > 3) return const SizedBox.shrink();
    final isMobile = SizeConfig.isMobile;

    final button = Obx(() {
      final isLoading = controller.isUpdateHPBookingLoading.value ||
          controller.isVerifyOtpLoading.value;

      return ElevatedButton.icon(
        onPressed: isLoading ? null : () => _handleAction(hp),
        icon: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColor.buttonTextWhite,
                ),
              )
            : Icon(
                hp.status == 3 ? LucideIcons.keyRound : LucideIcons.arrowRight,
                size: 18,
              ),
        label: Text(_nextActionLabel(hp.status)),
      );
    });

    return AppCard(
      title: 'Next Action',
      icon: LucideIcons.zap,
      iconTone: _statusTone(hp.status),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _getActionDescription(hp.status),
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColor.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          if (isMobile)
            button
          else
            Align(alignment: Alignment.centerRight, child: button),
        ],
      ),
    );
  }

  String _getActionDescription(int status) {
    switch (status) {
      case 1:
        return 'This caregiver has been shortlisted. Click below to schedule an interview.';
      case 2:
        return 'Interview has been scheduled. Click below to finalize this caregiver.';
      case 3:
        return 'This caregiver is finalized. Click below to verify the 6-digit OTP to confirm the caregiver placement.';
      default:
        return '';
    }
  }

  void _handleAction(GetBookingHpModel hp) {
    switch (hp.status) {
      case 1:
        // Shortlisted → Interview Stage (need interview date)
        _showInterviewDateDialog(hp);
        break;
      case 2:
        // Interview Stage → Finalized
        controller.updateHPBookingStatus(
          bookingId: widget.bookingId,
          hpUniqueId: hp.hpUniqueId,
          status: 3,
        );
        break;
      case 3:
        // Finalized → Verify OTP → Active HP
        _showOtpDialog(hp);
        break;
    }
  }

  // ─────────────────────────────────────────────
  // Interview Date Dialog
  // ─────────────────────────────────────────────
  void _showInterviewDateDialog(GetBookingHpModel hp) {
    final Rx<DateTime?> interviewDate = Rx<DateTime?>(null);

    Get.dialog(
      AppDialog(
        title: 'Schedule Interview',
        subtitle: 'Select the interview date for this caregiver:',
        icon: LucideIcons.calendar,
        tone: AppTone.violet,
        maxWidth: 480,
        onClose: () => Get.back(),
        actions: [
          OutlinedButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (interviewDate.value == null) {
                _showError('Please select an interview date');
                return;
              }
              Get.back();
              controller.updateHPBookingStatus(
                bookingId: widget.bookingId,
                hpUniqueId: hp.hpUniqueId,
                status: 2,
                interviewDate:  DateFormat('yyyy-MM-dd')
      .format(DateTime.parse(interviewDate.value.toString())),
              );
            },
            child: const Text('Schedule Interview'),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Interview Date',
              style: TextStyle(fontSize: 14, color: AppColor.textSecondary),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Material(
                color: AppColor.whiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  side: BorderSide(color: AppColor.borderStrong),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: Get.context!,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      interviewDate.value = picked;
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(LucideIcons.calendarDays,
                            color: AppColor.textTertiary, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            interviewDate.value != null
                                ? DateFormat('dd MMM yyyy')
                                    .format(interviewDate.value!)
                                : 'Select Interview Date',
                            style: TextStyle(
                              fontSize: 14,
                              color: interviewDate.value != null
                                  ? AppColor.textPrimary
                                  : AppColor.textTertiary,
                            ),
                          ),
                        ),
                      ],
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

  // ─────────────────────────────────────────────
  // OTP Verification Dialog
  // ─────────────────────────────────────────────
  void _showOtpDialog(GetBookingHpModel hp) {
    final isMobile = SizeConfig.isMobile;
    final List<TextEditingController> otpControllers =
        List.generate(6, (_) => TextEditingController());
    final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

    void closeDialog() {
      for (var c in otpControllers) {
        c.dispose();
      }
      for (var f in focusNodes) {
        f.dispose();
      }
      Get.back();
    }

    Get.dialog(
      AppDialog(
        title: 'Verify OTP',
        icon: LucideIcons.keyRound,
        tone: AppTone.success,
        maxWidth: 460,
        onClose: closeDialog,
        actions: [
          OutlinedButton(
            onPressed: closeDialog,
            child: const Text('Cancel'),
          ),
          Obx(() {
            final isLoading = controller.isVerifyOtpLoading.value;
            return ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      final otp = otpControllers
                          .map((c) => c.text)
                          .join();
                      if (otp.length != 6) {
                        _showError('Please enter all 6 digits');
                        return;
                      }
                      controller.verifyOtp(
                        bookingId: widget.bookingId,
                        hpUniqueId: hp.hpUniqueId,
                        otp: otp,
                      );
                    },
              child: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColor.buttonTextWhite,
                      ),
                    )
                  : const Text('Verify OTP'),
            );
          }),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.successSoft,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                children: [
                  Icon(
                    LucideIcons.shieldCheck,
                    color: AppColor.success,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter 6-Digit OTP',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.success,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Please enter the OTP to verify caregiver placement',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColor.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Container(
                  width: isMobile ? 40 : 46,
                  margin: EdgeInsets.symmetric(horizontal: isMobile ? 3 : 4),
                  child: TextField(
                    controller: otpControllers[index],
                    focusNode: focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColor.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        focusNodes[index + 1].requestFocus();
                      } else if (value.isEmpty && index > 0) {
                        focusNodes[index - 1].requestFocus();
                      }
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}
