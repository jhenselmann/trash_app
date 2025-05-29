import 'package:flutter/material.dart';
import 'package:trash_app/screens/more.dart';
import 'package:trash_app/screens/new_trashcan_screen.dart';
import 'screens/trash_map_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trash App',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.yellow,
          brightness: Brightness.light,
          primary: Colors.black,
          secondary: Colors.yellow,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
          titleMedium: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
        ),
      ),
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
  int _selectedIndex = 1; //Merkt sich welcher Tab aktiv ist

  final List<Widget> _pages = [
    //Diese 3 Seiten haben wir
    NewTrashcanScreen(),
    TrashMapScreen(),
    MorePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Stack(
          children: [
            AnimatedAlign(
              alignment: _getAlignmentForIndex(_selectedIndex),
              duration: const Duration(milliseconds: 200),
              curve: Curves.decelerate,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double itemWidth = (constraints.maxWidth / 3) - 16;

                  return Container(
                    width: itemWidth,
                    height: 60,
                    margin: const EdgeInsets.only(
                      top: 8,
                      bottom: 25,
                      left: 8,
                      right: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  );
                },
              ),
            ),

            Row(
              children: [
                _buildNavItem(icon: Icons.add_location, label: 'New', index: 0),
                _buildNavItem(icon: Icons.map, label: 'Map', index: 1),
                _buildNavItem(icon: Icons.more_horiz, label: 'More', index: 2),
              ],
            ),
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
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(8, 8, 8, 25),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(icon), Text(label)],
          ),
        ),
      ),
    );
  }

  Alignment _getAlignmentForIndex(int index) {
    switch (index) {
      case 0:
        return Alignment(-1.0, 0.0);
      case 1:
        return Alignment(0.0, 0.0);
      case 2:
        return Alignment(1.0, 0.0);
      default:
        return Alignment.center;
    }
  }
}
