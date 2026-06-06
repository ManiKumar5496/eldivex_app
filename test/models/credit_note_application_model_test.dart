import 'package:flutter_test/flutter_test.dart';
import 'package:eldivex_app/app/modules/accounts/models/credit_note_application_model.dart';

void main() {
  // ── Fixture ──────────────────────────────────────────────────────────────────

  Map<String, dynamic> validJson() => {
    'id': 1,
    'org_id': 1,
    'credit_note_id': 5,
    'target_booking_id': 10,
    'target_invoice_id': 3,
    'amount_applied': '500.00',
    'status': 'APPLIED',
    'applied_by': 7,
    'applied_at': '2026-06-06 10:00:00',
    'ledger_entry_id': 99,
    'notes': 'Applied to June invoice',
    'reversed_by': null,
    'reversed_at': null,
    'reversal_reason': null,
    'applied_by_name': 'Admin User',
    'target_booking_ref': 'BK-000010',
    'target_invoice_ref': 'INV-000003',
  };

  // ── Happy path ────────────────────────────────────────────────────────────────

  group('CreditNoteApplicationModel.fromJson — happy path', () {
    test('parses id as int', () {
      final m = CreditNoteApplicationModel.fromJson(validJson());
      expect(m.id, 1);
    });

    test('parses orgId as int', () {
      final m = CreditNoteApplicationModel.fromJson(validJson());
      expect(m.orgId, 1);
    });

    test('parses creditNoteId as int', () {
      final m = CreditNoteApplicationModel.fromJson(validJson());
      expect(m.creditNoteId, 5);
    });

    test('parses targetBookingId as int', () {
      final m = CreditNoteApplicationModel.fromJson(validJson());
      expect(m.targetBookingId, 10);
    });

    test('parses targetInvoiceId as int', () {
      final m = CreditNoteApplicationModel.fromJson(validJson());
      expect(m.targetInvoiceId, 3);
    });

    test('parses appliedBy as int', () {
      final m = CreditNoteApplicationModel.fromJson(validJson());
      expect(m.appliedBy, 7);
    });

    test('parses ledgerEntryId as int', () {
      final m = CreditNoteApplicationModel.fromJson(validJson());
      expect(m.ledgerEntryId, 99);
    });

    test('parses amountApplied as double from string', () {
      final m = CreditNoteApplicationModel.fromJson(validJson());
      expect(m.amountApplied, closeTo(500.0, 0.001));
    });

    test('parses status as String', () {
      final m = CreditNoteApplicationModel.fromJson(validJson());
      expect(m.status, 'APPLIED');
    });

    test('parses appliedAt as String', () {
      final m = CreditNoteApplicationModel.fromJson(validJson());
      expect(m.appliedAt, '2026-06-06 10:00:00');
    });

    test('parses notes as String', () {
      final m = CreditNoteApplicationModel.fromJson(validJson());
      expect(m.notes, 'Applied to June invoice');
    });

    test('appliedByName parsed from joined field', () {
      final m = CreditNoteApplicationModel.fromJson(validJson());
      expect(m.appliedByName, 'Admin User');
    });

    test('targetBookingRef parsed correctly', () {
      final m = CreditNoteApplicationModel.fromJson(validJson());
      expect(m.targetBookingRef, 'BK-000010');
    });

    test('targetInvoiceRef parsed correctly', () {
      final m = CreditNoteApplicationModel.fromJson(validJson());
      expect(m.targetInvoiceRef, 'INV-000003');
    });

    test('reversedBy is null when field is null', () {
      final m = CreditNoteApplicationModel.fromJson(validJson());
      expect(m.reversedBy, isNull);
    });

    test('reversedAt is null when field is null', () {
      final m = CreditNoteApplicationModel.fromJson(validJson());
      expect(m.reversedAt, isNull);
    });

    test('reversalReason is null when field is null', () {
      final m = CreditNoteApplicationModel.fromJson(validJson());
      expect(m.reversalReason, isNull);
    });
  });

  // ── Null / missing fields ─────────────────────────────────────────────────────

  group('CreditNoteApplicationModel.fromJson — null / missing fields', () {
    test('notes is null when field is null', () {
      final json = validJson()..['notes'] = null;
      expect(CreditNoteApplicationModel.fromJson(json).notes, isNull);
    });

    test('notes is null when field is absent', () {
      final json = validJson()..remove('notes');
      expect(CreditNoteApplicationModel.fromJson(json).notes, isNull);
    });

    test('appliedByName is null when field is absent', () {
      final json = validJson()..remove('applied_by_name');
      expect(CreditNoteApplicationModel.fromJson(json).appliedByName, isNull);
    });

    test('targetBookingRef is null when field is absent', () {
      final json = validJson()..remove('target_booking_ref');
      expect(CreditNoteApplicationModel.fromJson(json).targetBookingRef, isNull);
    });

    test('targetInvoiceRef is null when field is absent', () {
      final json = validJson()..remove('target_invoice_ref');
      expect(CreditNoteApplicationModel.fromJson(json).targetInvoiceRef, isNull);
    });

    test('appliedBy is null when field is absent', () {
      final json = validJson()..remove('applied_by');
      expect(CreditNoteApplicationModel.fromJson(json).appliedBy, isNull);
    });

    test('ledgerEntryId is null when field is absent', () {
      final json = validJson()..remove('ledger_entry_id');
      expect(CreditNoteApplicationModel.fromJson(json).ledgerEntryId, isNull);
    });

    test('appliedAt is null when field is absent', () {
      final json = validJson()..remove('applied_at');
      expect(CreditNoteApplicationModel.fromJson(json).appliedAt, isNull);
    });
  });

  // ── Type safety ───────────────────────────────────────────────────────────────

  group('CreditNoteApplicationModel.fromJson — type safety', () {
    test('amountApplied as int parses to double', () {
      final json = validJson()..['amount_applied'] = 500;
      expect(CreditNoteApplicationModel.fromJson(json).amountApplied, closeTo(500.0, 0.001));
    });

    test('amountApplied as double literal parses correctly', () {
      final json = validJson()..['amount_applied'] = 500.75;
      expect(CreditNoteApplicationModel.fromJson(json).amountApplied, closeTo(500.75, 0.001));
    });

    test('id from double parses to int', () {
      final json = validJson()..['id'] = 1.0;
      expect(CreditNoteApplicationModel.fromJson(json).id, 1);
    });

    test('creditNoteId from double parses to int', () {
      final json = validJson()..['credit_note_id'] = 5.0;
      expect(CreditNoteApplicationModel.fromJson(json).creditNoteId, 5);
    });

    test('targetBookingId from double parses to int', () {
      final json = validJson()..['target_booking_id'] = 10.0;
      expect(CreditNoteApplicationModel.fromJson(json).targetBookingId, 10);
    });

    test('id defaults to 0 when field is null', () {
      final json = validJson()..['id'] = null;
      expect(CreditNoteApplicationModel.fromJson(json).id, 0);
    });
  });

  // ── toJson round-trip ─────────────────────────────────────────────────────────

  group('CreditNoteApplicationModel — toJson round-trip', () {
    test('toJson contains "credit_note_id", "amount_applied", "status"', () {
      final json = CreditNoteApplicationModel.fromJson(validJson()).toJson();
      expect(json.containsKey('credit_note_id'), isTrue);
      expect(json.containsKey('amount_applied'), isTrue);
      expect(json.containsKey('status'), isTrue);
    });

    test('toJson contains all expected keys', () {
      final json = CreditNoteApplicationModel.fromJson(validJson()).toJson();
      expect(json.containsKey('id'), isTrue);
      expect(json.containsKey('org_id'), isTrue);
      expect(json.containsKey('target_booking_id'), isTrue);
      expect(json.containsKey('target_invoice_id'), isTrue);
      expect(json.containsKey('applied_by_name'), isTrue);
      expect(json.containsKey('target_booking_ref'), isTrue);
      expect(json.containsKey('target_invoice_ref'), isTrue);
    });

    test('toJson preserves id and creditNoteId', () {
      final json = CreditNoteApplicationModel.fromJson(validJson()).toJson();
      expect(json['id'], 1);
      expect(json['credit_note_id'], 5);
    });

    test('toJson preserves amountApplied as double', () {
      final json = CreditNoteApplicationModel.fromJson(validJson()).toJson();
      expect(json['amount_applied'], closeTo(500.0, 0.001));
    });

    test('toJson preserves status', () {
      final json = CreditNoteApplicationModel.fromJson(validJson()).toJson();
      expect(json['status'], 'APPLIED');
    });

    test('toJson preserves appliedByName and targetBookingRef', () {
      final json = CreditNoteApplicationModel.fromJson(validJson()).toJson();
      expect(json['applied_by_name'], 'Admin User');
      expect(json['target_booking_ref'], 'BK-000010');
    });

    test('null reversedBy remains null in toJson', () {
      final json = CreditNoteApplicationModel.fromJson(validJson()).toJson();
      expect(json['reversed_by'], isNull);
    });
  });

  // ── fromJsonList ──────────────────────────────────────────────────────────────

  group('CreditNoteApplicationModel.fromJsonList', () {
    test('parses a list of 2 items correctly', () {
      final list = [validJson(), validJson()..['id'] = 2];
      final result = CreditNoteApplicationModel.fromJsonList(list);
      expect(result, isA<List<CreditNoteApplicationModel>>());
      expect(result.length, 2);
    });

    test('first item has correct status', () {
      final list = [validJson(), validJson()..['id'] = 2];
      final result = CreditNoteApplicationModel.fromJsonList(list);
      expect(result[0].status, 'APPLIED');
    });

    test('items have correct ids', () {
      final list = [validJson(), validJson()..['id'] = 2];
      final result = CreditNoteApplicationModel.fromJsonList(list);
      expect(result[0].id, 1);
      expect(result[1].id, 2);
    });

    test('returns empty list for empty input', () {
      expect(CreditNoteApplicationModel.fromJsonList([]), isEmpty);
    });
  });
}
