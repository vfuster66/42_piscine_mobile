
// profile_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'entry_form_page.dart';
import 'first_page.dart'; // Importer FirstPage pour rediriger après déconnexion

class ReverseScrollPhysics extends ScrollPhysics {
  const ReverseScrollPhysics({super.parent});

  @override
  ReverseScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ReverseScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return -offset;
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  late CollectionReference _entries;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _entries = _firestore.collection('entries').doc(_user!.uid).collection('userEntries');
  }

  Future<void> _deleteEntry(String id) async {
    await _entries.doc(id).delete();
  }

  void _navigateToEntryForm([DocumentSnapshot? entry]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EntryFormPage(entry: entry)),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const FirstPage()),
          (Route<dynamic> route) => false,
    );
  }



  @override
  Widget build(BuildContext context) {
    const Color darkPurple = Color(0xAA6A0DAD);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
        backgroundColor: darkPurple,
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18, // Taille de police augmentée pour plus de visibilité
                fontWeight: FontWeight.bold, // Ajout de gras pour plus de visibilité
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Image de fond
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _entries.orderBy('date').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final entries = snapshot.data!.docs;
                    return Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      thickness: 8.0,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: entries.length,
                        reverse: false,
                        physics: const ReverseScrollPhysics(),
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            padding: const EdgeInsets.all(16.0),
                            width: MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4.0,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Text(entry['title']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Date: ${(entry['date'] as Timestamp).toDate()}'),
                                  Text(entry['content']),
                                ],
                              ),
                              onTap: () => _navigateToEntryForm(entry),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteEntry(entry.id),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => _navigateToEntryForm(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    ),
                  ),

                  child: const Text(
                    'Add New Entry',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18, // Taille de police augmentée
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
