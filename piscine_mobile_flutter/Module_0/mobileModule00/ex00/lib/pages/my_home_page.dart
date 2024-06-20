// pages/my_home_page.dart
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
                    print('Button pressed');
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
