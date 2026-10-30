import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:kuliahku/core/constants/app_constants.dart';
import 'package:kuliahku/data/models/course_model.dart';
import 'package:kuliahku/data/models/course_score_model.dart';
import 'package:kuliahku/data/models/meeting_attachment_model.dart';
import 'package:kuliahku/data/models/meeting_model.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDB,
      onConfigure: _configureDB,
    );
  }

  Future<void> _configureDB(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Courses Table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableCourses} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        sks INTEGER NOT NULL DEFAULT 3,
        lecturer TEXT,
        room TEXT,
        day_of_week INTEGER NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        max_absence INTEGER NOT NULL DEFAULT 4,
        uts_meeting INTEGER NOT NULL DEFAULT 8,
        total_meetings INTEGER NOT NULL DEFAULT 16,
        weight_presence REAL NOT NULL DEFAULT 10.0,
        weight_assignment REAL NOT NULL DEFAULT 20.0,
        weight_uts REAL NOT NULL DEFAULT 30.0,
        weight_uas REAL NOT NULL DEFAULT 40.0,
        target_grade TEXT DEFAULT 'A',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 2. Meetings Table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableMeetings} (
        id TEXT PRIMARY KEY,
        course_id TEXT NOT NULL,
        meeting_number INTEGER NOT NULL,
        date INTEGER,
        topic TEXT,
        notes TEXT,
        presence_status TEXT NOT NULL DEFAULT 'hadir',
        is_exam_clue INTEGER NOT NULL DEFAULT 0,
        exam_clue_notes TEXT,
        audio_path TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (course_id) REFERENCES ${AppConstants.tableCourses} (id) ON DELETE CASCADE
      )
    ''');

    // 3. Meeting Attachments Table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableMeetingAttachments} (
        id TEXT PRIMARY KEY,
        meeting_id TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_name TEXT NOT NULL,
        file_type TEXT NOT NULL,
        file_size INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (meeting_id) REFERENCES ${AppConstants.tableMeetings} (id) ON DELETE CASCADE
      )
    ''');

    // 4. Course Scores Table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableCourseScores} (
        id TEXT PRIMARY KEY,
        course_id TEXT NOT NULL UNIQUE,
        score_presence REAL,
        score_assignment REAL,
        score_uts REAL,
        score_uas REAL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (course_id) REFERENCES ${AppConstants.tableCourses} (id) ON DELETE CASCADE
      )
    ''');

    // Indices
    await db.execute('CREATE INDEX idx_meetings_course_id ON ${AppConstants.tableMeetings} (course_id)');
    await db.execute('CREATE INDEX idx_attachments_meeting_id ON ${AppConstants.tableMeetingAttachments} (meeting_id)');
    await db.execute('CREATE INDEX idx_courses_day ON ${AppConstants.tableCourses} (day_of_week)');
  }

  // --- CRUD COURSES ---

  Future<void> insertCourse(CourseModel course) async {
    final db = await database;
    await db.transaction((txn) async {
      // 1. Insert course
      await txn.insert(
        AppConstants.tableCourses,
        course.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Auto-generate slots for meetings (1 to totalMeetings)
      final now = DateTime.now();
      for (int i = 1; i <= course.totalMeetings; i++) {
        final meeting = MeetingModel(
          id: const Uuid().v4(),
          courseId: course.id,
          meetingNumber: i,
          presenceStatus: 'hadir',
          createdAt: now,
          updatedAt: now,
        );
        await txn.insert(
          AppConstants.tableMeetings,
          meeting.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // 3. Insert initial course scores
      final initialScore = CourseScoreModel(
        id: const Uuid().v4(),
        courseId: course.id,
        scorePresence: 100.0,
        updatedAt: now,
      );
      await txn.insert(
        AppConstants.tableCourseScores,
        initialScore.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> updateCourse(CourseModel course) async {
    final db = await database;
    await db.update(
      AppConstants.tableCourses,
      course.toMap(),
      where: 'id = ?',
      whereArgs: [course.id],
    );
  }

  Future<void> deleteCourse(String id) async {
    final db = await database;
    await db.delete(
      AppConstants.tableCourses,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<CourseModel>> getAllCourses() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableCourses,
      orderBy: 'day_of_week ASC, start_time ASC',
    );
    return maps.map((m) => CourseModel.fromMap(m)).toList();
  }

  Future<CourseModel?> getCourseById(String id) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableCourses,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CourseModel.fromMap(maps.first);
  }

  // --- CRUD MEETINGS & ATTACHMENTS ---

  Future<List<MeetingModel>> getMeetingsByCourse(String courseId) async {
    final db = await database;
    final meetingMaps = await db.query(
      AppConstants.tableMeetings,
      where: 'course_id = ?',
      whereArgs: [courseId],
      orderBy: 'meeting_number ASC',
    );

    final List<MeetingModel> results = [];
    for (final mMap in meetingMaps) {
      final meetingId = mMap['id'] as String;
      final attMaps = await db.query(
        AppConstants.tableMeetingAttachments,
        where: 'meeting_id = ?',
        whereArgs: [meetingId],
        orderBy: 'created_at ASC',
      );
      final attachments = attMaps.map((a) => MeetingAttachmentModel.fromMap(a)).toList();
      results.add(MeetingModel.fromMap(mMap, attachments: attachments));
    }

    return results;
  }

  Future<MeetingModel?> getMeetingById(String id) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableMeetings,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;

    final attMaps = await db.query(
      AppConstants.tableMeetingAttachments,
      where: 'meeting_id = ?',
      whereArgs: [id],
    );
    final attachments = attMaps.map((a) => MeetingAttachmentModel.fromMap(a)).toList();
    return MeetingModel.fromMap(maps.first, attachments: attachments);
  }

  Future<void> updateMeeting(MeetingModel meeting) async {
    final db = await database;
    await db.update(
      AppConstants.tableMeetings,
      meeting.toMap(),
      where: 'id = ?',
      whereArgs: [meeting.id],
    );
  }

  Future<void> updatePresenceStatus(String meetingId, String newStatus) async {
    final db = await database;
    await db.update(
      AppConstants.tableMeetings,
      {
        'presence_status': newStatus,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [meetingId],
    );
  }

  Future<void> insertAttachment(MeetingAttachmentModel attachment) async {
    final db = await database;
    await db.insert(
      AppConstants.tableMeetingAttachments,
      attachment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteAttachment(String attachmentId) async {
    final db = await database;
    await db.delete(
      AppConstants.tableMeetingAttachments,
      where: 'id = ?',
      whereArgs: [attachmentId],
    );
  }

  Future<List<MeetingModel>> getExamCluesByCourse(String courseId) async {
    final db = await database;
    final meetingMaps = await db.query(
      AppConstants.tableMeetings,
      where: 'course_id = ? AND is_exam_clue = 1',
      whereArgs: [courseId],
      orderBy: 'meeting_number ASC',
    );

    final List<MeetingModel> results = [];
    for (final mMap in meetingMaps) {
      final meetingId = mMap['id'] as String;
      final attMaps = await db.query(
        AppConstants.tableMeetingAttachments,
        where: 'meeting_id = ?',
        whereArgs: [meetingId],
      );
      final attachments = attMaps.map((a) => MeetingAttachmentModel.fromMap(a)).toList();
      results.add(MeetingModel.fromMap(mMap, attachments: attachments));
    }

    return results;
  }

  Future<int> getAbsentCountByCourse(String courseId) async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM ${AppConstants.tableMeetings} WHERE course_id = ? AND LOWER(presence_status) != "hadir"',
      [courseId],
    ));
    return count ?? 0;
  }

  // --- SCORES CRUD ---

  Future<CourseScoreModel?> getScoreByCourse(String courseId) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableCourseScores,
      where: 'course_id = ?',
      whereArgs: [courseId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CourseScoreModel.fromMap(maps.first);
  }

  Future<void> upsertScore(CourseScoreModel score) async {
    final db = await database;
    await db.insert(
      AppConstants.tableCourseScores,
      score.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
