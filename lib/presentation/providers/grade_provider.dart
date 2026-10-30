import 'package:flutter/material.dart';
import 'package:kuliahku/data/models/course_model.dart';
import 'package:kuliahku/data/models/course_score_model.dart';
import 'package:kuliahku/data/repositories/course_repository.dart';
import 'package:uuid/uuid.dart';

class GradeProvider extends ChangeNotifier {
  final CourseRepository _repository;

  CourseScoreModel? _currentScore;
  bool _isLoading = false;

  GradeProvider({CourseRepository? repository})
      : _repository = repository ?? CourseRepositoryImpl();

  CourseScoreModel? get currentScore => _currentScore;
  bool get isLoading => _isLoading;

  Future<void> loadScore(String courseId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentScore = await _repository.getScore(courseId);
    } catch (_) {
      // Safe fallback
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateScore({
    required CourseModel course,
    double? scorePresence,
    double? scoreAssignment,
    double? scoreUts,
    double? scoreUas,
  }) async {
    final updatedScore = CourseScoreModel(
      id: _currentScore?.id ?? const Uuid().v4(),
      courseId: course.id,
      scorePresence: scorePresence,
      scoreAssignment: scoreAssignment,
      scoreUts: scoreUts,
      scoreUas: scoreUas,
      updatedAt: DateTime.now(),
    );

    await _repository.saveScore(updatedScore);
    _currentScore = updatedScore;
    notifyListeners();
  }

  double calculateCurrentTotal(CourseModel course) {
    if (_currentScore == null) return 0.0;
    return _currentScore!.calculateCurrentTotal(course);
  }

  String getCurrentGradeLetter(CourseModel course) {
    final total = calculateCurrentTotal(course);
    return CourseScoreModel.getGradeLetter(total);
  }

  double getMinTargetScore(String targetGrade) {
    switch (targetGrade) {
      case 'A':
        return 80.0;
      case 'B+':
        return 75.0;
      case 'B':
        return 70.0;
      case 'C+':
        return 65.0;
      case 'C':
        return 60.0;
      case 'D':
        return 50.0;
      default:
        return 80.0;
    }
  }

  double? calculateNeededUas(CourseModel course, {String? targetGrade}) {
    if (_currentScore == null) return null;
    final grade = targetGrade ?? course.targetGrade;
    final minScore = getMinTargetScore(grade);
    return _currentScore!.calculateNeededUas(course, minScore);
  }
}
