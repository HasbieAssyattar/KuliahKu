import 'package:kuliahku/core/constants/app_constants.dart';
import 'package:kuliahku/data/models/course_model.dart';

class CourseScoreModel {
  final String id;
  final String courseId;
  final double? scorePresence;
  final double? scoreAssignment;
  final double? scoreUts;
  final double? scoreUas;
  final DateTime updatedAt;

  const CourseScoreModel({
    required this.id,
    required this.courseId,
    this.scorePresence,
    this.scoreAssignment,
    this.scoreUts,
    this.scoreUas,
    required this.updatedAt,
  });

  double calculateCurrentTotal(CourseModel course) {
    double total = 0.0;
    if (scorePresence != null) {
      total += (scorePresence! * course.weightPresence / 100);
    }
    if (scoreAssignment != null) {
      total += (scoreAssignment! * course.weightAssignment / 100);
    }
    if (scoreUts != null) {
      total += (scoreUts! * course.weightUts / 100);
    }
    if (scoreUas != null) {
      total += (scoreUas! * course.weightUas / 100);
    }
    return total;
  }

  double? calculateNeededUas(CourseModel course, double targetScore) {
    if (course.weightUas <= 0) return null;

    double currentWithoutUas = 0.0;
    if (scorePresence != null) {
      currentWithoutUas += (scorePresence! * course.weightPresence / 100);
    }
    if (scoreAssignment != null) {
      currentWithoutUas += (scoreAssignment! * course.weightAssignment / 100);
    }
    if (scoreUts != null) {
      currentWithoutUas += (scoreUts! * course.weightUts / 100);
    }

    final needed = targetScore - currentWithoutUas;
    final uasRequired = needed / (course.weightUas / 100);
    return uasRequired;
  }

  static String getGradeLetter(double score) {
    if (score >= 80.0) return 'A';
    if (score >= 75.0) return 'B+';
    if (score >= 70.0) return 'B';
    if (score >= 65.0) return 'C+';
    if (score >= 60.0) return 'C';
    if (score >= 50.0) return 'D';
    return 'E';
  }

  static double getGradePoint(String letter) {
    return AppConstants.gradePoint[letter] ?? 0.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'score_presence': scorePresence,
      'score_assignment': scoreAssignment,
      'score_uts': scoreUts,
      'score_uas': scoreUas,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory CourseScoreModel.fromMap(Map<String, dynamic> map) {
    return CourseScoreModel(
      id: map['id'] as String,
      courseId: map['course_id'] as String,
      scorePresence: (map['score_presence'] as num?)?.toDouble(),
      scoreAssignment: (map['score_assignment'] as num?)?.toDouble(),
      scoreUts: (map['score_uts'] as num?)?.toDouble(),
      scoreUas: (map['score_uas'] as num?)?.toDouble(),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  CourseScoreModel copyWith({
    String? id,
    String? courseId,
    double? scorePresence,
    double? scoreAssignment,
    double? scoreUts,
    double? scoreUas,
    DateTime? updatedAt,
  }) {
    return CourseScoreModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      scorePresence: scorePresence ?? this.scorePresence,
      scoreAssignment: scoreAssignment ?? this.scoreAssignment,
      scoreUts: scoreUts ?? this.scoreUts,
      scoreUas: scoreUas ?? this.scoreUas,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
