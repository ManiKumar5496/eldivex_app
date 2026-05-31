class ServicesByCategoryModel {
  final int id;
  final int serviceType;
  final int serviceCategoryId;
  final int liveType;
  final int hpGender;
  final String name;
  final String serviceRate;
  final String marketRate;
  final int branchId;
  final String description;
  final String imageUrl;
  final String effectiveFromDate;
  final String effectiveToDate;
  final String createdOn;
  final int createdBy;
  final String updatedOn;
  final int updatedBy;
  final int status;

  ServicesByCategoryModel({
    required this.id,
    required this.serviceType,
    required this.serviceCategoryId,
    required this.liveType,
    required this.hpGender,
    required this.name,
    required this.serviceRate,
    required this.marketRate,
    required this.branchId,
    required this.description,
    required this.imageUrl,
    required this.effectiveFromDate,
    required this.effectiveToDate,
    required this.createdOn,
    required this.createdBy,
    required this.updatedOn,
    required this.updatedBy,
    required this.status,
  });

  factory ServicesByCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServicesByCategoryModel(
      id: json['id'] ?? 0,
      serviceType: json['service_type'] ?? 0,
      serviceCategoryId: json['service_category_id'] ?? 0,
      liveType: json['live_type'] ?? 0,
      hpGender: json['hp_gender'] ?? 0,
      name: json['name'] ?? '',
      serviceRate: json['service_rate']?.toString() ?? '',
      marketRate: json['market_rate']?.toString() ?? '',
      branchId: json['branch_id'] ?? 0,
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      effectiveFromDate: json['effective_from_date'] ?? '',
      effectiveToDate: json['effective_to_date'] ?? '',
      createdOn: json['created_on'] ?? '',
      createdBy: json['created_by'] ?? 0,
      updatedOn: json['updated_on'] ?? '',
      updatedBy: json['updated_by'] ?? 0,
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "service_type": serviceType,
      "service_category_id": serviceCategoryId,
      "live_type": liveType,
      "hp_gender": hpGender,
      "name": name,
      "service_rate": serviceRate,
      "market_rate": marketRate,
      "branch_id": branchId,
      "description": description,
      "image_url": imageUrl,
      "effective_from_date": effectiveFromDate,
      "effective_to_date": effectiveToDate,
      "created_on": createdOn,
      "created_by": createdBy,
      "updated_on": updatedOn,
      "updated_by": updatedBy,
      "status": status,
    };
  }
}
