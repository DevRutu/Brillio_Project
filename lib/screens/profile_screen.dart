import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'edit_profile_screen.dart';
import '../screens/signin_screen.dart';
import '../screens/home_screen.dart';
import '../screens/explore_screen.dart';
import '../screens/scheduler_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onReturn;
  final String previousScreen; // Add this to track where we came from
  
  const ProfileScreen({
    super.key,
    required this.onReturn,
    required this.previousScreen, // Add this parameter
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<DocumentSnapshot> _userStream;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      _userStream = _firestore.collection('users').doc(user.uid).snapshots();
    }
  }

  String _getBadgeIcon(String badge) {
    switch (badge.toLowerCase()) {
      case 'gold':
        return '🏆';
      case 'silver':
        return '🥈';
      case 'bronze':
        return '🥉';
      default:
        return '🎯';
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SignInScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error signing out. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleBackNavigation() {
    widget.onReturn();
    
    // Navigate based on the previous screen
    Widget targetScreen;
    switch (widget.previousScreen) {
      case 'home':
        targetScreen = const HomeScreen();
        break;
      case 'explore':
        targetScreen = const ExploreScreen();
        break;
      case 'scheduler':
        targetScreen = const SchedulerScreen();
        break;
      default:
        targetScreen = const HomeScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleBackNavigation();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream: _userStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }

              final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
              
              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildProfileSection(userData),
                    _buildScoreBadge(userData),
                    const Divider(
                      color: Color(0xFFEEEEEE),
                      thickness: 1,
                      indent: 20,
                      endIndent: 20,
                    ),
                    _buildMenuItems(userData),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF5D7BD5)),
            onPressed: _handleBackNavigation,
          ),
          Text(
            'Profile',
            style: GoogleFonts.quicksand(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5D7BD5),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildProfileSection(Map<String, dynamic> userData) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 60,
          backgroundColor: Color(0xFFA873E8),
          backgroundImage: AssetImage('assets/profile_images/profile_pic.jpg'),
        ),
        const SizedBox(height: 16),
        Text(
          userData['name'] ?? 'User Name',
          style: GoogleFonts.quicksand(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5D7BD5),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreBadge(Map<String, dynamic> userData) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                _getBadgeIcon(userData['badge'] ?? 'bronze'),
                style: const TextStyle(fontSize: 32),
              ),
              Text(
                userData['badge']?.toUpperCase() ?? 'BRONZE',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5D7BD5),
                ),
              ),
            ],
          ),
          Container(
            width: 2,
            height: 50,
            color: const Color(0xFFEEEEEE),
          ),
          Column(
            children: [
              Text(
                '${userData['score'] ?? 0}',
                style: GoogleFonts.quicksand(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFA873E8),
                ),
              ),
              Text(
                'POINTS',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  color: const Color(0xFF5D7BD5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(Map<String, dynamic> userData) {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.edit,
          title: 'Edit Profile',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditProfileScreen(
                  isInitialSetup: false,
                  userData: userData,
                ),
              ),
            );
          },
        ),
        _buildMenuItem(
          icon: Icons.email,
          title: 'Change Email',
          onTap: () {
            // TODO: Implement email change
          },
        ),
        _buildMenuItem(
          icon: Icons.help,
          title: 'Help & Support',
          onTap: () {
            // TODO: Implement help & support
          },
        ),
        _buildMenuItem(
          icon: Icons.logout,
          title: 'Logout',
          onTap: _signOut,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : const Color(0xFFA873E8),
      ),
      title: Text(
        title,
        style: GoogleFonts.quicksand(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : const Color(0xFF5D7BD5),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: isDestructive ? Colors.red : const Color(0xFFA873E8),
        size: 16,
      ),
      onTap: onTap,
    );
  }
}