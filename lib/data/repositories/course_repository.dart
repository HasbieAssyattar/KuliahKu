import 'package:kuliahku/data/database/app_database.dart';
import 'package:kuliahku/data/models/course_model.dart';
import 'package:kuliahku/data/models/course_score_model.dart';

abstract class CourseRepository {
  Future<List<CourseModel>> getAllCourses();
  Future<CourseModel?> getCourseById(String id);
  Future<void> addCourse(CourseModel course);
  Future<void> updateCourse(CourseModel course);
  Future<void> deleteCourse(String id);
  Future<int> getAbsentCount(String courseId);
  Future<CourseScoreModel?> getScore(String courseId);
  Future<void> saveScore(CourseScoreModel score);
}

class CourseRepositoryImpl implements CourseRepository {
  final AppDatabase _db;

  CourseRepositoryImpl({AppDatabase? db}) : _db = db ?? AppDatabase.instance;

  @override
  Future<List<CourseModel>> getAllCourses() async {
    return await _db.getAllCourses();
  }

  @override
  Future<CourseModel?> getCourseById(String id) async {
    return await _db.getCourseById(id);
  }

  @override
  Future<void> addCourse(CourseModel course) async {
    await _db.insertCourse(course);
  }

  @override
  Future<void> updateCourse(CourseModel course) async {
    await _db.updateCourse(course);
  }

  @override
  Future<void> deleteCourse(String id) async {
    await _db.deleteCourse(id);
  }

  @override
  Future<int> getAbsentCount(String courseId) async {
    return await _db.getAbsentCountByCourse(courseId);
  }

  @override
  Future<CourseScoreModel?> getScore(String courseId) async {
    return await _db.getScoreByCourse(courseId);
  }

  @override
  Future<void> saveScore(CourseScoreModel score) async {
    await _db.upsertScore(score);
  }
}
