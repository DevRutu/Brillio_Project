import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'schedule_provider.dart';

class ScheduleFormScreen extends StatefulWidget {
  final bool isFirstTime;
  final Function() onScheduleCreated;

  const ScheduleFormScreen({
    super.key,
    required this.isFirstTime,
    required this.onScheduleCreated,
  });

  @override
  _ScheduleFormScreenState createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends State<ScheduleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _wakeUpTimeController = TextEditingController(text: '6:30 am');
  final _sleepTimeController = TextEditingController(text: '9:00 pm');
  final _ageController = TextEditingController();
  final _interestsController = TextEditingController();
  final _activitiesController = TextEditingController();
  final _schoolTimeController = TextEditingController();
  
  bool _isLoading = false;
  bool _showGeneratedSchedule = false;
  
  List<Map<String, dynamic>> _generatedMorningTasks = [];
  List<Map<String, dynamic>> _generatedAfternoonTasks = [];
  List<Map<String, dynamic>> _generatedEveningTasks = [];
  
  @override
  void initState() {
    super.initState();
    _loadExistingScheduleData();
  }

  @override
  void dispose() {
    _wakeUpTimeController.dispose();
    _sleepTimeController.dispose();
    _ageController.dispose();
    _interestsController.dispose();
    _activitiesController.dispose();
    _schoolTimeController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingScheduleData() async {
    if (!widget.isFirstTime) {
      final provider = Provider.of<ScheduleProvider>(context, listen: false);
      
      // Extract wake up time from first morning task if available
      if (provider.morningTasks.isNotEmpty) {
        _wakeUpTimeController.text = provider.morningTasks.first['time'];
      }
      
      // Extract sleep time from last evening task if available
      if (provider.eveningTasks.isNotEmpty) {
        _sleepTimeController.text = provider.eveningTasks.last['time'];
      }
    }
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    // Parse the current time from the controller
    final TimeOfDay initialTime = _parseTimeString(controller.text);
    
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFA873E8),
              onPrimary: Colors.white,
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
    
    if (pickedTime != null) {
      final now = DateTime.now();
      final pickedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      
      final formattedTime = DateFormat('h:mm a').format(pickedDateTime).toLowerCase();
      
      setState(() {
        controller.text = formattedTime;
      });
    }
  }
  
  TimeOfDay _parseTimeString(String timeString) {
    try {
      final timeParts = timeString.split(':');
      final hourPart = timeParts[0];
      final minuteAmPm = timeParts[1].split(' ');
      final minute = int.parse(minuteAmPm[0]);
      final amPm = minuteAmPm[1].toLowerCase();
      
      int hour = int.parse(hourPart);
      
      // Convert to 24-hour format for TimeOfDay
      if (amPm == 'pm' && hour < 12) {
        hour += 12;
      } else if (amPm == 'am' && hour == 12) {
        hour = 0;
      }
      
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      // Default to 8:00 AM if parsing fails
      return const TimeOfDay(hour: 8, minute: 0);
    }
  }

