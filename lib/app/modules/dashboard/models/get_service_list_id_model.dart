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

  factory ServicesByCategoryModel.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    return ServicesByCategoryModel(
      id: _toInt(json['id']),
      serviceType: _toInt(json['service_type']),
      serviceCategoryId: _toInt(json['service_category_id']),
      liveType: _toInt(json['live_type']),
      hpGender: _toInt(json['hp_gender']),
      name: _toStr(json['name']),
      serviceRate: _toStr(json['service_rate']),
      marketRate: _toStr(json['market_rate']),
      branchId: _toInt(json['branch_id']),
      description: _toStr(json['description']),
      imageUrl: _toStr(json['image_url']),
      effectiveFromDate: _toStr(json['effective_from_date']),
      effectiveToDate: _toStr(json['effective_to_date']),
      createdOn: _toStr(json['created_on']),
      createdBy: _toInt(json['created_by']),
      updatedOn: _toStr(json['updated_on']),
      updatedBy: _toInt(json['updated_by']),
      status: _toInt(json['status']),
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

int _toInt(dynamic v) => v is int ? v : int.tryParse('${v ?? ''}') ?? 0;

String _toStr(dynamic v) => v == null ? '' : v.toString();
