import 'package:flutter_test/flutter_test.dart';
import 'package:eldivex_app/app/modules/accounts/models/approval_history_model.dart';

void main() {
  // ── Fixture ──────────────────────────────────────────────────────────────────

  Map<String, dynamic> validJson() => {
    'id': 1,
    'org_id': 1,
    'reference_type': 'WRITE_OFF',
    'reference_id': 42,
    'action': 'APPROVED',
    'action_by': 7,
    'notes': 'Looks good',
    'approval_level': 2,
    'action_on': '2026-06-06 10:00:00',
    'action_by_name': 'Finance Head',
  };

  // ── Happy path ────────────────────────────────────────────────────────────────

  group('ApprovalHistoryModel.fromJson — happy path', () {
    test('parses id as int', () {
      final m = ApprovalHistoryModel.fromJson(validJson());
      expect(m.id, 1);
    });

    test('parses orgId as int', () {
      final m = ApprovalHistoryModel.fromJson(validJson());
      expect(m.orgId, 1);
    });

    test('parses referenceId as int', () {
      final m = ApprovalHistoryModel.fromJson(validJson());
      expect(m.referenceId, 42);
    });

    test('parses actionBy as int', () {
      final m = ApprovalHistoryModel.fromJson(validJson());
      expect(m.actionBy, 7);
    });

    test('parses approvalLevel as int', () {
      final m = ApprovalHistoryModel.fromJson(validJson());
      expect(m.approvalLevel, 2);
    });

    test('parses referenceType as String', () {
      final m = ApprovalHistoryModel.fromJson(validJson());
      expect(m.referenceType, 'WRITE_OFF');
    });

    test('parses action as String', () {
      final m = ApprovalHistoryModel.fromJson(validJson());
      expect(m.action, 'APPROVED');
    });

    test('parses notes as String', () {
      final m = ApprovalHistoryModel.fromJson(validJson());
      expect(m.notes, 'Looks good');
    });

    test('parses actionOn as String', () {
      final m = ApprovalHistoryModel.fromJson(validJson());
      expect(m.actionOn, '2026-06-06 10:00:00');
    });

    test('parses actionByName as String', () {
      final m = ApprovalHistoryModel.fromJson(validJson());
      expect(m.actionByName, 'Finance Head');
    });
  });

  // ── Null / missing fields ─────────────────────────────────────────────────────

  group('ApprovalHistoryModel.fromJson — null / missing fields', () {
    test('actionByName is null when field is absent', () {
      final json = validJson()..remove('action_by_name');
      expect(ApprovalHistoryModel.fromJson(json).actionByName, isNull);
    });

    test('notes is null when field is null', () {
      final json = validJson()..['notes'] = null;
      expect(ApprovalHistoryModel.fromJson(json).notes, isNull);
    });

    test('approvalLevel is null when field is null', () {
      final json = validJson()..['approval_level'] = null;
      expect(ApprovalHistoryModel.fromJson(json).approvalLevel, isNull);
    });

    test('approvalLevel is null when field is absent', () {
      final json = validJson()..remove('approval_level');
      expect(ApprovalHistoryModel.fromJson(json).approvalLevel, isNull);
    });

    test('actionOn is null when field is absent', () {
      final json = validJson()..remove('action_on');
      expect(ApprovalHistoryModel.fromJson(json).actionOn, isNull);
    });

    test('notes is null when field is absent', () {
      final json = validJson()..remove('notes');
      expect(ApprovalHistoryModel.fromJson(json).notes, isNull);
    });
  });

  // ── Type safety ───────────────────────────────────────────────────────────────

  group('ApprovalHistoryModel.fromJson — type safety', () {
    test('id from num parses to int', () {
      final json = validJson()..['id'] = 1.0;
      expect(ApprovalHistoryModel.fromJson(json).id, 1);
    });

    test('referenceId from double parses to int', () {
      final json = validJson()..['reference_id'] = 42.0;
      expect(ApprovalHistoryModel.fromJson(json).referenceId, 42);
    });

    test('approvalLevel from double parses to int', () {
      final json = validJson()..['approval_level'] = 2.0;
      expect(ApprovalHistoryModel.fromJson(json).approvalLevel, 2);
    });

    test('actionBy from double parses to int', () {
      final json = validJson()..['action_by'] = 7.0;
      expect(ApprovalHistoryModel.fromJson(json).actionBy, 7);
    });

    test('id defaults to 0 when field is null', () {
      final json = validJson()..['id'] = null;
      expect(ApprovalHistoryModel.fromJson(json).id, 0);
    });
  });

  // ── toJson round-trip ─────────────────────────────────────────────────────────

  group('ApprovalHistoryModel — toJson round-trip', () {
    test('toJson contains "reference_type", "action", "action_by"', () {
      final json = ApprovalHistoryModel.fromJson(validJson()).toJson();
      expect(json.containsKey('reference_type'), isTrue);
      expect(json.containsKey('action'), isTrue);
      expect(json.containsKey('action_by'), isTrue);
    });

    test('toJson contains all expected keys', () {
      final json = ApprovalHistoryModel.fromJson(validJson()).toJson();
      expect(json.containsKey('id'), isTrue);
      expect(json.containsKey('org_id'), isTrue);
      expect(json.containsKey('reference_id'), isTrue);
      expect(json.containsKey('approval_level'), isTrue);
      expect(json.containsKey('action_by_name'), isTrue);
    });

    test('toJson preserves id and referenceId', () {
      final json = ApprovalHistoryModel.fromJson(validJson()).toJson();
      expect(json['id'], 1);
      expect(json['reference_id'], 42);
    });

    test('toJson preserves action and referenceType', () {
      final json = ApprovalHistoryModel.fromJson(validJson()).toJson();
      expect(json['action'], 'APPROVED');
      expect(json['reference_type'], 'WRITE_OFF');
    });

    test('toJson preserves actionByName', () {
      final json = ApprovalHistoryModel.fromJson(validJson()).toJson();
      expect(json['action_by_name'], 'Finance Head');
    });

    test('null notes remains null in toJson', () {
      final json = validJson()..['notes'] = null;
      final result = ApprovalHistoryModel.fromJson(json).toJson();
      expect(result['notes'], isNull);
    });
  });

  // ── fromJsonList ──────────────────────────────────────────────────────────────

  group('ApprovalHistoryModel.fromJsonList', () {
    test('parses a list of 3 items correctly', () {
      final list = [
        validJson(),
        validJson()..['id'] = 2,
        validJson()..['id'] = 3,
      ];
      final result = ApprovalHistoryModel.fromJsonList(list);
      expect(result, isA<List<ApprovalHistoryModel>>());
      expect(result.length, 3);
    });

    test('first item has correct action', () {
      final list = [validJson(), validJson()..['id'] = 2, validJson()..['id'] = 3];
      final result = ApprovalHistoryModel.fromJsonList(list);
      expect(result[0].action, 'APPROVED');
    });

    test('items have correct ids', () {
      final list = [
        validJson(),
        validJson()..['id'] = 2,
        validJson()..['id'] = 3,
      ];
      final result = ApprovalHistoryModel.fromJsonList(list);
      expect(result[0].id, 1);
      expect(result[1].id, 2);
      expect(result[2].id, 3);
    });

    test('returns empty list for empty input', () {
      expect(ApprovalHistoryModel.fromJsonList([]), isEmpty);
    });
  });
}
