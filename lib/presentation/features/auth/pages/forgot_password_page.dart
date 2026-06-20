import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/presentation/features/auth/providers/auth_providers.dart';
import 'package:fresh_market/presentation/features/auth/widgets/auth_form_field.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _sent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final error = await ref.read(authNotifierProvider.notifier).sendPasswordReset(
          _emailController.text.trim(),
        );
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (error == null) {
          _sent = true;
        } else {
          context.showSnackBar(error, isError: true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.lock_reset,
                  size: 64,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  context.l10n.forgotPassword,
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.passwordResetHint,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                AuthFormField(
                  controller: _emailController,
                  label: context.l10n.email,
                  prefixIcon: Icons.email_outlined,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return context.l10n.required;
                    if (!v.contains('@')) return context.l10n.invalidEmail;
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (_sent)
                  Column(
                    children: [
                      Icon(Icons.check_circle, size: 48, color: context.colorScheme.primary),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.passwordResetSent,
                        style: context.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => context.pop(),
                        child: Text(context.l10n.backToSignIn),
                      ),
                    ],
                  )
                else
                  FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(context.l10n.sendResetLink),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
