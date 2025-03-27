import 'package:flutter/material.dart';
import 'package:responsive_app/LargeScreenlayout.dart';
import 'package:responsive_app/MediumScreenlayout.dart';
import 'package:responsive_app/SmallScreenlayout.dart';

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
