import 'package:flutter/material.dart';

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
