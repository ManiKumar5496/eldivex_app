import 'package:flutter_test/flutter_test.dart';
import 'package:eldivex_app/app/modules/register_cg/models/get_cg_details_model.dart';

void main() {
  // ── Helpers ────────────────────────────────────────────────────────────────

  Map<String, dynamic> validJson() => {
    'hp_reg_id': 1,
    'hp_reg_photo': 'http://example.com/photo.jpg',
    'hp_reg_first_name': 'Priya',
    'hp_reg_last_name': 'Kumar',
    'hp_reg_email': 'priya@example.com',
    'hp_reg_phone_number': '9876543210',
    'hp_reg_gender': 'Female',
    'hp_reg_city': 'Chennai',
    'hp_reg_state': 'Tamil Nadu',
    'hp_reg_pin_code': '600001',
    'hp_reg_languages': 'Tamil,English',
    'hp_reg_branch_id': 2,
    'hp_reg_marital_status': 'Married',
    'hp_reg_identity_proof_type': 'Aadhar',
    'hp_reg_identity_proof_number': '1234-5678-9012',
    'hp_reg_identity_proof_front_image': 'front.jpg',
    'hp_reg_identity_proof_back_image': 'back.jpg',
    'hp_reg_education': 'BSc Nursing',
    'hp_reg_education_certificate': 'cert.pdf',
    'hp_reg_address': '12 Main Street',
    'hp_reg_dob': '1990-05-15',
    'hp_reg_experience': '3',
    'hp_reg_status': 1,
    'livein_pay': '500',
    'liveout_pay': '400',
    'monthly_livein_pay': '12000',
    'monthly_liveout_pay': '10000',
    'hp_effect_date': '2026-01-01',
  };

  // ── Successful parsing ─────────────────────────────────────────────────────

  group('GetCgDetails.fromJson — happy path', () {
    test('parses all standard fields correctly', () {
      final model = GetCgDetails.fromJson(validJson());

      expect(model.hpRegId, 1);
      expect(model.hpRegFirstName, 'Priya');
      expect(model.hpRegGender, 'Female');
      expect(model.hpRegMaritalStatus, 'Married');
      expect(model.hpRegPinCode, '600001');
      expect(model.hpRegExperience, '3');
      expect(model.hpRegStatus, 1);
      expect(model.hpRegBranchId, 2);
    });

    test('parses hpRegDob as DateTime', () {
      final model = GetCgDetails.fromJson(validJson());
      expect(model.hpRegDob, isNotNull);
      expect(model.hpRegDob!.year, 1990);
      expect(model.hpRegDob!.month, 5);
    });

    test('parses hpEffectDate as DateTime', () {
      final model = GetCgDetails.fromJson(validJson());
      expect(model.hpEffectDate, isNotNull);
      expect(model.hpEffectDate!.year, 2026);
    });
  });

  // ── Type-safety (the bug we fixed) ────────────────────────────────────────

  group('GetCgDetails.fromJson — type safety (Phase 1 bug fixes)', () {
    test('does NOT crash when hp_reg_marital_status is a String like "Married"', () {
      final json = validJson()..['hp_reg_marital_status'] = 'Married';
      expect(() => GetCgDetails.fromJson(json), returnsNormally);
      expect(GetCgDetails.fromJson(json).hpRegMaritalStatus, 'Married');
    });

    test('does NOT crash when hp_reg_gender is "Female"', () {
      final json = validJson()..['hp_reg_gender'] = 'Female';
      expect(() => GetCgDetails.fromJson(json), returnsNormally);
      expect(GetCgDetails.fromJson(json).hpRegGender, 'Female');
    });

    test('does NOT crash when hp_reg_pin_code is an int from DB', () {
      final json = validJson()..['hp_reg_pin_code'] = 600001;
      expect(() => GetCgDetails.fromJson(json), returnsNormally);
      expect(GetCgDetails.fromJson(json).hpRegPinCode, '600001');
    });

    test('does NOT crash when hp_reg_experience is a string "2 years"', () {
      final json = validJson()..['hp_reg_experience'] = '2 years';
      expect(() => GetCgDetails.fromJson(json), returnsNormally);
    });

    test('_safeInt handles int value correctly for hp_reg_status', () {
      final json = validJson()..['hp_reg_status'] = 2;
      expect(GetCgDetails.fromJson(json).hpRegStatus, 2);
    });

    test('_safeInt handles numeric string for hp_reg_branch_id', () {
      final json = validJson()..['hp_reg_branch_id'] = '3';
      expect(GetCgDetails.fromJson(json).hpRegBranchId, 3);
    });

    test('_safeInt returns 0 for non-numeric string on hp_reg_status', () {
      final json = validJson()..['hp_reg_status'] = 'pending';
      expect(GetCgDetails.fromJson(json).hpRegStatus, 0);
    });
  });

  // ── Null / missing fields ─────────────────────────────────────────────────

  group('GetCgDetails.fromJson — null/missing fields', () {
    test('handles null JSON gracefully (empty map fallback)', () {
      expect(() => GetCgDetails.fromJson(null), returnsNormally);
    });

    test('hpRegDob is null when field is missing', () {
      final json = validJson()..remove('hp_reg_dob');
      expect(GetCgDetails.fromJson(json).hpRegDob, isNull);
    });

    test('hpEffectDate is null when field is missing', () {
      final json = validJson()..remove('hp_effect_date');
      expect(GetCgDetails.fromJson(json).hpEffectDate, isNull);
    });

    test('defaults to empty string for missing string fields', () {
      final json = <String, dynamic>{
        'hp_reg_id': 1, 'hp_reg_status': 0, 'hp_reg_branch_id': 1,
      };
      final model = GetCgDetails.fromJson(json);
      expect(model.hpRegFirstName, '');
      expect(model.hpRegGender, '');
      expect(model.hpRegMaritalStatus, '');
    });
  });
}
