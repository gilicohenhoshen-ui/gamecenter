import 'package:flutter/material.dart';

void main() => runApp(const MyAppsHub());

class MyAppsHub extends StatelessWidget {
  const MyAppsHub({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Apps Menu',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const HomeMenuScreen(),
    );
  }
}

class HomeMenuScreen extends StatefulWidget {
  const HomeMenuScreen({super.key});

  @override
  State<HomeMenuScreen> createState() => _HomeMenuScreenState();
}

class _HomeMenuScreenState extends State<HomeMenuScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _apps = [
    {'title': 'Notes App', 'icon': Icons.note_alt, 'color': Colors.amber},
    {'title': 'Calculator', 'icon': Icons.calculate, 'color': Colors.green},
    {'title': 'Weather', 'icon': Icons.cloud, 'color': Colors.lightBlue},
    {'title': 'Settings', 'icon': Icons.settings, 'color': Colors.grey},
  ];

  void _selectApp(int index) {
    setState(() => _selectedIndex = index);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentApp = _apps[_selectedIndex];

    return Scaffold(
      appBar: AppBar(title: Text(currentApp['title'])),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'My Apps Launcher',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            for (int i = 0; i < _apps.length; i++)
              ListTile(
                leading: Icon(_apps[i]['icon']),
                title: Text(_apps[i]['title']),
                selected: _selectedIndex == i,
                onTap: () => _selectApp(i),
              ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(currentApp['icon'], size: 80, color: currentApp['color']),
            const SizedBox(height: 16),
            Text(
              'Welcome to ${currentApp['title']}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
