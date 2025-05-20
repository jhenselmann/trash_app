import 'package:flutter/material.dart'; //Flutters frundlegendes UI Kit

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //MaterialApp ist ein Widget
      title: 'Trash App', //title ein argument
      theme: ThemeData(primarySwatch: Colors.yellow),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; //Merkt sich welcher Tab aktiv ist

  final List<Widget> _pages = [
    //Diese 3 Seiten haben wir
    Center(child: Text('New Trashcan Screen')),
    Center(child: Text('Map Screen')), //Aktuell nur Platzhalter
    Center(child: Text('More Screen')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //--> Leerer App Rahmen mit Zugriff auf Standard Elemente
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildNavItem(icon: Icons.add_location, label: 'New', index: 0),
            _buildNavItem(icon: Icons.map, label: 'Map', index: 1),
            _buildNavItem(icon: Icons.more_horiz, label: 'More', index: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(8, 8, 8, 25),
          decoration: BoxDecoration(
            color: isSelected ? Colors.yellow : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.black : Colors.grey),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
