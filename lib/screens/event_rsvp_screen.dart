import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/explore_screen.dart';

class EventRSVPScreen extends StatefulWidget {
  final String eventId;
  final int currentAttendees;
  final int capacity;

  const EventRSVPScreen({
    super.key,
    required this.eventId,
    required this.currentAttendees,
    required this.capacity,
  });

  @override
  State<EventRSVPScreen> createState() => _EventRSVPScreenState();
}

class _EventRSVPScreenState extends State<EventRSVPScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitRSVP() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        // Check capacity again before submitting
        final eventDoc = await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .get();
        
        final currentAttendees = eventDoc.data()?['currentAttendees'] ?? 0;
        if (currentAttendees >= widget.capacity) {
          _showError('Sorry, the event is full');
          return;
        }

        // Add attendee
        await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .collection('attendees')
            .doc(user.uid)
            .set({
          'name': _nameController.text,
          'contact': _contactController.text,
          'registeredAt': FieldValue.serverTimestamp(),
          'userId': user.uid,
        });

        // Increment attendee count
        await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .update({
          'currentAttendees': FieldValue.increment(1),
        });

        // Show success and navigate back
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully registered!')),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const ExploreScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        _showError('Failed to register. Please try again.');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5D7BD5)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Register for Event',
          style: GoogleFonts.quicksand(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFA873E8),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Your Name',
                        labelStyle: GoogleFonts.quicksand(
                          color: const Color(0xFF5D7BD5),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _contactController,
                      decoration: InputDecoration(
                        labelText: 'Contact Number',
                        labelStyle: GoogleFonts.quicksand(
                          color: const Color(0xFF5D7BD5),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter your contact number' : null,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _submitRSVP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA873E8),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Register',
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}