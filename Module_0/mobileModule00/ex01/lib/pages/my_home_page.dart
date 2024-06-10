import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Initialisation de la variable pour stocker le texte actuel
  String displayText = 'Hello, Flutter!';

  void _toggleText() {
    // Cette fonction met à jour le texte en fonction de son état actuel
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
      appBar: AppBar(
        title: const Text('Ex01'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              displayText, // Utilisation de la variable d'état pour l'affichage
            ),
            const SizedBox(height: 20), // Ajouter de l'espace entre le texte et le bouton
            ElevatedButton(
              onPressed: _toggleText, // Lier la fonction de commutation à l'appui sur le bouton
              child: const Text('Toggle Text'),
            ),
          ],
        ),
      ),
    );
  }
}
