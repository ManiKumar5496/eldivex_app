import 'package:flutter_test/flutter_test.dart';
import 'package:eldivex_app/app/modules/accounts/models/internal_transfer_model.dart';

void main() {
  // ── Fixture ──────────────────────────────────────────────────────────────────

  Map<String, dynamic> validJson() => {
    'id': 1,
    'org_id': 1,
    'client_id': 5,
    'source_booking_id': 10,
    'target_booking_id': 20,
    'transfer_amount': '1500.00',
    'transfer_type': 'OVERPAYMENT_TRANSFER',
    'reason': 'Excess payment on booking 10',
    'notes': null,
    'status': 'PENDING_APPROVAL',
    'approved_at': null,
    'source_transaction_entry_id': null,
    'target_transaction_entry_id': null,
    'requested_by': 7,
    'approved_by': null,
    'created_on': '2026-06-06 10:00:00',
    'updated_on': null,
    'client_name': 'Priya Sharma',
    'source_booking_ref': 'BK-000010',
    'target_booking_ref': 'BK-000020',
    'source_booking_balance': '-500.00',
    'target_booking_balance': '2000.00',
  };

  // ── Happy path ────────────────────────────────────────────────────────────────

  group('InternalTransferModel.fromJson — happy path', () {
    test('parses id, orgId, clientId as ints', () {
      final m = InternalTransferModel.fromJson(validJson());
      expect(m.id, 1);
      expect(m.orgId, 1);
      expect(m.clientId, 5);
    });

    test('parses sourceBookingId and targetBookingId as ints', () {
      final m = InternalTransferModel.fromJson(validJson());
      expect(m.sourceBookingId, 10);
      expect(m.targetBookingId, 20);
    });

    test('parses transferAmount as double from string', () {
      final m = InternalTransferModel.fromJson(validJson());
      expect(m.transferAmount, closeTo(1500.0, 0.001));
    });

    test('parses transferType as String', () {
      final m = InternalTransferModel.fromJson(validJson());
      expect(m.transferType, 'OVERPAYMENT_TRANSFER');
    });

    test('parses reason as String', () {
      final m = InternalTransferModel.fromJson(validJson());
      expect(m.reason, 'Excess payment on booking 10');
    });

    test('parses status as String', () {
      final m = InternalTransferModel.fromJson(validJson());
      expect(m.status, 'PENDING_APPROVAL');
    });

    test('parses requestedBy as int', () {
      final m = InternalTransferModel.fromJson(validJson());
      expect(m.requestedBy, 7);
    });

    test('parses createdOn as String', () {
      final m = InternalTransferModel.fromJson(validJson());
      expect(m.createdOn, '2026-06-06 10:00:00');
    });

    test('sourceBookingBalance parses as double (negative: -500.0)', () {
      final m = InternalTransferModel.fromJson(validJson());
      expect(m.sourceBookingBalance, closeTo(-500.0, 0.001));
    });

    test('targetBookingBalance parses as double', () {
      final m = InternalTransferModel.fromJson(validJson());
      expect(m.targetBookingBalance, closeTo(2000.0, 0.001));
    });

    test('clientName parsed from joined field', () {
      final m = InternalTransferModel.fromJson(validJson());
      expect(m.clientName, 'Priya Sharma');
    });

    test('sourceBookingRef parsed correctly', () {
      final m = InternalTransferModel.fromJson(validJson());
      expect(m.sourceBookingRef, 'BK-000010');
    });

    test('targetBookingRef parsed correctly', () {
      final m = InternalTransferModel.fromJson(validJson());
      expect(m.targetBookingRef, 'BK-000020');
    });

    test('notes is null when field is null', () {
      final m = InternalTransferModel.fromJson(validJson());
      expect(m.notes, isNull);
    });

    test('approvedBy is null when field is null', () {
      final m = InternalTransferModel.fromJson(validJson());
      expect(m.approvedBy, isNull);
    });

    test('sourceTransactionEntryId is null when field is null', () {
      final m = InternalTransferModel.fromJson(validJson());
      expect(m.sourceTransactionEntryId, isNull);
    });

    test('targetTransactionEntryId is null when field is null', () {
      final m = InternalTransferModel.fromJson(validJson());
      expect(m.targetTransactionEntryId, isNull);
    });

    test('approvedAt is null when field is null', () {
      final m = InternalTransferModel.fromJson(validJson());
      expect(m.approvedAt, isNull);
    });

    test('updatedOn is null when field is null', () {
      final m = InternalTransferModel.fromJson(validJson());
      expect(m.updatedOn, isNull);
    });
  });

  // ── Null / missing fields ─────────────────────────────────────────────────────

  group('InternalTransferModel.fromJson — null / missing fields', () {
    test('notes is null when field is absent', () {
      final json = validJson()..remove('notes');
      expect(InternalTransferModel.fromJson(json).notes, isNull);
    });

    test('approvedBy is null when field is absent', () {
      final json = validJson()..remove('approved_by');
      expect(InternalTransferModel.fromJson(json).approvedBy, isNull);
    });

    test('sourceTransactionEntryId is null when field is absent', () {
      final json = validJson()..remove('source_transaction_entry_id');
      expect(InternalTransferModel.fromJson(json).sourceTransactionEntryId, isNull);
    });

    test('sourceBookingBalance is null when field is absent', () {
      final json = validJson()..remove('source_booking_balance');
      expect(InternalTransferModel.fromJson(json).sourceBookingBalance, isNull);
    });

    test('targetBookingBalance is null when field is absent', () {
      final json = validJson()..remove('target_booking_balance');
      expect(InternalTransferModel.fromJson(json).targetBookingBalance, isNull);
    });

    test('clientName is null when field is absent', () {
      final json = validJson()..remove('client_name');
      expect(InternalTransferModel.fromJson(json).clientName, isNull);
    });

    test('sourceBookingRef is null when field is absent', () {
      final json = validJson()..remove('source_booking_ref');
      expect(InternalTransferModel.fromJson(json).sourceBookingRef, isNull);
    });

    test('requestedBy is null when field is absent', () {
      final json = validJson()..remove('requested_by');
      expect(InternalTransferModel.fromJson(json).requestedBy, isNull);
    });
  });

  // ── Type safety ───────────────────────────────────────────────────────────────

  group('InternalTransferModel.fromJson — type safety', () {
    test('transferAmount as int parses to double', () {
      final json = validJson()..['transfer_amount'] = 1500;
      expect(InternalTransferModel.fromJson(json).transferAmount, closeTo(1500.0, 0.001));
    });

    test('transferAmount as double literal parses correctly', () {
      final json = validJson()..['transfer_amount'] = 1500.5;
      expect(InternalTransferModel.fromJson(json).transferAmount, closeTo(1500.5, 0.001));
    });

    test('sourceBookingBalance as int (negative) parses to double', () {
      final json = validJson()..['source_booking_balance'] = -500;
      expect(InternalTransferModel.fromJson(json).sourceBookingBalance, closeTo(-500.0, 0.001));
    });

    test('targetBookingBalance as int parses to double', () {
      final json = validJson()..['target_booking_balance'] = 2000;
      expect(InternalTransferModel.fromJson(json).targetBookingBalance, closeTo(2000.0, 0.001));
    });

    test('id from double parses to int', () {
      final json = validJson()..['id'] = 1.0;
      expect(InternalTransferModel.fromJson(json).id, 1);
    });

    test('sourceBookingId from double parses to int', () {
      final json = validJson()..['source_booking_id'] = 10.0;
      expect(InternalTransferModel.fromJson(json).sourceBookingId, 10);
    });

    test('id defaults to 0 when field is null', () {
      final json = validJson()..['id'] = null;
      expect(InternalTransferModel.fromJson(json).id, 0);
    });
  });

  // ── toJson round-trip ─────────────────────────────────────────────────────────

  group('InternalTransferModel — toJson round-trip', () {
    test('toJson contains "transfer_amount", "transfer_type", "status"', () {
      final json = InternalTransferModel.fromJson(validJson()).toJson();
      expect(json.containsKey('transfer_amount'), isTrue);
      expect(json.containsKey('transfer_type'), isTrue);
      expect(json.containsKey('status'), isTrue);
    });

    test('toJson contains "source_booking_id" and "target_booking_id"', () {
      final json = InternalTransferModel.fromJson(validJson()).toJson();
      expect(json.containsKey('source_booking_id'), isTrue);
      expect(json.containsKey('target_booking_id'), isTrue);
    });

    test('toJson contains all expected keys', () {
      final json = InternalTransferModel.fromJson(validJson()).toJson();
      expect(json.containsKey('id'), isTrue);
      expect(json.containsKey('client_id'), isTrue);
      expect(json.containsKey('reason'), isTrue);
      expect(json.containsKey('client_name'), isTrue);
      expect(json.containsKey('source_booking_ref'), isTrue);
      expect(json.containsKey('target_booking_ref'), isTrue);
    });

    test('toJson preserves id and clientId', () {
      final json = InternalTransferModel.fromJson(validJson()).toJson();
      expect(json['id'], 1);
      expect(json['client_id'], 5);
    });

    test('toJson preserves sourceBookingId and targetBookingId', () {
      final json = InternalTransferModel.fromJson(validJson()).toJson();
      expect(json['source_booking_id'], 10);
      expect(json['target_booking_id'], 20);
    });

    test('toJson preserves transferAmount as double', () {
      final json = InternalTransferModel.fromJson(validJson()).toJson();
      expect(json['transfer_amount'], closeTo(1500.0, 0.001));
    });

    test('toJson preserves status and transferType', () {
      final json = InternalTransferModel.fromJson(validJson()).toJson();
      expect(json['status'], 'PENDING_APPROVAL');
      expect(json['transfer_type'], 'OVERPAYMENT_TRANSFER');
    });

    test('reason preserved in round-trip', () {
      final json = InternalTransferModel.fromJson(validJson()).toJson();
      expect(json['reason'], 'Excess payment on booking 10');
    });

    test('toJson preserves sourceBookingBalance as double (negative)', () {
      final json = InternalTransferModel.fromJson(validJson()).toJson();
      expect(json['source_booking_balance'], closeTo(-500.0, 0.001));
    });

    test('null notes remains null in toJson', () {
      final json = InternalTransferModel.fromJson(validJson()).toJson();
      expect(json['notes'], isNull);
    });

    test('null approvedBy remains null in toJson', () {
      final json = InternalTransferModel.fromJson(validJson()).toJson();
      expect(json['approved_by'], isNull);
    });
  });

  // ── fromJsonList ──────────────────────────────────────────────────────────────

  group('InternalTransferModel.fromJsonList', () {
    test('parses a list of 2 items correctly', () {
      final list = [validJson(), validJson()..['id'] = 2];
      final result = InternalTransferModel.fromJsonList(list);
      expect(result, isA<List<InternalTransferModel>>());
      expect(result.length, 2);
    });

    test('first item has correct transferType', () {
      final list = [validJson(), validJson()..['id'] = 2];
      final result = InternalTransferModel.fromJsonList(list);
      expect(result[0].transferType, 'OVERPAYMENT_TRANSFER');
    });

    test('items have correct ids', () {
      final list = [validJson(), validJson()..['id'] = 2];
      final result = InternalTransferModel.fromJsonList(list);
      expect(result[0].id, 1);
      expect(result[1].id, 2);
    });

    test('returns empty list for empty input', () {
      expect(InternalTransferModel.fromJsonList([]), isEmpty);
    });
  });
}
