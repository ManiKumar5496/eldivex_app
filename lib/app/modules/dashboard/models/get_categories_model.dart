class CategoryModel {
  final int id;
  final String catName;
  final String catIcon;
  final int status;

  CategoryModel({
    required this.id,
    required this.catName,
    required this.catIcon,
    required this.status,
  });

  factory CategoryModel.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    return CategoryModel(
      id: _toInt(json['id']),
      catName: _toStr(json['cat_name']),
      catIcon: _toStr(json['cat_icon']),
      status: _toInt(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "cat_name": catName,
      "cat_icon": catIcon,
      "status": status,
    };
  }
}

int _toInt(dynamic v) => v is int ? v : int.tryParse('${v ?? ''}') ?? 0;

String _toStr(dynamic v) => v == null ? '' : v.toString();
