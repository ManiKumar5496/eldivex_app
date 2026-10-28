import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../core/values/color_constants.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/ui/ui.dart';
import '../controllers/login_controller.dart';
import 'package:eldivex_app/app/core/values/lucide_icons.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cAppBackgroundColor,
      body: AuthSplitLayout(child: _form()),
    );
  }

  Widget _form() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Text(
          'Sign in to Eldivex',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            color: AppColor.textPrimary,
          ),
        ),
        const SizedBox(height: 6),

        // Subtitle
        Text(
          'Welcome back! Please enter your details.',
          style: TextStyle(fontSize: 14, color: AppColor.textTertiary),
        ),
        const SizedBox(height: 28),

        // Email Field
        const AuthFieldLabel('Email'),
        TextField(
          controller: controller.emailController.value,
          decoration: InputDecoration(
            hintText: 'Enter your email',
            prefixIcon: Icon(
              LucideIcons.mail,
              color: AppColor.textTertiary,
              size: 18,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Password Field + Forgot Password
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(child: AuthFieldLabel('Password')),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: TextButton(
                onPressed: () => Get.toNamed(Routes.forgotPassword),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(
                    fontFamily: 'inter_regular',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Forgot password?'),
              ),
            ),
          ],
        ),
        Obx(
          () => TextField(
            controller: controller.passwordController.value,
            obscureText: controller.isPasswordHidden.value,
            onSubmitted: (value) {
              controller.login(
                controller.emailController.value.text,
                controller.passwordController.value.text,
              );
            },
            decoration: InputDecoration(
              hintText: 'Enter your password',
              prefixIcon: Icon(
                LucideIcons.lock,
                color: AppColor.textTertiary,
                size: 18,
              ),
              suffixIcon: IconButton(
                tooltip: controller.isPasswordHidden.value
                    ? 'Show password'
                    : 'Hide password',
                icon: Icon(
                  controller.isPasswordHidden.value
                      ? LucideIcons.eye
                      : LucideIcons.eyeOff,
                  color: AppColor.textTertiary,
                  size: 18,
                ),
                onPressed: () {
                  controller.isPasswordHidden.value =
                      !controller.isPasswordHidden.value;
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Inline error banner
        Obx(() {
          final err = controller.loginError.value;
          if (err.isEmpty) return const SizedBox.shrink();
          return AuthErrorBanner(message: err);
        }),

        // Login Button
        Obx(
          () => SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: controller.isLoginLoading.value
                  ? null
                  : () {
                      controller.login(
                        controller.emailController.value.text,
                        controller.passwordController.value.text,
                      );
                    },
              style: authPrimaryButtonStyle(),
              child: controller.isLoginLoading.value
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColor.buttonTextWhite,
                        ),
                      ),
                    )
                  : const Text('Sign in'),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Divider(height: 1, color: AppColor.borderSubtle),
        const SizedBox(height: 20),

        // Contact Administrator
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Don\'t have an account?  ',
              style: TextStyle(fontSize: 13, color: AppColor.textTertiary),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'Contact Administrator',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColor.cPrimaryButtonColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared auth-page building blocks (also used by Forgot password and Terms).
// ─────────────────────────────────────────────────────────────────────────────

/// Primary button style for auth forms: keeps the brand fill while a request
/// is in flight so the white spinner stays visible.
ButtonStyle authPrimaryButtonStyle() => ElevatedButton.styleFrom(
      disabledBackgroundColor:
          AppColor.cPrimaryButtonColor.withValues(alpha: 0.7),
      disabledForegroundColor: AppColor.buttonTextWhite,
    );

/// The Eldivex hexagon mark on a white app-icon tile, so it reads on any
/// surface (light card, dark card or the brand-coloured panel).
class EldivexMark extends StatelessWidget {
  const EldivexMark({super.key, this.size = 44, this.bordered = true});

  final double size;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.16),
      decoration: BoxDecoration(
        color: AppColor.pureWhite,
        borderRadius: BorderRadius.circular(size * 0.26),
        border: bordered ? Border.all(color: AppColor.divColor) : null,
        boxShadow: AppShadows.card,
      ),
      child: Image.asset('assets/images/e_mark.png', fit: BoxFit.contain),
    );
  }
}

/// Small label shown above an auth form field.
class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColor.textSecondary,
        ),
      ),
    );
  }
}

