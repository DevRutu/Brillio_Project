import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendeeListScreen extends StatelessWidget {
  final String eventId;

  const AttendeeListScreen({
    super.key,
    required this.eventId,
  });

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
          'Attendees',
          style: GoogleFonts.quicksand(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFA873E8),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .collection('attendees')
            .orderBy('registeredAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading attendees'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final attendees = snapshot.data!.docs;

          if (attendees.isEmpty) {
            return Center(
              child: Text(
                'No attendees yet',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: attendees.length,
            itemBuilder: (context, index) {
              final attendee = attendees[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  title: Text(
                    attendee['name'] ?? 'Unknown',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5D7BD5),
                    ),
                  ),
                  subtitle: Text(
                    attendee['contact'] ?? 'No contact provided',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}