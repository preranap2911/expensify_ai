import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/primary_button.dart';
import '../../state/auth_providers.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool loading = false;

  Future<void> _refresh() async {
    setState(() => loading = true);
    await ref.read(authServiceProvider).reloadUser();
    final verified = ref.read(authServiceProvider).isEmailVerified;
    setState(() => loading = false);

    if (!mounted) return;

    if (verified) {
      context.go('/app');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not verified yet. Check your email.')),
      );
    }
  }

  Future<void> _resend() async {
    await ref.read(authServiceProvider).sendEmailVerification();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification email sent again.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify your email')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "We've sent a verification link to your email.\n\n"
                  "Open your email, verify, then come back and tap Refresh.",
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              text: 'Refresh (I verified)',
              loading: loading,
              onPressed: _refresh,
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _resend,
              child: const Text('Resend email'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                await ref.read(authServiceProvider).signOut();
                if (!mounted) return;
                context.go('/login');
              },
              child: const Text('Back to login'),
            ),
          ],
        ),
      ),
    );
  }
}
