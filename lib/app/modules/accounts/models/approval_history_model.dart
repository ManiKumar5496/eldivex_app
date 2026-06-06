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
      id:            (json['id'] as num?)?.toInt() ?? 0,
      orgId:         (json['org_id'] as num?)?.toInt() ?? 0,
      referenceId:   (json['reference_id'] as num?)?.toInt() ?? 0,
      actionBy:      (json['action_by'] as num?)?.toInt() ?? 0,
      referenceType: json['reference_type']?.toString() ?? '',
      action:        json['action']?.toString() ?? '',
      notes:         json['notes'] as String?,
      actionOn:      json['action_on'] as String?,
      actionByName:  json['action_by_name'] as String?,
      approvalLevel: (json['approval_level'] as num?)?.toInt(),
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
      list.map((e) => ApprovalHistoryModel.fromJson(e as Map<String, dynamic>)).toList();
}
