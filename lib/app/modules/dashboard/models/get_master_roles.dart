class GetMasterRoles {
  final int id;
  final String roleName;
  final String accessList;
  final String modules;
  final String moduleIds;

  GetMasterRoles({
    required this.id,
    required this.roleName,
    required this.accessList,
    required this.modules,
    required this.moduleIds,
  });

  factory GetMasterRoles.fromJson(Map<String, dynamic>? json) {
    json ??= {};

    return GetMasterRoles(
      id: _toInt(json["id"]),
      roleName: _toStr(json["role_name"]),
      accessList: _toStr(json["access_list"]),
      modules: _toStr(json["modules"]),
      moduleIds: _toStr(json["module_ids"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "role_name": roleName,
    "access_list": accessList,
    "modules": modules,
    "module_ids": moduleIds,
  };
}

int _toInt(dynamic v) => v is int ? v : int.tryParse('${v ?? ''}') ?? 0;

String _toStr(dynamic v) => v == null ? '' : v.toString();
