import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'contact_formular.dart';

class HelpPage extends StatelessWidget {
  HelpPage({Key? key}) : super(key: key);

  final GlobalKey visionKey = GlobalKey();
  final GlobalKey featuresKey = GlobalKey();
  final GlobalKey contactKey = GlobalKey();
  final ScrollController scrollController = ScrollController();

  void _scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _launchPhoneDialer() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+1234567890');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final yellowHighlight = Colors.yellow.shade100;

    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          controller: scrollController,
          children: [
            // Contact Buttons (styled)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildYellowButton(
                  context,
                  icon: Icons.phone,
                  label: 'Call Us',
                  onPressed: _launchPhoneDialer,
                ),
                _buildYellowButton(
                  context,
                  icon: Icons.email,
                  label: 'Contact Form',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ContactFormPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Header
            const Text(
              'Help & Support',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Natural "Links" to Chapters
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLink(context, '→ Our Vision', () => _scrollTo(visionKey)),
                _buildLink(context, '→ Features', () => _scrollTo(featuresKey)),
                _buildLink(
                  context,
                  '→ Contact Us',
                  () => _scrollTo(contactKey),
                ),
              ],
            ),
            const Divider(height: 40),

            // Vision Section
            Container(
              key: visionKey,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Vision',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'We are developing the Trash App to make waste disposal easier and more responsible. '
                    'The main goal is to help users locate the nearest trash bin, so littering can be avoided altogether. '
                    'We believe that having access to proper disposal options can make a difference in keeping our streets clean.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),

            // Features Section
            Container(
              key: featuresKey,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Features',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Add Trashcans: You can contribute by adding new trashcan locations via the "+" button.\n'
                    '• Trash Map: View all nearby and global trashcan locations on an interactive map – similar to Google Maps.\n'
                    '• Filter by Type: Need a glass or paper bin? Use filters (top-left) to show specific trashcan types:\n'
                    '  - General Waste\n'
                    '  - Plastic\n'
                    '  - Glass Bottles / Glass\n'
                    '  - Paper\n'
                    '  - Cans\n'
                    '  - Clothes, Shoes\n'
                    '  - Beverage Cartons, PET Bottles\n'
                    '  - Aluminium, Metal, Scrap Metal\n'
                    '  - Dog Waste, Cigarettes\n'
                    '  - Mixed Waste\n'
                    '• Tap on a pin to see detailed information about that trashcan location.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),

            // Contact Section
            Container(
              key: contactKey,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need Help or Have Feedback?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Feel free to reach out to us at any time using the contact form above or via support@trashapp.dev.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 32),
                  Center(
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYellowButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.black),
      label: Text(label, style: const TextStyle(color: Colors.black)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellow.shade100,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    );
  }

  Widget _buildLink(BuildContext context, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
