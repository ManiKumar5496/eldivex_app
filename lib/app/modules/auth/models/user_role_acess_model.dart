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
      id: int.tryParse('${json?['id'] ?? ''}') ?? 0,
      roleName: (json?['role_name'] ?? "").toString(),
      accessList: (json?['access_list'] ?? "").toString(),
      modules: (json?['modules'] ?? "").toString(),
      moduleIds: (json?['module_ids'] ?? "").toString(),
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