  Future<void> _generateSchedule() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _showGeneratedSchedule = false;
    });
    
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('Gemini API key not found. Please check your .env file.');
      }
      
      // Create the prompt for Gemini
      final prompt = '''
Create a healthy daily schedule for a ${_ageController.text} year old child who wakes up at ${_wakeUpTimeController.text} and goes to bed at ${_sleepTimeController.text}.
School/classes time: ${_schoolTimeController.text}
Child's interests: ${_interestsController.text}
Preferred activities: ${_activitiesController.text}

Important guidelines:
1. Minimize screen time, prioritize educational, physical, and social activities.
2. Include time for healthy meals and snacks.
3. Include outdoor activities, play, and exercise.
4. Include time for rest/quiet time.
5. Include time for reading and learning.
6. Include necessary routines like bathing, brushing teeth, etc.

Format the schedule in JSON with three sections: morning, afternoon, and evening.
Each task should include a time and description.
Follow this exact format:
{
  "morning": [
    {"time": "6:30 am", "task": "Wake up and get ready", "completed": false},
    {"time": "7:00 am", "task": "Breakfast", "completed": false}
  ],
  "afternoon": [
    {"time": "12:00 pm", "task": "Lunch", "completed": false}
  ],
  "evening": [
    {"time": "6:00 pm", "task": "Dinner", "completed": false},
    {"time": "8:30 pm", "task": "Bedtime routine", "completed": false}
  ]
}
''';

      // Make request to Gemini API
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          }
        }),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to generate schedule. Status code: ${response.statusCode}');
      }
      
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      // Parse the generated text to extract JSON
      final String generatedText = responseData['candidates'][0]['content']['parts'][0]['text'];
      
      // Extract JSON from the generated text
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(generatedText);
      if (jsonMatch == null) {
        throw Exception('Failed to parse generated schedule');
      }
      
      final String jsonContent = jsonMatch.group(0)!;
      final Map<String, dynamic> scheduleData = jsonDecode(jsonContent);
      
      // Update state with generated schedule
      setState(() {
        _generatedMorningTasks = List<Map<String, dynamic>>.from(scheduleData['morning']);
        _generatedAfternoonTasks = List<Map<String, dynamic>>.from(scheduleData['afternoon']);
        _generatedEveningTasks = List<Map<String, dynamic>>.from(scheduleData['evening']);
        _showGeneratedSchedule = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error generating schedule: ${e.toString()}',
            style: GoogleFonts.quicksand(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _saveSchedule() {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    
    // Update the schedule in the provider
    provider.updateSchedule(
      newMorningTasks: _generatedMorningTasks,
      newAfternoonTasks: _generatedAfternoonTasks,
      newEveningTasks: _generatedEveningTasks,
      newTimeRange: '${_wakeUpTimeController.text} - ${_sleepTimeController.text}',
    );
    
    // Call the callback to indicate schedule creation
    widget.onScheduleCreated();
    
    // Navigate back to the scheduler screen
    Navigator.pop(context);
  }
  
  void _regenerateSchedule() {
    _generateSchedule();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFA873E8)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isFirstTime ? 'Create New Schedule' : 'Edit Schedule',
          style: GoogleFonts.quicksand(
            color: const Color(0xFFA873E8),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _showGeneratedSchedule 
          ? _buildGeneratedScheduleView() 
          : _buildScheduleForm(),
    );
  }

  Widget _buildScheduleForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction text
            Text(
              widget.isFirstTime 
                  ? 'Let\'s create a smart schedule for your child!' 
                  : 'Update your child\'s schedule',
              style: GoogleFonts.quicksand(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5D7BD5),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Fill in the details below, and we\'ll use AI to generate a balanced daily routine.',
              style: GoogleFonts.quicksand(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),
            
            // Child's age
            _buildFormField(
              label: 'Child\'s Age',
              controller: _ageController,
              hintText: 'e.g., 7',
              icon: Icons.cake,
              keyboardType: TextInputType.number,
              validator: (value) => value == null || value.isEmpty 
                  ? 'Please enter your child\'s age' 
                  : null,
            ),
            const SizedBox(height: 20),
            
            // Wake up & sleep time
            Row(
              children: [
                Expanded(
                  child: _buildTimeField(
                    label: 'Wake Up Time',
                    controller: _wakeUpTimeController,
                    icon: Icons.wb_sunny_outlined,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildTimeField(
                    label: 'Sleep Time',
                    controller: _sleepTimeController,
                    icon: Icons.nights_stay_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // School time
            _buildFormField(
              label: 'School/Class Time',
              controller: _schoolTimeController,
              hintText: 'e.g., 8:30 am to 3:00 pm',
              icon: Icons.school_outlined,
              validator: (value) => value == null || value.isEmpty 
                  ? 'Please enter school/class hours' 
                  : null,
            ),
            const SizedBox(height: 20),
            
            // Child's interests
            _buildFormField(
              label: 'Child\'s Interests',
              controller: _interestsController,
              hintText: 'e.g., dinosaurs, space, drawing',
              icon: Icons.interests,
              maxLines: 2,
              validator: (value) => value == null || value.isEmpty 
                  ? 'Please enter at least one interest' 
                  : null,
            ),
            const SizedBox(height: 20),
            
            // Preferred activities
            _buildFormField(
              label: 'Preferred Activities',
              controller: _activitiesController,
              hintText: 'e.g., swimming, reading, playing outside',
              icon: Icons.directions_run,
              maxLines: 2,
              validator: (value) => value == null || value.isEmpty 
                  ? 'Please enter some activities' 
                  : null,
            ),
            const SizedBox(height: 40),
            
            // Generate schedule button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA873E8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Generate Smart Schedule',
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5D7BD5),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: GoogleFonts.quicksand(
            fontSize: 16,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.quicksand(
              color: Colors.black38,
            ),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFFA873E8),
            ),
            filled: true,
            fillColor: const Color(0xFFF5F5FF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5D7BD5),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectTime(context, controller),
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller,
              style: GoogleFonts.quicksand(
                fontSize: 16,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  icon,
                  color: const Color(0xFFA873E8),
                ),
                suffixIcon: const Icon(
                  Icons.access_time,
                  color: Color(0xFFA873E8),
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator: (value) => value == null || value.isEmpty 
                  ? 'Please select a time' 
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneratedScheduleView() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generated Schedule',
                  style: GoogleFonts.quicksand(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D7BD5),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Here\'s a balanced schedule for your child based on your input.',
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                
                // Time range of the schedule
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA873E8).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule,
                        color: Color(0xFFA873E8),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_wakeUpTimeController.text} - ${_sleepTimeController.text}',
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFA873E8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                
                // Morning schedule
                _buildScheduleSection('Morning', _generatedMorningTasks),
                const SizedBox(height: 20),
                
                // Afternoon schedule
                _buildScheduleSection('Afternoon', _generatedAfternoonTasks),
                const SizedBox(height: 20),
                
                // Evening schedule
                _buildScheduleSection('Evening', _generatedEveningTasks),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        
        // Action buttons
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _regenerateSchedule,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF5D7BD5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Regenerate',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5D7BD5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveSchedule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA873E8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Save Schedule',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleSection(String title, List<Map<String, dynamic>> tasks) {
    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5FF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5D7BD5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tasks.map((task) => _buildTaskItem(task)),
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

  Widget _buildTaskItem(Map<String, dynamic> task) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              task['time'],
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFA873E8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task['task'],
              style: GoogleFonts.quicksand(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}