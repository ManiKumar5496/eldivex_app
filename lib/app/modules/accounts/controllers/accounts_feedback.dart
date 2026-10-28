import 'package:dio/dio.dart' show Response;
import 'package:flutter/material.dart';
import '../../../data/base_api_services.dart';
import '../../../widgets/helper_ui.dart';
import '../models/parse_utils.dart';

/// Success = any 2xx. Used for the raw ApiService methods.
bool isOkResponse(Response? r) => ApiService.isOk(r);

/// Shows the backend `error` / `message` from [r], else [ApiService.lastError]
/// (null-returning methods such as patchRaw), else [fallback].
void toastApiError(Response? r, String fallback) {
  HelperUi.showToast(
    message: apiErrorMessage(r?.data) ?? ApiService.lastError ?? fallback,
    backgroundColor: Colors.red,
  );
}

void toastSuccess(String message) {
  HelperUi.showToast(message: message, backgroundColor: Colors.green);
}

void toastValidation(String message) {
  HelperUi.showToast(message: message, backgroundColor: Colors.red);
}
