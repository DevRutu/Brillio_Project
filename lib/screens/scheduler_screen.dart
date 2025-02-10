import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'explore_screen.dart';

class SchedulerScreen extends StatefulWidget {
  final Function()? onReturn;
  
  const SchedulerScreen({Key? key, this.onReturn}) : super(key: key);

  @override
  _SchedulerScreenState createState() => _SchedulerScreenState();
}

class _SchedulerScreenState extends State<SchedulerScreen> {
  int _selectedIndex = 2; // Since Scheduler is the third tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildScheduleHeader(),
              _buildEditButton(),
              _buildScheduleSection('Morning', _morningTasks),
              _buildScheduleSection('Afternoon', _afternoonTasks),
              _buildScheduleSection('Evening', _eveningTasks),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    String currentDate = DateFormat('MMMM d, yyyy').format(DateTime.now());
    
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Scheduler',
            style: GoogleFonts.quicksand(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFA873E8),
            ),
          ),
          Text(
            currentDate,
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF5D7BD5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Your Schedule',
            style: GoogleFonts.quicksand(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5D7BD5),
            ),
          ),
          Text(
            '7 am - 9 pm',
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF5D7BD5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton.icon(
        onPressed: () {
          // Add edit schedule functionality here
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Edit Schedule functionality coming soon!',
                style: GoogleFonts.quicksand(),
              ),
              backgroundColor: const Color(0xFFA873E8),
            ),
          );
        },
        icon: const Icon(Icons.edit_calendar, size: 24),
        label: Text(
          'Edit Schedule',
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA873E8),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> _morningTasks = [
    {'time': '6:30 am', 'task': 'Wake up and get ready', 'completed': true},
    {'time': '7:00 am', 'task': 'Do yoga and meditation', 'completed': true},
    {'time': '7:30 am', 'task': 'Have breakfast', 'completed': true},
    {'time': '8:00 am', 'task': 'Go to school', 'completed': true},
  ];

  final List<Map<String, dynamic>> _afternoonTasks = [
    {'time': '2:00 pm', 'task': 'Back from school', 'completed': true},
    {'time': '2:30 pm', 'task': 'Lunch time', 'completed': false},
    {'time': '3:30 pm', 'task': 'Homework time', 'completed': false},
  ];

  final List<Map<String, dynamic>> _eveningTasks = [
    {'time': '5:00 pm', 'task': 'Outdoor play time', 'completed': false},
    {'time': '7:00 pm', 'task': 'Dinner time', 'completed': false},
    {'time': '8:30 pm', 'task': 'Reading time', 'completed': false},
    {'time': '9:00 pm', 'task': 'Time to get to bed', 'completed': false},
  ];

  Widget _buildScheduleSection(String title, List<Map<String, dynamic>> tasks) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5D7BD5),
            ),
          ),
          const SizedBox(height: 10),
          ...tasks.map((task) => _buildTaskItem(task)).toList(),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFC2FFEE),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            task['completed'] ? Icons.check_circle : Icons.access_time,
            color: task['completed'] ? Colors.green : const Color(0xFF5D7BD5),
          ),
        ),
        title: Text(
          task['task'],
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF5D7BD5),
          ),
        ),
        trailing: Text(
          task['time'],
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
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
        
        // Handle navigation based on index
        switch (index) {
          case 0: // Home tab
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
            break;
          case 1: // Explore tab
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ExploreScreen()),
            );
            break;
          case 3: // Profile tab
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(
                  onReturn: () {
                    setState(() => _selectedIndex = 2); // Reset to schedule when returning
                  },
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
}