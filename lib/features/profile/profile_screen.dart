import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/primary_button.dart';
import '../../state/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    final uid = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() ?? {};
          final name = (data['name'] ?? '') as String;
          final phone = (data['phone'] ?? '') as String;
          final email = user.email ?? '';
          final verified = user.emailVerified;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        child: Text(
                          (name.isNotEmpty ? name[0] : 'U').toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.isEmpty ? 'Your name' : name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(email),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  verified ? Icons.verified : Icons.warning_amber,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  verified ? 'Email verified' : 'Email not verified',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: verified
                                        ? Colors.green
                                        : Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Phone', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(phone.isEmpty ? 'Not set' : phone),
                      const SizedBox(height: 14),
                      const Text('User ID', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      SelectableText(uid),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              if (!verified) ...[
                PrimaryButton(
                  text: 'Send verification email',
                  loading: false,
                  onPressed: () async {
                    try {
                      await ref.read(authServiceProvider).sendEmailVerification();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Verification email sent.')),
                      );
                    } catch (e) {
                      final msg = ref.read(authServiceProvider).friendlyError(e);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(msg)),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () async {
                    await ref.read(authServiceProvider).reloadUser();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Refreshed.')),
                    );
                  },
                  child: const Text('Refresh verification status'),
                ),
              ],

              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authServiceProvider).signOut();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ],
          );
        },
      ),
    );
  }
}
