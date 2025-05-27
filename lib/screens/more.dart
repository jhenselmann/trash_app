import 'package:flutter/material.dart';

class MorePage extends StatelessWidget {
  const MorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        children: [
          _buildListTile(
            context,
            icon: Icons.person,
            title: 'Profile',
            route: '/more/profile',
          ),
          _buildListTile(
            context,
            icon: Icons.bookmark,
            title: 'Saved Trashcans',
            route: '/more/saved_trashcan',
          ),
          _buildListTile(
            context,
            icon: Icons.delete,
            title: 'My Trashcans',
            route: '/more/my_trashcans',
          ),
          _buildListTile(
            context,
            icon: Icons.settings,
            title: 'Settings',
            route: '/more/settings',
          ),
          _buildListTile(
            context,
            icon: Icons.language,
            title: 'Languages',
            route: '/more/languages',
          ),
          SwitchListTile(
            secondary: const Icon(Icons.brightness_6),
            title: const Text('Dark Mode'),
            value: isDarkMode,
            onChanged: (value) {
              // Hier solltest du dein Theme-Management integrieren
              // z.B. mit Provider, Riverpod, GetX, etc.
            },
          ),
          _buildListTile(
            context,
            icon: Icons.help_outline,
            title: 'Help',
            route: '/more/help',
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }
}
