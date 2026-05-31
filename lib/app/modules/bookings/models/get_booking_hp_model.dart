class GetBookingHpModel {
  final int id;
  final int bkngId;
  final int hpUniqueId;
  final DateTime? interviewDate;
  final String? interviewTime;
  final DateTime? interviewExpirydate;
  final DateTime? reportingDatePlanned;
  final DateTime? endDatePlanned;
  final DateTime? reportingDateRequestedByClient;
  final String? inTime;
  final String? outTime;
  final DateTime? reportingDateActual;
  final DateTime? endDateActual;
  final int? otp;
  final DateTime? otpVerificationDatetime;
  final String? otpVerificationIpAddress;
  final DateTime? createdOn;
  final int createdBy;
  final DateTime? updatedOn;
  final int updatedBy;
  final int status;
  final DateTime? otpGeneratationDatetime;
  final String? placementTime;

  // HP Registration fields
  final int? hpRegId;
  final String? hpRegPhoto;
  final String? hpRegFirstName;
  final String? hpRegLastName;
  final String? hpRegEmail;
  final String? hpRegPhoneNumber;
  final String? hpRegAddress;
  final DateTime? hpRegDob;
  final int? hpRegGender;
  final String? hpRegCity;
  final String? hpRegState;
  final int? hpRegPinCode;
  final String? hpRegEmergencyContactPhone;
  final String? hpRegLanguages;
  final int? hpRegBranchId;
  final int? hpRegMaritalStatus;
  final int? hpRegExperience;
  final String? hpRegFatherName;
  final String? hpRegFatherOccupation;
  final String? hpRegMotherName;
  final String? hpRegIdentityProofType;
  final String? hpRegIdentityProofNumber;
  final String? hpRegIdentityProofFrontImage;
  final String? hpRegIdentityProofBackImage;
  final String? hpRegEducation;
  final String? hpRegEducationCertificate;
  final int? hpRegStatus;

  GetBookingHpModel({
    required this.id,
    required this.bkngId,
    required this.hpUniqueId,
    this.interviewDate,
    this.interviewTime,
    this.interviewExpirydate,
    this.reportingDatePlanned,
    this.endDatePlanned,
    this.reportingDateRequestedByClient,
    this.inTime,
    this.outTime,
    this.reportingDateActual,
    this.endDateActual,
    this.otp,
    this.otpVerificationDatetime,
    this.otpVerificationIpAddress,
    this.createdOn,
    required this.createdBy,
    this.updatedOn,
    required this.updatedBy,
    required this.status,
    this.otpGeneratationDatetime,
    this.placementTime,
    this.hpRegId,
    this.hpRegPhoto,
    this.hpRegFirstName,
    this.hpRegLastName,
    this.hpRegEmail,
    this.hpRegPhoneNumber,
    this.hpRegAddress,
    this.hpRegDob,
    this.hpRegGender,
    this.hpRegCity,
    this.hpRegState,
    this.hpRegPinCode,
    this.hpRegEmergencyContactPhone,
    this.hpRegLanguages,
    this.hpRegBranchId,
    this.hpRegMaritalStatus,
    this.hpRegExperience,
    this.hpRegFatherName,
    this.hpRegFatherOccupation,
    this.hpRegMotherName,
    this.hpRegIdentityProofType,
    this.hpRegIdentityProofNumber,
    this.hpRegIdentityProofFrontImage,
    this.hpRegIdentityProofBackImage,
    this.hpRegEducation,
    this.hpRegEducationCertificate,
    this.hpRegStatus,
  });

  static int _i(dynamic v, [int fallback = 0]) =>
      v == null ? fallback : (v is num ? v.toInt() : int.tryParse(v.toString()) ?? fallback);

  static int? _iN(dynamic v) =>
      v == null ? null : (v is num ? v.toInt() : int.tryParse(v.toString()));

  factory GetBookingHpModel.fromJson(Map<String, dynamic> json) {
    return GetBookingHpModel(
      id: _i(json['id']),
      bkngId: _i(json['bkng_id']),
      hpUniqueId: _i(json['hp_unique_id']),
      interviewDate: json['interview_date'] != null
          ? DateTime.tryParse(json['interview_date'])
          : null,
      interviewTime: json['interview_time'],
      interviewExpirydate: json['interview_expirydate'] != null
          ? DateTime.tryParse(json['interview_expirydate'])
          : null,
      reportingDatePlanned: json['reporting_date_planned'] != null
          ? DateTime.tryParse(json['reporting_date_planned'])
          : null,
      endDatePlanned: json['end_date_planned'] != null
          ? DateTime.tryParse(json['end_date_planned'])
          : null,
      reportingDateRequestedByClient:
          json['reporting_date_requested_by_client'] != null
              ? DateTime.tryParse(json['reporting_date_requested_by_client'])
              : null,
      inTime: json['in_time'],
      outTime: json['out_time'],
      reportingDateActual: json['reporting_date_actual'] != null
          ? DateTime.tryParse(json['reporting_date_actual'])
          : null,
      endDateActual: json['end_date_actual'] != null
          ? DateTime.tryParse(json['end_date_actual'])
          : null,
      otp: _iN(json['otp']),
      otpVerificationDatetime: json['otp_verification_datetime'] != null
          ? DateTime.tryParse(json['otp_verification_datetime'])
          : null,
      otpVerificationIpAddress: json['otp_verification_ip_address'],
      createdOn: json['created_on'] != null
          ? DateTime.tryParse(json['created_on'])
          : null,
      createdBy: _i(json['created_by']),
      updatedOn: json['updated_on'] != null
          ? DateTime.tryParse(json['updated_on'])
          : null,
      updatedBy: _i(json['updated_by']),
      status: _i(json['status']),
      otpGeneratationDatetime: json['otp_generatation_datetime'] != null
          ? DateTime.tryParse(json['otp_generatation_datetime'])
          : null,
      placementTime: json['placement_time'],
      hpRegId: _iN(json['hp_reg_id']),
      hpRegPhoto: json['hp_reg_photo'],
      hpRegFirstName: json['hp_reg_first_name'],
      hpRegLastName: json['hp_reg_last_name'],
      hpRegEmail: json['hp_reg_email'],
      hpRegPhoneNumber: json['hp_reg_phone_number'],
      hpRegAddress: json['hp_reg_address'],
      hpRegDob: json['hp_reg_dob'] != null
          ? DateTime.tryParse(json['hp_reg_dob'])
          : null,
      hpRegGender: _iN(json['hp_reg_gender']),
      hpRegCity: json['hp_reg_city'],
      hpRegState: json['hp_reg_state'],
      hpRegPinCode: _iN(json['hp_reg_pin_code']),
      hpRegEmergencyContactPhone: json['hp_reg_emergency_contact_phone'],
      hpRegLanguages: json['hp_reg_languages'],
      hpRegBranchId: _iN(json['hp_reg_branch_id']),
      hpRegMaritalStatus: _iN(json['hp_reg_marital_status']),
      hpRegExperience: _iN(json['hp_reg_experience']),
      hpRegFatherName: json['hp_reg_father_name'],
      hpRegFatherOccupation: json['hp_reg_father_occupation'],
      hpRegMotherName: json['hp_reg_mother_name'],
      hpRegIdentityProofType: json['hp_reg_identity_proof_type'],
      hpRegIdentityProofNumber: json['hp_reg_identity_proof_number'],
      hpRegIdentityProofFrontImage: json['hp_reg_identity_proof_front_image'],
      hpRegIdentityProofBackImage: json['hp_reg_identity_proof_back_image'],
      hpRegEducation: json['hp_reg_education'],
      hpRegEducationCertificate: json['hp_reg_education_certificate'],
      hpRegStatus: _iN(json['hp_reg_status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bkng_id': bkngId,
      'hp_unique_id': hpUniqueId,
      'interview_date': interviewDate?.toIso8601String(),
      'interview_time': interviewTime,
      'interview_expirydate': interviewExpirydate?.toIso8601String(),
      'reporting_date_planned': reportingDatePlanned?.toIso8601String(),
      'end_date_planned': endDatePlanned?.toIso8601String(),
      'reporting_date_requested_by_client':
          reportingDateRequestedByClient?.toIso8601String(),
      'in_time': inTime,
      'out_time': outTime,
      'reporting_date_actual': reportingDateActual?.toIso8601String(),
      'end_date_actual': endDateActual?.toIso8601String(),
      'otp': otp,
      'otp_verification_datetime':
          otpVerificationDatetime?.toIso8601String(),
      'otp_verification_ip_address': otpVerificationIpAddress,
      'created_on': createdOn?.toIso8601String(),
      'created_by': createdBy,
      'updated_on': updatedOn?.toIso8601String(),
      'updated_by': updatedBy,
      'status': status,
      'otp_generatation_datetime':
          otpGeneratationDatetime?.toIso8601String(),
      'placement_time': placementTime,
      'hp_reg_id': hpRegId,
      'hp_reg_photo': hpRegPhoto,
      'hp_reg_first_name': hpRegFirstName,
      'hp_reg_last_name': hpRegLastName,
      'hp_reg_email': hpRegEmail,
      'hp_reg_phone_number': hpRegPhoneNumber,
      'hp_reg_address': hpRegAddress,
      'hp_reg_dob': hpRegDob?.toIso8601String(),
      'hp_reg_gender': hpRegGender,
      'hp_reg_city': hpRegCity,
      'hp_reg_state': hpRegState,
      'hp_reg_pin_code': hpRegPinCode,
      'hp_reg_emergency_contact_phone': hpRegEmergencyContactPhone,
      'hp_reg_languages': hpRegLanguages,
      'hp_reg_branch_id': hpRegBranchId,
      'hp_reg_marital_status': hpRegMaritalStatus,
      'hp_reg_experience': hpRegExperience,
      'hp_reg_father_name': hpRegFatherName,
      'hp_reg_father_occupation': hpRegFatherOccupation,
      'hp_reg_mother_name': hpRegMotherName,
      'hp_reg_identity_proof_type': hpRegIdentityProofType,
      'hp_reg_identity_proof_number': hpRegIdentityProofNumber,
      'hp_reg_identity_proof_front_image': hpRegIdentityProofFrontImage,
      'hp_reg_identity_proof_back_image': hpRegIdentityProofBackImage,
      'hp_reg_education': hpRegEducation,
      'hp_reg_education_certificate': hpRegEducationCertificate,
      'hp_reg_status': hpRegStatus,
    };
  }
}
