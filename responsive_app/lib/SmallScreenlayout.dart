import 'package:flutter/material.dart';

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
