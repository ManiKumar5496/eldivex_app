import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/values/color_constants.dart';
import '../../controllers/saas_accounts_controller.dart';

class StatusTransitionDialog extends StatefulWidget {
  const StatusTransitionDialog({
    super.key,
    required this.orgId,
    required this.orgName,
    required this.currentStatus,
  });

  final int orgId;
  final String orgName;
  final String currentStatus;

  static Future<void> show({
    required int orgId,
    required String orgName,
    required String currentStatus,
  }) =>
      Get.dialog(
        StatusTransitionDialog(
          orgId: orgId,
          orgName: orgName,
          currentStatus: currentStatus,
        ),
        barrierDismissible: true,
      );

  @override
  State<StatusTransitionDialog> createState() => _StatusTransitionDialogState();
}

class _StatusTransitionDialogState extends State<StatusTransitionDialog> {
  final _ctrl = Get.find<SaasAccountsController>();
  String? _selected;
  final _reasonCtrl = TextEditingController();

  bool get _isDestructive =>
      _selected == 'cancelled' || _selected == 'suspended';

  bool get _canConfirm {
    if (_selected == null) return false;
    if (_isDestructive && _reasonCtrl.text.trim().length < 10) return false;
    return true;
  }

  Color _statusColor(String s) => switch (s) {
        'active'    => Colors.green,
        'suspended' => Colors.orange,
        'cancelled' => AppColor.calenderRed,
        'expired'   => AppColor.fontColorGrey,
        _           => Colors.blue,
      };

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allowed = _ctrl.allowedNextStatuses(widget.currentStatus);
    final allStatuses = ['active', 'suspended', 'cancelled', 'expired'];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text('Change Status — ${widget.orgName}',
          style: const TextStyle(fontSize: 15)),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current: ${widget.currentStatus}',
                style: TextStyle(
                    fontSize: 13,
                    color: _statusColor(widget.currentStatus),
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            const Text('Select next status:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allStatuses.map((s) {
                final isAllowed = allowed.contains(s);
                final isSelected = _selected == s;
                return Tooltip(
                  message: isAllowed
                      ? ''
                      : 'Cannot transition from "${widget.currentStatus}" to "$s"',
                  child: ChoiceChip(
                    label: Text(s),
                    selected: isSelected,
                    onSelected: isAllowed
                        ? (_) => setState(() => _selected = s)
                        : null,
                    selectedColor: _statusColor(s).withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: isAllowed
                          ? (isSelected ? _statusColor(s) : AppColor.fontColorBlack)
                          : AppColor.lightGrey,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                    side: BorderSide(
                      color: isAllowed
                          ? (isSelected
                              ? _statusColor(s)
                              : AppColor.divColor)
                          : AppColor.divColor,
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_selected != null) ...[
              const SizedBox(height: 16),
              Text(
                _isDestructive ? 'Reason * (required)' : 'Reason (optional)',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _reasonCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Min 10 characters…',
                  border: const OutlineInputBorder(),
                  errorText: _isDestructive &&
                          _reasonCtrl.text.isNotEmpty &&
                          _reasonCtrl.text.trim().length < 10
                      ? 'At least 10 characters required'
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        Obx(() => ElevatedButton(
              onPressed: (_canConfirm && !_ctrl.saving.value)
                  ? () async {
                      Get.back();
                      await _ctrl.transitionSubscriptionStatus(
                        widget.orgId,
                        _selected!,
                        _reasonCtrl.text.trim().isEmpty
                            ? 'Admin action'
                            : _reasonCtrl.text.trim(),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selected != null
                    ? _statusColor(_selected!)
                    : AppColor.fontColorGrey,
                foregroundColor: AppColor.buttonTextWhite,
              ),
              child: _ctrl.saving.value
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColor.buttonTextWhite))
                  : Text('Set to ${_selected ?? '…'}'),
            )),
      ],
    );
  }
}
