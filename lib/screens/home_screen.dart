import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
      backgroundColor: const Color(0xFFF0F7FF),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Discover',
            style: GoogleFonts.quicksand(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF45C4E6),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Color(0xFF45C4E6),
              size: 32,
            ),
            padding: const EdgeInsets.all(8),
            onPressed: () {},
          ),
        ],
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
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              // Handle tap
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF45C4E6), Color(0xFFE668D9)],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF45C4E6).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nature Scavenger Hunt',
                          style: GoogleFonts.quicksand(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Explore nature and find hidden treasures in your backyard',
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
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
          padding: const EdgeInsets.all(20),
          child: Text(
            'Categories',
            style: GoogleFonts.quicksand(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: categoryCards.length,
            itemBuilder: (context, index) {
              return _buildCategoryCard(categoryCards[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, String> category) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            image: DecorationImage(
              image: AssetImage(category['image']!),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4),
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
                const SizedBox(height: 5),
                Text(
                  category['description']!,
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
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
      {
        'title': 'Art and Craft Session',
        'description': 'Create beautiful artwork using household items'
      },
      {
        'title': 'Music and Movement',
        'description': 'Dance and rhythm activities for kids'
      },
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
              color: Colors.black87,
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
            return InkWell(
              onTap: () {
                // Handle tap
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF45C4E6).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activities[index]['title']!,
                            style: GoogleFonts.quicksand(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            activities[index]['description']!,
                            style: GoogleFonts.quicksand(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: const Color(0xFF45C4E6),
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

Widget _buildBottomNavBar() {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF45C4E6).withOpacity(0.1),
            blurRadius: 10,
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
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF45C4E6), Color(0xFFE668D9)],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.quicksand(
                color: isSelected ? Colors.white : Colors.grey[600],
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