import 'package:flutter_test/flutter_test.dart';
import 'package:eldivex_app/app/modules/bookings/models/get_bookings_model.dart';

void main() {
  // ── Fixture ──────────────────────────────────────────────────────────────────

  Map<String, dynamic> validJson() => {
    'id': 1,
    'service_type_id': 2,
    'branch_id': 3,
    'user_id': 4,
    'patient_id': 5,
    'hp_manager': 6,
    'coupon_discount_id': null,
    'coupon_discount_applied_value': null,
    'address_id': 7,
    'patient_conditions_others': 'Diabetes',
    'spl_care_requirements': 'Wheelchair required',
    'original_booking_date': null,
    'updated_booking_date': null,
    'base_rate': '500',
    'base_unit': 'per day',
    'base_discount_percentage': '10.0',
    'final_rate': '450.0',
    'quantity': 1,
    'service_start_date': '2026-06-01',
    'service_end_date': '2026-06-30',
    'service_start_time': '08:00',
    'service_end_time': '20:00',
    'placement_time': null,
    'hold_start_date': null,
    'hold_end_date': null,
    'spl_instructions': 'No stairs',
    'landmark': 'Near temple',
    'pending_internal_action': null,
    'lead_potential': 'High',
    'followup_date': '2026-06-05',
    'created_on': '2026-05-25 10:00:00',
    'created_by': 99,
    'updated_on': null,
    'updated_by': 0,
    'created_through_newwebapp': 1,
    'status': '1',
    'user_name': 'Arjun Sharma',
    'user_mobile': '9876543210',
    'user_email': 'arjun@example.com',
    'address_tag_name': 'Home',
    'city': 'Mumbai',
    'state': 'Maharashtra',
    'country': 'India',
    'address_line1': '12 Marine Drive',
    'address_line2': null,
    'locality': 'Churchgate',
    'pincode': '400020',
    'patient_name': 'Radha Devi',
    'patient_age': 75,
    'patient_gender': 2,
    'patient_phone_number': '9811122233',
    'patient_email': 'radha@example.com',
    'patient_yob': 1951,
    'patient_weight': '62',
    'caremanager_name': null,
    'caremanager_mobile': null,
    'service_name': 'Elder Care',
    'service_type_name': 'Home Nursing',
    'extension_status': 0,
    'hold_ticket_open': 0,
    'cancellation_ticket_open': 0,
  };

  // ── Happy path ────────────────────────────────────────────────────────────────

  group('GetBookingsModel.fromJson — happy path', () {
    test('parses required integer IDs', () {
      final m = GetBookingsModel.fromJson(validJson());
      expect(m.id, 1);
      expect(m.branchId, 3);
      expect(m.userId, 4);
      expect(m.patientId, 5);
      expect(m.addressId, 7);
    });

    test('parses optional integer IDs', () {
      final m = GetBookingsModel.fromJson(validJson());
      expect(m.serviceTypeId, 2);
      expect(m.hpManager, 6);
    });

    test('parses baseRate as String', () {
      final m = GetBookingsModel.fromJson(validJson());
      expect(m.baseRate, '500');
    });

    test('parses finalRate as double', () {
      final m = GetBookingsModel.fromJson(validJson());
      expect(m.finalRate, closeTo(450.0, 0.001));
    });

    test('parses baseDiscountPercentage as double', () {
      final m = GetBookingsModel.fromJson(validJson());
      expect(m.baseDiscountPercentage, closeTo(10.0, 0.001));
    });

    test('parses status as String', () {
      final m = GetBookingsModel.fromJson(validJson());
      expect(m.status, '1');
    });

    test('parses serviceName and serviceTypeName', () {
      final m = GetBookingsModel.fromJson(validJson());
      expect(m.serviceName, 'Elder Care');
      expect(m.serviceTypeName, 'Home Nursing');
    });

    test('parses user-related fields', () {
      final m = GetBookingsModel.fromJson(validJson());
      expect(m.userName, 'Arjun Sharma');
      expect(m.userMobile, '9876543210');
      expect(m.userEmail, 'arjun@example.com');
    });

    test('parses patient-related fields', () {
      final m = GetBookingsModel.fromJson(validJson());
      expect(m.patientName, 'Radha Devi');
      expect(m.patientAge, 75);
      expect(m.patientGender, 2);
      expect(m.patientYob, 1951);
    });

    test('parses address fields', () {
      final m = GetBookingsModel.fromJson(validJson());
      expect(m.city, 'Mumbai');
      expect(m.state, 'Maharashtra');
      expect(m.pincode, '400020');
      expect(m.addressTagName, 'Home');
    });

    test('parses extension/ticket status fields', () {
      final m = GetBookingsModel.fromJson(validJson());
      expect(m.extensionStatus, 0);
      expect(m.holdTicketOpen, 0);
      expect(m.cancellationTicketOpen, 0);
    });

    test('parses createdThroughNewWebApp from int 1 as true', () {
      final m = GetBookingsModel.fromJson(validJson());
      expect(m.createdThroughNewWebApp, isTrue);
    });

    test('parses createdThroughNewWebApp from int 0 as false', () {
      final json = validJson()..['created_through_newwebapp'] = 0;
      expect(GetBookingsModel.fromJson(json).createdThroughNewWebApp, isFalse);
    });

    test('parses createdThroughNewWebApp from bool true', () {
      final json = validJson()..['created_through_newwebapp'] = true;
      expect(GetBookingsModel.fromJson(json).createdThroughNewWebApp, isTrue);
    });
  });

  // ── Date parsing ──────────────────────────────────────────────────────────────

  group('GetBookingsModel.fromJson — date parsing', () {
    test('parses serviceStartDate from ISO string', () {
      final m = GetBookingsModel.fromJson(validJson());
      expect(m.serviceStartDate, isNotNull);
      expect(m.serviceStartDate!.year, 2026);
      expect(m.serviceStartDate!.month, 6);
      expect(m.serviceStartDate!.day, 1);
    });

    test('parses serviceEndDate from ISO string', () {
      final m = GetBookingsModel.fromJson(validJson());
      expect(m.serviceEndDate, isNotNull);
      expect(m.serviceEndDate!.day, 30);
    });

    test('parses createdOn as DateTime', () {
      final m = GetBookingsModel.fromJson(validJson());
      expect(m.createdOn, isNotNull);
      expect(m.createdOn!.year, 2026);
    });

    test('parses followupDate from ISO string', () {
      final m = GetBookingsModel.fromJson(validJson());
      expect(m.followupDate, isNotNull);
      expect(m.followupDate!.day, 5);
    });

    test('returns null for serviceStartDate when field is null', () {
      final json = validJson()..['service_start_date'] = null;
      expect(GetBookingsModel.fromJson(json).serviceStartDate, isNull);
    });

    test('returns null for updatedOn when field is null', () {
      final m = GetBookingsModel.fromJson(validJson());
      expect(m.updatedOn, isNull);
    });

    test('returns null for holdStartDate when field is null', () {
      final m = GetBookingsModel.fromJson(validJson());
      expect(m.holdStartDate, isNull);
    });

    test('handles invalid date string gracefully (returns null)', () {
      final json = validJson()..['service_start_date'] = 'not-a-date';
      expect(GetBookingsModel.fromJson(json).serviceStartDate, isNull);
    });
  });

  // ── Type safety ───────────────────────────────────────────────────────────────

  group('GetBookingsModel.fromJson — type safety', () {
    test('baseRate from int still becomes String', () {
      final json = validJson()..['base_rate'] = 500;
      expect(GetBookingsModel.fromJson(json).baseRate, '500');
    });

    test('baseRate from double still becomes String', () {
      final json = validJson()..['base_rate'] = 500.5;
      expect(GetBookingsModel.fromJson(json).baseRate, '500.5');
    });

    test('finalRate from String parses to double', () {
      final json = validJson()..['final_rate'] = '450.00';
      expect(GetBookingsModel.fromJson(json).finalRate, closeTo(450.0, 0.001));
    });

    test('finalRate is null when field is null', () {
      final json = validJson()..['final_rate'] = null;
      expect(GetBookingsModel.fromJson(json).finalRate, isNull);
    });

    test('userId from int JSON parses correctly', () {
      final json = validJson()..['user_id'] = 42;
      expect(GetBookingsModel.fromJson(json).userId, 42);
    });

    test('patientAge from num parses to int', () {
      final json = validJson()..['patient_age'] = 75.0;
      expect(GetBookingsModel.fromJson(json).patientAge, 75);
    });

    test('pincode from int becomes String', () {
      final json = validJson()..['pincode'] = 400020;
      expect(GetBookingsModel.fromJson(json).pincode, '400020');
    });

    test('status from int becomes String', () {
      final json = validJson()..['status'] = 2;
      expect(GetBookingsModel.fromJson(json).status, '2');
    });

    test('does not crash when service_start_time is null (falls back to empty)', () {
      final json = validJson()..['service_start_time'] = null;
      expect(() => GetBookingsModel.fromJson(json), returnsNormally);
      expect(GetBookingsModel.fromJson(json).serviceStartTime, '');
    });
  });

  // ── Optional / missing fields ─────────────────────────────────────────────────

  group('GetBookingsModel.fromJson — optional and missing fields', () {
    test('patientName is null when field is absent', () {
      final json = validJson()..remove('patient_name');
      expect(GetBookingsModel.fromJson(json).patientName, isNull);
    });

    test('userName is null when field is absent', () {
      final json = validJson()..remove('user_name');
      expect(GetBookingsModel.fromJson(json).userName, isNull);
    });

    test('holdTicketOpen is null when field is absent', () {
      final json = validJson()..remove('hold_ticket_open');
      expect(GetBookingsModel.fromJson(json).holdTicketOpen, isNull);
    });

    test('extensionStatus is null when field is absent', () {
      final json = validJson()..remove('extension_status');
      expect(GetBookingsModel.fromJson(json).extensionStatus, isNull);
    });

    test('couponDiscountId is null when field is null', () {
      final m = GetBookingsModel.fromJson(validJson());
      expect(m.couponDiscountId, isNull);
    });

    test('minimal JSON with only required fields does not crash', () {
      final json = <String, dynamic>{
        'id': 1,
        'branch_id': 1,
        'user_id': 1,
        'patient_id': 1,
        'address_id': 1,
        'base_rate': '100',
        'base_unit': '',
        'quantity': 1,
        'service_start_time': '08:00',
        'service_end_time': '20:00',
        'created_by': 1,
        'updated_by': 0,
      };
      expect(() => GetBookingsModel.fromJson(json), returnsNormally);
      final m = GetBookingsModel.fromJson(json);
      expect(m.id, 1);
      expect(m.serviceStartDate, isNull);
      expect(m.patientName, isNull);
    });
  });

  // ── toJson round-trip ─────────────────────────────────────────────────────────

  group('GetBookingsModel — toJson round-trip', () {
    test('toJson contains all expected keys', () {
      final json = GetBookingsModel.fromJson(validJson()).toJson();
      expect(json.containsKey('id'), isTrue);
      expect(json.containsKey('branch_id'), isTrue);
      expect(json.containsKey('user_id'), isTrue);
      expect(json.containsKey('status'), isTrue);
      expect(json.containsKey('service_start_date'), isTrue);
      expect(json.containsKey('base_rate'), isTrue);
      expect(json.containsKey('patient_name'), isTrue);
    });

    test('toJson preserves id and branchId', () {
      final json = GetBookingsModel.fromJson(validJson()).toJson();
      expect(json['id'], 1);
      expect(json['branch_id'], 3);
    });

    test('toJson preserves status', () {
      final json = GetBookingsModel.fromJson(validJson()).toJson();
      expect(json['status'], '1');
    });

    test('toJson preserves baseRate as String', () {
      final json = GetBookingsModel.fromJson(validJson()).toJson();
      expect(json['base_rate'], '500');
    });

    test('serviceStartDate in toJson is ISO8601 string', () {
      final json = GetBookingsModel.fromJson(validJson()).toJson();
      expect(json['service_start_date'], isA<String>());
      expect(json['service_start_date'], contains('2026-06-01'));
    });

    test('null optional fields remain null in toJson', () {
      final json = GetBookingsModel.fromJson(validJson()).toJson();
      expect(json['hold_start_date'], isNull);
      expect(json['updated_on'], isNull);
    });
  });
}
