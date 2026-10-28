class GetEmployeeDetails {
  final int id;
  final String userName;
  final int userGender;
  final String userImage;
  final String userEmail;
  final int userHomeBranch;
  final String userMobile;
  final int userRole;
  final String userBranchAccess;
  final int userStatus;
  final int createdBy;
  final String createdOn;
  final int updatedBy;
  final String updatedOn;
  final String roleName;
  final String accessList;
  final int status;

  GetEmployeeDetails({
    required this.id,
    required this.userName,
    required this.userGender,
    required this.userImage,
    required this.userEmail,
    required this.userHomeBranch,
    required this.userMobile,
    required this.userRole,
    required this.userBranchAccess,
    required this.userStatus,
    required this.createdBy,
    required this.createdOn,
    required this.updatedBy,
    required this.updatedOn,
    required this.roleName,
    required this.accessList,
    required this.status,
  });

  /// user_status 1 = active, 0 = terminated.
  bool get isActive => userStatus == 1;

  factory GetEmployeeDetails.fromJson(Map<String, dynamic>? json) {
    json ??= {};

    return GetEmployeeDetails(
      id: _toInt(json["id"]),
      userName: _toStr(json["user_name"]),
      userGender: _toInt(json["user_gender"]),
      userImage: _toStr(json["user_image"]),
      userEmail: _toStr(json["user_email"]),
      userHomeBranch: _toInt(json["user_home_branch"]),
      userMobile: _toStr(json["user_mobile"]),
      userRole: _toInt(json["user_role"]),
      userBranchAccess: _toStr(json["user_branch_access"]),
      userStatus: _toInt(json["user_status"]),
      createdBy: _toInt(json["created_by"]),
      createdOn: _toStr(json["created_on"]),
      updatedBy: _toInt(json["updated_by"]),
      updatedOn: _toStr(json["updated_on"]),
      roleName: _toStr(json["role_name"]),
      accessList: _toStr(json["access_list"]),
      status: _toInt(json["status"]),
    );
  }

  /// Backend columns are loosely typed — numeric fields can come back as ints,
  /// numeric strings ("2"), or the literal "NA" (createUserWeb's default). Parse
  /// defensively so a single odd row never throws and blanks the whole list.
  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static String _toStr(dynamic v) => v?.toString() ?? "";

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_name": userName,
    "user_gender": userGender,
    "user_image": userImage,
    "user_email": userEmail,
    "user_home_branch": userHomeBranch,
    "user_mobile": userMobile,
    "user_role": userRole,
    "user_branch_access": userBranchAccess,
    "user_status": userStatus,
    "created_by": createdBy,
    "created_on": createdOn,
    "updated_by": updatedBy,
    "updated_on": updatedOn,
    "role_name": roleName,
    "access_list": accessList,
    "status": status,
  };
}
