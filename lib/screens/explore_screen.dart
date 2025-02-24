import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../screens/events_nearby_screen.dart';
import '../screens/host_event_screen.dart';
import '../screens/kids_marketplace_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/scheduler_screen.dart';
import '../screens/curio_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _selectedIndex = 1;
  String? _selectedCity;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> indianCities = [
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Ahmedabad',
    'Jaipur',
    'Lucknow'
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedCity();
    _cleanupPastEvents();
  }

  Future<void> _cleanupPastEvents() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final QuerySnapshot eventsToDelete = await _firestore
        .collection('events')
        .where('date_timestamp', isLessThan: today.millisecondsSinceEpoch)
        .get();

    for (var doc in eventsToDelete.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> _loadSelectedCity() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _selectedCity = doc.data()?['selectedCity'];
        });
      }
    }
  }

  Future<void> _saveSelectedCity(String city) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'selectedCity': city,
      });
    }
  }

  void _navigateToScreen(int index) {
    if (index == _selectedIndex) return;

    Widget screen;
    switch (index) {
      case 0:
        screen = const HomeScreen();
        break;
      case 2:
        screen = const SchedulerScreen();
        break;
      case 3:
        screen = ProfileScreen(
          onReturn: () => setState(() => _selectedIndex = 1),
          previousScreen: 'explore',
        );
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: _buildChatbotButton(),
      bottomNavigationBar: _buildBottomNavBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildCitySelector(),
              _buildEventsSection(),
              _buildKidsMarketplaceSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        'Explore',
        style: GoogleFonts.quicksand(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFA873E8),
        ),
      ),
    );
  }

  Widget _buildCitySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select City',
            style: GoogleFonts.quicksand(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5D7BD5),
            ),
          ),
          const SizedBox(height: 10),
          DropdownSearch<String>(
            popupProps: const PopupProps.menu(
              showSelectedItems: true,
              showSearchBox: true,
            ),
            items: indianCities,
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFF5D7BD5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFF5D7BD5)),
                ),
              ),
            ),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() => _selectedCity = newValue);
                _saveSelectedCity(newValue);
              }
            },
            selectedItem: _selectedCity,
          ),
        ],
      ),
    );
  }

  Widget _buildEventsSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventsSectionHeader(),
          const SizedBox(height: 10),
          _buildEventsSectionContent(),
        ],
      ),
    );
  }

  Widget _buildEventsSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Events Nearby',
          style: GoogleFonts.quicksand(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5D7BD5),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  EventsNearbyScreen(selectedCity: _selectedCity ?? ''),
            ),
          ),
          child: Text(
            'Show More',
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFA873E8),
            ),
          ),
        ),
      ],
    );
  }

  // In explore_screen.dart - Update _buildEventsSectionContent()
  Widget _buildEventsSectionContent() {
    if (_selectedCity == null) {
      return _buildNoEventsContent();
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .where('city', isEqualTo: _selectedCity)
          .where('date_timestamp',
              isGreaterThanOrEqualTo: today.millisecondsSinceEpoch)
          .orderBy('date_timestamp')
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Center(child: Text('Error loading events'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildNoEventsContent();
        }

        final events = snapshot.data!.docs;
        final user = FirebaseAuth.instance.currentUser;
        bool hasCreatedEvents = false;
        String? userEventId;

        // Check if user has created any events
        if (user != null) {
          for (var event in events) {
            final data = event.data() as Map<String, dynamic>;
            if (data['createdBy'] == user.uid) {
              hasCreatedEvents = true;
              userEventId = event.id;
              break;
            }
          }
        }

        return Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                final data = event.data() as Map<String, dynamic>;
                return _buildEventCard(event);
              },
            ),
            const SizedBox(height: 20),
            _buildHostEventButton(),
            if (hasCreatedEvents) ...[
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HostEventScreen(
                      isEditing: true,
                      eventId: userEventId,
                    ),
                  ),
                ),
                child: Text(
                  'Edit your event',
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    color: const Color(0xFF5D7BD5),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildNoEventsContent() {
    return Column(
      children: [
        Text(
          'No events available in $_selectedCity. Try hosting one!',
          style: GoogleFonts.quicksand(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 15),
        _buildHostEventButton(),
      ],
    );
  }

  Widget _buildHostEventButton() {
    return ElevatedButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HostEventScreen()),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFA873E8),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
        'Host Event',
        style: GoogleFonts.quicksand(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildEventCard(DocumentSnapshot event) {
    final data = event.data() as Map<String, dynamic>;

    // Safely access the timestamp with a default value
    final timestamp =
        data['date_timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch;
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);

    final formattedDate = DateFormat('dd').format(date);
    final formattedMonth = DateFormat('MMM').format(date);

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                EventsNearbyScreen(selectedCity: _selectedCity ?? ''),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
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
                      data['title']?.toString() ?? 'Untitled Event',
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5D7BD5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Color(0xFFA873E8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${data['location']?.toString() ?? 'Unknown'}, ${data['city']?.toString() ?? ''}',
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
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

  Widget _buildKidsMarketplaceSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KidsMarketplaceScreen()),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF5D7BD5), Color(0xFFA873E8)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5D7BD5).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  Icons.shopping_bag_rounded,
                  size: 100,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.storefront_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Kids Marketplace',
                          style: GoogleFonts.quicksand(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Discover amazing products for your kids - toys, books, educational items, and more!',
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Shop Now',
                            style: GoogleFonts.quicksand(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF5D7BD5),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Color(0xFF5D7BD5),
                            size: 20,
                          ),
                        ],
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

  Widget _buildBottomNavBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.home_rounded, 'Home'),
          _buildNavItem(1, Icons.explore_rounded, 'Explore'),
          _buildNavItem(2, Icons.schedule_rounded, 'Schedule'),
          _buildNavItem(3, Icons.person_rounded, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _navigateToScreen(index),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFA873E8) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF5D7BD5),
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.quicksand(
                color: isSelected ? Colors.white : const Color(0xFF5D7BD5),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatbotButton() {
    return FloatingActionButton(
      backgroundColor: const Color(0xFFA873E8),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CurioScreen()),
        );
      },
      child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
    );
  }
}
