import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/api_constant_url.dart';
import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';

class OrgModel {
  final int id;
  final String name;
  final String slug;
  final String email;
  final String phone;
  final String status;
  final String planName;
  final String subStatus;

  OrgModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.email,
    required this.phone,
    required this.status,
    required this.planName,
    required this.subStatus,
  });

  factory OrgModel.fromJson(Map<String, dynamic> json) => OrgModel(
        id:        json['id'] as int? ?? 0,
        name:      json['name']?.toString()       ?? '',
        slug:      json['slug']?.toString()       ?? '',
        email:     json['email']?.toString()      ?? '',
        phone:     json['phone']?.toString()      ?? '',
        status:    json['status']?.toString()     ?? '',
        planName:  json['plan_name']?.toString()  ?? 'None',
        subStatus: json['sub_status']?.toString() ?? '',
      );
}

class OrganisationsController extends GetxController {
  final ApiService _api = ApiService();

  final RxList<OrgModel> orgs   = <OrgModel>[].obs;
  final RxBool loading          = false.obs;
  final RxBool saving           = false.obs;

  // Form controllers for create/edit dialog
  final nameCtrl    = TextEditingController();
  final slugCtrl    = TextEditingController();
  final emailCtrl   = TextEditingController();
  final phoneCtrl   = TextEditingController();
  final adminEmailCtrl    = TextEditingController();
  final adminPasswordCtrl = TextEditingController();
  final RxString selectedPlan   = 'Starter'.obs;
  final RxString selectedStatus = 'active'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrganisations();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    slugCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    adminEmailCtrl.dispose();
    adminPasswordCtrl.dispose();
    super.onClose();
  }

  Future<void> fetchOrganisations() async {
    loading.value = true;
    try {
      final resp = await _api.getList<OrgModel>(
        ApiConstants.getOrganisations,
        (json) => OrgModel.fromJson(json),
      );
      orgs.value = resp ?? [];
    } catch (e) {
      HelperUi.showToast(message: 'Failed to load organisations: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> createOrganisation() async {
    if (nameCtrl.text.trim().isEmpty || slugCtrl.text.trim().isEmpty) {
      HelperUi.showToast(message: 'Name and slug are required.');
      return;
    }
    saving.value = true;
    try {
      final planId = selectedPlan.value == 'Starter'
          ? 1
          : selectedPlan.value == 'Growth'
              ? 2
              : 3;
      final body = {
        'name':           nameCtrl.text.trim(),
        'slug':           slugCtrl.text.trim(),
        'email':          emailCtrl.text.trim(),
        'phone':          phoneCtrl.text.trim(),
        'plan_id':        planId,
        if (adminEmailCtrl.text.trim().isNotEmpty) ...{
          'admin_email':    adminEmailCtrl.text.trim(),
          'admin_password': adminPasswordCtrl.text.trim(),
        },
      };
      final resp = await _api.postRaw(ApiConstants.createOrganisation, body);
      if (resp != null && resp.statusCode == 201) {
        HelperUi.showToast(message: 'Organisation created.');
        _clearForm();
        await fetchOrganisations();
      } else {
        HelperUi.showToast(message: resp?.data['message'] ?? 'Failed to create.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error: $e');
    } finally {
      saving.value = false;
    }
  }

  Future<void> updateOrganisation(int orgId) async {
    saving.value = true;
    try {
      final body = {
        'name':   nameCtrl.text.trim(),
        'email':  emailCtrl.text.trim(),
        'phone':  phoneCtrl.text.trim(),
        'status': selectedStatus.value,
      };
      final resp = await _api.putRaw(
        ApiConstants.updateOrganisation(orgId),
        body,
      );
      if (resp != null && (resp.statusCode == 200 || resp.statusCode == 201)) {
        HelperUi.showToast(message: 'Organisation updated.');
        _clearForm();
        await fetchOrganisations();
      } else {
        HelperUi.showToast(message: resp?.data['message'] ?? 'Failed to update.');
      }
    } catch (e) {
      HelperUi.showToast(message: 'Error: $e');
    } finally {
      saving.value = false;
    }
  }

  void populateForEdit(OrgModel org) {
    nameCtrl.text    = org.name;
    slugCtrl.text    = org.slug;
    emailCtrl.text   = org.email;
    phoneCtrl.text   = org.phone;
    selectedPlan.value   = org.planName;
    selectedStatus.value = org.status;
  }

  void _clearForm() {
    nameCtrl.clear();
    slugCtrl.clear();
    emailCtrl.clear();
    phoneCtrl.clear();
    adminEmailCtrl.clear();
    adminPasswordCtrl.clear();
    selectedPlan.value   = 'Starter';
    selectedStatus.value = 'active';
  }
}
