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
  // Days since service_end_date; only meaningful when extensionStatus == 4.
  final int? overdueDays;
  final int? holdTicketOpen;
  final int? cancellationTicketOpen;

  // Patient preferences (only present when getUserBookings selects them).
  final String? patientLanguages;
  final String? patientRelation;
  final int? patientIsStayAlone;

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
    this.overdueDays,
    this.holdTicketOpen,
    this.cancellationTicketOpen,
    this.patientLanguages,
    this.patientRelation,
    this.patientIsStayAlone,
  });

  factory GetBookingsModel.fromJson(Map<String, dynamic> json) {
    return GetBookingsModel(
      id: _toInt(json['id']) ?? 0,
      serviceTypeId: _toInt(json['service_type_id']),
      branchId: _toInt(json['branch_id']) ?? 0,
      userId: _toInt(json['user_id']) ?? 0,
      patientId: _toInt(json['patient_id']) ?? 0,
      hpManager: _toInt(json['hp_manager']),

      couponDiscountId: _toInt(json['coupon_discount_id']),
      couponDiscountAppliedValue:
      json['coupon_discount_applied_value']?.toString(),

      addressId: _toInt(json['address_id']) ?? 0,

      patientConditionsOthers:
      _str(json['patient_conditions_others']),
      splCareRequirements: _str(json['spl_care_requirements']),

      originalBookingDate: _parseDate(json['original_booking_date']),
      updatedBookingDate: _parseDate(json['updated_booking_date']),

      baseRate: json['base_rate']?.toString() ?? '0.00',
      baseUnit: json['base_unit']?.toString() ?? '',

      baseDiscountPercentage: _parseDouble(json['base_discount_percentage']),
      finalRate: _parseDouble(json['final_rate']),

      quantity: _toInt(json['quantity']) ?? 0,

      serviceStartDate: _parseDate(json['service_start_date']),
      serviceEndDate: _parseDate(json['service_end_date']),

      serviceStartTime: json['service_start_time']?.toString() ?? '',
      serviceEndTime: json['service_end_time']?.toString() ?? '',

      placementTime: _str(json['placement_time']),

      holdStartDate: _parseDate(json['hold_start_date']),
      holdEndDate: _parseDate(json['hold_end_date']),

      splInstructions: _str(json['spl_instructions']),
      landmark: _str(json['landmark']),

      pendingInternalAction: _str(json['pending_internal_action']),
      leadPotential: json['lead_potential']?.toString(),

      followupDate: _parseDate(json['followup_date']),

      createdOn: _parseDate(json['created_on']),
      createdBy: _toInt(json['created_by']) ?? 0,

      updatedOn: _parseDate(json['updated_on']),
      updatedBy: _toInt(json['updated_by']) ?? 0,

      createdThroughNewWebApp: json['created_through_newwebapp'] == 1 ||
          json['created_through_newwebapp'] == true,

      status: json['status']?.toString(),

      userName: _str(json['user_name']),
      userMobile: _str(json['user_mobile']),
      userEmail: _str(json['user_email']),

      // Address fields
      addressTagName: _str(json['address_tag_name']),
      city: _str(json['city']),
      state: _str(json['state']),
      country: _str(json['country']),
      addressLine1: _str(json['address_line1']),
      addressLine2: _str(json['address_line2']),
      locality: _str(json['locality']),
      pincode: json['pincode']?.toString(),

      patientName: _str(json['patient_name']),
      patientAge: _toInt(json['patient_age']),
      patientGender: _toInt(json['patient_gender']),

      patientPhoneNumber: _str(json['patient_phone_number']),
      patientEmail: _str(json['patient_email']),
      patientYob: _toInt(json['patient_yob']),
      patientWeight: json['patient_weight']?.toString(),

      careManagerName: _str(json['caremanager_name']),
      careManagerMobile: _str(json['caremanager_mobile']),

      branchName: _str(json['branch_name']),
      branchCity: _str(json['branch_city']),
      serviceName: _str(json['service_name']),
      serviceTypeName: _str(json['service_type_name']),
      extensionStatus: _toInt(json['extension_status']),
      overdueDays: _toInt(json['overdue_days']),
      holdTicketOpen: _toInt(json['hold_ticket_open']),
      cancellationTicketOpen: _toInt(json['cancellation_ticket_open']),
      patientLanguages: _str(json['patient_languages']),
      patientRelation: _str(json['patient_relation']),
      patientIsStayAlone: _toInt(json['patient_is_stay_alone']),
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
      'overdue_days': overdueDays,
      'hold_ticket_open': holdTicketOpen,
      'cancellation_ticket_open': cancellationTicketOpen,
      'patient_languages': patientLanguages,
      'patient_relation': patientRelation,
      'patient_is_stay_alone': patientIsStayAlone,
    };
  }

  // ─── Private helpers ────────────────────────────────────────────────────────

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  /// Nullable string; the backend's 'NA' placeholder and blanks become null.
  static String? _str(dynamic value) {
    if (value == null) return null;
    final s = value.toString();
    final t = s.trim();
    return (t.isEmpty || t == 'NA') ? null : s;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }

  // Backend stores omitted numeric fields as the string 'NA' (and other
  // loosely-typed values). A raw `value as num?` cast throws on those strings,
  // crashing fromJson and blanking the entire list. Parse defensively instead.
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static List<GetBookingsModel> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .whereType<Map>()
        .map((e) => GetBookingsModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  String toString() => 'GetBookingsModel(id: $id, status: $status)';
}