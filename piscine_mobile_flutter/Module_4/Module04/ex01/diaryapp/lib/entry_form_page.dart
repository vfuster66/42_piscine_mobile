
// entry_form_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class EntryFormPage extends StatefulWidget {
  final DocumentSnapshot? entry;

  const EntryFormPage({super.key, this.entry});

  @override
  EntryFormPageState createState() => EntryFormPageState();
}

class EntryFormPageState extends State<EntryFormPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _contentController;
  DateTime? _selectedDate;
  String? _selectedFeeling;

  final List<Map<String, String>> _feelings = [
    {'label': 'Happy', 'emoji': '😊'},
    {'label': 'Sad', 'emoji': '😢'},
    {'label': 'Angry', 'emoji': '😠'},
    {'label': 'Excited', 'emoji': '😃'},
    {'label': 'Tired', 'emoji': '😴'},
    {'label': 'Confused', 'emoji': '😕'},
    {'label': 'Surprised', 'emoji': '😮'},
    {'label': 'Calm', 'emoji': '😌'},
    {'label': 'Fearful', 'emoji': '😨'},
    {'label': 'Disgusted', 'emoji': '🤢'},
    {'label': 'Pensive', 'emoji': '🤔'},
    {'label': 'Joyful', 'emoji': '😁'},
    {'label': 'Relaxed', 'emoji': '😎'},
    {'label': 'Annoyed', 'emoji': '😒'},

  ];

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
        text: widget.entry != null ? widget.entry!['title'] : '');
    _contentController = TextEditingController(
        text: widget.entry != null ? widget.entry!['content'] : '');
    _selectedDate = widget.entry != null
        ? (widget.entry!['date'] as Timestamp).toDate()
        : DateTime.now();
    _selectedFeeling = widget.entry != null ? widget.entry!['feeling'] : null;
  }

  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate() && _selectedFeeling != null) {
      final User? user = _auth.currentUser;

      if (user != null) {
        final contextToUse = context;
        if (widget.entry != null) {
          await _firestore
              .collection('entries')
              .doc(user.uid)
              .collection('userEntries')
              .doc(widget.entry!.id)
              .update({
            'title': _titleController.text,
            'feeling': _selectedFeeling,
            'content': _contentController.text,
            'date': _selectedDate,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entrée mise à jour avec succès')),
          );
        } else {
          await _firestore
              .collection('entries')
              .doc(user.uid)
              .collection('userEntries')
              .add({
            'title': _titleController.text,
            'feeling': _selectedFeeling,
            'content': _contentController.text,
            'date': _selectedDate,
            'email': user.email,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nouvelle entrée ajoutée avec succès')),
          );
        }
        if (contextToUse.mounted) {
          Navigator.pop(contextToUse);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs et sélectionner un sentiment')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _cancelEntry() {
    Navigator.pop(context);
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
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20), // Add space at the top
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un titre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        labelText: 'Content',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer du contenu';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          _selectedDate != null
                              ? 'Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}'
                              : 'Pas de date sélectionnée',
                          style: const TextStyle(fontSize: 16, color: darkPurple),
                        ),
                        const SizedBox(width: 20),
                        TextButton(
                          onPressed: () => _selectDate(context),
                          style: TextButton.styleFrom(
                            foregroundColor: darkPurple,
                            side: const BorderSide(color: darkPurple),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Sélectionner la date'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Sentiment :', style: TextStyle(fontSize: 16, color: darkPurple)),
                    Wrap(
                      spacing: 4.0,
                      runSpacing: 4.0,
                      children: _feelings.map((feeling) {
                        return SizedBox(
                          width: 40,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFeeling = feeling['label'];
                              });
                            },
                            child: Tooltip(
                              message: feeling['label']!,
                              child: Container(
                                margin: const EdgeInsets.all(2.0),
                                padding: const EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                  color: _selectedFeeling == feeling['label']
                                      ? darkPurple.withOpacity(0.3)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: _selectedFeeling == feeling['label']
                                        ? darkPurple
                                        : Colors.transparent,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    feeling['emoji']!,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: _cancelEntry,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: const Text('Annuler'),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: TextButton(
                            onPressed: _saveEntry,
                            style: TextButton.styleFrom(
                              foregroundColor: darkPurple,
                              side: const BorderSide(color: darkPurple),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: Text(widget.entry != null ? 'Mettre à jour' : 'Ajouter'),
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
}



