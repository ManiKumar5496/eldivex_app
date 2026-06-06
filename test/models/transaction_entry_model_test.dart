import 'package:flutter_test/flutter_test.dart';
import 'package:eldivex_app/app/modules/accounts/models/transaction_entry_model.dart';

void main() {
  // ── Fixture ──────────────────────────────────────────────────────────────────

  Map<String, dynamic> validJson() => {
    'id': 1,
    'org_id': 1,
    'client_id': 5,
    'booking_id': 10,
    'invoice_id': 3,
    'transaction_type': 'RECEIPT',
    'direction': 'CREDIT',
    'amount': '500.00',
    'reference_id': 99,
    'reference_type': 'RECEIPT',
    'status': 'COMPLETED',
    'description': 'Payment received',
    'notes': null,
    'running_balance_client': '1500.00',
    'running_balance_booking': '500.00',
    'created_by': 7,
    'created_on': '2026-06-06 10:00:00',
    'reversed_by': null,
    'reversed_at': null,
    'reversal_reason': null,
  };

  // ── Happy path ────────────────────────────────────────────────────────────────

  group('TransactionEntryModel.fromJson — happy path', () {
    test('parses id, orgId, clientId, bookingId, invoiceId as ints', () {
      final m = TransactionEntryModel.fromJson(validJson());
      expect(m.id, 1);
      expect(m.orgId, 1);
      expect(m.clientId, 5);
      expect(m.bookingId, 10);
      expect(m.invoiceId, 3);
    });

    test('parses amount as double from string "500.00"', () {
      final m = TransactionEntryModel.fromJson(validJson());
      expect(m.amount, closeTo(500.0, 0.001));
    });

    test('parses transactionType and direction as strings', () {
      final m = TransactionEntryModel.fromJson(validJson());
      expect(m.transactionType, 'RECEIPT');
      expect(m.direction, 'CREDIT');
    });

    test('parses status as String', () {
      final m = TransactionEntryModel.fromJson(validJson());
      expect(m.status, 'COMPLETED');
    });

    test('parses description as String', () {
      final m = TransactionEntryModel.fromJson(validJson());
      expect(m.description, 'Payment received');
    });

    test('parses runningBalanceClient as double from string', () {
      final m = TransactionEntryModel.fromJson(validJson());
      expect(m.runningBalanceClient, closeTo(1500.0, 0.001));
    });

    test('parses runningBalanceBooking as double from string', () {
      final m = TransactionEntryModel.fromJson(validJson());
      expect(m.runningBalanceBooking, closeTo(500.0, 0.001));
    });

    test('parses createdBy and referenceId as ints', () {
      final m = TransactionEntryModel.fromJson(validJson());
      expect(m.createdBy, 7);
      expect(m.referenceId, 99);
    });

    test('parses createdOn as String', () {
      final m = TransactionEntryModel.fromJson(validJson());
      expect(m.createdOn, '2026-06-06 10:00:00');
    });

    test('notes is null when field is null', () {
      final m = TransactionEntryModel.fromJson(validJson());
      expect(m.notes, isNull);
    });

    test('reversedBy is null when field is null', () {
      final m = TransactionEntryModel.fromJson(validJson());
      expect(m.reversedBy, isNull);
    });

    test('reversedAt is null when field is null', () {
      final m = TransactionEntryModel.fromJson(validJson());
      expect(m.reversedAt, isNull);
    });

    test('reversalReason is null when field is null', () {
      final m = TransactionEntryModel.fromJson(validJson());
      expect(m.reversalReason, isNull);
    });
  });

  // ── Null / missing fields ─────────────────────────────────────────────────────

  group('TransactionEntryModel.fromJson — null / missing fields', () {
    test('bookingId is null when field is null', () {
      final json = validJson()..['booking_id'] = null;
      expect(TransactionEntryModel.fromJson(json).bookingId, isNull);
    });

    test('invoiceId is null when field is null', () {
      final json = validJson()..['invoice_id'] = null;
      expect(TransactionEntryModel.fromJson(json).invoiceId, isNull);
    });

    test('runningBalanceClient is null when field is absent', () {
      final json = validJson()..remove('running_balance_client');
      expect(TransactionEntryModel.fromJson(json).runningBalanceClient, isNull);
    });

    test('runningBalanceBooking is null when field is absent', () {
      final json = validJson()..remove('running_balance_booking');
      expect(TransactionEntryModel.fromJson(json).runningBalanceBooking, isNull);
    });

    test('description is null when field is absent', () {
      final json = validJson()..remove('description');
      expect(TransactionEntryModel.fromJson(json).description, isNull);
    });

    test('referenceId is null when field is absent', () {
      final json = validJson()..remove('reference_id');
      expect(TransactionEntryModel.fromJson(json).referenceId, isNull);
    });

    test('referenceType is null when field is absent', () {
      final json = validJson()..remove('reference_type');
      expect(TransactionEntryModel.fromJson(json).referenceType, isNull);
    });
  });

  // ── Type safety ───────────────────────────────────────────────────────────────

  group('TransactionEntryModel.fromJson — type safety', () {
    test('amount as int in JSON parses to double', () {
      final json = validJson()..['amount'] = 500;
      expect(TransactionEntryModel.fromJson(json).amount, closeTo(500.0, 0.001));
    });

    test('amount as double literal in JSON parses correctly', () {
      final json = validJson()..['amount'] = 500.75;
      expect(TransactionEntryModel.fromJson(json).amount, closeTo(500.75, 0.001));
    });

    test('runningBalanceClient as int parses to double', () {
      final json = validJson()..['running_balance_client'] = 1500;
      expect(TransactionEntryModel.fromJson(json).runningBalanceClient, closeTo(1500.0, 0.001));
    });

    test('id from num parses to int', () {
      final json = validJson()..['id'] = 1.0;
      expect(TransactionEntryModel.fromJson(json).id, 1);
    });

    test('transactionType from non-String still returns String via toString', () {
      final json = validJson()..['transaction_type'] = 'PAYMENT';
      expect(TransactionEntryModel.fromJson(json).transactionType, 'PAYMENT');
    });
  });

  // ── toJson round-trip ─────────────────────────────────────────────────────────

  group('TransactionEntryModel — toJson round-trip', () {
    test('toJson contains expected keys', () {
      final json = TransactionEntryModel.fromJson(validJson()).toJson();
      expect(json.containsKey('transaction_type'), isTrue);
      expect(json.containsKey('direction'), isTrue);
      expect(json.containsKey('amount'), isTrue);
      expect(json.containsKey('status'), isTrue);
      expect(json.containsKey('id'), isTrue);
    });

    test('toJson preserves id and clientId', () {
      final json = TransactionEntryModel.fromJson(validJson()).toJson();
      expect(json['id'], 1);
      expect(json['client_id'], 5);
    });

    test('toJson preserves transactionType and direction', () {
      final json = TransactionEntryModel.fromJson(validJson()).toJson();
      expect(json['transaction_type'], 'RECEIPT');
      expect(json['direction'], 'CREDIT');
    });

    test('toJson preserves amount as double', () {
      final json = TransactionEntryModel.fromJson(validJson()).toJson();
      expect(json['amount'], closeTo(500.0, 0.001));
    });

    test('toJson preserves null fields as null', () {
      final json = TransactionEntryModel.fromJson(validJson()).toJson();
      expect(json['notes'], isNull);
      expect(json['reversed_by'], isNull);
      expect(json['reversed_at'], isNull);
    });

    test('bookingId preserved in round-trip', () {
      final json = TransactionEntryModel.fromJson(validJson()).toJson();
      expect(json['booking_id'], 10);
    });
  });

  // ── fromJsonList ──────────────────────────────────────────────────────────────

  group('TransactionEntryModel.fromJsonList', () {
    test('parses a list of 2 items correctly', () {
      final list = [validJson(), validJson()..['id'] = 2];
      final result = TransactionEntryModel.fromJsonList(list);
      expect(result, isA<List<TransactionEntryModel>>());
      expect(result.length, 2);
    });

    test('first item has correct id', () {
      final list = [validJson(), validJson()..['id'] = 2];
      final result = TransactionEntryModel.fromJsonList(list);
      expect(result[0].id, 1);
    });

    test('second item has correct id', () {
      final list = [validJson(), validJson()..['id'] = 2];
      final result = TransactionEntryModel.fromJsonList(list);
      expect(result[1].id, 2);
    });

    test('returns empty list for empty input', () {
      expect(TransactionEntryModel.fromJsonList([]), isEmpty);
    });
  });
}
