import 'package:flutter/material.dart';

import 'profile_link.dart';

// Personal account links are still available from the feed's app bar.
class SocialAccountsPage extends StatelessWidget {
  const SocialAccountsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('My Social Links')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Connect With Me',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Tap an account to view my profile.\nYou can also copy its link from the message.',
        ),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            leading: const Icon(Icons.facebook, color: Colors.blue),
            title: const Text('Facebook'),
            subtitle: const Text('jolex.pasignasigna'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => showProfileLink(
              context,
              'Facebook: jolex.pasignasigna',
              'https://www.facebook.com/jolex.pasignasigna',
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.pink),
            title: const Text('Instagram'),
            subtitle: const Text('@_p.jlx'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => showProfileLink(
              context,
              'Instagram: @_p.jlx',
              'https://www.instagram.com/_p.jlx/',
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.music_note, color: Colors.black),
            title: const Text('TikTok'),
            subtitle: const Text('@xophiasbrother'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => showProfileLink(
              context,
              'TikTok: @xophiasbrother',
              'https://www.tiktok.com/@xophiasbrother',
            ),
          ),
        ),
      ],
    ),
  );
}
