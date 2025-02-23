import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final bool isInitialSetup;
  final Map<String, dynamic>? userData;

  const EditProfileScreen({
    super.key,
    required this.isInitialSetup,
    this.userData,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController _nameController;
  late TextEditingController _parentNameController;
  DateTime? _dateOfBirth;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeData();
      _isInitialized = true;
    }
  }

  void _initializeData() {
    _nameController = TextEditingController(text: widget.userData?['name'] ?? '');
    _parentNameController = TextEditingController(text: widget.userData?['parentName'] ?? '');
    _dateOfBirth = widget.userData?['dateOfBirth']?.toDate();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _parentNameController.dispose();
    super.dispose();
  }

  String _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age.toString();
  }

  Future<void> _selectDate() async {
    if (!mounted) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 5)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 17)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFA873E8),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF5D7BD5),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFA873E8),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _dateOfBirth && mounted) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate() && _dateOfBirth != null) {
      if (!mounted) return;
      
      setState(() => _isLoading = true);

      try {
        final user = _auth.currentUser;
        if (user != null) {
          final age = int.parse(_calculateAge(_dateOfBirth!));
          
          await _firestore.collection('users').doc(user.uid).set({
            'name': _nameController.text.trim(),
            'parentName': _parentNameController.text.trim(),
            'dateOfBirth': Timestamp.fromDate(_dateOfBirth!),
            'age': age,
            'profileImage': 'assets/profile_images/profile_pic.jpg',
            'profileCompleted': true,
            'score': widget.userData?['score'] ?? 0,
            'badge': widget.userData?['badge'] ?? 'bronze',
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          if (!mounted) return;

          if (widget.isInitialSetup) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          } else {
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } else if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date of birth'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.isInitialSetup)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF5D7BD5)),
                  onPressed: () => Navigator.pop(context),
                ),
              Text(
                widget.isInitialSetup ? 'Complete Your Profile' : 'Edit Profile',
                style: GoogleFonts.quicksand(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFA873E8),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFFA873E8),
                  backgroundImage: const AssetImage('assets/profile_images/profile_pic.jpg'),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEBC2FF).withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _parentNameController,
                        label: 'Parent\'s Name',
                        icon: Icons.family_restroom,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter parent\'s name';
                          }
                          if (value.length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Child\'s Name',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter child\'s name';
                          }
                          if (value.length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildDatePicker(),
                      const SizedBox(height: 30),
                      if (_isLoading)
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA873E8)),
                        )
                      else
                        ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA873E8),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            'Save Profile',
                            style: GoogleFonts.quicksand(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.quicksand(
          color: const Color(0xFF5D7BD5),
        ),
        prefixIcon: Icon(icon, color: const Color(0xFFA873E8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFF56D1DC),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFF56D1DC),
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        errorStyle: GoogleFonts.quicksand(
          color: Colors.red,
        ),
      ),
      style: GoogleFonts.quicksand(
        color: const Color(0xFF5D7BD5),
        fontSize: 16,
      ),
      validator: validator,
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF56D1DC)),
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFFA873E8)),
            const SizedBox(width: 12),
            Text(
              _dateOfBirth == null
                  ? 'Select Date of Birth'
                  : '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
              style: GoogleFonts.quicksand(
                color: _dateOfBirth == null ? Colors.grey : const Color(0xFF5D7BD5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
