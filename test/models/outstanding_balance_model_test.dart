import 'package:flutter_test/flutter_test.dart';
import 'package:eldivex_app/app/modules/accounts/models/outstanding_balance_model.dart';

void main() {
  // ── Fixture ──────────────────────────────────────────────────────────────────

  Map<String, dynamic> validJson() => {
    'client_id': 5,
    'booking_id': null,
    'total_billed': '5000.00',
    'total_paid': '3000.00',
    'total_write_off': '200.00',
    'total_credit_note_issued': '0.00',
    'total_credit_note_applied': '300.00',
    'total_refunded': '100.00',
    'total_internal_transfer_in': '0.00',
    'total_internal_transfer_out': '0.00',
    'outstanding_amount': '1400.00',
    'last_updated': '2026-06-06',
    'aging_buckets': [
      {'label': 'Current', 'amount': 800.0, 'count': 2},
      {'label': '31-60 days', 'amount': 600.0, 'count': 1},
    ],
  };

  // ── Happy path ────────────────────────────────────────────────────────────────

  group('OutstandingBalanceModel.fromJson — happy path', () {
    test('parses clientId as int', () {
      final m = OutstandingBalanceModel.fromJson(validJson());
      expect(m.clientId, 5);
    });

    test('bookingId is null when field is null', () {
      final m = OutstandingBalanceModel.fromJson(validJson());
      expect(m.bookingId, isNull);
    });

    test('parses totalBilled as double from string', () {
      final m = OutstandingBalanceModel.fromJson(validJson());
      expect(m.totalBilled, closeTo(5000.0, 0.001));
    });

    test('parses totalPaid as double from string', () {
      final m = OutstandingBalanceModel.fromJson(validJson());
      expect(m.totalPaid, closeTo(3000.0, 0.001));
    });

    test('parses totalWriteOff as double from string', () {
      final m = OutstandingBalanceModel.fromJson(validJson());
      expect(m.totalWriteOff, closeTo(200.0, 0.001));
    });

    test('parses totalCreditNoteIssued as double from string', () {
      final m = OutstandingBalanceModel.fromJson(validJson());
      expect(m.totalCreditNoteIssued, closeTo(0.0, 0.001));
    });

    test('parses totalCreditNoteApplied as double from string', () {
      final m = OutstandingBalanceModel.fromJson(validJson());
      expect(m.totalCreditNoteApplied, closeTo(300.0, 0.001));
    });

    test('parses totalRefunded as double from string', () {
      final m = OutstandingBalanceModel.fromJson(validJson());
      expect(m.totalRefunded, closeTo(100.0, 0.001));
    });

    test('parses totalInternalTransferIn as double from string', () {
      final m = OutstandingBalanceModel.fromJson(validJson());
      expect(m.totalInternalTransferIn, closeTo(0.0, 0.001));
    });

    test('parses totalInternalTransferOut as double from string', () {
      final m = OutstandingBalanceModel.fromJson(validJson());
      expect(m.totalInternalTransferOut, closeTo(0.0, 0.001));
    });

    test('parses outstandingAmount correctly', () {
      final m = OutstandingBalanceModel.fromJson(validJson());
      expect(m.outstandingAmount, closeTo(1400.0, 0.001));
    });

    test('parses lastUpdated as String', () {
      final m = OutstandingBalanceModel.fromJson(validJson());
      expect(m.lastUpdated, '2026-06-06');
    });

    test('agingBuckets is a List<AgingBucket> with 2 items', () {
      final m = OutstandingBalanceModel.fromJson(validJson());
      expect(m.agingBuckets, isNotNull);
      expect(m.agingBuckets, isA<List<AgingBucket>>());
      expect(m.agingBuckets!.length, 2);
    });

    test('agingBuckets[0].label == "Current"', () {
      final m = OutstandingBalanceModel.fromJson(validJson());
      expect(m.agingBuckets![0].label, 'Current');
    });

    test('agingBuckets[0].amount == 800.0', () {
      final m = OutstandingBalanceModel.fromJson(validJson());
      expect(m.agingBuckets![0].amount, closeTo(800.0, 0.001));
    });

    test('agingBuckets[0].count == 2', () {
      final m = OutstandingBalanceModel.fromJson(validJson());
      expect(m.agingBuckets![0].count, 2);
    });

    test('agingBuckets[1].label == "31-60 days"', () {
      final m = OutstandingBalanceModel.fromJson(validJson());
      expect(m.agingBuckets![1].label, '31-60 days');
    });

    test('agingBuckets[1].amount == 600.0', () {
      final m = OutstandingBalanceModel.fromJson(validJson());
      expect(m.agingBuckets![1].amount, closeTo(600.0, 0.001));
    });
  });

  // ── Null / missing fields ─────────────────────────────────────────────────────

  group('OutstandingBalanceModel.fromJson — null / missing fields', () {
    test('bookingId is null when field is null', () {
      final json = validJson()..['booking_id'] = null;
      expect(OutstandingBalanceModel.fromJson(json).bookingId, isNull);
    });

    test('agingBuckets is null when field is null', () {
      final json = validJson()..['aging_buckets'] = null;
      expect(OutstandingBalanceModel.fromJson(json).agingBuckets, isNull);
    });

    test('agingBuckets is null when field is absent', () {
      final json = validJson()..remove('aging_buckets');
      expect(OutstandingBalanceModel.fromJson(json).agingBuckets, isNull);
    });

    test('lastUpdated is null when field is absent', () {
      final json = validJson()..remove('last_updated');
      expect(OutstandingBalanceModel.fromJson(json).lastUpdated, isNull);
    });

    test('clientId is null when field is absent', () {
      final json = validJson()..remove('client_id');
      expect(OutstandingBalanceModel.fromJson(json).clientId, isNull);
    });
  });

  // ── Type safety ───────────────────────────────────────────────────────────────

  group('OutstandingBalanceModel.fromJson — type safety', () {
    test('totalBilled as int parses to double', () {
      final json = validJson()..['total_billed'] = 5000;
      expect(OutstandingBalanceModel.fromJson(json).totalBilled, closeTo(5000.0, 0.001));
    });

    test('totalPaid as double literal parses correctly', () {
      final json = validJson()..['total_paid'] = 3000.0;
      expect(OutstandingBalanceModel.fromJson(json).totalPaid, closeTo(3000.0, 0.001));
    });

    test('outstandingAmount as int parses to double', () {
      final json = validJson()..['outstanding_amount'] = 1400;
      expect(OutstandingBalanceModel.fromJson(json).outstandingAmount, closeTo(1400.0, 0.001));
    });

    test('totalCreditNoteApplied as int parses to double', () {
      final json = validJson()..['total_credit_note_applied'] = 300;
      expect(OutstandingBalanceModel.fromJson(json).totalCreditNoteApplied, closeTo(300.0, 0.001));
    });

    test('all totals default to 0.0 when field is null', () {
      final json = validJson()
        ..['total_billed'] = null
        ..['total_paid'] = null;
      final m = OutstandingBalanceModel.fromJson(json);
      expect(m.totalBilled, closeTo(0.0, 0.001));
      expect(m.totalPaid, closeTo(0.0, 0.001));
    });
  });

  // ── toJson round-trip ─────────────────────────────────────────────────────────

  group('OutstandingBalanceModel — toJson round-trip', () {
    test('toJson contains "outstanding_amount" key', () {
      final json = OutstandingBalanceModel.fromJson(validJson()).toJson();
      expect(json.containsKey('outstanding_amount'), isTrue);
    });

    test('toJson contains all expected keys', () {
      final json = OutstandingBalanceModel.fromJson(validJson()).toJson();
      expect(json.containsKey('client_id'), isTrue);
      expect(json.containsKey('total_billed'), isTrue);
      expect(json.containsKey('total_paid'), isTrue);
      expect(json.containsKey('aging_buckets'), isTrue);
      expect(json.containsKey('last_updated'), isTrue);
    });

    test('toJson preserves clientId', () {
      final json = OutstandingBalanceModel.fromJson(validJson()).toJson();
      expect(json['client_id'], 5);
    });

    test('toJson preserves outstandingAmount as double', () {
      final json = OutstandingBalanceModel.fromJson(validJson()).toJson();
      expect(json['outstanding_amount'], closeTo(1400.0, 0.001));
    });

    test('toJson preserves bookingId as null', () {
      final json = OutstandingBalanceModel.fromJson(validJson()).toJson();
      expect(json['booking_id'], isNull);
    });

    test('toJson serialises agingBuckets as List', () {
      final json = OutstandingBalanceModel.fromJson(validJson()).toJson();
      expect(json['aging_buckets'], isA<List>());
      expect((json['aging_buckets'] as List).length, 2);
    });

    test('agingBucket toJson preserves label and amount', () {
      final json = OutstandingBalanceModel.fromJson(validJson()).toJson();
      final bucket = (json['aging_buckets'] as List)[0] as Map<String, dynamic>;
      expect(bucket['label'], 'Current');
      expect(bucket['amount'], closeTo(800.0, 0.001));
    });
  });

  // ── fromJsonList ──────────────────────────────────────────────────────────────

  group('OutstandingBalanceModel — no fromJsonList (single-record API)', () {
    test('fromJson returns a single OutstandingBalanceModel', () {
      final m = OutstandingBalanceModel.fromJson(validJson());
      expect(m, isA<OutstandingBalanceModel>());
      expect(m.clientId, 5);
    });

    test('two independent fromJson calls produce correct models', () {
      final m1 = OutstandingBalanceModel.fromJson(validJson());
      final m2 = OutstandingBalanceModel.fromJson(
        validJson()
          ..['client_id'] = 6
          ..['outstanding_amount'] = '2000.00',
      );
      expect(m1.clientId, 5);
      expect(m2.clientId, 6);
      expect(m2.outstandingAmount, closeTo(2000.0, 0.001));
    });
  });
}
