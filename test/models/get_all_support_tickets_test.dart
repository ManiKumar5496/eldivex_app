import 'package:flutter_test/flutter_test.dart';
import 'package:eldivex_app/app/modules/support/models/get_all_support_tickets.dart';

void main() {
  Map<String, dynamic> validJson() => {
    'id': 1,
    'user_id': 3,
    'support_type_id': 2,
    'booking_details': '5',
    'due_date': '2026-12-20',
    'start_date': '2026-06-01',
    'end_date': '2026-06-30',
    'title': 'CG not arrived',
    'description': 'The caregiver did not show up for morning shift.',
    'comments': 'Called client to confirm',
    'conversionlog_details': '',
    'created_by_employee': '1',
    'created_on': '2026-05-24 10:00:00',
    'created_by': '1',
    'updated_on': null,
    'updated_by': '0',
    'status': 1,
  };

  // ── Happy path ─────────────────────────────────────────────────────────────

  group('GetAllSupportTickets.fromJson — happy path', () {
    test('parses all fields correctly', () {
      final t = GetAllSupportTickets.fromJson(validJson());
      expect(t.id, 1);
      expect(t.title, 'CG not arrived');
      expect(t.status, 1);
      expect(t.userId, '3');
      expect(t.supportTypeId, '2');
    });

    test('parses createdOn as DateTime', () {
      final t = GetAllSupportTickets.fromJson(validJson());
      expect(t.createdOn, isNotNull);
      expect(t.createdOn!.year, 2026);
    });

    test('updatedOn is null when field is null', () {
      final t = GetAllSupportTickets.fromJson(validJson());
      expect(t.updatedOn, isNull);
    });

    test('parses updatedOn when provided', () {
      final json = validJson()..['updated_on'] = '2026-05-25 08:00:00';
      final t = GetAllSupportTickets.fromJson(json);
      expect(t.updatedOn, isNotNull);
      expect(t.updatedOn!.day, 25);
    });
  });

  // ── Type-safety (the bug we fixed) ────────────────────────────────────────

  group('GetAllSupportTickets.fromJson — type safety (Phase 1 bug fixes)', () {
    test('does NOT crash when user_id is int 2 from DB', () {
      final json = validJson()..['user_id'] = 2;
      expect(() => GetAllSupportTickets.fromJson(json), returnsNormally);
      expect(GetAllSupportTickets.fromJson(json).userId, '2');
    });

    test('does NOT crash when support_type_id is int', () {
      final json = validJson()..['support_type_id'] = 3;
      expect(() => GetAllSupportTickets.fromJson(json), returnsNormally);
    });

    test('does NOT crash when created_by_employee is "NA"', () {
      final json = validJson()..['created_by_employee'] = 'NA';
      expect(() => GetAllSupportTickets.fromJson(json), returnsNormally);
      expect(GetAllSupportTickets.fromJson(json).createdByEmployee, 'NA');
    });

    test('does NOT crash when booking_details is an int', () {
      final json = validJson()..['booking_details'] = 5;
      expect(() => GetAllSupportTickets.fromJson(json), returnsNormally);
      expect(GetAllSupportTickets.fromJson(json).bookingDetails, '5');
    });

    test('status parses correctly as int from DB', () {
      final json = validJson()..['status'] = 2;
      expect(GetAllSupportTickets.fromJson(json).status, 2);
    });

    test('due_date returns null when value is "NA"', () {
      final json = validJson()..['due_date'] = 'NA';
      expect(GetAllSupportTickets.fromJson(json).dueDate, isNull);
    });

    test('created_on returns null when value is "NA"', () {
      final json = validJson()..['created_on'] = 'NA';
      expect(GetAllSupportTickets.fromJson(json).createdOn, isNull);
    });

    test('handles completely missing optional fields', () {
      final json = <String, dynamic>{'id': 1, 'status': 0};
      expect(() => GetAllSupportTickets.fromJson(json), returnsNormally);
      final t = GetAllSupportTickets.fromJson(json);
      expect(t.title, '');
      expect(t.userId, '');
      expect(t.dueDate, isNull);
    });
  });

  // ── toJson round-trip ──────────────────────────────────────────────────────

  group('GetAllSupportTickets — toJson round-trip', () {
    test('toJson contains all keys', () {
      final t = GetAllSupportTickets.fromJson(validJson());
      final json = t.toJson();
      expect(json.containsKey('id'), isTrue);
      expect(json.containsKey('status'), isTrue);
      expect(json.containsKey('title'), isTrue);
      expect(json['id'], 1);
      expect(json['status'], 1);
    });
  });
}
