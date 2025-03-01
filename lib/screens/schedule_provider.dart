import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ScheduleProvider extends ChangeNotifier {
  List<Map<String, dynamic>> morningTasks = [];
  List<Map<String, dynamic>> afternoonTasks = [];
  List<Map<String, dynamic>> eveningTasks = [];
  bool isTaskCompletionMode = false;
  String scheduleTimeRange = '6:30 am - 9:00 pm';

  void toggleTaskCompletionMode() {
    isTaskCompletionMode = !isTaskCompletionMode;
    notifyListeners();
  }

  Future<void> loadSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    
    try {
      final morningTasksJson = prefs.getString('morning_tasks');
      final afternoonTasksJson = prefs.getString('afternoon_tasks');
      final eveningTasksJson = prefs.getString('evening_tasks');
      final timeRange = prefs.getString('schedule_time_range');
      
      if (morningTasksJson != null) {
        morningTasks = List<Map<String, dynamic>>.from(
          jsonDecode(morningTasksJson).map((x) => Map<String, dynamic>.from(x))
        );
      } else {
        // Default morning tasks
        morningTasks = [
          {'time': '6:30 am', 'task': 'Wake up and get ready', 'completed': false},
          {'time': '7:00 am', 'task': 'Morning yoga/stretches', 'completed': false},
          {'time': '7:30 am', 'task': 'Breakfast time', 'completed': false},
          {'time': '8:00 am', 'task': 'Get ready for school', 'completed': false},
        ];
      }
      
      if (afternoonTasksJson != null) {
        afternoonTasks = List<Map<String, dynamic>>.from(
          jsonDecode(afternoonTasksJson).map((x) => Map<String, dynamic>.from(x))
        );
      } else {
        // Default afternoon tasks
        afternoonTasks = [
          {'time': '1:00 pm', 'task': 'Lunch time', 'completed': false},
          {'time': '2:00 pm', 'task': 'Reading time', 'completed': false},
          {'time': '3:30 pm', 'task': 'Snack break', 'completed': false},
          {'time': '4:00 pm', 'task': 'Homework time', 'completed': false},
        ];
      }
      
      if (eveningTasksJson != null) {
        eveningTasks = List<Map<String, dynamic>>.from(
          jsonDecode(eveningTasksJson).map((x) => Map<String, dynamic>.from(x))
        );
      } else {
        // Default evening tasks
        eveningTasks = [
          {'time': '5:00 pm', 'task': 'Outdoor play time', 'completed': false},
          {'time': '6:30 pm', 'task': 'Dinner time', 'completed': false},
          {'time': '7:30 pm', 'task': 'Bath time', 'completed': false},
          {'time': '8:00 pm', 'task': 'Reading/story time', 'completed': false},
          {'time': '8:30 pm', 'task': 'Bedtime routine', 'completed': false},
          {'time': '9:00 pm', 'task': 'Lights out', 'completed': false},
        ];
      }
      
      if (timeRange != null) {
        scheduleTimeRange = timeRange;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading schedule: $e');
    }
  }

  Future<void> saveSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    
    try {
      await prefs.setString('morning_tasks', jsonEncode(morningTasks));
      await prefs.setString('afternoon_tasks', jsonEncode(afternoonTasks));
      await prefs.setString('evening_tasks', jsonEncode(eveningTasks));
      await prefs.setString('schedule_time_range', scheduleTimeRange);
      await prefs.setBool('has_schedule', true);
    } catch (e) {
      debugPrint('Error saving schedule: $e');
    }
  }

  void updateSchedule({
    List<Map<String, dynamic>>? newMorningTasks,
    List<Map<String, dynamic>>? newAfternoonTasks,
    List<Map<String, dynamic>>? newEveningTasks,
    String? newTimeRange,
  }) {
    if (newMorningTasks != null) morningTasks = newMorningTasks;
    if (newAfternoonTasks != null) afternoonTasks = newAfternoonTasks;
    if (newEveningTasks != null) eveningTasks = newEveningTasks;
    if (newTimeRange != null) scheduleTimeRange = newTimeRange;
    
    saveSchedule();
    notifyListeners();
  }

  void toggleTaskCompletion(String section, Map<String, dynamic> task) {
    List<Map<String, dynamic>> targetList;
    
    switch (section) {
      case 'morning':
        targetList = morningTasks;
        break;
      case 'afternoon':
        targetList = afternoonTasks;
        break;
      case 'evening':
        targetList = eveningTasks;
        break;
      default:
        return;
    }
    
    final index = targetList.indexWhere((t) => 
      t['time'] == task['time'] && t['task'] == task['task']);
    
    if (index != -1) {
      targetList[index]['completed'] = !(targetList[index]['completed'] ?? false);
      saveSchedule();
      notifyListeners();
    }
  }

  void resetDailyTasks() {
    // Reset all tasks to uncompleted for a new day
    for (var task in morningTasks) {
      task['completed'] = false;
    }
    
    for (var task in afternoonTasks) {
      task['completed'] = false;
    }
    
    for (var task in eveningTasks) {
      task['completed'] = false;
    }
    
    saveSchedule();
    notifyListeners();
  }
}