
// first_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'profile_page.dart' as profile; // Alias pour profile_page

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  Future<User?> _checkIfLoggedIn() async {
    print("FirstPage: Checking if user is logged in");
    User? user = FirebaseAuth.instance.currentUser;
    return user;
  }

  @override
  Widget build(BuildContext context) {
    print("FirstPage: build method called");

    return Scaffold(
      body: Stack( // Utilisation d'un Stack pour afficher le fond d'écran
        children: [
          // Image de fond
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/first_page.jpg'), // Chemin de ton image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Contenu principal (bouton Login ou redirection)
          FutureBuilder<User?>(
            future: _checkIfLoggedIn(),
            builder: (context, snapshot) {
              // Si la vérification est en cours, affichons un indicateur de chargement
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Si l'utilisateur est connecté, on le redirige vers ProfilePage
              if (snapshot.hasData) {
                print("FirstPage: User is logged in, navigating to ProfilePage");
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const profile.ProfilePage()),
                  );
                });
              }

              // Si l'utilisateur n'est pas connecté, on affiche le bouton "Login"
              return _buildLoginButton(context);
            },
          ),
        ],
      ),
    );
  }

  // Widget du bouton "Login"
  Widget _buildLoginButton(BuildContext context) {
    const Color darkPurple = Color(0xFF6A0DAD);

    return Center(
      child: ElevatedButton(
        onPressed: () async {
          print("FirstPage: Login button pressed");

          try {
            print("FirstPage: Navigating to LoginPage");
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
            print("FirstPage: Successfully navigated to LoginPage");
          } catch (e) {
            print("FirstPage: Error navigating to LoginPage: $e");
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          side: const BorderSide(color: darkPurple),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          fixedSize: const Size(200, 70),
        ),
        child: const Text(
          'Login',
          style: TextStyle(
            color: darkPurple,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

