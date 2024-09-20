
// first_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'profile_page.dart' as profile;

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  Future<User?> _checkIfLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/first_page.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          FutureBuilder<User?>(
            future: _checkIfLoggedIn(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasData) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const profile.ProfilePage()),
                  );
                });
              }

              return _buildLoginAndRegisterButtons(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoginAndRegisterButtons(BuildContext context) {
    const Color darkPurple = Color(0xFF6A0DAD);

    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 8),
            ElevatedButton(
              onPressed: () async {

                try {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {

                try {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  );
                } catch (e) {
                  print("FirstPage: Error navigating to RegisterPage: $e");
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
                'Register',
                style: TextStyle(
                  color: darkPurple,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(flex: 5),
          ],
        ),
      ),
    );
  }
}

