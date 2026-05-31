class UserRoleAccessModel {
  final int id;
  final String roleName;
  final String accessList;
  final String modules;
  final String moduleIds;

  const UserRoleAccessModel({
    required this.id,
    required this.roleName,
    required this.accessList,
    required this.modules,
    required this.moduleIds,
  });

  factory UserRoleAccessModel.fromJson(Map<String, dynamic>? json) {
    return UserRoleAccessModel(
      id: json?['id'] ?? 0,
      roleName: json?['role_name'] ?? "",
      accessList: json?['access_list'] ?? "",
      modules: json?['modules'] ?? "",
      moduleIds: json?['module_ids'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "role_name": roleName,
      "access_list": accessList,
      "modules": modules,
      "module_ids": moduleIds,
    };
  }
}
