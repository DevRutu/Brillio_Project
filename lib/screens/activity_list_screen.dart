import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'activity_detail_screen.dart';

class ActivitiesScreen extends StatefulWidget {
  final String subcategoryName;
  final String categoryId;
  final String subcategoryId;
  final String ageGroup;

  const ActivitiesScreen({
    Key? key,
    required this.subcategoryName,
    required this.categoryId,
    required this.subcategoryId,
    required this.ageGroup,
  }) : super(key: key);

  @override
  _ActivitiesScreenState createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> activities = [];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  void _loadActivities() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get activities for this subcategory
      QuerySnapshot activitiesSnapshot = await FirebaseFirestore.instance
          .collection('activities')
          .doc(widget.ageGroup)
          .collection('categories')
          .doc(widget.categoryId)
          .collection('subcategories')
          .doc(widget.subcategoryId)
          .collection('activities')
          .get();

      List<Map<String, dynamic>> loadedActivities = activitiesSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'title': doc['title'],
          'description': doc['description'],
          'image_url': doc['image_url'],
        };
      }).toList();

      setState(() {
        activities = loadedActivities;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading activities: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF5D7BD5)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.subcategoryName,
          style: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5D7BD5),
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFA873E8)))
          : activities.isEmpty
              ? Center(
                  child: Text(
                    'No activities found',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              : _buildActivitiesList(),
    );
  }

  Widget _buildActivitiesList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivityDetailScreen(
                    activity: activity,
                    subcategoryName: widget.subcategoryName,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      color: const Color(0xFFE8F0FE),
                      child: Center(
                        child: Icon(
                          Icons.photo,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['title'],
                          style: GoogleFonts.quicksand(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF5D7BD5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          activity['description'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF5D7BD5),
                                    Color(0xFFA873E8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Explore',
                                style: GoogleFonts.quicksand(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate(delay: Duration(milliseconds: index * 100))
                .fadeIn(duration: const Duration(milliseconds: 300))
                .slideY(begin: 0.2, end: 0, duration: const Duration(milliseconds: 300)),
          );
        },
      ),
    );
  }
}