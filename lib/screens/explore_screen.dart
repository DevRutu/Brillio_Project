import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_animate/flutter_animate.dart';
import './profile_screen.dart';
import './home_screen.dart';
import '../screens/scheduler_screen.dart';


class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _selectedIndex = 1; // Set to 1 since this is the Explore tab

  final List<String> indianCities = [
    'Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Chennai',
    'Kolkata', 'Pune', 'Ahmedabad', 'Jaipur', 'Lucknow'
  ];

  final List<Map<String, dynamic>> events = [
    {
      'title': 'Kids Art Festival',
      'city': 'Mumbai',
      'image': 'assets/activity_images/creative.jpg',
    },
    {
      'title': 'Science Exhibition',
      'city': 'Delhi',
      'image': 'assets/activity_images/education.jpg',
    },
    {
      'title': 'Story Telling Workshop',
      'city': 'Bangalore',
      'image': 'assets/activity_images/knowledge.jpg',
    },
  ];

  final List<Map<String, dynamic>> coachings = [
    {
      'title': 'Little Champs Cricket Academy',
      'city': 'Mumbai',
      'image': 'assets/activity_images/physical.jpg',
    },
    {
      'title': 'Harmony Music School',
      'city': 'Delhi',
      'image': 'assets/activity_images/creative.jpg',
    },
    {
      'title': 'Dance Buddies',
      'city': 'Bangalore',
      'image': 'assets/activity_images/social.jpg',
    },
  ];

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
              _buildMap(),
              _buildEventsSection(),
              _buildCoachingsSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              // Handle city selection
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF5D7BD5)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: FlutterMap(
            options: MapOptions(
              center: LatLng(20.5937, 78.9629), // Center of India
              zoom: 4,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Events Nearby',
            style: GoogleFonts.quicksand(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5D7BD5),
            ),
          ),
          const SizedBox(height: 15),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, index) => _buildEventCard(events[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            // Handle event tap
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    event['image'],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'],
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
                            '${event['city']}, India',
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
      ),
    );
  }

  Widget _buildCoachingsSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Coachings',
            style: GoogleFonts.quicksand(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5D7BD5),
            ),
          ),
          const SizedBox(height: 15),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: coachings.length,
            itemBuilder: (context, index) => _buildEventCard(coachings[index]),
          ),
        ],
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
            color: const Color.fromARGB(255, 210, 210, 210).withOpacity(0.2),
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
      onTap: () {
        setState(() => _selectedIndex = index);
        
        switch (index) {
          case 0: // Home tab
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HomeScreen(),
              ),
            );
            break;
          case 2: // Schedule tab
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SchedulerScreen(),
              ),
            ).then((_) {
              setState(
                  () => _selectedIndex = 0); // Reset to home when returning
            });
            break;
          case 3: // Profile tab
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(
                  onReturn: () {},
                  previousScreen: 'explore', // Reset to explore when returnin
                ),
              ),
            );
            break;
        }
      },
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
      ).animate(
        target: isSelected ? 1 : 0,
      ).scale(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        begin: const Offset(1, 1),
        end: const Offset(1.05, 1.05),
      ),
    );
  }

  Widget _buildChatbotButton() {
    return FloatingActionButton(
      backgroundColor: const Color(0xFFA873E8),
      child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      onPressed: () {
        // Navigate to chatbot screen
        // Navigator.push(context, MaterialPageRoute(builder: (_) => ChatbotScreen()));
      },
    );
  }
}