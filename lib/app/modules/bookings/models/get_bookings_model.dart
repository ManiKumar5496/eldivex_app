class GetBookingsModel {
  final int id;
  final int? serviceTypeId;
  final int branchId;
  final int userId;
  final int patientId;
  final int? hpManager;

  final int? couponDiscountId;
  final String? couponDiscountAppliedValue;

  final int addressId;

  final String? patientConditionsOthers;
  final String? splCareRequirements;

  final DateTime? originalBookingDate;
  final DateTime? updatedBookingDate;

  final String baseRate;
  final String baseUnit;
  final double? baseDiscountPercentage;
  final double? finalRate;

  final int quantity;

  final DateTime? serviceStartDate;
  final DateTime? serviceEndDate;

  final String serviceStartTime;
  final String serviceEndTime;

  final String? placementTime;

  final DateTime? holdStartDate;
  final DateTime? holdEndDate;

  final String? splInstructions;
  final String? landmark;

  final String? pendingInternalAction;
  final String? leadPotential;

  final DateTime? followupDate;

  final DateTime? createdOn;
  final int createdBy;

  final DateTime? updatedOn;
  final int updatedBy;

  final bool? createdThroughNewWebApp;

  final String? status;

  final String? userName;
  final String? userMobile;
  final String? userEmail;

  // Address fields
  final String? addressTagName;
  final String? city;
  final String? state;
  final String? country;
  final String? addressLine1;
  final String? addressLine2;
  final String? locality;
  final String? pincode;

  final String? patientName;
  final int? patientAge;
  final int? patientGender;

  final String? patientPhoneNumber;
  final String? patientEmail;
  final int? patientYob;
  final String? patientWeight;

  final String? careManagerName;
  final String? careManagerMobile;

  final String? branchName;
  final String? branchCity;

  final String? serviceName;
  final String? serviceTypeName;

  final int? extensionStatus;
  final int? holdTicketOpen;
  final int? cancellationTicketOpen;

  const GetBookingsModel({
    required this.id,
    this.serviceTypeId,
    required this.branchId,
    required this.userId,
    required this.patientId,
    this.hpManager,
    this.couponDiscountId,
    this.couponDiscountAppliedValue,
    required this.addressId,
    this.patientConditionsOthers,
    this.splCareRequirements,
    this.originalBookingDate,
    this.updatedBookingDate,
    required this.baseRate,
    required this.baseUnit,
    this.baseDiscountPercentage,
    this.finalRate,
    required this.quantity,
    this.serviceStartDate,
    this.serviceEndDate,
    required this.serviceStartTime,
    required this.serviceEndTime,
    this.placementTime,
    this.holdStartDate,
    this.holdEndDate,
    this.splInstructions,
    this.landmark,
    this.pendingInternalAction,
    this.leadPotential,
    this.followupDate,
    this.createdOn,
    required this.createdBy,
    this.updatedOn,
    required this.updatedBy,
    this.createdThroughNewWebApp,
    this.status,
    this.userName,
    this.userMobile,
    this.userEmail,
    this.addressTagName,
    this.city,
    this.state,
    this.country,
    this.addressLine1,
    this.addressLine2,
    this.locality,
    this.pincode,
    this.patientName,
    this.patientAge,
    this.patientGender,
    this.patientPhoneNumber,
    this.patientEmail,
    this.patientYob,
    this.patientWeight,
    this.careManagerName,
    this.careManagerMobile,
    this.branchName,
    this.branchCity,
    this.serviceName,
    this.serviceTypeName,
    this.extensionStatus,
    this.holdTicketOpen,
    this.cancellationTicketOpen,
  });

  factory GetBookingsModel.fromJson(Map<String, dynamic> json) {
    return GetBookingsModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      serviceTypeId: (json['service_type_id'] as num?)?.toInt(),
      branchId: (json['branch_id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      patientId: (json['patient_id'] as num?)?.toInt() ?? 0,
      hpManager: (json['hp_manager'] as num?)?.toInt(),

      couponDiscountId: (json['coupon_discount_id'] as num?)?.toInt(),
      couponDiscountAppliedValue:
      json['coupon_discount_applied_value']?.toString(),

      addressId: (json['address_id'] as num?)?.toInt() ?? 0,

      patientConditionsOthers:
      json['patient_conditions_others'] as String?,
      splCareRequirements: json['spl_care_requirements'] as String?,

      originalBookingDate: _parseDate(json['original_booking_date']),
      updatedBookingDate: _parseDate(json['updated_booking_date']),

      baseRate: json['base_rate']?.toString() ?? '0.00',
      baseUnit: json['base_unit']?.toString() ?? '',

      baseDiscountPercentage: _parseDouble(json['base_discount_percentage']),
      finalRate: _parseDouble(json['final_rate']),

      quantity: (json['quantity'] as num?)?.toInt() ?? 0,

      serviceStartDate: _parseDate(json['service_start_date']),
      serviceEndDate: _parseDate(json['service_end_date']),

      serviceStartTime: json['service_start_time']?.toString() ?? '',
      serviceEndTime: json['service_end_time']?.toString() ?? '',

      placementTime: json['placement_time'] as String?,

      holdStartDate: _parseDate(json['hold_start_date']),
      holdEndDate: _parseDate(json['hold_end_date']),

      splInstructions: json['spl_instructions'] as String?,
      landmark: json['landmark'] as String?,

      pendingInternalAction: json['pending_internal_action'] as String?,
      leadPotential: json['lead_potential']?.toString(),

      followupDate: _parseDate(json['followup_date']),

      createdOn: _parseDate(json['created_on']),
      createdBy: (json['created_by'] as num?)?.toInt() ?? 0,

      updatedOn: _parseDate(json['updated_on']),
      updatedBy: (json['updated_by'] as num?)?.toInt() ?? 0,

      createdThroughNewWebApp: json['created_through_newwebapp'] == 1 ||
          json['created_through_newwebapp'] == true,

      status: json['status']?.toString(),

      userName: json['user_name'] as String?,
      userMobile: json['user_mobile'] as String?,
      userEmail: json['user_email'] as String?,

      // Address fields
      addressTagName: json['address_tag_name'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      addressLine1: json['address_line1'] as String?,
      addressLine2: json['address_line2'] as String?,
      locality: json['locality'] as String?,
      pincode: json['pincode']?.toString(),

      patientName: json['patient_name'] as String?,
      patientAge: (json['patient_age'] as num?)?.toInt(),
      patientGender: (json['patient_gender'] as num?)?.toInt(),

      patientPhoneNumber: json['patient_phone_number'] as String?,
      patientEmail: json['patient_email'] as String?,
      patientYob: (json['patient_yob'] as num?)?.toInt(),
      patientWeight: json['patient_weight']?.toString(),

      careManagerName: json['caremanager_name'] as String?,
      careManagerMobile: json['caremanager_mobile'] as String?,

      branchName: json['branch_name'] as String?,
      branchCity: json['branch_city'] as String?,
      serviceName: json['service_name'] as String?,
      serviceTypeName: json['service_type_name'] as String?,
      extensionStatus: (json['extension_status'] as num?)?.toInt(),
      holdTicketOpen: (json['hold_ticket_open'] as num?)?.toInt(),
      cancellationTicketOpen: (json['cancellation_ticket_open'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_type_id': serviceTypeId,
      'branch_id': branchId,
      'user_id': userId,
      'patient_id': patientId,
      'hp_manager': hpManager,
      'coupon_discount_id': couponDiscountId,
      'coupon_discount_applied_value': couponDiscountAppliedValue,
      'address_id': addressId,
      'patient_conditions_others': patientConditionsOthers,
      'spl_care_requirements': splCareRequirements,
      'original_booking_date': originalBookingDate?.toIso8601String(),
      'updated_booking_date': updatedBookingDate?.toIso8601String(),
      'base_rate': baseRate,
      'base_unit': baseUnit,
      'base_discount_percentage': baseDiscountPercentage,
      'final_rate': finalRate,
      'quantity': quantity,
      'service_start_date': serviceStartDate?.toIso8601String(),
      'service_end_date': serviceEndDate?.toIso8601String(),
      'service_start_time': serviceStartTime,
      'service_end_time': serviceEndTime,
      'placement_time': placementTime,
      'hold_start_date': holdStartDate?.toIso8601String(),
      'hold_end_date': holdEndDate?.toIso8601String(),
      'spl_instructions': splInstructions,
      'landmark': landmark,
      'pending_internal_action': pendingInternalAction,
      'lead_potential': leadPotential,
      'followup_date': followupDate?.toIso8601String(),
      'created_on': createdOn?.toIso8601String(),
      'created_by': createdBy,
      'updated_on': updatedOn?.toIso8601String(),
      'updated_by': updatedBy,
      'created_through_newwebapp': createdThroughNewWebApp,
      'status': status,
      'user_name': userName,
      'user_mobile': userMobile,
      'user_email': userEmail,
      'address_tag_name': addressTagName,
      'city': city,
      'state': state,
      'country': country,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'locality': locality,
      'pincode': pincode,
      'patient_name': patientName,
      'patient_age': patientAge,
      'patient_gender': patientGender,
      'patient_phone_number': patientPhoneNumber,
      'patient_email': patientEmail,
      'patient_yob': patientYob,
      'patient_weight': patientWeight,
      'caremanager_name': careManagerName,
      'caremanager_mobile': careManagerMobile,
      'branch_name': branchName,
      'branch_city': branchCity,
      'service_name': serviceName,
      'service_type_name': serviceTypeName,
      'extension_status': extensionStatus,
      'hold_ticket_open': holdTicketOpen,
      'cancellation_ticket_open': cancellationTicketOpen,
    };
  }

  // ─── Private helpers ────────────────────────────────────────────────────────

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }

  static List<GetBookingsModel> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((e) => GetBookingsModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  String toString() => 'GetBookingsModel(id: $id, status: $status)';
}