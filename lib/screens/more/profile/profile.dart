import 'package:flutter/material.dart';
import 'user_section.dart';
import 'adress_section.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            UserSection(),
            SizedBox(height: 32),
            Divider(),
            SizedBox(height: 32),
            AddressSection(),
          ],
        ),
      ),
    );
  }
}
