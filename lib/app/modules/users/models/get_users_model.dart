class GetEmployeeDetails {
  final int id;
  final String userName;
  final int userGender;
  final String userImage;
  final String userEmail;
  final String userPassword;
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
    required this.userPassword,
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

  factory GetEmployeeDetails.fromJson(Map<String, dynamic>? json) {
    json ??= {};

    return GetEmployeeDetails(
      id: json["id"] ?? 0,
      userName: json["user_name"] ?? "",
      userGender: json["user_gender"] ?? 0,
      userImage: json["user_image"] ?? "",
      userEmail: json["user_email"] ?? "",
      userPassword: json["user_password"] ?? "",
      userHomeBranch: json["user_home_branch"] ?? 0,
      userMobile: json["user_mobile"] ?? "",
      userRole: json["user_role"] ?? 0,
      userBranchAccess: json["user_branch_access"] ?? "",
      userStatus: json["user_status"] ?? 0,
      createdBy: json["created_by"] ?? 0,
      createdOn: json["created_on"] ?? "",
      updatedBy: json["updated_by"] ?? 0,
      updatedOn: json["updated_on"] ?? "",
      roleName: json["role_name"] ?? "",
      accessList: json["access_list"] ?? "",
      status: json["status"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_name": userName,
    "user_gender": userGender,
    "user_image": userImage,
    "user_email": userEmail,
    "user_password": userPassword,
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
