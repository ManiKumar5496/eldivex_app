class MasterModuleList {
  final int id;
  final String moduleName;

  MasterModuleList({
    required this.id,
    required this.moduleName,
  });

  factory MasterModuleList.fromJson(Map<String, dynamic>? json) {
    json ??= {};

    return MasterModuleList(
      id: _toInt(json["id"]),
      moduleName: _toStr(json["module_name"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "module_name": moduleName,
  };
  List<String> getModulesList() {
    if (moduleName.isEmpty) return [];
    return moduleName.split(',').map((e) => e.trim()).toList();
  }

  // Helper method to get individual module IDs
  List<String> getModuleIdsList() {
    if (id == 0) return [];
    return moduleName.split(',').map((e) => e.trim()).toList();
  }
}

int _toInt(dynamic v) => v is int ? v : int.tryParse('${v ?? ''}') ?? 0;

String _toStr(dynamic v) => v == null ? '' : v.toString();
