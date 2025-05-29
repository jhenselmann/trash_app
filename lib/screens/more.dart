import 'package:flutter/material.dart';
import 'package:trash_app/screens/more/help.dart';
import 'package:trash_app/screens/more/profile/profile.dart';

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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Saved Trashcans are not implemented yet. '),
                ),
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.delete,
            title: 'My Trashcans',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('My Trashcans are not implemented yet. '),
                ),
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
