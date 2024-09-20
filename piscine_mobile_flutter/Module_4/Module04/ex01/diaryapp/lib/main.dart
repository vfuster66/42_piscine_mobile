
// main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:diaryapp/first_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialisation de Firebase avec gestion d'erreurs
    await Firebase.initializeApp();
    print("Firebase initialized successfully.");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Ajout d'un titre à l'application
      title: 'DiaryApp',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const FirstPage(),
    );
  }
}

