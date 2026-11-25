import 'package:flutter/material.dart';

import 'profile_link.dart';
import 'demo_auth.dart';
import 'login_screen.dart';

class ProfilePage extends StatelessWidget {
  final String username;

  const ProfilePage({super.key, required this.username});

  void logout(BuildContext context) {
    DemoAuth.logout();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Student Profile')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Center(
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.indigo,
            child: Text(
              'JP',
              style: TextStyle(fontSize: 32, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Jolex Pasignasigna',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text('BS Information Technology', textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('Logged in as: $username', textAlign: TextAlign.center),
        const SizedBox(height: 24),
        const Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.badge),
                title: Text('Student ID'),
                subtitle: Text('557989'),
              ),
              ListTile(
                leading: Icon(Icons.school),
                title: Text('Course and Year'),
                subtitle: Text('BSIT — 3rd Year'),
              ),
              ListTile(
                leading: Icon(Icons.class_),
                title: Text('Subject and Section'),
                subtitle: Text('CCE106(3450)'),
              ),
              ListTile(
                leading: Icon(Icons.email),
                title: Text('Email'),
                subtitle: Text('Jolex129@gmail.com'),
              ),
              ListTile(
                leading: Icon(Icons.alternate_email),
                title: Text('School Email'),
                subtitle: Text('j.pasignasigna.557989@umindanao.edu.ph'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('About Me', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text(
          'I am a third-year Information Technology student at the '
          'University of Mindanao. I enjoy exploring how technology '
          'can solve everyday problems while improving my programming '
          'skills. I look forward to working with others to create '
          'practical and useful applications.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 24),
        Text('Hobbies', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(avatar: Icon(Icons.gamepad, size: 18), label: Text('Gaming')),
            Chip(
              avatar: Icon(Icons.motorcycle, size: 18),
              label: Text('Riding'),
            ),
            Chip(
              avatar: Icon(Icons.headphones, size: 18),
              label: Text('Listening to music'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => showProfileLink(
            context,
            'GitHub: saltylex/student_profile_app',
            'https://github.com/saltylex/student_profile_app',
          ),
          icon: const Icon(Icons.code),
          label: const Text('Student Profile Repository'),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          key: const ValueKey('logout'),
          onPressed: () => logout(context),
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    ),
  );
}
