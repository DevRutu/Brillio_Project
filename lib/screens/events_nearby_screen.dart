import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../screens/explore_screen.dart';
import '../screens/event_details_screen.dart'; // Add this import

class EventsNearbyScreen extends StatelessWidget {
  final String selectedCity;

  const EventsNearbyScreen({
    super.key,
    required this.selectedCity,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildEventsList(context), // Pass context here
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF5D7BD5),
            ),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ExploreScreen()),
            ),
          ),
          Text(
            'Events in $selectedCity',
            style: GoogleFonts.quicksand(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFA873E8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(BuildContext context) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('events')
        .where('city', isEqualTo: selectedCity)
        .where('date_timestamp', isGreaterThanOrEqualTo: today.millisecondsSinceEpoch)
        .orderBy('date_timestamp')
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        print('Error: ${snapshot.error}');
        return Center(
          child: Text(
            'Error loading events',
            style: GoogleFonts.quicksand(color: Colors.red),
          ),
        );
      }

      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final events = snapshot.data!.docs;

      if (events.isEmpty) {
        return Center(
          child: Text(
            'No events available in $selectedCity',
            style: GoogleFonts.quicksand(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: events.length,
        itemBuilder: (context, index) => _buildEventCard(context, events[index]),
      );
    },
  );
}

  Widget _buildEventCard(BuildContext context, DocumentSnapshot event) {
    final data = event.data() as Map<String, dynamic>;
    final date = DateTime.fromMillisecondsSinceEpoch(data['date_timestamp']);
    final formattedDate = DateFormat('dd').format(date);
    final formattedMonth = DateFormat('MMM').format(date);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailsScreen(
                eventData: data,
                eventId: event.id, // Pass eventId here
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFA873E8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      formattedDate,
                      style: GoogleFonts.quicksand(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFA873E8),
                      ),
                    ),
                    Text(
                      formattedMonth,
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        color: const Color(0xFFA873E8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title'] ?? 'Untitled Event',
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5D7BD5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['location'] ?? 'Unknown Location',
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, MMMM d, y').format(date),
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        color: const Color(0xFFA873E8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
