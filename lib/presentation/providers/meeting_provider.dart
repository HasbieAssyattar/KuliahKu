import 'package:flutter/material.dart';
import 'package:kuliahku/data/models/meeting_attachment_model.dart';
import 'package:kuliahku/data/models/meeting_model.dart';
import 'package:kuliahku/data/repositories/meeting_repository.dart';

class MeetingProvider extends ChangeNotifier {
  final MeetingRepository _repository;

  String? _currentCourseId;
  List<MeetingModel> _meetings = [];
  List<MeetingModel> _examClues = [];
  bool _isLoading = false;

  MeetingProvider({MeetingRepository? repository})
      : _repository = repository ?? MeetingRepositoryImpl();

  String? get currentCourseId => _currentCourseId;
  List<MeetingModel> get meetings => _meetings;
  List<MeetingModel> get examClues => _examClues;
  bool get isLoading => _isLoading;

  List<MeetingModel> getPreUtsMeetings(int utsMeeting) {
    return _meetings.where((m) => m.meetingNumber < utsMeeting).toList();
  }

  MeetingModel? getUtsMeeting(int utsMeeting) {
    try {
      return _meetings.firstWhere((m) => m.meetingNumber == utsMeeting);
    } catch (_) {
      return null;
    }
  }

  List<MeetingModel> getPreUasMeetings(int utsMeeting, int totalMeetings) {
    return _meetings
        .where((m) => m.meetingNumber > utsMeeting && m.meetingNumber < totalMeetings)
        .toList();
  }

  MeetingModel? getUasMeeting(int totalMeetings) {
    try {
      return _meetings.firstWhere((m) => m.meetingNumber == totalMeetings);
    } catch (_) {
      return null;
    }
  }

  List<MeetingModel> getPreUtsExamClues(int utsMeeting) {
    return _examClues.where((m) => m.meetingNumber <= utsMeeting).toList();
  }

  List<MeetingModel> getPreUasExamClues(int utsMeeting) {
    return _examClues.where((m) => m.meetingNumber > utsMeeting).toList();
  }

  Future<void> loadMeetingsForCourse(String courseId) async {
    _currentCourseId = courseId;
    _isLoading = true;
    notifyListeners();

    try {
      _meetings = await _repository.getMeetings(courseId);
      _examClues = await _repository.getExamClues(courseId);
    } catch (_) {
      // Safe fallback
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePresence(String meetingId, String newStatus) async {
    await _repository.updatePresence(meetingId, newStatus);
    final index = _meetings.indexWhere((m) => m.id == meetingId);
    if (index != -1) {
      _meetings[index] = _meetings[index].copyWith(
        presenceStatus: newStatus,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  Future<void> updateMeetingDetails(MeetingModel updated) async {
    await _repository.updateMeeting(updated);
    final index = _meetings.indexWhere((m) => m.id == updated.id);
    if (index != -1) {
      _meetings[index] = updated;
      _refreshExamClues();
      notifyListeners();
    }
  }

  Future<void> addAttachment(MeetingAttachmentModel attachment) async {
    await _repository.addAttachment(attachment);
    final index = _meetings.indexWhere((m) => m.id == attachment.meetingId);
    if (index != -1) {
      final currentList = List<MeetingAttachmentModel>.from(_meetings[index].attachments);
      currentList.add(attachment);
      _meetings[index] = _meetings[index].copyWith(attachments: currentList);
      _refreshExamClues();
      notifyListeners();
    }
  }

  Future<void> removeAttachment(String meetingId, String attachmentId) async {
    await _repository.removeAttachment(attachmentId);
    final index = _meetings.indexWhere((m) => m.id == meetingId);
    if (index != -1) {
      final currentList = List<MeetingAttachmentModel>.from(_meetings[index].attachments);
      currentList.removeWhere((a) => a.id == attachmentId);
      _meetings[index] = _meetings[index].copyWith(attachments: currentList);
      _refreshExamClues();
      notifyListeners();
    }
  }

  Future<void> toggleExamClue(String meetingId, bool isClue, String? notes) async {
    final index = _meetings.indexWhere((m) => m.id == meetingId);
    if (index != -1) {
      final updated = _meetings[index].copyWith(
        isExamClue: isClue,
        examClueNotes: notes,
        updatedAt: DateTime.now(),
      );
      await _repository.updateMeeting(updated);
      _meetings[index] = updated;
      _refreshExamClues();
      notifyListeners();
    }
  }

  void _refreshExamClues() {
    _examClues = _meetings.where((m) => m.isExamClue).toList();
  }
}
