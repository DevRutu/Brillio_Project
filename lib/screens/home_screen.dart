import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import '../screens/profile_screen.dart';
import '../screens/explore_screen.dart';
import '../screens/scheduler_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Map<String, String>> categoryCards = [
    {
      'title': 'BrainQuest',
      'description': 'Exciting puzzles and mental challenges',
      'image': 'assets/activity_images/education.jpg',
      'category': 'Education'
    },
    {
      'title': 'MindCraft',
      'description': 'Build logical thinking skills',
      'image': 'assets/activity_images/logic.jpg',
      'category': 'Logic Building'
    },
    {
      'title': 'Explorer',
      'description': 'Discover the world around you',
      'image': 'assets/activity_images/knowledge.jpg',
      'category': 'General Knowledge'
    },
    {
      'title': 'Outdoor',
      'description': 'Fun physical activities and sports',
      'image': 'assets/activity_images/physical.jpg',
      'category': 'Physical Activity'
    },
    {
      'title': 'ArtSpark',
      'description': 'Express yourself through art',
      'image': 'assets/activity_images/creative.jpg',
      'category': 'Creative Arts'
    },
    {
      'title': 'EmoGrow',
      'description': 'Develop emotional intelligence',
      'image': 'assets/activity_images/social.jpg',
      'category': 'Social Skills'
    },
  ];

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
              _buildDailyActivity(),
              _buildCategorySection(),
              const SizedBox(height: 30),
              _buildTopPicks(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text(
        'Discover',
        style: GoogleFonts.quicksand(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFA873E8),
        ),
      ),
    );
  }

  Widget _buildDailyActivity() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Activity',
            style: GoogleFonts.quicksand(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5D7BD5),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
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
                  right: -15,
                  top: -15,
                  child: Icon(
                    Icons.explore,
                    size: 80,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nature Scavenger Hunt',
                              style: GoogleFonts.quicksand(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Explore nature and find hidden treasures in your backyard',
                              style: GoogleFonts.quicksand(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 12),
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
                                    'Start Activity',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF5D7BD5),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Color(0xFF5D7BD5),
                                    size: 16,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Creative Corner',
            style: GoogleFonts.quicksand(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5D7BD5),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: categoryCards.length,
            itemBuilder: (context, index) {
              return _buildCategoryCard(categoryCards[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, String> category, int index) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage(category['image']!),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.25), // Reduced darkness from 0.4 to 0.25
                BlendMode.darken,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  category['title']!,
                  style: GoogleFonts.quicksand(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category['description']!,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ).animate(delay: Duration(milliseconds: index * 100))
        .fadeIn(duration: const Duration(milliseconds: 300))
        .slideY(begin: 0.2, end: 0, duration: const Duration(milliseconds: 300)),
    );
  }

  Widget _buildTopPicks() {
    final List<Map<String, String>> activities = [
      {
        'title': 'DIY Science Experiments',
        'description': 'Learn basic science concepts through fun experiments'
      },
      {
        'title': 'Story Time Adventure',
        'description': 'Interactive storytelling with creative exercises'
      },
      {
        'title': 'Math Magic Games',
        'description': 'Fun ways to practice basic mathematics'
      },
    ];

    // Darker gradient colors to improve text contrast
    final List<List<Color>> gradientColors = [
      [
        const Color(0xFFFF6B8B), // Darker pink/red
        const Color(0xFFE05C7F), // Darker salmon
      ],
      [
        const Color(0xFF4CD280), // Darker green
        const Color(0xFF28A55F), // Darker teal
      ],
      [
        const Color(0xFF7A93D8), // Darker blue
        const Color(0xFFB772D9), // Darker purple
      ],
    ];

    // More generic icons that would work for any activity type
    final List<IconData> activityIcons = [
      Icons.lightbulb_outline, // Generic "idea" icon
      Icons.emoji_events_outlined, // Generic "achievement" icon
      Icons.extension_outlined, // Generic "puzzle piece" icon for any activity
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Top Picks For You',
            style: GoogleFonts.quicksand(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5D7BD5),
            ),
          ),
        ),
        const SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 15),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors[index],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    // Background pattern for added visual interest
                    Positioned(
                      right: -15,
                      top: -15,
                      child: Icon(
                        Icons.stars, // Generic icon for all activities
                        size: 70,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      title: Text(
                        activities[index]['title']!,
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          // Add a slight text shadow for better contrast
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          activities[index]['description']!,
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            color: Colors.white,
                            // Add a slight text shadow for better contrast
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(0, 1),
                                blurRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: gradientColors[index][0],
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate(delay: Duration(milliseconds: index * 150))
              .fadeIn(duration: const Duration(milliseconds: 300))
              .slideX(begin: 0.2, end: 0, duration: const Duration(milliseconds: 300));
          },
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
      onTap: () {
        setState(() => _selectedIndex = index);

        // Handle navigation based on index
        switch (index) {
          case 1: // Explore tab
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ExploreScreen(),
              ),
            ).then((_) {
              setState(() => _selectedIndex = 0); // Reset to home when returning
            });
            break;
          case 2: // Schedule tab
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SchedulerScreen(),
              ),
            ).then((_) {
              setState(() => _selectedIndex = 0); // Reset to home when returning
            });
            break;
          case 3: // Profile tab
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(
                  onReturn: () {
                    setState(() => _selectedIndex = 0); // Reset to home when returning
                  },
                  previousScreen: 'home',
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
      ).animate(target: isSelected ? 1 : 0)
        .scale(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
        ),
    );
  }
}