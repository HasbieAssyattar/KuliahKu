import 'package:kuliahku/core/constants/app_constants.dart';

enum SecurityZone {
  safe, // Hijau: Sisa >= 3
  warning, // Kuning: Sisa == 2
  danger, // Merah: Sisa == 1 (Kritis)
  overdue; // Merah pekat: Sisa <= 0 (Habis)

  String get displayName {
    switch (this) {
      case SecurityZone.safe:
        return 'Aman';
      case SecurityZone.warning:
        return 'Waspada';
      case SecurityZone.danger:
        return 'Jatah Kritis!';
      case SecurityZone.overdue:
        return 'Jatah Habis!';
    }
  }
}

class CourseModel {
  final String id;
  final String name;
  final int sks;
  final String? lecturer; // Nama PJ / Dosen
  final String? room;
  final int dayOfWeek; // 1 = Senin, ... 6 = Sabtu
  final String startTime;
  final String endTime;
  final int maxAbsence;
  final int utsMeeting; // Nomor pertemuan pelaksanaan UTS (fleksibel)
  final int totalMeetings; // Total pertemuan satu semester (fleksibel)
  final double weightPresence;
  final double weightAssignment;
  final double weightUts;
  final double weightUas;
  final String targetGrade;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CourseModel({
    required this.id,
    required this.name,
    this.sks = AppConstants.defaultSks,
    this.lecturer,
    this.room,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.maxAbsence = AppConstants.defaultMaxAbsence,
    this.utsMeeting = AppConstants.defaultUtsMeeting,
    this.totalMeetings = AppConstants.defaultTotalMeetings,
    this.weightPresence = AppConstants.defaultWeightPresence,
    this.weightAssignment = AppConstants.defaultWeightAssignment,
    this.weightUts = AppConstants.defaultWeightUts,
    this.weightUas = AppConstants.defaultWeightUas,
    this.targetGrade = 'A',
    required this.createdAt,
    required this.updatedAt,
  });

  int calculateRemainingQuota(int absentCount) {
    return maxAbsence - absentCount;
  }

  SecurityZone calculateZone(int absentCount) {
    final remaining = calculateRemainingQuota(absentCount);
    if (remaining >= 3) {
      return SecurityZone.safe;
    } else if (remaining == 2) {
      return SecurityZone.warning;
    } else if (remaining == 1) {
      return SecurityZone.danger;
    } else {
      return SecurityZone.overdue;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sks': sks,
      'lecturer': lecturer,
      'room': room,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'max_absence': maxAbsence,
      'uts_meeting': utsMeeting,
      'total_meetings': totalMeetings,
      'weight_presence': weightPresence,
      'weight_assignment': weightAssignment,
      'weight_uts': weightUts,
      'weight_uas': weightUas,
      'target_grade': targetGrade,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory CourseModel.fromMap(Map<String, dynamic> map) {
    return CourseModel(
      id: map['id'] as String,
      name: map['name'] as String,
      sks: (map['sks'] as num?)?.toInt() ?? AppConstants.defaultSks,
      lecturer: map['lecturer'] as String?,
      room: map['room'] as String?,
      dayOfWeek: (map['day_of_week'] as num?)?.toInt() ?? 1,
      startTime: map['start_time'] as String? ?? '08:00',
      endTime: map['end_time'] as String? ?? '10:30',
      maxAbsence: (map['max_absence'] as num?)?.toInt() ?? AppConstants.defaultMaxAbsence,
      utsMeeting: (map['uts_meeting'] as num?)?.toInt() ?? AppConstants.defaultUtsMeeting,
      totalMeetings: (map['total_meetings'] as num?)?.toInt() ?? AppConstants.defaultTotalMeetings,
      weightPresence: (map['weight_presence'] as num?)?.toDouble() ?? AppConstants.defaultWeightPresence,
      weightAssignment: (map['weight_assignment'] as num?)?.toDouble() ?? AppConstants.defaultWeightAssignment,
      weightUts: (map['weight_uts'] as num?)?.toDouble() ?? AppConstants.defaultWeightUts,
      weightUas: (map['weight_uas'] as num?)?.toDouble() ?? AppConstants.defaultWeightUas,
      targetGrade: map['target_grade'] as String? ?? 'A',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  CourseModel copyWith({
    String? id,
    String? name,
    int? sks,
    String? lecturer,
    String? room,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    int? maxAbsence,
    int? utsMeeting,
    int? totalMeetings,
    double? weightPresence,
    double? weightAssignment,
    double? weightUts,
    double? weightUas,
    String? targetGrade,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sks: sks ?? this.sks,
      lecturer: lecturer ?? this.lecturer,
      room: room ?? this.room,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      maxAbsence: maxAbsence ?? this.maxAbsence,
      utsMeeting: utsMeeting ?? this.utsMeeting,
      totalMeetings: totalMeetings ?? this.totalMeetings,
      weightPresence: weightPresence ?? this.weightPresence,
      weightAssignment: weightAssignment ?? this.weightAssignment,
      weightUts: weightUts ?? this.weightUas,
      weightUas: weightUas ?? this.weightUas,
      targetGrade: targetGrade ?? this.targetGrade,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
