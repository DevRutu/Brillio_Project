import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'activity_list_screen.dart';

class SubcategoryScreen extends StatefulWidget {
  final String categoryName;

  const SubcategoryScreen({
    Key? key,
    required this.categoryName,
  }) : super(key: key);

  @override
  _SubcategoryScreenState createState() => _SubcategoryScreenState();
}

class _SubcategoryScreenState extends State<SubcategoryScreen> {
  final List<String> ageGroups = ['1-3', '3-5', '5-7'];
  String selectedAgeGroup = '1-3'; // Default age group
  bool isLoading = true;
  List<Map<String, dynamic>> subcategories = [];

  @override
  void initState() {
    super.initState();
    _loadSavedAgeGroup();
  }

  Future<void> _loadSavedAgeGroup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAgeGroup = prefs.getString('selectedAgeGroup');
      if (savedAgeGroup != null) {
        setState(() {
          selectedAgeGroup = savedAgeGroup;
        });
      }
      _loadSubcategories();
    } catch (e) {
      print('Error loading saved age group: $e');
      _loadSubcategories();
    }
  }

  Future<void> _saveAgeGroup(String ageGroup) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedAgeGroup', ageGroup);
    } catch (e) {
      print('Error saving age group: $e');
    }
  }

  void _loadSubcategories() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Map from UI category name to Firestore category name
      Map<String, String> categoryMapping = {
        'BrainQuest': 'Brainquest',
        'MindCraft': 'Mindcraft',
        'Explorer': 'Explorer',
        'ArtSpark': 'Artspark',
        'EmoGrow': 'Emogrow',
        'Outdoor': 'Outdoor', // Assuming there's an Outdoor category in Firestore
      };

      String firestoreCategoryName = categoryMapping[widget.categoryName] ?? widget.categoryName;
      
      // Find the category document
      QuerySnapshot categorySnapshot = await FirebaseFirestore.instance
          .collection('activities')
          .doc(selectedAgeGroup)
          .collection('categories')
          .where('name', isEqualTo: firestoreCategoryName)
          .get();

      if (categorySnapshot.docs.isEmpty) {
        setState(() {
          isLoading = false;
          subcategories = [];
        });
        return;
      }

      // Get subcategories for this category
      QuerySnapshot subcategorySnapshot = await FirebaseFirestore.instance
          .collection('activities')
          .doc(selectedAgeGroup)
          .collection('categories')
          .doc(categorySnapshot.docs.first.id)
          .collection('subcategories')
          .get();

      List<Map<String, dynamic>> loadedSubcategories = subcategorySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'categoryId': categorySnapshot.docs.first.id,
        };
      }).toList();

      setState(() {
        subcategories = loadedSubcategories;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading subcategories: $e');
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
          widget.categoryName,
          style: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5D7BD5),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildAgeFilter(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFA873E8)))
                : subcategories.isEmpty
                    ? Center(
                        child: Text(
                          'No subcategories found',
                          style: GoogleFonts.quicksand(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : _buildSubcategoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Age Group',
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5D7BD5),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: ageGroups.map((ageGroup) {
              final isSelected = selectedAgeGroup == ageGroup;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedAgeGroup = ageGroup;
                  });
                  _saveAgeGroup(ageGroup);
                  _loadSubcategories();
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFA873E8) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFA873E8) : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    '$ageGroup years',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: subcategories.length,
      itemBuilder: (context, index) {
        final subcategory = subcategories[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ActivitiesScreen(
                  subcategoryName: subcategory['name'],
                  categoryId: subcategory['categoryId'],
                  subcategoryId: subcategory['id'],
                  ageGroup: selectedAgeGroup,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF5D7BD5),
                  const Color(0xFFA873E8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5D7BD5).withOpacity(0.2),
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
                    Icons.blur_circular,
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
                    subcategory['name'],
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  trailing: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF5D7BD5),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ).animate(delay: Duration(milliseconds: index * 100))
            .fadeIn(duration: const Duration(milliseconds: 300))
            .slideY(begin: 0.2, end: 0, duration: const Duration(milliseconds: 300)),
        );
      },
    );
  }
}