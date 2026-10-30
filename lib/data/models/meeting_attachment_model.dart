class MeetingAttachmentModel {
  final String id;
  final String meetingId;
  final String filePath;
  final String fileName;
  final String fileType; // 'image' or 'file'
  final int fileSize;
  final DateTime createdAt;

  const MeetingAttachmentModel({
    required this.id,
    required this.meetingId,
    required this.filePath,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.createdAt,
  });

  bool get isImage => fileType == 'image';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'meeting_id': meetingId,
      'file_path': filePath,
      'file_name': fileName,
      'file_type': fileType,
      'file_size': fileSize,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory MeetingAttachmentModel.fromMap(Map<String, dynamic> map) {
    return MeetingAttachmentModel(
      id: map['id'] as String,
      meetingId: map['meeting_id'] as String,
      filePath: map['file_path'] as String,
      fileName: map['file_name'] as String,
      fileType: map['file_type'] as String,
      fileSize: (map['file_size'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }
}
