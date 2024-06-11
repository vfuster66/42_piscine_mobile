import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';  // Ajoutez ce package pour la gestion des dates

class EntryFormPage extends StatefulWidget {
  final DocumentSnapshot? entry;

  const EntryFormPage({Key? key, this.entry}) : super(key: key);

  @override
  _EntryFormPageState createState() => _EntryFormPageState();
}

class _EntryFormPageState extends State<EntryFormPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _feelingController;
  late TextEditingController _contentController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
        text: widget.entry != null ? widget.entry!['title'] : '');
    _feelingController = TextEditingController(
        text: widget.entry != null ? widget.entry!['feeling'] : '');
    _contentController = TextEditingController(
        text: widget.entry != null ? widget.entry!['content'] : '');
    _selectedDate = widget.entry != null
        ? (widget.entry!['date'] as Timestamp).toDate()
        : DateTime.now();
  }

  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      final User? user = _auth.currentUser;

      if (user != null) {
        if (widget.entry != null) {
          // Update existing entry
          await _firestore
              .collection('entries')
              .doc(user.uid)
              .collection('userEntries')
              .doc(widget.entry!.id)
              .update({
            'title': _titleController.text,
            'feeling': _feelingController.text,
            'content': _contentController.text,
            'date': _selectedDate,
          });
        } else {
          // Create new entry
          await _firestore
              .collection('entries')
              .doc(user.uid)
              .collection('userEntries')
              .add({
            'title': _titleController.text,
            'feeling': _feelingController.text,
            'content': _contentController.text,
            'date': _selectedDate,
            'email': user.email,
          });
        }

        Navigator.pop(context);
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.entry != null ? 'Edit Entry' : 'New Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _feelingController,
                decoration: const InputDecoration(labelText: 'Feeling'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a feeling';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some content';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    _selectedDate != null
                        ? 'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}'
                        : 'No date selected',
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Select date'),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _saveEntry,
                child: Text(widget.entry != null ? 'Update Entry' : 'Add Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
