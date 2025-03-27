import 'package:flutter/material.dart';

void main() {
  runApp(const ResponsiveApp());
}

class ResponsiveApp extends StatelessWidget {
  const ResponsiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsive Design Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ResponsiveHomePage(),
    );
  }
}

class ResponsiveHomePage extends StatelessWidget {
  const ResponsiveHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Responsive Design Demo')),
      // Drawer for very small screens
      drawer:
          MediaQuery.of(context).size.width < 600 ? const AppDrawer() : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            // Small screen (mobile) - drawer accessible via hamburger menu
            return SmallScreenLayout();
          } else if (constraints.maxWidth < 1200) {
            // Medium screen (tablet) - persistent sidebar
            return MediumScreenLayout();
          } else {
            // Large screen (desktop) - persistent sidebar with more space
            return LargeScreenLayout();
          }
        },
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class LargeScreenLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Expanded sidebar
        Container(
          width: 250,
          color: Colors.purple[100],
          child: const Column(
            children: [
              SizedBox(height: 24),
              Text('Navigation', style: TextStyle(fontSize: 24)),
              SizedBox(height: 24),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home', style: TextStyle(fontSize: 18)),
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings', style: TextStyle(fontSize: 18)),
              ),
              ListTile(
                leading: Icon(Icons.favorite),
                title: Text('Favorites', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
        // Main content area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Container(
                  height: 150,
                  color: Colors.blue[100],
                  alignment: Alignment.center,
                  child: const Text('Header', style: TextStyle(fontSize: 32)),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          color: Colors.green[100],
                          alignment: Alignment.center,
                          child: const Text(
                            'Main Content Area',
                            style: TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: Colors.red[100],
                          alignment: Alignment.center,
                          child: const Text(
                            'Side Panel',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 100,
                  color: Colors.orange[100],
                  alignment: Alignment.center,
                  child: const Text(
                    'Footer with Additional Information',
                    style: TextStyle(fontSize: 28),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MediumScreenLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Persistent sidebar
        Container(
          width: 200,
          color: Colors.purple[100],
          child: const Column(
            children: [
              SizedBox(height: 16),
              Text('Sidebar', style: TextStyle(fontSize: 20)),
              SizedBox(height: 16),
              ListTile(leading: Icon(Icons.home), title: Text('Home')),
              ListTile(leading: Icon(Icons.settings), title: Text('Settings')),
            ],
          ),
        ),
        // Main content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  height: 150,
                  color: Colors.blue[100],
                  alignment: Alignment.center,
                  child: const Text('Header', style: TextStyle(fontSize: 28)),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    color: Colors.green[100],
                    alignment: Alignment.center,
                    child: const Text(
                      'Main Content',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 100,
                  color: Colors.orange[100],
                  alignment: Alignment.center,
                  child: const Text('Footer', style: TextStyle(fontSize: 28)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SmallScreenLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 150,
              color: Colors.blue[100],
              alignment: Alignment.center,
              child: const Text(
                'Content (swipe from left for menu)',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              color: Colors.green[100],
              alignment: Alignment.center,
              child: const Text('Main Content', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 16),
            Container(
              height: 100,
              color: Colors.orange[100],
              alignment: Alignment.center,
              child: const Text('Footer', style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
      ),
    );
  }
}
