import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:eldivex_app/app/core/values/color_constants.dart';
import 'package:eldivex_app/app/core/values/size_configue.dart';
import '../controllers/bookings_controller.dart';
import '../models/get_booking_hp_model.dart';

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

  Color _statusColor(int status) {
    switch (status) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.purple;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.green;
      case 5:
        return Colors.red;
      default:
        return AppColor.fontColorGrey;
    }
  }

  IconData _statusIcon(int status) {
    switch (status) {
      case 1:
        return Icons.star_outline;
      case 2:
        return Icons.calendar_today;
      case 3:
        return Icons.check_circle_outline;
      case 4:
        return Icons.person;
      case 5:
        return Icons.exit_to_app;
      default:
        return Icons.help_outline;
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

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.fontColorBlack),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Caregiver Review - HP${widget.hp.hpUniqueId}',
          style: TextStyle(
            color: AppColor.fontColorBlack,
            fontSize: SizeConfig.isMobile ? 18 : SizeConfig.blockSizeHorizontal * 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        final hpList = controller.allBookingHpData.value;
        final currentHp = hpList.firstWhereOrNull(
          (h) => h.hpUniqueId == widget.hp.hpUniqueId && h.bkngId == widget.bookingId,
        );
        final hp = currentHp ?? widget.hp;

        return SingleChildScrollView(
          padding: EdgeInsets.all(SizeConfig.isMobile ? 12 : SizeConfig.blockSizeHorizontal * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(hp),
              SizedBox(height: SizeConfig.isMobile ? 16 : SizeConfig.blockSizeVertical * 2.5),
              _buildStatusTimeline(hp),
              SizedBox(height: SizeConfig.isMobile ? 16 : SizeConfig.blockSizeVertical * 2.5),
              _buildActionSection(hp),
            ],
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

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 12 : SizeConfig.blockSizeHorizontal * 2),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColor.divColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: isMobile ? 20 : SizeConfig.blockSizeHorizontal * 2,
                backgroundColor: _statusColor(hp.status).withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: _statusColor(hp.status),
                  size: isMobile ? 20 : SizeConfig.blockSizeHorizontal * 2,
                ),
              ),
              SizedBox(width: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1.5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HP${hp.hpRegFirstName} ${hp.hpRegLastName}',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : SizeConfig.blockSizeHorizontal * 1.3,
                        fontWeight: FontWeight.w600,
                        color: AppColor.fontColorBlack,
                      ),
                    ),
                    SizedBox(height: SizeConfig.blockSizeVertical * 0.3),
                    Text(
                      'Booking ID: ${hp.bkngId}',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1,
                        color: AppColor.fontColorGrey,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(hp.status),
            ],
          ),
          SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
          Divider(color: AppColor.divColor),
          SizedBox(height: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5),
          if (isMobile)
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _infoTileMobile('Planned Start', formatDate(hp.reportingDatePlanned)),
                _infoTileMobile('Planned End', formatDate(hp.endDatePlanned)),
                _infoTileMobile('Actual Start', formatDate(hp.reportingDateActual)),
                _infoTileMobile('Interview Date', formatDate(hp.interviewDate)),
              ],
            )
          else
            Row(
              children: [
                _infoTile('Planned Start', formatDate(hp.reportingDatePlanned)),
                _infoTile('Planned End', formatDate(hp.endDatePlanned)),
                _infoTile('Actual Start', formatDate(hp.reportingDateActual)),
                _infoTile('Interview Date', formatDate(hp.interviewDate)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: SizeConfig.blockSizeHorizontal * 0.9,
              color: AppColor.fontColorGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: SizeConfig.blockSizeVertical * 0.3),
          Text(
            value,
            style: TextStyle(
              fontSize: SizeConfig.blockSizeHorizontal * 1.05,
              color: AppColor.fontColorBlack,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTileMobile(String label, String value) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColor.fontColorGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: AppColor.fontColorBlack,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(int status) {
    final color = _statusColor(status);
    final isMobile = SizeConfig.isMobile;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : SizeConfig.blockSizeHorizontal * 1,
        vertical: isMobile ? 4 : SizeConfig.blockSizeVertical * 0.5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          fontSize: isMobile ? 11 : SizeConfig.blockSizeHorizontal * 0.9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
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

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 12 : SizeConfig.blockSizeHorizontal * 2),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColor.divColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Flow',
            style: TextStyle(
              fontSize: isMobile ? 16 : SizeConfig.blockSizeHorizontal * 1.3,
              fontWeight: FontWeight.w600,
              color: AppColor.fontColorBlack,
            ),
          ),
          SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
          Row(
            children: List.generate(stages.length, (index) {
              final stage = stages[index];
              final stageStatus = stage['status'] as int;
              final isCompleted = hp.status > stageStatus;
              final isCurrent = hp.status == stageStatus;
              final isUpcoming = hp.status < stageStatus;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: isMobile ? 28 : SizeConfig.blockSizeHorizontal * 3,
                            height: isMobile ? 28 : SizeConfig.blockSizeHorizontal * 3,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted
                                  ? Colors.green
                                  : isCurrent
                                      ? _statusColor(stageStatus)
                                      : AppColor.divColor,
                              border: isCurrent
                                  ? Border.all(
                                      color: _statusColor(stageStatus)
                                          .withOpacity(0.3),
                                      width: 3,
                                    )
                                  : null,
                            ),
                            child: Icon(
                              isCompleted
                                  ? Icons.check
                                  : _statusIcon(stageStatus),
                              color: isUpcoming
                                  ? AppColor.fontColorGrey
                                  : AppColor.buttonTextWhite,
                              size: isMobile ? 14 : SizeConfig.blockSizeHorizontal * 1.5,
                            ),
                          ),
                          SizedBox(height: isMobile ? 6 : SizeConfig.blockSizeVertical * 0.8),
                          Text(
                            stage['label'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isMobile ? 10 : SizeConfig.blockSizeHorizontal * 0.85,
                              fontWeight:
                                  isCurrent ? FontWeight.w600 : FontWeight.w400,
                              color: isUpcoming
                                  ? AppColor.lightGrey
                                  : AppColor.fontColorBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index < stages.length - 1)
                      Expanded(
                        flex: 0,
                        child: Container(
                          height: 2,
                          width: isMobile ? 20 : SizeConfig.blockSizeHorizontal * 3,
                          color: isCompleted
                              ? Colors.green
                              : AppColor.divColor,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Action Section
  // ─────────────────────────────────────────────
  Widget _buildActionSection(GetBookingHpModel hp) {
    if (hp.status > 3) return const SizedBox.shrink();
    final isMobile = SizeConfig.isMobile;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 12 : SizeConfig.blockSizeHorizontal * 2),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColor.divColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next Action',
            style: TextStyle(
              fontSize: isMobile ? 16 : SizeConfig.blockSizeHorizontal * 1.3,
              fontWeight: FontWeight.w600,
              color: AppColor.fontColorBlack,
            ),
          ),
          SizedBox(height: isMobile ? 8 : SizeConfig.blockSizeVertical * 1),
          Text(
            _getActionDescription(hp.status),
            style: TextStyle(
              fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1,
              color: AppColor.fontColorGrey,
            ),
          ),
          SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
          Obx(() {
            final isLoading = controller.isUpdateHPBookingLoading.value ||
                controller.isVerifyOtpLoading.value;

            return SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : () => _handleAction(hp),
                icon: isLoading
                    ? SizedBox(
                        width: isMobile ? 16 : SizeConfig.blockSizeHorizontal * 1.2,
                        height: isMobile ? 16 : SizeConfig.blockSizeHorizontal * 1.2,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColor.buttonTextWhite,
                        ),
                      )
                    : Icon(
                        hp.status == 3 ? Icons.vpn_key : Icons.arrow_forward,
                        size: isMobile ? 18 : SizeConfig.blockSizeHorizontal * 1.3,
                      ),
                label: Text(
                  _nextActionLabel(hp.status),
                  style: TextStyle(
                    fontSize: isMobile ? 14 : SizeConfig.blockSizeHorizontal * 1.1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _statusColor(hp.status),
                  foregroundColor: AppColor.buttonTextWhite,
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            );
          }),
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
    final isMobile = SizeConfig.isMobile;
    final Rx<DateTime?> interviewDate = Rx<DateTime?>(null);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: isMobile ? double.infinity : SizeConfig.blockSizeHorizontal * 40,
          padding: EdgeInsets.all(isMobile ? 16 : SizeConfig.blockSizeHorizontal * 2.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      color: Colors.purple, size: isMobile ? 20 : SizeConfig.blockSizeHorizontal * 2),
                  SizedBox(width: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 1),
                  Text(
                    'Schedule Interview',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : SizeConfig.blockSizeHorizontal * 1.5,
                      fontWeight: FontWeight.w600,
                      color: AppColor.fontColorBlack,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                    iconSize: isMobile ? 20 : SizeConfig.blockSizeHorizontal * 1.5,
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
              Text(
                'Select the interview date for this caregiver:',
                style: TextStyle(
                  fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1.1,
                  color: AppColor.fontColorGrey,
                ),
              ),
              SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
              Obx(
                () => InkWell(
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
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1.5,
                      vertical: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColor.divColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month,
                            color: AppColor.fontColorGrey,
                            size: isMobile ? 18 : SizeConfig.blockSizeHorizontal * 1.3),
                        SizedBox(width: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 1),
                        Text(
                          interviewDate.value != null
                              ? DateFormat('dd MMM yyyy')
                                  .format(interviewDate.value!)
                              : 'Select Interview Date',
                          style: TextStyle(
                            fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1.1,
                            color: interviewDate.value != null
                                ? AppColor.fontColorBlack
                                : AppColor.fontColorGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 20 : SizeConfig.blockSizeVertical * 2.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColor.fontColorGrey,
                      side: BorderSide(color: AppColor.divColor),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : SizeConfig.blockSizeHorizontal * 2,
                        vertical: isMobile ? 10 : SizeConfig.blockSizeVertical * 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1.1),
                    ),
                  ),
                  SizedBox(width: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 1),
                  ElevatedButton(
                    onPressed: () {
                      if (interviewDate.value == null) {
                        Get.snackbar(
                          'Error',
                          'Please select an interview date',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.red.shade100,
                          colorText: Colors.red.shade900,
                        );
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: AppColor.buttonTextWhite,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : SizeConfig.blockSizeHorizontal * 2,
                        vertical: isMobile ? 10 : SizeConfig.blockSizeVertical * 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'Schedule Interview',
                      style: TextStyle(
                          fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1.1),
                    ),
                  ),
                ],
              ),
            ],
          ),
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

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: isMobile ? double.infinity : SizeConfig.blockSizeHorizontal * 40,
          padding: EdgeInsets.all(isMobile ? 16 : SizeConfig.blockSizeHorizontal * 2.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.vpn_key,
                      color: Colors.green, size: isMobile ? 20 : SizeConfig.blockSizeHorizontal * 2),
                  SizedBox(width: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 1),
                  Text(
                    'Verify OTP',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : SizeConfig.blockSizeHorizontal * 1.5,
                      fontWeight: FontWeight.w600,
                      color: AppColor.fontColorBlack,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      for (var c in otpControllers) {
                        c.dispose();
                      }
                      for (var f in focusNodes) {
                        f.dispose();
                      }
                      Get.back();
                    },
                    icon: const Icon(Icons.close),
                    iconSize: isMobile ? 20 : SizeConfig.blockSizeHorizontal * 1.5,
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 16 : SizeConfig.blockSizeVertical * 2),
              Container(
                padding: EdgeInsets.all(isMobile ? 12 : SizeConfig.blockSizeHorizontal * 1.5),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.verified_user,
                      color: Colors.green,
                      size: isMobile ? 32 : SizeConfig.blockSizeHorizontal * 3,
                    ),
                    SizedBox(height: isMobile ? 8 : SizeConfig.blockSizeVertical * 1),
                    Text(
                      'Enter 6-Digit OTP',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : SizeConfig.blockSizeHorizontal * 1.2,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                    SizedBox(height: isMobile ? 4 : SizeConfig.blockSizeVertical * 0.5),
                    Text(
                      'Please enter the OTP to verify caregiver placement',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : SizeConfig.blockSizeHorizontal * 0.95,
                        color: AppColor.fontColorGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 20 : SizeConfig.blockSizeVertical * 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    width: isMobile ? 40 : SizeConfig.blockSizeHorizontal * 4,
                    margin: EdgeInsets.symmetric(
                      horizontal: isMobile ? 3 : SizeConfig.blockSizeHorizontal * 0.4,
                    ),
                    child: TextField(
                      controller: otpControllers[index],
                      focusNode: focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(
                        fontSize: isMobile ? 20 : SizeConfig.blockSizeHorizontal * 1.8,
                        fontWeight: FontWeight.w700,
                        color: AppColor.fontColorBlack,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.symmetric(
                          vertical: isMobile ? 12 : SizeConfig.blockSizeVertical * 1.5,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColor.divColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColor.divColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.green, width: 2),
                        ),
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
              SizedBox(height: isMobile ? 20 : SizeConfig.blockSizeVertical * 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      for (var c in otpControllers) {
                        c.dispose();
                      }
                      for (var f in focusNodes) {
                        f.dispose();
                      }
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColor.fontColorGrey,
                      side: BorderSide(color: AppColor.divColor),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : SizeConfig.blockSizeHorizontal * 2,
                        vertical: isMobile ? 10 : SizeConfig.blockSizeVertical * 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          fontSize: isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1.1),
                    ),
                  ),
                  SizedBox(width: isMobile ? 8 : SizeConfig.blockSizeHorizontal * 1),
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
                                Get.snackbar(
                                  'Error',
                                  'Please enter all 6 digits',
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: Colors.red.shade100,
                                  colorText: Colors.red.shade900,
                                );
                                return;
                              }
                              controller.verifyOtp(
                                bookingId: widget.bookingId,
                                hpUniqueId: hp.hpUniqueId,
                                otp: otp,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: AppColor.buttonTextWhite,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16 : SizeConfig.blockSizeHorizontal * 2,
                          vertical: isMobile ? 10 : SizeConfig.blockSizeVertical * 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: isMobile ? 16 : SizeConfig.blockSizeHorizontal * 1.2,
                              height: isMobile ? 16 : SizeConfig.blockSizeHorizontal * 1.2,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColor.buttonTextWhite,
                              ),
                            )
                          : Text(
                              'Verify OTP',
                              style: TextStyle(
                                  fontSize:
                                      isMobile ? 13 : SizeConfig.blockSizeHorizontal * 1.1),
                            ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
