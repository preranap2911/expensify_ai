import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:country_code_picker/country_code_picker.dart';

import '../../core/widgets/primary_button.dart';
import '../../state/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();

  String countryCode = '+44'; // 🇬🇧 default UK
  bool loading = false;

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  bool _isValidEmail(String v) => v.contains('@') && v.contains('.');
  bool _isValidPhone(String v) => v.length >= 7;

  Future<void> _register() async {
    final n = name.text.trim();
    final p = phone.text.trim();
    final e = email.text.trim();
    final pw = pass.text;

    if (n.isEmpty ||
        p.isEmpty ||
        !_isValidPhone(p) ||
        e.isEmpty ||
        !_isValidEmail(e) ||
        pw.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await ref.read(authServiceProvider).signUp(
        name: n,
        phone: '$countryCode$p',
        email: e,
        password: pw,
      );

      if (!mounted) return;
      context.go('/app');
    } catch (e) {
      final msg = ref.read(authServiceProvider).friendlyError(e);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                CountryCodePicker(
                  initialSelection: 'GB',
                  favorite: const ['+44', 'GB'],
                  onChanged: (code) {
                    countryCode = code.dialCode ?? '+44';
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: phone,
                    keyboardType: TextInputType.phone,
                    decoration:
                    const InputDecoration(labelText: 'Phone number'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pass,
              obscureText: true,
              decoration:
              const InputDecoration(labelText: 'Password (6+ characters)'),
            ),
            const SizedBox(height: 18),

            PrimaryButton(
              text: 'Register',
              loading: loading,
              onPressed: _register,
            ),

            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
