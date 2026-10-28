import 'parse_utils.dart';

class ApprovalHistoryModel {
  final int id;
  final int orgId;
  final int referenceId;
  final int actionBy;
  final String referenceType;
  final String action;
  final String? notes;
  final String? actionOn;
  final String? actionByName;
  final int? approvalLevel;

  ApprovalHistoryModel({
    required this.id,
    required this.orgId,
    required this.referenceId,
    required this.actionBy,
    required this.referenceType,
    required this.action,
    this.notes,
    this.actionOn,
    this.actionByName,
    this.approvalLevel,
  });

  factory ApprovalHistoryModel.fromJson(Map<String, dynamic> json) {
    return ApprovalHistoryModel(
      id:            toInt(json['id']),
      orgId:         toInt(json['org_id']),
      referenceId:   toInt(json['reference_id']),
      actionBy:      toInt(json['action_by']),
      referenceType: toStr(json['reference_type']),
      action:        toStr(json['action']),
      notes:         toStrOrNull(json['notes']),
      actionOn:      toStrOrNull(json['action_on']),
      actionByName:  toStrOrNull(json['action_by_name']),
      approvalLevel: toIntOrNull(json['approval_level']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id':             id,
    'org_id':         orgId,
    'reference_id':   referenceId,
    'action_by':      actionBy,
    'reference_type': referenceType,
    'action':         action,
    'notes':          notes,
    'action_on':      actionOn,
    'action_by_name': actionByName,
    'approval_level': approvalLevel,
  };

  static List<ApprovalHistoryModel> fromJsonList(List list) =>
      parseList(list, ApprovalHistoryModel.fromJson);
}
