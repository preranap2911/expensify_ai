import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const ListTile(
              title: Text('ExpensifyAI'),
              subtitle: Text('AI-powered receipt tracking'),
              leading: CircleAvatar(child: Icon(Icons.auto_awesome)),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('Dark mode'),
              subtitle: const Text('Uses system setting'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => context.go('/login'),
            ),
          ],
        ),
      ),
    );
  }
}
