import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../screens/explore_screen.dart';
import '../screens/attendee_list_screen.dart';

class HostEventScreen extends StatefulWidget {
  final bool isEditing;
  final String? eventId;

  const HostEventScreen({
    super.key,
    this.isEditing = false,
    this.eventId,
  });

  @override
  _HostEventScreenState createState() => _HostEventScreenState();
}

class _HostEventScreenState extends State<HostEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadEventData();
    }
  }

  Future<void> _loadEventData() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      DocumentSnapshot? eventDoc;
      if (widget.eventId != null) {
        eventDoc = await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .get();
      } else {
        final eventQuery = await FirebaseFirestore.instance
            .collection('events')
            .where('createdBy', isEqualTo: user.uid)
            .get();
        if (eventQuery.docs.isNotEmpty) {
          eventDoc = eventQuery.docs.first;
        }
      }

      if (eventDoc != null && eventDoc.exists) {
        final eventData = eventDoc.data() as Map<String, dynamic>;
        _titleController.text = eventData['title'] ?? '';
        _descriptionController.text = eventData['description'] ?? '';
        _cityController.text = eventData['city'] ?? '';
        _locationController.text = eventData['location'] ?? '';
        _dateController.text = eventData['date'] ?? '';
        _timeController.text = eventData['time'] ?? '';
        _contactNumberController.text = eventData['contactNumber'] ?? '';
        _capacityController.text = (eventData['capacity'] ?? '').toString();

        if (eventData['date_timestamp'] != null) {
          _selectedDate =
              DateTime.fromMillisecondsSinceEpoch(eventData['date_timestamp']);
        }
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _deleteEvent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      if (widget.eventId != null) {
        await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .delete();
      } else {
        final eventQuery = await FirebaseFirestore.instance
            .collection('events')
            .where('createdBy', isEqualTo: user.uid)
            .get();

        if (eventQuery.docs.isNotEmpty) {
          await eventQuery.docs.first.reference.delete();
        }
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ExploreScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete event')),
      );
    }
  }

  Future<void> _submitEvent() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      setState(() => _isLoading = true);
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        final eventDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
        );

        final eventData = {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'city': _cityController.text,
          'location': _locationController.text,
          'date': _dateController.text,
          'time': _timeController.text,
          'contactNumber': _contactNumberController.text,
          'date_timestamp': eventDate.millisecondsSinceEpoch,
          'createdBy': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'capacity': int.parse(_capacityController.text),
          'currentAttendees':
              widget.isEditing ? null : 0, // Initialize for new events
        };

        if (widget.isEditing && widget.eventId != null) {
          // Update existing event
          await FirebaseFirestore.instance
              .collection('events')
              .doc(widget.eventId)
              .update(eventData);
        } else {
          // Create new event
          await FirebaseFirestore.instance.collection('events').add(eventData);
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ExploreScreen()),
        );
      } catch (e) {
        print('Error submitting event: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save event')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF5D7BD5)),
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ExploreScreen()),
                    ),
                  ),
                  Text(
                    widget.isEditing ? 'Edit Event' : 'Host Event',
                    style: GoogleFonts.quicksand(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFA873E8),
                    ),
                  ),
                  if (widget.isEditing) ...[
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              'Delete Event',
                              style: GoogleFonts.quicksand(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              'Are you sure you want to delete this event?',
                              style: GoogleFonts.quicksand(),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.quicksand(),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteEvent();
                                },
                                child: Text(
                                  'Delete',
                                  style: GoogleFonts.quicksand(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(_titleController,
                        'Give title to your Event', Icons.title),
                    _buildTextField(_descriptionController,
                        'Enter event details', Icons.description),
                    _buildTextField(
                        _cityController, 'Enter city', Icons.location_city),
                    _buildTextField(_locationController,
                        'Enter detailed location', Icons.map),
                    _buildDateField(context),
                    _buildTextField(_timeController,
                        'Set the event time (HH:MM AM/PM)', Icons.access_time),
                    _buildTextField(_contactNumberController,
                        'Enter your contact number', Icons.phone),
                    _buildTextField(_capacityController,
                        'Enter maximum capacity', Icons.group),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA873E8),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        widget.isEditing ? 'Update Event' : 'Host Event',
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (widget.isEditing) ...[
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AttendeeListScreen(eventId: widget.eventId!),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5D7BD5),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          'See Attendees',
                          style: GoogleFonts.quicksand(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: _dateController,
        readOnly: true,
        onTap: () => _selectDate(context),
        decoration: InputDecoration(
          labelText: 'Set the event date',
          labelStyle: GoogleFonts.quicksand(
            color: const Color(0xFF5D7BD5),
          ),
          prefixIcon:
              Icon(Icons.calendar_today, color: const Color(0xFFA873E8)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a date';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.quicksand(
            color: const Color(0xFF5D7BD5),
          ),
          prefixIcon: Icon(icon, color: const Color(0xFFA873E8)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
