import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/values/color_constants.dart';

enum DestructiveTier { low, medium, high }

class DestructiveActionDialog extends StatefulWidget {
  const DestructiveActionDialog({
    super.key,
    required this.tier,
    required this.title,
    required this.body,
    required this.confirmLabel,
    this.requireSlug,
    this.requireReason = false,
    required this.onConfirm,
  });

  final DestructiveTier tier;
  final String title;
  final String body;
  final String confirmLabel;
  final String? requireSlug;
  final bool requireReason;
  final void Function(String? reason) onConfirm;

  static Future<void> show({
    required String title,
    required String body,
    required String confirmLabel,
    required DestructiveTier tier,
    String? requireSlug,
    bool requireReason = false,
    required void Function(String? reason) onConfirm,
  }) {
    return Get.dialog(
      DestructiveActionDialog(
        title: title,
        body: body,
        confirmLabel: confirmLabel,
        tier: tier,
        requireSlug: requireSlug,
        requireReason: requireReason,
        onConfirm: onConfirm,
      ),
      barrierDismissible: false,
    );
  }

  @override
  State<DestructiveActionDialog> createState() =>
      _DestructiveActionDialogState();
}

class _DestructiveActionDialogState extends State<DestructiveActionDialog> {
  final _reasonCtrl = TextEditingController();
  final _slugCtrl   = TextEditingController();
  bool _cooldown    = false;
  int  _countdown   = 2;

  bool get _canConfirm {
    if (widget.requireReason && _reasonCtrl.text.trim().length < 10) return false;
    if (widget.requireSlug != null &&
        _slugCtrl.text.trim().toLowerCase() !=
            widget.requireSlug!.toLowerCase()) return false;
    return true;
  }

  void _startCooldown() {
    setState(() => _cooldown = true);
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 1) {
        t.cancel();
        if (mounted) setState(() { _cooldown = false; _countdown = 2; });
      } else {
        if (mounted) setState(() => _countdown--);
      }
    });
  }

  Color get _btnColor => switch (widget.tier) {
        DestructiveTier.low    => AppColor.cPrimaryButtonColor,
        DestructiveTier.medium => Colors.orange,
        DestructiveTier.high   => AppColor.calenderRed,
      };

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _slugCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        children: [
          Icon(
            widget.tier == DestructiveTier.high
                ? Icons.warning_amber_rounded
                : Icons.info_outline,
            color: _btnColor,
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(widget.title, style: const TextStyle(fontSize: 16))),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.tier != DestructiveTier.low)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _btnColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _btnColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(widget.body,
                      style: TextStyle(fontSize: 13, color: _btnColor)),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(widget.body,
                      style: TextStyle(fontSize: 14, color: AppColor.fontColorBlack)),
                ),
              if (widget.requireReason) ...[
                const Text('Reason *',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: _reasonCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Minimum 10 characters…',
                    border: const OutlineInputBorder(),
                    errorText: _reasonCtrl.text.isNotEmpty &&
                            _reasonCtrl.text.trim().length < 10
                        ? 'At least 10 characters required'
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),
              ],
              if (widget.requireSlug != null) ...[
                Text(
                  'Type "${widget.requireSlug}" to confirm:',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _slugCtrl,
                  decoration: InputDecoration(
                    hintText: widget.requireSlug,
                    border: const OutlineInputBorder(),
                    suffixIcon: _slugCtrl.text.trim().toLowerCase() ==
                            widget.requireSlug!.toLowerCase()
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        StatefulBuilder(
          builder: (_, ss) => ElevatedButton(
            onPressed: (_canConfirm && !_cooldown)
                ? () {
                    if (widget.tier == DestructiveTier.high && !_cooldown) {
                      _startCooldown();
                    } else {
                      Get.back();
                      widget.onConfirm(_reasonCtrl.text.trim().isEmpty
                          ? null
                          : _reasonCtrl.text.trim());
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _btnColor,
              foregroundColor: AppColor.buttonTextWhite,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              _cooldown
                  ? 'Wait $_countdown…'
                  : widget.confirmLabel,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}
