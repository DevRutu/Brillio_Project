import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/event_rsvp_screen.dart';
import '../screens/host_event_screen.dart';

class EventDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> eventData;
  final String eventId;
  final bool isHost;

  const EventDetailsScreen({
    super.key,
    required this.eventData,
    required this.eventId,
    this.isHost = false,
  });

  Future<bool> _checkIfRegistered() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final doc = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('attendees')
        .doc(user.uid)
        .get();
    return doc.exists;
  }

  Future<void> _handleRSVP(BuildContext context) async {
    final currentAttendees = eventData['currentAttendees'] ?? 0;
    final capacity = eventData['capacity'] ?? 0;
    if (currentAttendees >= capacity) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Event Full', style: GoogleFonts.quicksand(fontWeight: FontWeight.bold)),
          content: Text('Sorry, this event is already full.', style: GoogleFonts.quicksand()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: GoogleFonts.quicksand()),
            ),
          ],
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventRSVPScreen(
          eventId: eventId,
          currentAttendees: currentAttendees,
          capacity: capacity,
        ),
      ),
    );
  }

  Future<void> _openInGoogleMaps(BuildContext context) async {
    final location = eventData['location']?.trim() ?? '';
    final city = eventData['city']?.trim() ?? '';
    final address = '$location, $city, India'.trim();

    if (location.isEmpty || city.isEmpty) {
      debugPrint('Location or city is empty');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Location or city information is missing.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final encodedAddress = Uri.encodeComponent(address);
    final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
    final uri = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Could not open Google Maps.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(eventData['date_timestamp']);
    final contactNumber = eventData['contactNumber'] ?? eventData['contact_number'] ?? eventData['contact'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5D7BD5)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Event Details',
          style: GoogleFonts.quicksand(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFA873E8),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eventData['title'] ?? 'Untitled Event',
                style: GoogleFonts.quicksand(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5D7BD5),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Description',
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5D7BD5),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                eventData['description'] ?? 'No description available',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  color: Colors.grey[800],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Color(0xFFA873E8),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM d, y').format(date),
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        eventData['time'] ?? DateFormat('h:mm a').format(date),
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFFA873E8),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${eventData['location'] ?? ''}, ${eventData['city'] ?? ''}',
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (contactNumber != null)
                Row(
                  children: [
                    const Icon(
                      Icons.phone,
                      color: Color(0xFFA873E8),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      contactNumber,
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 40),
              FutureBuilder<bool>(
                future: _checkIfRegistered(),
                builder: (context, snapshot) {
                  final isRegistered = snapshot.data ?? false;
                  
                  if (isHost) {
                    return Column(
                      children: [
                        Text(
                          'Available Seats: ${(eventData['capacity'] ?? 0) - (eventData['currentAttendees'] ?? 0)}',
                          style: GoogleFonts.quicksand(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HostEventScreen(
                                  isEditing: true,
                                  eventId: eventId,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5D7BD5),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            'Edit Event',
                            style: GoogleFonts.quicksand(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  
                  return Column(
                    children: [
                      Text(
                        'Available Seats: ${(eventData['capacity'] ?? 0) - (eventData['currentAttendees'] ?? 0)}',
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (!isRegistered)
                        ElevatedButton(
                          onPressed: () => _handleRSVP(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5D7BD5),
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            'Register for Event',
                            style: GoogleFonts.quicksand(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      if (isRegistered)
                        Text(
                          'You are registered for this event',
                          style: GoogleFonts.quicksand(
                            fontSize: 16,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _openInGoogleMaps(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA873E8),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.directions,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Get Directions",
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
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