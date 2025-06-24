import 'package:flutter/material.dart';
import 'package:trash_app/services/user_trashcan_service.dart';
import 'package:trash_app/data/trashcan.dart';
import 'package:trash_app/widgets/trashcan_tile.dart';

class MyContributionsPage extends StatefulWidget {
  const MyContributionsPage({super.key});

  @override
  State<MyContributionsPage> createState() => _MyContributionsPageState();
}

class _MyContributionsPageState extends State<MyContributionsPage> {
  List<Trashcan> _trashcans = [];

  @override
  void initState() {
    super.initState();
    _loadTrashcans();
  }

  Future<void> _loadTrashcans() async {
    final cans = await UserTrashcanService.loadUserTrashcans();
    setState(() => _trashcans = cans);
  }

  @override
  Widget build(BuildContext context) {
    final myTrashcans = _trashcans.where((t) => t.addedByUser).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Impact')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            _trashcans.isEmpty
                ? const Center(
                  child: Text('You haven’t added any trashcans yet.'),
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎯 ${myTrashcans.length} Trashcans added',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _buildBadgesSection(),
                    const SizedBox(height: 16),
                    const Text(
                      'Your Trashcans:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: myTrashcans.length,
                        itemBuilder: (context, index) {
                          final t = myTrashcans[index];
                          return TrashcanTile(
                            item: {
                              'id': t.id,
                              'coordinates': t.coordinates,
                              'wasteForm': t.wasteForm,
                              'wasteTypes': t.wasteTypes,
                              'addedBy': t.addedBy,
                            },
                            userLocation: null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🏅 Badges',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const [
            _BadgeTile(
              icon: Icons.emoji_events,
              label: '100 Added',
              unlocked: false,
            ),
            _BadgeTile(
              icon: Icons.map,
              label: '50 Navigations',
              unlocked: false,
            ),
            _BadgeTile(icon: Icons.star, label: 'App Lover', unlocked: true),
          ],
        ),
      ],
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool unlocked;

  const _BadgeTile({
    required this.icon,
    required this.label,
    this.unlocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showBadgeInfo(context),
      child: Chip(
        avatar: Icon(icon, color: unlocked ? Colors.amber : Colors.grey),
        label: Text(label),
        backgroundColor:
            unlocked ? Colors.yellow.shade100 : Colors.grey.shade200,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showBadgeInfo(BuildContext context) {
    String title = '';
    String description = '';

    switch (label) {
      case '100 Added':
        title = '100 Trashcans Added';
        description =
            'You added 100 trashcans – that’s incredible!\n\nThat helps reduce litter and makes your city cleaner. 🌍';
        break;
      case '50 Navigations':
        title = 'Navigator';
        description =
            'You navigated to 50 trashcans!\n\nThanks for taking action and choosing the sustainable way. 🗺️';
        break;
      case 'App Lover':
        title = 'App Lover';
        description =
            'You opened the app over 20 times – we love your dedication! 💛\n\nKeep using the app to make a difference and inspire others.';
        break;
      default:
        title = label;
        description = 'More info coming soon!';
    }

    showDialog(
      context: context,
      useRootNavigator: true,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(description),
            actions: [
              TextButton(
                child: const Text('Nice!'),
                onPressed:
                    () => Navigator.of(context, rootNavigator: true).pop(),
              ),
            ],
          ),
    );
  }
}
