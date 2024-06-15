import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'entry_form_page.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'package:intl/intl.dart';

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

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  AgendaPageState createState() => AgendaPageState();
}

class AgendaPageState extends State<AgendaPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  late CollectionReference _entries;
  late String _userName;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

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

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _userName = _user?.displayName ?? 'User';
    _entries = _firestore.collection('entries').doc(_user!.uid).collection('userEntries');
  }

  Future<void> _deleteEntry(String id, DateTime selectedDay) async {
    await _entries.doc(id).delete();
    _showEntriesDialog(selectedDay);
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

  void _navigateToEntryForm(BuildContext context, [DocumentSnapshot? entry]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EntryFormPage(entry: entry)),
    );
  }

  void _showEntriesDialog(DateTime selectedDay) {
    const Color darkPurple = Color(0xFF6A0DAD);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Entries for ${DateFormat('dd/MM/yyyy').format(selectedDay)}',
            style: const TextStyle(color: darkPurple),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400, // Fixe la hauteur pour permettre le défilement
            child: StreamBuilder<QuerySnapshot>(
              stream: _entries
                  .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime(selectedDay.year, selectedDay.month, selectedDay.day)))
                  .where('date', isLessThanOrEqualTo: Timestamp.fromDate(
                  DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 23, 59, 59)))
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final entries = snapshot.data!.docs;
                if (entries.isEmpty) {
                  return const Center(child: Text(
                    'No entries for this date.',
                    style: TextStyle(color: darkPurple),
                  ));
                }
                return Scrollbar(
                  thumbVisibility: true,
                  child: ListView.builder(
                    physics: const ReverseScrollPhysics(),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return Column(
                        children: [
                          Card(
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ListTile(
                              title: Text(
                                entry['title'],
                                style: const TextStyle(color: darkPurple),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date: ${DateFormat('dd/MM/yyyy').format((entry['date'] as Timestamp).toDate())}',
                                    style: const TextStyle(color: darkPurple),
                                  ),
                                  Text(
                                    'Feeling: ${_feelingEmojis[entry['feeling']]} ${entry['feeling']}',
                                    style: const TextStyle(color: darkPurple),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                _navigateToEntryForm(context, entry);
                              },
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: darkPurple),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  _deleteEntry(entry.id, selectedDay);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            Center(
              child: Column(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _navigateToEntryForm(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: darkPurple,
                      side: const BorderSide(color: darkPurple),
                    ),
                    child: const Text('Add New Entry'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: darkPurple,
                      side: const BorderSide(color: darkPurple),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToProfilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color darkPurple = Color(0xFF6A0DAD);

    return Scaffold(
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.person, color: darkPurple),
                    onPressed: _navigateToProfilePage,
                  ),
                  title: Text(
                    _userName,
                    style: const TextStyle(
                      color: darkPurple,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout, color: darkPurple),
                      onPressed: () => _logout(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: TableCalendar(
                    firstDay: DateTime.utc(2000, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      _showEntriesDialog(selectedDay);
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: const BoxDecoration(
                        color: darkPurple,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: darkPurple,
                        shape: BoxShape.circle,
                      ),
                      weekendTextStyle: const TextStyle().copyWith(color: darkPurple),
                      defaultTextStyle: const TextStyle().copyWith(color: darkPurple),
                      outsideTextStyle: const TextStyle().copyWith(color: darkPurple.withOpacity(0.5)),
                      holidayTextStyle: const TextStyle().copyWith(color: darkPurple),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: const TextStyle().copyWith(color: darkPurple),
                      weekendStyle: const TextStyle().copyWith(color: darkPurple),
                    ),
                    headerStyle: HeaderStyle(
                      titleTextStyle: const TextStyle().copyWith(color: darkPurple, fontSize: 16),
                      leftChevronIcon: const Icon(Icons.chevron_left, color: darkPurple),
                      rightChevronIcon: const Icon(Icons.chevron_right, color: darkPurple),
                      formatButtonVisible: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
