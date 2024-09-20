
// login_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'profile_page.dart';
import 'package:github_sign_in_plus/github_sign_in_plus.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LogInPageState createState() => LogInPageState();
}

class LogInPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Configuration pour GitHubSignIn
  final GitHubSignIn gitHubSignIn = GitHubSignIn(
    clientId: 'Ov23lik6uSvtMxRtlEgA',  // Ton Client ID GitHub
    clientSecret: '7cc7d69e0a82150b06706087f8fd4a2eaddbdcf5',  // Ton Client Secret GitHub
    redirectUrl: 'https://diaryapp-35992.firebaseapp.com/__/auth/handler',  // URL de rappel configurée dans Firebase
  );

  // Validation du format de l'e-mail
  bool _isEmailValid(String email) {
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegExp.hasMatch(email);
  }

  // Validation du mot de passe (minimum 6 caractères)
  bool _isPasswordValid(String password) {
    return password.length >= 6;
  }

  @override
  Widget build(BuildContext context) {
    const Color darkPurple = Color(0xFF6A0DAD);
    const double buttonWidth = 200.0;
    const double buttonHeight = 50.0;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 50),
                    const Text(
                      'Log in',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Pacifico',
                        color: darkPurple,
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: darkPurple),
                        prefixIcon: const Icon(Icons.email, color: darkPurple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                      ),
                      style: const TextStyle(color: darkPurple),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: darkPurple),
                        prefixIcon: const Icon(Icons.lock, color: darkPurple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                      ),
                      style: const TextStyle(color: darkPurple),
                      obscureText: true,
                    ),
                    const SizedBox(height: 40),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                      children: [
                        SizedBox(
                          width: buttonWidth,
                          height: buttonHeight,
                          child: TextButton(
                            onPressed: _isLoading ? null : _signIn, // Désactivation pendant le chargement
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(color: darkPurple),
                              ),
                              backgroundColor: Colors.transparent,
                              foregroundColor: darkPurple,
                            ),
                            child: const Text('Log In'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: buttonWidth,
                          height: buttonHeight,
                          child: TextButton.icon(
                            onPressed: _isLoading ? null : _signInWithGoogle, // Désactivation pendant le chargement
                            icon: const Icon(Icons.login, color: darkPurple),
                            label: const Text('Log In with Google'),
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(color: darkPurple),
                              ),
                              backgroundColor: Colors.transparent,
                              foregroundColor: darkPurple,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: buttonWidth,
                          height: buttonHeight,
                          child: TextButton.icon(
                            onPressed: _isLoading ? null : _signInWithGitHub, // Désactivation pendant le chargement
                            icon: const Icon(Icons.code, color: darkPurple),
                            label: const Text('Log In with GitHub'),
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(color: darkPurple),
                              ),
                              backgroundColor: Colors.transparent,
                              foregroundColor: darkPurple,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: buttonWidth,
                          height: buttonHeight,
                          child: TextButton(
                            onPressed: _isLoading ? null : _resetPassword, // Désactivation pendant le chargement
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(color: darkPurple),
                              ),
                              backgroundColor: Colors.transparent,
                              foregroundColor: darkPurple,
                            ),
                            child: const Text('Forgot Password?'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    // Validation de l'email et du mot de passe avant de tenter la connexion
    if (!_isEmailValid(_emailController.text)) {
      _showErrorDialog('Erreur', 'Veuillez entrer une adresse e-mail valide.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (!_isPasswordValid(_passwordController.text)) {
      _showErrorDialog('Erreur', 'Le mot de passe doit comporter au moins 6 caractères.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      UserCredential _ = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = "L'adresse e-mail n'est pas valide.";
          break;
        case 'user-disabled':
          errorMessage = "Cet utilisateur a été désactivé.";
          break;
        case 'user-not-found':
          errorMessage = "Aucun utilisateur trouvé pour cet email.";
          break;
        case 'wrong-password':
          errorMessage = "Mot de passe incorrect.";
          break;
        default:
          errorMessage = "Connexion échouée.";
      }

      _showErrorDialog('Échec de la connexion', errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Méthode pour Google Sign-In
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await _auth.signInWithCredential(credential);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    } catch (e) {
      _showErrorDialog('Erreur de connexion', 'Connexion avec Google échouée.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Méthode pour GitHub Sign-In
  Future<void> _signInWithGitHub() async {
    print("GitHub Sign-In: Initiating GitHub sign-in.");

    // Vérifier si le widget est encore monté avant de mettre à jour l'UI
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print("GitHub Sign-In: Attempting to sign in with GitHub provider.");
      var result = await gitHubSignIn.signIn(context);

      print("GitHub Sign-In: Result status - ${result.status}");

      if (result.status == GitHubSignInResultStatus.ok) {
        print("GitHub Sign-In: Sign-in successful, token: ${result.token}");

        final AuthCredential githubCredential = GithubAuthProvider.credential(result.token!);
        print("GitHub Sign-In: Created AuthCredential with GitHub token.");

        try {
          print("GitHub Sign-In: Attempting Firebase authentication with GitHub credential.");
          await _auth.signInWithCredential(githubCredential);
          print("GitHub Sign-In: Firebase authentication successful.");

          if (mounted) {
            print("GitHub Sign-In: Navigating to ProfilePage.");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }
        } on FirebaseAuthException catch (e) {
          print("GitHub Sign-In: FirebaseAuthException caught - ${e.code}");

          if (e.code == 'account-exists-with-different-credential') {
            print("GitHub Sign-In: Account exists with different credentials. Attempting Google sign-in.");

            final email = e.email;
            final signInMethods = await _auth.fetchSignInMethodsForEmail(email!);
            print("GitHub Sign-In: Sign-in methods for email - $signInMethods");

            if (signInMethods.contains('google.com')) {
              print("GitHub Sign-In: Google sign-in method found. Attempting Google sign-in.");
              final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
              final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

              final AuthCredential googleCredential = GoogleAuthProvider.credential(
                accessToken: googleAuth?.accessToken,
                idToken: googleAuth?.idToken,
              );
              print("GitHub Sign-In: Google AuthCredential created.");

              UserCredential userCredential = await _auth.signInWithCredential(googleCredential);
              print("GitHub Sign-In: Firebase authentication with Google successful. Linking with GitHub credential.");

              await userCredential.user?.linkWithCredential(githubCredential);
              print("GitHub Sign-In: GitHub credential linked successfully.");

              if (mounted) {
                print("GitHub Sign-In: Navigating to ProfilePage after linking.");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              }
            }
          } else {
            print("GitHub Sign-In: Authentication failed with error: ${e.message}");
            _showErrorDialog('Erreur de connexion', 'Connexion avec GitHub échouée.');
          }
        }
      } else {
        print("GitHub Sign-In: Sign-in failed - ${result.errorMessage}");
        _showErrorDialog('Erreur de connexion', result.errorMessage ?? 'Connexion avec GitHub échouée.');
      }
    } catch (e) {
      print("GitHub Sign-In: Exception caught - $e");
      _showErrorDialog('Erreur de connexion', 'Connexion avec GitHub échouée.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print("GitHub Sign-In: Finished sign-in process.");
    }
  }


  // Méthode pour réinitialiser le mot de passe
  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      _showErrorDialog('Erreur', 'Entrez votre email pour réinitialiser le mot de passe.');
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      _showErrorDialog('Mot de passe réinitialisé', 'Vérifiez votre boîte de réception.');
    } catch (e) {
      _showErrorDialog('Erreur', 'Erreur lors de la réinitialisation du mot de passe.');
    }
  }

// Autres méthodes comme _signIn() pour email et mot de passe restent inchangées.
}

