import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'entry_form_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  late CollectionReference _entries;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _entries.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final entries = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return ListTile(
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
                    );
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => _navigateToEntryForm(),
            child: const Text('Add New Entry'),
          ),
        ],
      ),
    );
  }
}
