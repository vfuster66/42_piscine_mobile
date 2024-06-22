
// pages/my_home_page.dart
// This file defines the home page of the application as a StatefulWidget.
// The home page consists of a centered text and a button. When the button is pressed,
// the text alternates between "Hello, Flutter!" and "Hello World!".

import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  String displayText = 'Hello, Flutter!'; // Initial text to be displayed

  // Method to toggle the displayed text
  void _toggleText() {
    setState(() {
      if (displayText == 'Hello, Flutter!') {
        displayText = 'Hello World!';
      } else {
        displayText = 'Hello, Flutter!';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use LayoutBuilder to make the UI responsive
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Display the current text
                Text(displayText),
                const SizedBox(height: 20), // Add space between the text and the button
                // Button to toggle the text
                ElevatedButton(
                  onPressed: _toggleText, // Call the _toggleText method on button press
                  child: const Text('Toggle Text'), // Button label
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

