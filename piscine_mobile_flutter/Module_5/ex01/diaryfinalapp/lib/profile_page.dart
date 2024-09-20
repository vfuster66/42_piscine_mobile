import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'login_page.dart';
import 'entry_form_page.dart';
import 'agenda_page.dart'; // Importation de la page d'agenda

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  void _navigateToEntryForm([DocumentSnapshot<Object?>? entry]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EntryFormPage(entry: entry)),
    );
  }

  void _navigateToAgendaPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AgendaPage()),
    );
  }

  void _deleteEntry(String id) async {
    await _entries.doc(id).delete();
  }

  Map<String, int> _calculateFeelingStats(List<QueryDocumentSnapshot> docs) {
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
    return stats;
  }

  @override
  Widget build(BuildContext context) {
    const Color darkPurple = Color(0xCC6A0DAD);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _user?.displayName ?? 'Nom non disponible',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: darkPurple,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: _navigateToAgendaPage,
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
            iconSize: 26,
          )

        ],
      ),
      body: Stack(
        children: [
          // Fond d'écran
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
                        const SizedBox(height: 20),
                        const Text(
                          'Recent Entries:',
                          style: TextStyle(color: darkPurple, fontSize: 18),
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: _entries.orderBy('date', descending: true).limit(2).snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final entries = snapshot.data!.docs;

                            if (entries.isEmpty) {
                              return const Text(
                                'No entries yet.',
                                style: TextStyle(color: darkPurple),
                              );
                            }

                            return Column(
                              children: entries.map((entry) {
                                final data = entry.data() as Map<String, dynamic>;

                                // Formater la date
                                final Timestamp timestamp = data['date'];
                                final DateTime date = timestamp.toDate();
                                final String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);

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
                                    title: Text(data['title']),
                                    subtitle: Text(
                                      '$formattedDate',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    onTap: () => _navigateToEntryForm(entry),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, color: darkPurple),
                                      onPressed: () => _deleteEntry(entry.id),
                                    ),
                                    leading: Text(
                                      _feelingEmojis[data['feeling']] ?? '',
                                      style: const TextStyle(
                                        fontSize: 32, // Agrandir l'emoji
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: _entries.snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final docs = snapshot.data!.docs;
                          final totalEntries = docs.length;
                          final feelingStats = _calculateFeelingStats(docs);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Feelings Statistics for your $totalEntries entries:',
                                style: const TextStyle(color: darkPurple, fontSize: 18),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 60,
                                child: Scrollbar(
                                  controller: _scrollController,
                                  thumbVisibility: true,
                                  child: SingleChildScrollView(
                                    controller: _scrollController,
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: feelingStats.entries.map((entry) => Container(
                                        width: MediaQuery.of(context).size.width / 4 - 24,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _feelingEmojis[entry.key] ?? '',
                                              style: const TextStyle(fontSize: 20),
                                            ),
                                            Text(
                                              '${(entry.value / totalEntries * 100).toStringAsFixed(1)}%',
                                              style: const TextStyle(color: darkPurple, fontSize: 14),
                                            ),
                                            const SizedBox(width: 20),
                                          ],
                                        ),
                                      )).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _navigateToEntryForm,
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
                            fontSize: 18,
                          ),
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
