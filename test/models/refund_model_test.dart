import 'package:flutter_test/flutter_test.dart';
import 'package:eldivex_app/app/modules/accounts/models/refund_model.dart';

void main() {
  // ── Fixture ──────────────────────────────────────────────────────────────────

  Map<String, dynamic> validJson() => {
    'id': 1,
    'org_id': 1,
    'client_id': 5,
    'booking_id': 10,
    'invoice_id': 3,
    'refund_amount': '2500.00',
    'refund_channel': 'BANK_TRANSFER',
    'refund_reason': 'OVERPAYMENT',
    'status': 'PENDING_APPROVAL',
    'approval_level': 'L2',
    'receipt_ids': '[1, 2, 3]',
    'channel_details':
        '{"bankName":"HDFC","accountNumber":"123456","ifsc":"HDFC0001"}',
    'dispatch_details': null,
    'notes': 'Client requested refund',
    'requested_by': 7,
    'approved_by': null,
    'created_on': '2026-06-06 10:00:00',
    'client_name': 'Anil Kumar',
    'booking_ref': 'BK-000010',
  };

  // ── Happy path ────────────────────────────────────────────────────────────────

  group('RefundModel.fromJson — happy path', () {
    test('parses id, orgId, clientId, bookingId as ints', () {
      final m = RefundModel.fromJson(validJson());
      expect(m.id, 1);
      expect(m.orgId, 1);
      expect(m.clientId, 5);
      expect(m.bookingId, 10);
    });

    test('parses invoiceId as int', () {
      final m = RefundModel.fromJson(validJson());
      expect(m.invoiceId, 3);
    });

    test('parses refundAmount as double from string', () {
      final m = RefundModel.fromJson(validJson());
      expect(m.refundAmount, closeTo(2500.0, 0.001));
    });

    test('parses refundChannel as String', () {
      final m = RefundModel.fromJson(validJson());
      expect(m.refundChannel, 'BANK_TRANSFER');
    });

    test('parses refundReason as String', () {
      final m = RefundModel.fromJson(validJson());
      expect(m.refundReason, 'OVERPAYMENT');
    });

    test('parses status as String', () {
      final m = RefundModel.fromJson(validJson());
      expect(m.status, 'PENDING_APPROVAL');
    });

    test('parses approvalLevel as String', () {
      final m = RefundModel.fromJson(validJson());
      expect(m.approvalLevel, 'L2');
    });

    test('receiptIds parses from JSON string "[1,2,3]" to List<int> with 3 items', () {
      final m = RefundModel.fromJson(validJson());
      expect(m.receiptIds, isNotNull);
      expect(m.receiptIds!.length, 3);
    });

    test('receiptIds[0] == 1', () {
      final m = RefundModel.fromJson(validJson());
      expect(m.receiptIds![0], 1);
    });

    test('receiptIds[1] == 2 and receiptIds[2] == 3', () {
      final m = RefundModel.fromJson(validJson());
      expect(m.receiptIds![1], 2);
      expect(m.receiptIds![2], 3);
    });

    test('channelDetails parses from JSON string to Map', () {
      final m = RefundModel.fromJson(validJson());
      expect(m.channelDetails, isNotNull);
      expect(m.channelDetails, isA<Map<String, dynamic>>());
    });

    test('channelDetails["bankName"] == "HDFC"', () {
      final m = RefundModel.fromJson(validJson());
      expect(m.channelDetails!['bankName'], 'HDFC');
    });

    test('channelDetails["accountNumber"] and ["ifsc"] parsed', () {
      final m = RefundModel.fromJson(validJson());
      expect(m.channelDetails!['accountNumber'], '123456');
      expect(m.channelDetails!['ifsc'], 'HDFC0001');
    });

    test('dispatchDetails is null when field is null', () {
      final m = RefundModel.fromJson(validJson());
      expect(m.dispatchDetails, isNull);
    });

    test('parses notes as String', () {
      final m = RefundModel.fromJson(validJson());
      expect(m.notes, 'Client requested refund');
    });

    test('parses requestedBy as int', () {
      final m = RefundModel.fromJson(validJson());
      expect(m.requestedBy, 7);
    });

    test('approvedBy is null when field is null', () {
      final m = RefundModel.fromJson(validJson());
      expect(m.approvedBy, isNull);
    });

    test('clientName and bookingRef parsed correctly', () {
      final m = RefundModel.fromJson(validJson());
      expect(m.clientName, 'Anil Kumar');
      expect(m.bookingRef, 'BK-000010');
    });

    test('parses createdOn as String', () {
      final m = RefundModel.fromJson(validJson());
      expect(m.createdOn, '2026-06-06 10:00:00');
    });
  });

  // ── Null / missing fields ─────────────────────────────────────────────────────

  group('RefundModel.fromJson — null / missing fields', () {
    test('receiptIds is null when field is null', () {
      final json = validJson()..['receipt_ids'] = null;
      expect(RefundModel.fromJson(json).receiptIds, isNull);
    });

    test('receiptIds is null when field is absent', () {
      final json = validJson()..remove('receipt_ids');
      expect(RefundModel.fromJson(json).receiptIds, isNull);
    });

    test('channelDetails is null when field is null', () {
      final json = validJson()..['channel_details'] = null;
      expect(RefundModel.fromJson(json).channelDetails, isNull);
    });

    test('channelDetails is null when field is absent', () {
      final json = validJson()..remove('channel_details');
      expect(RefundModel.fromJson(json).channelDetails, isNull);
    });

    test('invoiceId is null when field is null', () {
      final json = validJson()..['invoice_id'] = null;
      expect(RefundModel.fromJson(json).invoiceId, isNull);
    });

    test('notes is null when field is null', () {
      final json = validJson()..['notes'] = null;
      expect(RefundModel.fromJson(json).notes, isNull);
    });

    test('approvalLevel is null when field is absent', () {
      final json = validJson()..remove('approval_level');
      expect(RefundModel.fromJson(json).approvalLevel, isNull);
    });

    test('clientName is null when field is absent', () {
      final json = validJson()..remove('client_name');
      expect(RefundModel.fromJson(json).clientName, isNull);
    });
  });

  // ── Type safety ───────────────────────────────────────────────────────────────

  group('RefundModel.fromJson — type safety', () {
    test('refundAmount as int parses to double', () {
      final json = validJson()..['refund_amount'] = 2500;
      expect(RefundModel.fromJson(json).refundAmount, closeTo(2500.0, 0.001));
    });

    test('refundAmount as double literal parses correctly', () {
      final json = validJson()..['refund_amount'] = 2500.5;
      expect(RefundModel.fromJson(json).refundAmount, closeTo(2500.5, 0.001));
    });

    test('receiptIds parses from List<int> directly (not JSON string)', () {
      final json = validJson()..['receipt_ids'] = [10, 20, 30];
      final m = RefundModel.fromJson(json);
      expect(m.receiptIds, isNotNull);
      expect(m.receiptIds!.length, 3);
      expect(m.receiptIds![0], 10);
    });

    test('channelDetails parses from Map directly (not JSON string)', () {
      final json = validJson()
        ..['channel_details'] = {'bankName': 'SBI', 'accountNumber': '999'};
      final m = RefundModel.fromJson(json);
      expect(m.channelDetails!['bankName'], 'SBI');
    });

    test('id from double parses to int', () {
      final json = validJson()..['id'] = 1.0;
      expect(RefundModel.fromJson(json).id, 1);
    });
  });

  // ── toJson round-trip ─────────────────────────────────────────────────────────

  group('RefundModel — toJson round-trip', () {
    test('toJson contains "refund_amount", "refund_channel", "status"', () {
      final json = RefundModel.fromJson(validJson()).toJson();
      expect(json.containsKey('refund_amount'), isTrue);
      expect(json.containsKey('refund_channel'), isTrue);
      expect(json.containsKey('status'), isTrue);
    });

    test('toJson contains all expected keys', () {
      final json = RefundModel.fromJson(validJson()).toJson();
      expect(json.containsKey('id'), isTrue);
      expect(json.containsKey('client_id'), isTrue);
      expect(json.containsKey('booking_id'), isTrue);
      expect(json.containsKey('receipt_ids'), isTrue);
      expect(json.containsKey('channel_details'), isTrue);
      expect(json.containsKey('client_name'), isTrue);
    });

    test('toJson preserves refundAmount as double', () {
      final json = RefundModel.fromJson(validJson()).toJson();
      expect(json['refund_amount'], closeTo(2500.0, 0.001));
    });

    test('toJson preserves refundChannel and status', () {
      final json = RefundModel.fromJson(validJson()).toJson();
      expect(json['refund_channel'], 'BANK_TRANSFER');
      expect(json['status'], 'PENDING_APPROVAL');
    });

    test('toJson preserves clientName and bookingRef', () {
      final json = RefundModel.fromJson(validJson()).toJson();
      expect(json['client_name'], 'Anil Kumar');
      expect(json['booking_ref'], 'BK-000010');
    });

    test('toJson preserves null approvedBy', () {
      final json = RefundModel.fromJson(validJson()).toJson();
      expect(json['approved_by'], isNull);
    });

    test('channelDetails preserved in round-trip', () {
      final json = RefundModel.fromJson(validJson()).toJson();
      expect(json['channel_details'], isA<Map>());
      expect((json['channel_details'] as Map)['bankName'], 'HDFC');
    });
  });

  // ── fromJsonList ──────────────────────────────────────────────────────────────

  group('RefundModel.fromJsonList', () {
    test('parses a list of 2 items correctly', () {
      final list = [validJson(), validJson()..['id'] = 2];
      final result = RefundModel.fromJsonList(list);
      expect(result, isA<List<RefundModel>>());
      expect(result.length, 2);
    });

    test('first item has correct id and refundChannel', () {
      final list = [validJson(), validJson()..['id'] = 2];
      final result = RefundModel.fromJsonList(list);
      expect(result[0].id, 1);
      expect(result[0].refundChannel, 'BANK_TRANSFER');
    });

    test('second item has correct id', () {
      final list = [validJson(), validJson()..['id'] = 2];
      final result = RefundModel.fromJsonList(list);
      expect(result[1].id, 2);
    });

    test('returns empty list for empty input', () {
      expect(RefundModel.fromJsonList([]), isEmpty);
    });
  });
}
