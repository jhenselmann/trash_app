import 'package:flutter/material.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:trash_app/screens/more.dart';
import 'package:trash_app/screens/new_trashcan_screen.dart';
import 'screens/trash_map_screen.dart';
import 'package:provider/provider.dart';
import 'services/location_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/trashcan_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final config = PostHogConfig(
    'phc_QmZWVXEosANnEUQrUH8IZbzmB5do0V1TZjkBTkgjtUH',
  );
  config.host = 'https://eu.i.posthog.com';
  config.debug = true;
  config.captureApplicationLifecycleEvents = true;
  config.sessionReplay = true;
  config.sessionReplayConfig.maskAllTexts = false;
  config.sessionReplayConfig.maskAllImages = false;

  await Posthog().setup(config);
  await Posthog().reset();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => TrashcanProvider()),
        // Add other providers here if needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return PostHogWidget(
      child: MaterialApp(
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
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _askForName(context);
    });
  }

  void _navigateToRoot(String route) {
    _navigatorKey.currentState?.pushNamedAndRemoveUntil(
      route,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: _navigatorKey,
        initialRoute: '/map',
        onGenerateRoute: (RouteSettings settings) {
          Widget page;
          switch (settings.name) {
            case '/new':
              page = const NewTrashcanScreen();
              break;
            case '/map':
              page = const TrashMapScreen();
              break;
            case '/more':
              page = const MorePage();
              break;
            default:
              page = const TrashMapScreen();
          }
          return MaterialPageRoute(builder: (_) => page, settings: settings);
        },
      ),
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
            // 🔶 Das gelbe Blob-Highlight
            AnimatedAlign(
              alignment: _getAlignmentForIndex(_selectedIndex),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
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

            // 🔘 Die eigentlichen Buttons
            Row(
              children: [
                _buildNavItem(Icons.add_location, 'New', 0, '/new'),
                _buildNavItem(Icons.map, 'Map', 1, '/map'),
                _buildNavItem(Icons.more_horiz, 'More', 2, '/more'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, String route) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedIndex = index);
          _navigateToRoot(route);
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(8, 8, 8, 25),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.black),
              Text(label, style: const TextStyle(color: Colors.black)),
            ],
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

  Future<void> _askForName(BuildContext context) async {
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Who are you?'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Enter your name or ID',
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    () => Navigator.of(context).pop(nameController.text.trim()),
                child: const Text('OK'),
              ),
            ],
          ),
    );

    if (name != null && name.isNotEmpty) {
      const group = 'validation_yes'; // or dynamically choose per session
      final sessionId = '${name.toLowerCase()}.$group';

      await Posthog().identify(
        userId: sessionId,
        userProperties: {'tester_name': name, 'experiment_group': group},
      );

      await Posthog().group(
        groupType: 'validation_experiment',
        groupKey: group,
        groupProperties: {'name': group},
      );

      await Posthog().capture(
        eventName: 'tester_session_started',
        properties: {
          'session_id': sessionId,
          'tester_name': name,
          'experiment_group': group,
        },
      );
    }
  }
}
