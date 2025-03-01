import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/explore_screen.dart';
import '../screens/schedule_form_screen.dart';
import '../screens/schedule_provider.dart';

class SchedulerScreen extends StatefulWidget {
  final Function()? onReturn;
  
  const SchedulerScreen({super.key, this.onReturn});

  @override
  _SchedulerScreenState createState() => _SchedulerScreenState();
}

class _SchedulerScreenState extends State<SchedulerScreen> {
  int _selectedIndex = 2; // Since Scheduler is the third tab
  bool _isFirstTime = true;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _checkFirstTimeUser();
    _initializeNotifications();
    
    // Subscribe to schedule updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
      scheduleProvider.loadSchedule();
    });
  }

  Future<void> _initializeNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: true,
    );
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
    
    tz.initializeTimeZones();
    
    // Schedule notifications based on tasks
    _scheduleNotifications();
  }

  Future<void> _scheduleNotifications() async {
    final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
    final allTasks = [
      ...scheduleProvider.morningTasks,
      ...scheduleProvider.afternoonTasks,
      ...scheduleProvider.eveningTasks,
    ];

    // Cancel all previous notifications
    await flutterLocalNotificationsPlugin.cancelAll();

    // Schedule new notifications for upcoming tasks
    for (var task in allTasks) {
      if (!task['completed']) {
        try {
          final timeString = task['time'];
          final taskName = task['task'];
          
          // Parse time (assuming format like "7:00 am")
          final timeParts = timeString.split(':');
          final hourMinParts = timeParts[1].split(' ');
          
          int hour = int.parse(timeParts[0]);
          int minute = int.parse(hourMinParts[0]);
          final amPm = hourMinParts[1].toLowerCase();
          
          // Convert to 24-hour format
          if (amPm == 'pm' && hour < 12) {
            hour += 12;
          } else if (amPm == 'am' && hour == 12) {
            hour = 0;
          }
          
          // Get current date
          final now = DateTime.now();
          final scheduledDate = DateTime(
            now.year, 
            now.month, 
            now.day, 
            hour, 
            minute
          );
          
          // Only schedule if the time is in the future
          if (scheduledDate.isAfter(now)) {
            final taskMessage = "It's time for your child's ${taskName.toLowerCase()}";
            
            await flutterLocalNotificationsPlugin.zonedSchedule(
              task.hashCode,
              'Schedule Reminder',
              taskMessage,
              tz.TZDateTime.from(scheduledDate, tz.local),
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'schedule_channel',
                  'Schedule Notifications',
                  channelDescription: 'Notifications for child activities',
                  importance: Importance.high,
                  priority: Priority.high,
                ),
                iOS: DarwinNotificationDetails(
                  presentSound: true,
                  presentBadge: true,
                  presentAlert: true,
                ),
              ),
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
            );
          }
        } catch (e) {
          debugPrint('Error scheduling notification: $e');
        }
      }
    }
  }

  Future<void> _checkFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSchedule = prefs.getBool('has_schedule') ?? false;
    
    setState(() {
      _isFirstTime = !hasSchedule;
    });
  }

  void _navigateToScheduleForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleFormScreen(
          isFirstTime: _isFirstTime,
          onScheduleCreated: () {
            _setHasSchedule();
            _scheduleNotifications();
          },
        ),
      ),
    );
  }

  Future<void> _setHasSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_schedule', true);
    
    setState(() {
      _isFirstTime = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isFirstTime 
          ? _buildFirstTimeView() 
          : _buildScheduleView(),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildFirstTimeView() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/vector_images/schedule_illustration1.png',
            height: 240,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 40),
          Text(
            'Create Your Child\'s Smart Schedule',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFA873E8),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Plan your child\'s day with healthy activities, outdoor play, and limited screen time. Our AI will help create a balanced schedule.',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _navigateToScheduleForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA873E8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
            ),
            child: Text(
              'Let\'s Get Started',
              style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleView() {
    return Consumer<ScheduleProvider>(
      builder: (context, scheduleProvider, child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildScheduleHeader(),
              _buildEditButton(),
              _buildScheduleSection('Morning', scheduleProvider.morningTasks),
              _buildScheduleSection('Afternoon', scheduleProvider.afternoonTasks),
              _buildScheduleSection('Evening', scheduleProvider.eveningTasks),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8FD),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              currentDate,
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5D7BD5),
              ),
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
            'Your Child\'s Day',
            style: GoogleFonts.quicksand(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5D7BD5),
            ),
          ),
          Consumer<ScheduleProvider>(
            builder: (context, scheduleProvider, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFA873E8).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  scheduleProvider.scheduleTimeRange,
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5D7BD5),
                  ),
                ),
              );
            }
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _navigateToScheduleForm,
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF5D7BD5),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5D7BD5).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
                scheduleProvider.toggleTaskCompletionMode();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      scheduleProvider.isTaskCompletionMode 
                          ? 'Tap on tasks to mark them as completed' 
                          : 'Task completion mode turned off',
                      style: GoogleFonts.quicksand(),
                    ),
                    backgroundColor: const Color(0xFF5D7BD5),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: Consumer<ScheduleProvider>(
                builder: (context, scheduleProvider, child) {
                  return Icon(
                    scheduleProvider.isTaskCompletionMode 
                        ? Icons.check_circle 
                        : Icons.check_circle_outline,
                    color: Colors.white,
                    size: 28,
                  );
                }
              ),
              tooltip: 'Toggle task completion mode',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(String title, List<Map<String, dynamic>> tasks) {
    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5FF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getSectionColor(title),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getSectionIcon(title),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.quicksand(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D7BD5),
                  ),
                ),
                const Spacer(),
                Text(
                  '${tasks.where((task) => task['completed'] == true).length}/${tasks.length}',
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5D7BD5),
                  ),
                ),
              ],
            ),
          ),
          ...tasks.map((task) => _buildTaskItem(task, title)),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Color _getSectionColor(String title) {
    switch (title) {
      case 'Morning':
        return const Color(0xFFFFAD87);
      case 'Afternoon':
        return const Color(0xFFFFC56D);
      case 'Evening':
        return const Color(0xFF8D94EB);
      default:
        return const Color(0xFFA873E8);
    }
  }

  IconData _getSectionIcon(String title) {
    switch (title) {
      case 'Morning':
        return Icons.wb_sunny_rounded;
      case 'Afternoon':
        return Icons.wb_cloudy_rounded;
      case 'Evening':
        return Icons.nightlight_round;
      default:
        return Icons.schedule_rounded;
    }
  }

  Widget _buildTaskItem(Map<String, dynamic> task, String section) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
    final bool isCompleted = task['completed'] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
      decoration: BoxDecoration(
        color: isCompleted 
            ? const Color(0xFFE8E8FD)
            : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: scheduleProvider.isTaskCompletionMode
            ? () {
                scheduleProvider.toggleTaskCompletion(section.toLowerCase(), task);
                _scheduleNotifications();
              }
            : null,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green.withOpacity(0.1)
                    : const Color(0xFFE8E8FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCompleted 
                    ? Icons.check_circle
                    : Icons.access_time,
                color: isCompleted 
                    ? Colors.green
                    : const Color(0xFF5D7BD5),
                size: 24,
              ),
            ),
            title: Text(
              task['task'],
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5D7BD5),
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green.withOpacity(0.1)
                    : const Color(0xFFA873E8).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                task['time'],
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isCompleted ? Colors.green : const Color(0xFFA873E8),
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate(
      effects: [
        if (!isCompleted && scheduleProvider.isTaskCompletionMode)
          ShimmerEffect(
            duration: const Duration(seconds: 2),
            delay: const Duration(seconds: 1),
          ),
      ],
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
            color: const Color(0xFFA873E8).withOpacity(0.1),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
            break;
          case 1: // Explore tab
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ExploreScreen()),
            );
            break;
          case 3: // Profile tab
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(
                  onReturn: () {},
                  previousScreen: 'scheduler',
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