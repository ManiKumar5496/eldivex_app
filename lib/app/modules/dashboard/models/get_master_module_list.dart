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
      id: json["id"] ?? 0,
      moduleName: json["module_name"] ?? "",
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
