import 'package:flutter/material.dart';
import 'package:kuliahku/core/utils/date_time_helper.dart';
import 'package:kuliahku/data/models/course_model.dart';
import 'package:kuliahku/data/repositories/course_repository.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository _repository;

  List<CourseModel> _courses = [];
  final Map<String, int> _absentCounts = {};
  bool _isLoading = true;
  int _selectedDayFilter = DateTimeHelper.getTodayDayOfWeek();

  CourseProvider({CourseRepository? repository})
      : _repository = repository ?? CourseRepositoryImpl() {
    loadCourses();
  }

  List<CourseModel> get courses => _courses;
  bool get isLoading => _isLoading;
  int get selectedDayFilter => _selectedDayFilter;

  List<CourseModel> get todayCourses {
    final today = DateTimeHelper.getTodayDayOfWeek();
    return _courses.where((c) => c.dayOfWeek == today).toList();
  }

  List<CourseModel> get filteredCoursesByDay {
    if (_selectedDayFilter <= 0) return _courses;
    return _courses.where((c) => c.dayOfWeek == _selectedDayFilter).toList();
  }

  int get totalSks {
    return _courses.fold(0, (sum, c) => sum + c.sks);
  }

  int getAbsentCount(String courseId) {
    return _absentCounts[courseId] ?? 0;
  }

  int getRemainingQuota(CourseModel course) {
    return course.calculateRemainingQuota(getAbsentCount(course.id));
  }

  SecurityZone getSecurityZone(CourseModel course) {
    return course.calculateZone(getAbsentCount(course.id));
  }

  void setSelectedDayFilter(int day) {
    if (_selectedDayFilter != day) {
      _selectedDayFilter = day;
      notifyListeners();
    }
  }

  Future<void> loadCourses() async {
    _isLoading = true;
    notifyListeners();

    try {
      _courses = await _repository.getAllCourses();
      await refreshAbsentCounts();
    } catch (_) {
      // Safe fallback
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAbsentCounts() async {
    for (final course in _courses) {
      final absent = await _repository.getAbsentCount(course.id);
      _absentCounts[course.id] = absent;
    }
    notifyListeners();
  }

  Future<void> addCourse(CourseModel course) async {
    await _repository.addCourse(course);
    _courses.add(course);
    _absentCounts[course.id] = 0;
    _courses.sort((a, b) {
      if (a.dayOfWeek != b.dayOfWeek) return a.dayOfWeek.compareTo(b.dayOfWeek);
      return a.startTime.compareTo(b.startTime);
    });
    notifyListeners();
  }

  Future<void> updateCourse(CourseModel course) async {
    await _repository.updateCourse(course);
    final index = _courses.indexWhere((c) => c.id == course.id);
    if (index != -1) {
      _courses[index] = course;
      _courses.sort((a, b) {
        if (a.dayOfWeek != b.dayOfWeek) return a.dayOfWeek.compareTo(b.dayOfWeek);
        return a.startTime.compareTo(b.startTime);
      });
      notifyListeners();
    }
  }

  Future<void> deleteCourse(String id) async {
    await _repository.deleteCourse(id);
    _courses.removeWhere((c) => c.id == id);
    _absentCounts.remove(id);
    notifyListeners();
  }
}
