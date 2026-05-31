import 'package:flutter_test/flutter_test.dart';
import 'package:eldivex_app/app/modules/bookings/models/get_booking_hp_model.dart';

void main() {
  // ── Fixture ──────────────────────────────────────────────────────────────────

  Map<String, dynamic> validJson() => {
    'id': 1,
    'bkng_id': 10,
    'hp_unique_id': 7,
    'interview_date': '2026-05-28',
    'interview_time': '10:00',
    'interview_expirydate': '2026-05-30',
    'reporting_date_planned': '2026-06-01',
    'end_date_planned': '2026-06-30',
    'reporting_date_requested_by_client': null,
    'in_time': '08:00',
    'out_time': '20:00',
    'reporting_date_actual': null,
    'end_date_actual': null,
    'otp': 482910,
    'otp_verification_datetime': null,
    'otp_verification_ip_address': null,
    'otp_generatation_datetime': '2026-05-28 09:00:00',
    'placement_time': null,
    'created_on': '2026-05-25 10:00:00',
    'created_by': 99,
    'updated_on': null,
    'updated_by': 0,
    'status': 2,
    // HP registration fields
    'hp_reg_id': 7,
    'hp_reg_photo': null,
    'hp_reg_first_name': 'Priya',
    'hp_reg_last_name': 'Kumar',
    'hp_reg_email': 'priya@example.com',
    'hp_reg_phone_number': '9876543210',
    'hp_reg_address': '5 Main Road, Pune',
    'hp_reg_dob': '1990-03-15',
    'hp_reg_gender': 2,
    'hp_reg_city': 'Pune',
    'hp_reg_state': 'Maharashtra',
    'hp_reg_pin_code': 411001,
    'hp_reg_emergency_contact_phone': '9811100001',
    'hp_reg_languages': 'Hindi,English',
    'hp_reg_branch_id': 3,
    'hp_reg_marital_status': 1,
    'hp_reg_experience': 4,
    'hp_reg_father_name': null,
    'hp_reg_father_occupation': null,
    'hp_reg_mother_name': null,
    'hp_reg_identity_proof_type': 'Aadhaar',
    'hp_reg_identity_proof_number': '1234-5678-9012',
    'hp_reg_identity_proof_front_image': null,
    'hp_reg_identity_proof_back_image': null,
    'hp_reg_education': 'BSc Nursing',
    'hp_reg_education_certificate': null,
    'hp_reg_status': 6,
  };

  // ── Happy path ────────────────────────────────────────────────────────────────

  group('GetBookingHpModel.fromJson — happy path', () {
    test('parses required integer fields', () {
      final m = GetBookingHpModel.fromJson(validJson());
      expect(m.id, 1);
      expect(m.bkngId, 10);
      expect(m.hpUniqueId, 7);
      expect(m.status, 2);
    });

    test('parses createdBy and updatedBy', () {
      final m = GetBookingHpModel.fromJson(validJson());
      expect(m.createdBy, 99);
      expect(m.updatedBy, 0);
    });

    test('parses otp as int', () {
      final m = GetBookingHpModel.fromJson(validJson());
      expect(m.otp, 482910);
    });

    test('parses in_time and out_time as strings', () {
      final m = GetBookingHpModel.fromJson(validJson());
      expect(m.inTime, '08:00');
      expect(m.outTime, '20:00');
    });

    test('parses interviewTime as string', () {
      final m = GetBookingHpModel.fromJson(validJson());
      expect(m.interviewTime, '10:00');
    });

    test('parses HP registration name fields', () {
      final m = GetBookingHpModel.fromJson(validJson());
      expect(m.hpRegFirstName, 'Priya');
      expect(m.hpRegLastName, 'Kumar');
    });

    test('parses HP registration contact fields', () {
      final m = GetBookingHpModel.fromJson(validJson());
      expect(m.hpRegEmail, 'priya@example.com');
      expect(m.hpRegPhoneNumber, '9876543210');
    });

    test('parses HP registration location fields', () {
      final m = GetBookingHpModel.fromJson(validJson());
      expect(m.hpRegCity, 'Pune');
      expect(m.hpRegState, 'Maharashtra');
    });

    test('parses HP registration numeric fields', () {
      final m = GetBookingHpModel.fromJson(validJson());
      expect(m.hpRegGender, 2);
      expect(m.hpRegExperience, 4);
      expect(m.hpRegPinCode, 411001);
      expect(m.hpRegBranchId, 3);
      expect(m.hpRegStatus, 6);
    });

    test('parses HP education and identity proof fields', () {
      final m = GetBookingHpModel.fromJson(validJson());
      expect(m.hpRegEducation, 'BSc Nursing');
      expect(m.hpRegIdentityProofType, 'Aadhaar');
    });

    test('parses hp_reg_languages as string', () {
      final m = GetBookingHpModel.fromJson(validJson());
      expect(m.hpRegLanguages, 'Hindi,English');
    });
  });

  // ── Date and datetime parsing ─────────────────────────────────────────────────

  group('GetBookingHpModel.fromJson — date/datetime fields', () {
    test('parses interviewDate from ISO string', () {
      final m = GetBookingHpModel.fromJson(validJson());
      expect(m.interviewDate, isNotNull);
      expect(m.interviewDate!.year, 2026);
      expect(m.interviewDate!.month, 5);
      expect(m.interviewDate!.day, 28);
    });

    test('parses interviewExpirydate from ISO string', () {
      final m = GetBookingHpModel.fromJson(validJson());
      expect(m.interviewExpirydate, isNotNull);
      expect(m.interviewExpirydate!.day, 30);
    });

    test('parses reportingDatePlanned from ISO string', () {
      final m = GetBookingHpModel.fromJson(validJson());
      expect(m.reportingDatePlanned, isNotNull);
      expect(m.reportingDatePlanned!.day, 1);
    });

    test('parses endDatePlanned from ISO string', () {
      final m = GetBookingHpModel.fromJson(validJson());
      expect(m.endDatePlanned, isNotNull);
      expect(m.endDatePlanned!.day, 30);
    });

    test('parses otpGeneratationDatetime from datetime string', () {
      final m = GetBookingHpModel.fromJson(validJson());
      expect(m.otpGeneratationDatetime, isNotNull);
      expect(m.otpGeneratationDatetime!.hour, 9);
    });

    test('parses hpRegDob from ISO date string', () {
      final m = GetBookingHpModel.fromJson(validJson());
      expect(m.hpRegDob, isNotNull);
      expect(m.hpRegDob!.year, 1990);
    });

    test('createdOn is null when field is null', () {
      final json = validJson()..['created_on'] = null;
      expect(GetBookingHpModel.fromJson(json).createdOn, isNull);
    });

    test('reportingDateActual is null when field is null', () {
      final m = GetBookingHpModel.fromJson(validJson());
      expect(m.reportingDateActual, isNull);
    });

    test('otpVerificationDatetime is null when field is null', () {
      final m = GetBookingHpModel.fromJson(validJson());
      expect(m.otpVerificationDatetime, isNull);
    });

    test('invalid date string for interviewDate returns null gracefully', () {
      final json = validJson()..['interview_date'] = 'bad-date';
      expect(GetBookingHpModel.fromJson(json).interviewDate, isNull);
    });
  });

  // ── Type safety ───────────────────────────────────────────────────────────────

  group('GetBookingHpModel.fromJson — type safety', () {
    test('bkng_id from String parses to int', () {
      final json = validJson()..['bkng_id'] = '10';
      expect(GetBookingHpModel.fromJson(json).bkngId, 10);
    });

    test('hp_unique_id from String parses to int', () {
      final json = validJson()..['hp_unique_id'] = '7';
      expect(GetBookingHpModel.fromJson(json).hpUniqueId, 7);
    });

    test('status from int parses correctly', () {
      final json = validJson()..['status'] = 3;
      expect(GetBookingHpModel.fromJson(json).status, 3);
    });

    test('otp from String parses to int', () {
      final json = validJson()..['otp'] = '482910';
      expect(GetBookingHpModel.fromJson(json).otp, 482910);
    });

    test('otp as null returns null', () {
      final json = validJson()..['otp'] = null;
      expect(GetBookingHpModel.fromJson(json).otp, isNull);
    });

    test('hp_reg_experience from String parses to int', () {
      final json = validJson()..['hp_reg_experience'] = '3';
      expect(GetBookingHpModel.fromJson(json).hpRegExperience, 3);
    });

    test('hp_reg_pin_code from int parses correctly', () {
      final json = validJson()..['hp_reg_pin_code'] = 560001;
      expect(GetBookingHpModel.fromJson(json).hpRegPinCode, 560001);
    });

    test('created_by from String parses to int', () {
      final json = validJson()..['created_by'] = '99';
      expect(GetBookingHpModel.fromJson(json).createdBy, 99);
    });

    test('id falls back to 0 when null', () {
      final json = validJson()..['id'] = null;
      expect(GetBookingHpModel.fromJson(json).id, 0);
    });
  });

  // ── Optional HP profile fields ────────────────────────────────────────────────

  group('GetBookingHpModel.fromJson — optional HP profile fields', () {
    test('hpRegId is null when field is null', () {
      final json = validJson()..['hp_reg_id'] = null;
      expect(GetBookingHpModel.fromJson(json).hpRegId, isNull);
    });

    test('hpRegPhoto is null when field is null', () {
      final m = GetBookingHpModel.fromJson(validJson());
      expect(m.hpRegPhoto, isNull);
    });

    test('hpRegFatherName is null when field is null', () {
      final m = GetBookingHpModel.fromJson(validJson());
      expect(m.hpRegFatherName, isNull);
    });

    test('hpRegEducationCertificate is null when field is null', () {
      final m = GetBookingHpModel.fromJson(validJson());
      expect(m.hpRegEducationCertificate, isNull);
    });

    test('does not crash with minimal JSON (no HP profile fields)', () {
      final json = <String, dynamic>{
        'id': 1,
        'bkng_id': 10,
        'hp_unique_id': 7,
        'status': 1,
        'created_by': 1,
        'updated_by': 0,
      };
      expect(() => GetBookingHpModel.fromJson(json), returnsNormally);
      final m = GetBookingHpModel.fromJson(json);
      expect(m.hpRegFirstName, isNull);
      expect(m.hpRegCity, isNull);
      expect(m.hpRegExperience, isNull);
      expect(m.interviewDate, isNull);
      expect(m.otp, isNull);
    });
  });

  // ── toJson round-trip ─────────────────────────────────────────────────────────

  group('GetBookingHpModel — toJson round-trip', () {
    test('toJson contains all expected keys', () {
      final json = GetBookingHpModel.fromJson(validJson()).toJson();
      expect(json.containsKey('id'), isTrue);
      expect(json.containsKey('bkng_id'), isTrue);
      expect(json.containsKey('hp_unique_id'), isTrue);
      expect(json.containsKey('status'), isTrue);
      expect(json.containsKey('otp'), isTrue);
      expect(json.containsKey('hp_reg_first_name'), isTrue);
      expect(json.containsKey('hp_reg_experience'), isTrue);
    });

    test('toJson preserves bkngId and hpUniqueId', () {
      final json = GetBookingHpModel.fromJson(validJson()).toJson();
      expect(json['bkng_id'], 10);
      expect(json['hp_unique_id'], 7);
    });

    test('toJson preserves status', () {
      final json = GetBookingHpModel.fromJson(validJson()).toJson();
      expect(json['status'], 2);
    });

    test('toJson preserves otp', () {
      final json = GetBookingHpModel.fromJson(validJson()).toJson();
      expect(json['otp'], 482910);
    });

    test('interviewDate in toJson is ISO8601 string', () {
      final json = GetBookingHpModel.fromJson(validJson()).toJson();
      expect(json['interview_date'], isA<String>());
      expect(json['interview_date'], contains('2026-05-28'));
    });

    test('null datetime fields remain null in toJson', () {
      final json = GetBookingHpModel.fromJson(validJson()).toJson();
      expect(json['otp_verification_datetime'], isNull);
      expect(json['updated_on'], isNull);
      expect(json['reporting_date_actual'], isNull);
    });

    test('HP profile fields survive round-trip', () {
      final json = GetBookingHpModel.fromJson(validJson()).toJson();
      expect(json['hp_reg_first_name'], 'Priya');
      expect(json['hp_reg_city'], 'Pune');
      expect(json['hp_reg_experience'], 4);
      expect(json['hp_reg_status'], 6);
    });
  });
}
