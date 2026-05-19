import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../main.dart' show firebaseReady;
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref
        .read(authStateProvider.notifier)
        .login(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              ref.read(authStateProvider).error ?? 'Login failed'),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              ThemeNotifier.iconFor(ref.watch(themeProvider)),
              color: Theme.of(context).colorScheme.primary,
            ),
            tooltip: 'Toggle theme',
            onPressed: () => ref.read(themeProvider.notifier).toggle(),
          ),
          TextButton(
            onPressed: () => ref.read(localeProvider.notifier).toggle(),
            child: Text(
              t('lang_toggle'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
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
                Icon(Icons.biotech,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.5, 0.5)),
                const SizedBox(height: 16),
                Text(
                  t('app_name'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ).animate().fadeIn(delay: 200.ms),
                Text(
                  t('tagline'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 12),
                Chip(
                  avatar: Icon(
                    firebaseReady ? Icons.cloud_done : Icons.cloud_off,
                    size: 16,
                    color: firebaseReady ? Colors.green : Colors.orange,
                  ),
                  label: Text(
                    firebaseReady ? t('firebase_active') : t('local_auth'),
                    style: TextStyle(
                      fontSize: 12,
                      color: firebaseReady ? Colors.green : Colors.orange,
                    ),
                  ),
                  backgroundColor: firebaseReady
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                ).animate().fadeIn(delay: 350.ms),
                const SizedBox(height: 36),
                AuthTextField(
                  label: t('email'),
                  controller: _emailCtrl,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ).animate().slideX(begin: -0.3, delay: 400.ms),
                const SizedBox(height: 16),
                AuthTextField(
                  label: t('password'),
                  controller: _passwordCtrl,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: Validators.password,
                ).animate().slideX(begin: -0.3, delay: 500.ms),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      _emailCtrl.text = 'demo@protein3d.app';
                      _passwordCtrl.text = 'demo1234';
                    },
                    child: Text(t('demo_creds')),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(t('sign_in'),
                          style: const TextStyle(fontSize: 16)),
                ).animate().fadeIn(delay: 600.ms),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(t('no_account')),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: Text(t('register')),
                    ),
                  ],
                ).animate().fadeIn(delay: 700.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
