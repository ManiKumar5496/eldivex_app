import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/values/color_constants.dart';
import 'app_layout.dart';
import 'app_tokens.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

/// 40px search input with a leading icon and a clear button.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.hint = 'Search…',
    this.onChanged,
    this.onSubmitted,
    this.width,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Fixed width for toolbars; null fills the parent.
  final double? width;
  final bool autofocus;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = SizedBox(
      height: 40,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _controller,
        builder: (context, value, _) => TextField(
          controller: _controller,
          autofocus: widget.autofocus,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hint,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            prefixIcon: Icon(LucideIcons.search,
                size: 18, color: AppColor.textTertiary),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 38, minHeight: 40),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear',
                    splashRadius: 16,
                    icon: Icon(LucideIcons.x,
                        size: 16, color: AppColor.textTertiary),
                    onPressed: () {
                      _controller.clear();
                      widget.onChanged?.call('');
                    },
                  ),
          ),
        ),
      ),
    );
    return widget.width == null ? field : SizedBox(width: widget.width, child: field);
  }
}

/// Centered placeholder for empty lists, no-results and errors.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    this.icon = LucideIcons.inbox,
    required this.title,
    this.message,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.tone = AppTone.neutral,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final AppTone tone;

  /// Less vertical padding, for use inside cards and small panels.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconBox = compact ? 44.0 : 56.0;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: 24, vertical: compact ? 20 : 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: iconBox,
                height: iconBox,
                decoration: BoxDecoration(
                  color: tone.soft,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: iconBox * 0.46, color: tone.color),
              ),
              SizedBox(height: compact ? 12 : 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: compact ? 14 : 15,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textPrimary,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 6),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13.5, color: AppColor.textTertiary, height: 1.45),
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 18),
                actionIcon == null
                    ? ElevatedButton(onPressed: onAction, child: Text(actionLabel!))
                    : ElevatedButton.icon(
                        onPressed: onAction,
                        icon: Icon(actionIcon, size: 18),
                        label: Text(actionLabel!),
                      ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular avatar: network image when available, otherwise initials on a
/// brand tint.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 36,
    this.tone = AppTone.primary,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String name;
  final String? imageUrl;
  final double size;
  final AppTone tone;

  /// Override the tone colours, e.g. on the dark brand sidebar.
  final Color? backgroundColor;
  final Color? foregroundColor;

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: backgroundColor ?? tone.soft, shape: BoxShape.circle),
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? tone.color,
        ),
      ),
    );
    final url = imageUrl?.trim() ?? '';
    if (url.isEmpty) return fallback;
    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}

/// Label/value pair for detail screens. Vertical (label above) by default;
/// `horizontal: true` puts the label in a fixed-width left column.
class AppInfoRow extends StatelessWidget {
  const AppInfoRow({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
    this.icon,
    this.horizontal = false,
    this.labelWidth = 160,
  });

  final String label;
  final String? value;

  /// Use instead of [value] for badges, links, etc.
  final Widget? valueWidget;
  final IconData? icon;
  final bool horizontal;
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    final labelText = Text(
      label,
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: AppColor.textTertiary,
      ),
    );
    final v = valueWidget ??
        Text(
          (value == null || value!.trim().isEmpty) ? '—' : value!,
          style: TextStyle(fontSize: 14, color: AppColor.textPrimary),
        );

    Widget withIcon(Widget child) => icon == null
        ? child
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1, right: 10),
                child: Icon(icon, size: 16, color: AppColor.textTertiary),
              ),
              Expanded(child: child),
            ],
          );

    if (horizontal) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: withIcon(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: labelWidth, child: labelText),
            const SizedBox(width: 12),
            Expanded(child: v),
          ],
        )),
      );
    }
    return withIcon(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [labelText, const SizedBox(height: 4), v],
    ));
  }
}

/// Heading for a group of fields inside a form or detail card.
class AppSectionTitle extends StatelessWidget {
  const AppSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!,
                    style:
                        TextStyle(fontSize: 13, color: AppColor.textTertiary)),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Dialog frame: header with icon, title and close button, scrollable body,
/// and a footer action bar. Use for forms and detail popups.
///
/// ```dart
/// Get.dialog(AppDialog(
///   title: 'Approve refund',
///   icon: LucideIcons.circleCheck,
///   child: ...,
///   actions: [OutlinedButton(...), ElevatedButton(...)],
/// ));
/// ```
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.icon,
    this.tone = AppTone.primary,
    this.actions = const [],
    this.maxWidth = 520,
    this.onClose,
    this.bodyPadding,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final AppTone tone;
  final Widget child;
  final List<Widget> actions;
  final double maxWidth;

  /// Defaults to closing the dialog.
  final VoidCallback? onClose;
  final EdgeInsetsGeometry? bodyPadding;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 600;
    final hPad = narrow ? 18.0 : 24.0;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
          horizontal: narrow ? 12 : 24, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 18, 12, 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (icon != null) ...[
                    AppIconTile(icon: icon!, tone: tone, size: 38),
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: AppColor.textPrimary,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(subtitle!,
                              style: TextStyle(
                                  fontSize: 13.5,
                                  color: AppColor.textTertiary)),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    icon: Icon(LucideIcons.x,
                        size: 20, color: AppColor.textTertiary),
                    onPressed: onClose ?? () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColor.borderSubtle),
            Flexible(
              child: SingleChildScrollView(
                padding: bodyPadding ?? EdgeInsets.all(hPad),
                child: child,
              ),
            ),
            if (actions.isNotEmpty) ...[
              Divider(height: 1, color: AppColor.borderSubtle),
              Container(
                color: AppColor.surfaceMuted,
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 14),
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: actions,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Confirm/cancel prompt. Resolves `true` only when the user confirms.
Future<bool> showAppConfirmDialog({
  required String title,
  String? message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  AppTone tone = AppTone.primary,
  IconData? icon,
}) async {
  final result = await Get.dialog<bool>(
    AppDialog(
      title: title,
      icon: icon ??
          (tone == AppTone.danger
              ? LucideIcons.triangleAlert
              : LucideIcons.circleHelp),
      tone: tone,
      maxWidth: 440,
      onClose: () => Get.back(result: false),
      actions: [
        OutlinedButton(
          onPressed: () => Get.back(result: false),
          child: Text(cancelLabel),
        ),
        ElevatedButton(
          style: tone == AppTone.danger ? AppButtonStyles.danger : null,
          onPressed: () => Get.back(result: true),
          child: Text(confirmLabel),
        ),
      ],
      child: message == null
          ? const SizedBox.shrink()
          : Text(
              message,
              style: TextStyle(
                  fontSize: 14, height: 1.5, color: AppColor.textSecondary),
            ),
    ),
  );
  return result ?? false;
}
