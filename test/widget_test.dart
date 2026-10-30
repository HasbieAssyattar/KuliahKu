import 'package:flutter_test/flutter_test.dart';
import 'package:kuliahku/data/models/course_model.dart';
import 'package:kuliahku/data/models/course_score_model.dart';
import 'package:kuliahku/data/models/meeting_model.dart';

void main() {
  group('CourseModel Unit Tests', () {
    test('CourseModel serialization & deserialization', () {
      final now = DateTime.now();
      final course = CourseModel(
        id: 'c1',
        name: 'Pemrograman Web dan Mobile',
        sks: 3,
        lecturer: 'Pak Budi, M.Kom / PJ: Hasbi',
        room: 'Lab 2',
        dayOfWeek: 1, // Senin
        startTime: '08:00',
        endTime: '10:30',
        maxAbsence: 4,
        utsMeeting: 7, // Dosen labil: UTS di pertemuan 7
        totalMeetings: 16,
        weightPresence: 15.0,
        weightAssignment: 25.0,
        weightUts: 25.0,
        weightUas: 35.0,
        targetGrade: 'A',
        createdAt: now,
        updatedAt: now,
      );

      final map = course.toMap();
      expect(map['name'], 'Pemrograman Web dan Mobile');
      expect(map['lecturer'], 'Pak Budi, M.Kom / PJ: Hasbi');
      expect(map['uts_meeting'], 7);
      expect(map['weight_presence'], 15.0);

      final reconstructed = CourseModel.fromMap(map);
      expect(reconstructed.id, 'c1');
      expect(reconstructed.name, 'Pemrograman Web dan Mobile');
      expect(reconstructed.utsMeeting, 7);
      expect(reconstructed.weightUas, 35.0);
    });

    test('Absence Quota & Security Zone calculation', () {
      final now = DateTime.now();
      final course = CourseModel(
        id: 'c2',
        name: 'Basis Data',
        dayOfWeek: 2,
        startTime: '10:00',
        endTime: '12:00',
        maxAbsence: 4,
        createdAt: now,
        updatedAt: now,
      );

      // 0 absen -> sisa 4 -> Safe
      expect(course.calculateRemainingQuota(0), 4);
      expect(course.calculateZone(0), SecurityZone.safe);

      // 1 absen -> sisa 3 -> Safe
      expect(course.calculateRemainingQuota(1), 3);
      expect(course.calculateZone(1), SecurityZone.safe);

      // 2 absen -> sisa 2 -> Warning
      expect(course.calculateRemainingQuota(2), 2);
      expect(course.calculateZone(2), SecurityZone.warning);

      // 3 absen -> sisa 1 -> Danger (Kritis)
      expect(course.calculateRemainingQuota(3), 1);
      expect(course.calculateZone(3), SecurityZone.danger);

      // 4 absen -> sisa 0 -> Overdue (Habis)
      expect(course.calculateRemainingQuota(4), 0);
      expect(course.calculateZone(4), SecurityZone.overdue);
    });
  });

  group('MeetingModel Unit Tests', () {
    test('Flexible UTS and UAS detection', () {
      final now = DateTime.now();
      final meeting = MeetingModel(
        id: 'm1',
        courseId: 'c1',
        meetingNumber: 7,
        presenceStatus: 'alpa',
        isExamClue: true,
        examClueNotes: 'Kisi-kisi: Soal State Management 40%',
        createdAt: now,
        updatedAt: now,
      );

      expect(meeting.isAbsent, true);
      expect(meeting.isUts(7), true);
      expect(meeting.isUts(8), false);
      expect(meeting.isUas(16), false);

      final uasMeeting = meeting.copyWith(meetingNumber: 16);
      expect(uasMeeting.isUas(16), true);
    });
  });

  group('CourseScoreModel Unit Tests', () {
    test('Grade simulation & needed UAS calculation', () {
      final now = DateTime.now();
      final course = CourseModel(
        id: 'c3',
        name: 'Kecerdasan Buatan',
        dayOfWeek: 3,
        startTime: '13:00',
        endTime: '15:30',
        weightPresence: 10.0,
        weightAssignment: 20.0,
        weightUts: 30.0,
        weightUas: 40.0,
        createdAt: now,
        updatedAt: now,
      );

      final scores = CourseScoreModel(
        id: 's1',
        courseId: 'c3',
        scorePresence: 100.0, // 10.0 poin
        scoreAssignment: 85.0, // 17.0 poin
        scoreUts: 70.0, // 21.0 poin
        // Total so far = 48.0 poin
        scoreUas: null,
        updatedAt: now,
      );

      // Target Nilai A = 80.0
      // Butuh = 80 - 48 = 32 poin dari UAS (bobot 40%)
      // Nilai UAS minimal = 32 / 0.4 = 80.0
      final neededForA = scores.calculateNeededUas(course, 80.0);
      expect(neededForA, closeTo(80.0, 0.01));

      // Target Nilai B = 70.0
      // Butuh = 70 - 48 = 22 poin dari UAS
      // Nilai UAS minimal = 22 / 0.4 = 55.0
      final neededForB = scores.calculateNeededUas(course, 70.0);
      expect(neededForB, closeTo(55.0, 0.01));

      // Grade letters
      expect(CourseScoreModel.getGradeLetter(85.0), 'A');
      expect(CourseScoreModel.getGradeLetter(73.0), 'B');
      expect(CourseScoreModel.getGradeLetter(55.0), 'D');
    });
  });
}
