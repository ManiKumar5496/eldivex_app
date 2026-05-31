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

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      catName: json['cat_name'] ?? '',
      catIcon: json['cat_icon'] ?? '',
      status: json['status'] ?? 0,
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
