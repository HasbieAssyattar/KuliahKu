import 'package:kuliahku/data/database/app_database.dart';
import 'package:kuliahku/data/models/meeting_attachment_model.dart';
import 'package:kuliahku/data/models/meeting_model.dart';

abstract class MeetingRepository {
  Future<List<MeetingModel>> getMeetings(String courseId);
  Future<MeetingModel?> getMeetingById(String id);
  Future<void> updateMeeting(MeetingModel meeting);
  Future<void> updatePresence(String meetingId, String newStatus);
  Future<void> addAttachment(MeetingAttachmentModel attachment);
  Future<void> removeAttachment(String attachmentId);
  Future<List<MeetingModel>> getExamClues(String courseId);
}

class MeetingRepositoryImpl implements MeetingRepository {
  final AppDatabase _db;

  MeetingRepositoryImpl({AppDatabase? db}) : _db = db ?? AppDatabase.instance;

  @override
  Future<List<MeetingModel>> getMeetings(String courseId) async {
    return await _db.getMeetingsByCourse(courseId);
  }

  @override
  Future<MeetingModel?> getMeetingById(String id) async {
    return await _db.getMeetingById(id);
  }

  @override
  Future<void> updateMeeting(MeetingModel meeting) async {
    await _db.updateMeeting(meeting);
  }

  @override
  Future<void> updatePresence(String meetingId, String newStatus) async {
    await _db.updatePresenceStatus(meetingId, newStatus);
  }

  @override
  Future<void> addAttachment(MeetingAttachmentModel attachment) async {
    await _db.insertAttachment(attachment);
  }

  @override
  Future<void> removeAttachment(String attachmentId) async {
    await _db.deleteAttachment(attachmentId);
  }

  @override
  Future<List<MeetingModel>> getExamClues(String courseId) async {
    return await _db.getExamCluesByCourse(courseId);
  }
}
