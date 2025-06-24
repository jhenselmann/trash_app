import 'package:flutter/material.dart';
import 'package:trash_app/screens/more/help.dart';
import 'package:trash_app/screens/more/my_contributions_page.dart';
import 'package:trash_app/screens/more/profile/profile.dart';
import 'package:trash_app/screens/more/saved_trashcans_page.dart'; // hinzufügen

class MorePage extends StatelessWidget {
  const MorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        children: [
          _buildListTile(
            context,
            icon: Icons.person,
            title: 'Profile',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.bookmark,
            title: 'Saved Trashcans',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedTrashcansPage()),
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings are not implemented yet. '),
                ),
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.help_outline,
            title: 'Help',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
