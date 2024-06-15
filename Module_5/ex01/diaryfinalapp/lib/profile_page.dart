import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'agenda_page.dart';
import 'login_page.dart';
import 'entry_form_page.dart';

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
  int _totalEntries = 0;
  List<DocumentSnapshot> _recentEntries = [];
  Map<String, int> _feelingStats = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _entries = _firestore.collection('entries').doc(_user!.uid).collection('userEntries');
    _fetchEntries();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchEntries() async {
    final snapshot = await _entries.orderBy('date', descending: true).limit(2).get();
    final allEntriesSnapshot = await _entries.get();

    setState(() {
      _totalEntries = allEntriesSnapshot.size;
      _recentEntries = snapshot.docs;
      _calculateFeelingStats(allEntriesSnapshot.docs);
    });
  }

  void _calculateFeelingStats(List<QueryDocumentSnapshot> docs) {
    final Map<String, int> stats = {};
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final feeling = data['feeling'];
      if (stats.containsKey(feeling)) {
        stats[feeling] = stats[feeling]! + 1;
      } else {
        stats[feeling] = 1;
      }
    }
    setState(() {
      _feelingStats = stats;
    });
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  void _navigateToAgendaPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AgendaPage()),
    );
  }

  void _navigateToEntryForm([DocumentSnapshot<Object?>? entry]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EntryFormPage(entry: entry)),
    );
  }

  void _deleteEntry(String id) async {
    await _entries.doc(id).delete();
    _fetchEntries();
  }

  @override
  Widget build(BuildContext context) {
    const Color darkPurple = Color(0xFF6A0DAD);

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
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          leading: IconButton(
                            icon: const Icon(Icons.calendar_today, color: darkPurple),
                            onPressed: _navigateToAgendaPage,
                          ),
                          title: Text(
                            _user?.displayName ?? 'Profile',
                            style: const TextStyle(
                              color: darkPurple,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          actions: [
                            IconButton(
                              icon: const Icon(Icons.logout, color: darkPurple),
                              onPressed: _logout,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Recent Entries:',
                          style: TextStyle(color: darkPurple, fontSize: 18),
                        ),
                        Card(
                          elevation: 0.0,
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ..._recentEntries.map((entry) {
                                  final data = entry.data() as Map<String, dynamic>;
                                  return ListTile(
                                    title: Text(data['title']),
                                    subtitle: Text('${(data['date'] as Timestamp).toDate().toLocal()} - ${data['feeling']}'),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, color: darkPurple),
                                      onPressed: () => _deleteEntry(entry.id),
                                    ),
                                    onTap: () => _navigateToEntryForm(entry),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Feelings Statistics for your $_totalEntries entries:',
                          style: const TextStyle(color: darkPurple, fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 60, // Adjust height as needed
                          child: Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              physics: const ReverseScrollPhysics(),
                              child: Row(
                                children: _feelingStats.entries.map((entry) => Container(
                                  width: MediaQuery.of(context).size.width / 4 - 24,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _feelingEmojis[entry.key] ?? '',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      Text(
                                        '${(entry.value / _totalEntries * 100).toStringAsFixed(1)}%',
                                        style: const TextStyle(color: darkPurple, fontSize: 14),
                                      ),
                                      const SizedBox(width: 20), // Adjust the width as needed
                                    ],
                                  ),
                                )).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _navigateToEntryForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            side: const BorderSide(color: darkPurple),
                          ),
                          child: const Text('Add New Entry', style: TextStyle(color: darkPurple)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  final Map<String, String> _feelingEmojis = {
    'Happy': '😊',
    'Sad': '😢',
    'Angry': '😠',
    'Excited': '😃',
    'Tired': '😴',
    'Confused': '😕',
    'Surprised': '😮',
    'Calm': '😌',
    'Fearful': '😨',
    'Disgusted': '🤢',
    'Pensive': '🤔',
    'Joyful': '😁',
    'Relaxed': '😎',
    'Annoyed': '😒',
  };
}
