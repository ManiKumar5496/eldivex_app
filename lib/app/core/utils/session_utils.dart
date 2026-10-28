import 'package:get_storage/get_storage.dart';
import 'jwt_utils.dart';

/// Storage may hold ints, numeric strings or junk depending on which build
/// wrote them, so every admin-session value is parsed defensively.
int _readInt(String key) =>
    int.tryParse('${GetStorage().read(key) ?? ''}') ?? 0;

int adminRoleId() => _readInt('role_id');

/// Organisation of the logged-in admin, or 0 when unknown. There is no
/// fallback org: a session without one is treated as invalid.
int adminOrgId() => _readInt('org_id');

/// An admin session is usable only with an unexpired token, a role and an org.
bool isAdminAuthenticated() {
  final box = GetStorage();
  return isValidSessionToken(box.read('user_token')) &&
      adminRoleId() > 0 &&
      adminOrgId() > 0;
}

bool adminTermsAccepted() => GetStorage().read('terms_accepted') == true;
