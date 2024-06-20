// pages/my_home_page.dart
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  String displayText = 'Hello, Flutter!';

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  displayText,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _toggleText,
                  child: const Text('Toggle Text'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
