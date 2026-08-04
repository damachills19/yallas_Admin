import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/admin_strings.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/locale_toggle.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(adminAuthProvider.notifier).login(_email.text.trim(), _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(adminAuthProvider);
    final locale = ref.watch(adminLocaleProvider);
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.admin_panel_settings, size: 48, color: AppColors.primary),
                        const SizedBox(height: AppSpacing.sm),
                        Text(t(locale, 'app_title'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        const SizedBox(height: AppSpacing.xs),
                        Text(t(locale, 'sign_in_subtitle'), style: const TextStyle(color: AppColors.onSurfaceMuted), textAlign: TextAlign.center),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: t(locale, 'email'),
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => (v == null || v.trim().isEmpty) ? t(locale, 'required') : null,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: t(locale, 'password'),
                          controller: _password,
                          obscureText: true,
                          validator: (v) => (v == null || v.isEmpty) ? t(locale, 'required') : null,
                        ),
                        if (authState.error != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            authState.error == 'access_denied' ? t(locale, 'access_denied') : authState.error!,
                            style: const TextStyle(color: AppColors.error),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        AppButton(label: t(locale, 'sign_in'), onPressed: _submit, isLoading: authState.isLoading),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Positioned(top: AppSpacing.md, right: AppSpacing.md, child: LocaleToggle()),
        ],
      ),
    );
  }
}
