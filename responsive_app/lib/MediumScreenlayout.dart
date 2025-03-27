import 'package:flutter/material.dart';

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
