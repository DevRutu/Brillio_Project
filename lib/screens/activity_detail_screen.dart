import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ActivityDetailScreen extends StatefulWidget {
  final Map<String, dynamic> activity;
  final String subcategoryName;

  const ActivityDetailScreen({
    Key? key,
    required this.activity,
    required this.subcategoryName,
  }) : super(key: key);

  @override
  _ActivityDetailScreenState createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: _buildContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF5D7BD5),
                    Color(0xFFA873E8),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getActivityIcon(),
                      size: 70,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.activity['title'],
                      style: GoogleFonts.quicksand(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 30,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Color(0xFF5D7BD5)),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : const Color(0xFF5D7BD5),
            ),
          ),
          onPressed: () {
            setState(() {
              isFavorite = !isFavorite;
            });
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FD),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  widget.subcategoryName,
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D7BD5),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(duration: const Duration(milliseconds: 400)),
          const SizedBox(height: 24),
          Text(
            'Description',
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5D7BD5),
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 500)),
          const SizedBox(height: 12),
          Text(
            widget.activity['description'],
            style: GoogleFonts.quicksand(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 600)),
          const SizedBox(height: 32),
          _buildTipsSection(),
          const SizedBox(height: 32),
          _buildBenefitsSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    final tips = [
      'Start with simple steps and gradually increase difficulty',
      'Make it fun by adding your own creative twists',
      'Praise effort rather than results',
      'Take breaks if your child loses interest',
      'Repeat the activity on different days to reinforce learning'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tips for Parents',
          style: GoogleFonts.quicksand(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5D7BD5),
          ),
        ).animate().fadeIn(duration: const Duration(milliseconds: 700)),
        const SizedBox(height: 12),
        ...tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFFA873E8),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tip,
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
      ],
    ).animate().fadeIn(duration: const Duration(milliseconds: 800));
  }

  Widget _buildBenefitsSection() {
    final benefits = _getBenefits();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Benefits',
          style: GoogleFonts.quicksand(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5D7BD5),
          ),
        ).animate().fadeIn(duration: const Duration(milliseconds: 900)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: benefits.map((benefit) => Chip(
                label: Text(
                  benefit,
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    color: const Color(0xFF5D7BD5),
                  ),
                ),
                backgroundColor: const Color(0xFFF0F4FD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              )).toList(),
        ),
      ],
    ).animate().fadeIn(duration: const Duration(milliseconds: 1000));
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF5D7BD5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: const BorderSide(color: Color(0xFF5D7BD5)),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.share, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Share',
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D7BD5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bookmark, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Save',
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon() {
    if (widget.subcategoryName.contains('Sensory')) {
      return Icons.touch_app;
    } else if (widget.subcategoryName.contains('Creative')) {
      return Icons.brush;
    } else if (widget.subcategoryName.contains('Learning')) {
      return Icons.school;
    } else if (widget.subcategoryName.contains('Problem')) {
      return Icons.psychology;
    } else if (widget.subcategoryName.contains('Nature')) {
      return Icons.nature;
    } else if (widget.subcategoryName.contains('Science')) {
      return Icons.science;
    } else if (widget.subcategoryName.contains('Craft')) {
      return Icons.color_lens;
    } else if (widget.subcategoryName.contains('Play')) {
      return Icons.toys;
    } else if (widget.subcategoryName.contains('Emotion')) {
      return Icons.favorite;
    } else if (widget.subcategoryName.contains('Social')) {
      return Icons.people;
    } else {
      return Icons.star;
    }
  }

  List<String> _getBenefits() {
    if (widget.subcategoryName.contains('Sensory')) {
      return ['Sensory Development', 'Fine Motor Skills', 'Tactile Exploration', 'Brain Development'];
    } else if (widget.subcategoryName.contains('Learning')) {
      return ['Cognitive Development', 'Language Skills', 'Knowledge Building', 'Memory Enhancement'];
    } else if (widget.subcategoryName.contains('Creative')) {
      return ['Imagination', 'Creative Thinking', 'Self-Expression', 'Problem Solving'];
    } else if (widget.subcategoryName.contains('Problem')) {
      return ['Logical Thinking', 'Spatial Awareness', 'Critical Thinking', 'Patience'];
    } else if (widget.subcategoryName.contains('Nature')) {
      return ['Environmental Awareness', 'Natural Curiosity', 'Outdoor Learning', 'Exploration'];
    } else if (widget.subcategoryName.contains('Science')) {
      return ['Scientific Thinking', 'Cause and Effect', 'Observation Skills', 'Curiosity'];
    } else if (widget.subcategoryName.contains('Craft')) {
      return ['Fine Motor Skills', 'Creativity', 'Attention to Detail', 'Self-Expression'];
    } else if (widget.subcategoryName.contains('Play')) {
      return ['Social Skills', 'Creativity', 'Emotional Development', 'Fun Learning'];
    } else if (widget.subcategoryName.contains('Emotion')) {
      return ['Emotional Intelligence', 'Self-Awareness', 'Emotional Regulation', 'Empathy'];
    } else if (widget.subcategoryName.contains('Social')) {
      return ['Social Skills', 'Communication', 'Taking Turns', 'Empathy'];
    } else {
      return ['Child Development', 'Fun Learning', 'Engagement', 'Skill Building'];
    }
  }
}