/// Inline error message shown above the submit button.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColor.dangerSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColor.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(LucideIcons.circleAlert,
                color: AppColor.danger, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColor.danger,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Auth page frame. Desktop (≥ 960px): brand panel on the left, the form card
/// centred on the right. Tablet / phone: a single centred card with the mark.
class AuthSplitLayout extends StatelessWidget {
  const AuthSplitLayout({
    super.key,
    required this.child,
    this.showMark = true,
  });

  /// The form content (no card — the layout supplies it).
  final Widget child;

  /// Shows the Eldivex mark at the top of the card on tablet / phone, where
  /// the brand panel is hidden.
  final bool showMark;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 960;
      final narrow = constraints.maxWidth < 600;

      Widget card({required bool withMark}) => AppCard(
            padding: EdgeInsets.all(narrow ? 24 : 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (withMark) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: EldivexMark(size: 44),
                  ),
                  const SizedBox(height: 24),
                ],
                child,
              ],
            ),
          );

      final footer = Text(
        '© 2026 Eldivex. All rights reserved.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12.5, color: AppColor.textTertiary),
      );

      if (!wide) {
        return SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: 16, vertical: narrow ? 24 : 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    card(withMark: showMark),
                    const SizedBox(height: 20),
                    footer,
                  ],
                ),
              ),
            ),
          ),
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Expanded(flex: 5, child: _BrandPanel()),
          Expanded(
            flex: 6,
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      card(withMark: false),
                      const SizedBox(height: 20),
                      footer,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

/// Left-hand brand panel on desktop auth pages: primary fill with a faint
/// tonal mark watermark, product name, value proposition and trust bullets.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  static const _bullets = <(IconData, String)>[
    (LucideIcons.calendarCheck,
        'Bookings, caregivers and attendance in one place'),
    (LucideIcons.receiptText,
        'Invoices, receipts and caregiver payouts'),
    (LucideIcons.monitorSmartphone, 'Self-serve portals for caregivers and clients'),
    (LucideIcons.shieldCheck, 'Role-based access for your whole team'),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = AppColor.cAppPrimaryColor;
    final onBrand = AppColor.pureWhite;
    final deep = Color.alphaBlend(
        AppColor.blackColor.withValues(alpha: 0.22), primary);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, deep],
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Faint white silhouette of the mark as a tonal watermark.
          Positioned(
            right: -120,
            bottom: -110,
            child: IgnorePointer(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                    onBrand.withValues(alpha: 0.07), BlendMode.srcIn),
                child: Image.asset('assets/images/e_mark.png',
                    width: 460, height: 460),
              ),
            ),
          ),
          // Scrolls only when the window is too short for the panel.
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(child: _content(onBrand)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(Color onBrand) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(56, 48, 56, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const EldivexMark(size: 40, bordered: false),
              const SizedBox(width: 12),
              Text(
                'Eldivex',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: onBrand,
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          const Spacer(),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Run your home-care business from one dashboard.',
                  style: TextStyle(
                    fontSize: 32,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.8,
                    color: onBrand,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Bookings, caregivers, clients, billing and support, '
                  'together in a single secure workspace.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.55,
                    color: onBrand.withValues(alpha: 0.78),
                  ),
                ),
                const SizedBox(height: 32),
                for (final b in _bullets) ...[
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: onBrand.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(b.$1, size: 17, color: onBrand),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          b.$2,
                          style: TextStyle(
                            fontSize: 14.5,
                            color: onBrand.withValues(alpha: 0.92),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),
          const Spacer(),
          const SizedBox(height: 32),
          Text(
            'CARE  •  MEETS  •  TECH',
            style: TextStyle(
              fontSize: 11.5,
              letterSpacing: 2.4,
              fontWeight: FontWeight.w600,
              color: onBrand.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
