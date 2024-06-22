
// pages/my_home_page.dart
// This file defines the home page of the application as a StatefulWidget.
// The home page consists of a centered text and a button.
// When the button is pressed, a message "Button pressed" is logged in the console.

import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Hello, Flutter!'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    debugPrint('Button pressed');
                  },
                  child: const Text('Press me'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}