import 'package:kuliahku/data/models/meeting_attachment_model.dart';

class MeetingModel {
  final String id;
  final String courseId;
  final int meetingNumber;
  final DateTime? date;
  final String? topic;
  final String? notes;
  final String presenceStatus; // 'hadir', 'izin', 'sakit', 'alpa'
  final bool isExamClue;
  final String? examClueNotes;
  final String? audioPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<MeetingAttachmentModel> attachments;

  const MeetingModel({
    required this.id,
    required this.courseId,
    required this.meetingNumber,
    this.date,
    this.topic,
    this.notes,
    this.presenceStatus = 'hadir',
    this.isExamClue = false,
    this.examClueNotes,
    this.audioPath,
    required this.createdAt,
    required this.updatedAt,
    this.attachments = const [],
  });

  bool get isAbsent => presenceStatus.toLowerCase() != 'hadir';
  bool isUts(int utsMeetingNumber) => meetingNumber == utsMeetingNumber;
  bool isUas(int totalMeetingsNumber) => meetingNumber == totalMeetingsNumber;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'meeting_number': meetingNumber,
      'date': date?.millisecondsSinceEpoch,
      'topic': topic,
      'notes': notes,
      'presence_status': presenceStatus,
      'is_exam_clue': isExamClue ? 1 : 0,
      'exam_clue_notes': examClueNotes,
      'audio_path': audioPath,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory MeetingModel.fromMap(Map<String, dynamic> map, {List<MeetingAttachmentModel> attachments = const []}) {
    return MeetingModel(
      id: map['id'] as String,
      courseId: map['course_id'] as String,
      meetingNumber: (map['meeting_number'] as num).toInt(),
      date: map['date'] != null ? DateTime.fromMillisecondsSinceEpoch(map['date'] as int) : null,
      topic: map['topic'] as String?,
      notes: map['notes'] as String?,
      presenceStatus: map['presence_status'] as String? ?? 'hadir',
      isExamClue: (map['is_exam_clue'] as int? ?? 0) == 1,
      examClueNotes: map['exam_clue_notes'] as String?,
      audioPath: map['audio_path'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      attachments: attachments,
    );
  }

  MeetingModel copyWith({
    String? id,
    String? courseId,
    int? meetingNumber,
    DateTime? date,
    String? topic,
    String? notes,
    String? presenceStatus,
    bool? isExamClue,
    String? examClueNotes,
    String? audioPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<MeetingAttachmentModel>? attachments,
  }) {
    return MeetingModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      meetingNumber: meetingNumber ?? this.meetingNumber,
      date: date ?? this.date,
      topic: topic ?? this.topic,
      notes: notes ?? this.notes,
      presenceStatus: presenceStatus ?? this.presenceStatus,
      isExamClue: isExamClue ?? this.isExamClue,
      examClueNotes: examClueNotes ?? this.examClueNotes,
      audioPath: audioPath ?? this.audioPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attachments: attachments ?? this.attachments,
    );
  }
}
