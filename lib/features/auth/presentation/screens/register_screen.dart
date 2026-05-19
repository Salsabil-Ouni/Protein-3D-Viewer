import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref
        .read(authStateProvider.notifier)
        .register(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
          _firstNameCtrl.text.trim(),
          _lastNameCtrl.text.trim(),
        );
    if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              ref.read(authStateProvider).error ?? 'Registration failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStateProvider).isLoading;
    final locale = ref.watch(localeProvider);
    final t = (String k) => AppL10n.tr(locale, k);

    return Scaffold(
      appBar: AppBar(
        title: Text(t('register')),
        actions: [
          IconButton(
            icon: Icon(ThemeNotifier.iconFor(ref.watch(themeProvider))),
            tooltip: 'Toggle theme',
            onPressed: () => ref.read(themeProvider.notifier).toggle(),
          ),
          TextButton(
            onPressed: () => ref.read(localeProvider.notifier).toggle(),
            child: Text(
              t('lang_toggle'),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Icon(Icons.person_add_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary)
                    .animate()
                    .fadeIn()
                    .scale(begin: const Offset(0.5, 0.5)),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: AuthTextField(
                        label: t('first_name'),
                        controller: _firstNameCtrl,
                        prefixIcon: Icons.person_outline,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? (locale == 'fr' ? 'Requis' : 'Required')
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AuthTextField(
                        label: t('last_name'),
                        controller: _lastNameCtrl,
                        prefixIcon: Icons.person_outline,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? (locale == 'fr' ? 'Requis' : 'Required')
                            : null,
                      ),
                    ),
                  ],
                ).animate().slideX(begin: -0.3, delay: 200.ms),
                const SizedBox(height: 16),
                AuthTextField(
                  label: t('email'),
                  controller: _emailCtrl,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ).animate().slideX(begin: -0.3, delay: 300.ms),
                const SizedBox(height: 16),
                AuthTextField(
                  label: t('password'),
                  controller: _passwordCtrl,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: Validators.password,
                ).animate().slideX(begin: -0.3, delay: 400.ms),
                const SizedBox(height: 16),
                AuthTextField(
                  label: t('confirm_password'),
                  controller: _confirmCtrl,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (v) {
                    if (v != _passwordCtrl.text) return t('passwords_no_match');
                    return null;
                  },
                ).animate().slideX(begin: -0.3, delay: 500.ms),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : _register,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(t('register'),
                          style: const TextStyle(fontSize: 16)),
                ).animate().fadeIn(delay: 600.ms),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(t('already_account')),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(t('sign_in')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
