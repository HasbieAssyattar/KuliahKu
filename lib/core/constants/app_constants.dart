class AppConstants {
  static const String appName = 'KuliahKu';

  // Database
  static const String databaseName = 'kuliahku.db';
  static const int databaseVersion = 1;

  // Database Tables
  static const String tableCourses = 'courses';
  static const String tableMeetings = 'meetings';
  static const String tableMeetingAttachments = 'meeting_attachments';
  static const String tableCourseScores = 'course_scores';

  // Nilai Default Perkuliahan
  static const int defaultSks = 3;
  static const int defaultMaxAbsence = 4;
  static const int defaultUtsMeeting = 8;
  static const int defaultTotalMeetings = 16;

  // Bobot Komponen Penilaian Default (%)
  static const double defaultWeightPresence = 10.0;
  static const double defaultWeightAssignment = 20.0;
  static const double defaultWeightUts = 30.0;
  static const double defaultWeightUas = 40.0;

  // Nama Hari Kuliah (1 = Senin s/d 6 = Sabtu)
  static const List<String> days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];

  // Target Nilai Huruf Mutu & Standar Nilai Minimal
  static const Map<String, double> gradeScale = {
    'A': 80.0,
    'B+': 75.0,
    'B': 70.0,
    'C+': 65.0,
    'C': 60.0,
    'D': 50.0,
    'E': 0.0,
  };

  // Bobot Indeks IPK per Huruf
  static const Map<String, double> gradePoint = {
    'A': 4.0,
    'B+': 3.5,
    'B': 3.0,
    'C+': 2.5,
    'C': 2.0,
    'D': 1.0,
    'E': 0.0,
  };
}
