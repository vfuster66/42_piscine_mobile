import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ex00'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Hello, Flutter!'),
            const SizedBox(height: 20),  // Espace entre le texte et le bouton
            ElevatedButton(
              onPressed: () {
                print('Button pressed');
              },
              child: const Text('Press me'),
            ),
          ],
        ),
      ),
    );
  }
}