import 'package:flutter/material.dart';
import 'package:kuliahku/core/constants/app_colors.dart';
import 'package:kuliahku/data/models/course_model.dart';
import 'package:kuliahku/data/models/meeting_model.dart';
import 'package:kuliahku/presentation/providers/course_provider.dart';
import 'package:kuliahku/presentation/providers/meeting_provider.dart';
import 'package:kuliahku/presentation/widgets/media_attachment_picker.dart';
import 'package:provider/provider.dart';

class MeetingDetailScreen extends StatefulWidget {
  final CourseModel course;
  final MeetingModel meeting;

  const MeetingDetailScreen({
    super.key,
    required this.course,
    required this.meeting,
  });

  @override
  State<MeetingDetailScreen> createState() => _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends State<MeetingDetailScreen> {
  late MeetingModel _meeting;
  late TextEditingController _topicController;
  late TextEditingController _examClueNotesController;
  late String _selectedPresence;
  late bool _isExamClue;

  @override
  void initState() {
    super.initState();
    _meeting = widget.meeting;
    _topicController = TextEditingController(text: _meeting.topic);
    _examClueNotesController = TextEditingController(text: _meeting.examClueNotes ?? '');
    _selectedPresence = _meeting.presenceStatus;
    _isExamClue = _meeting.isExamClue;
  }

  @override
  void dispose() {
    _topicController.dispose();
    _examClueNotesController.dispose();
    super.dispose();
  }

  Future<void> _saveMeeting() async {
    final updated = _meeting.copyWith(
      topic: _topicController.text.trim(),
      presenceStatus: _selectedPresence,
      isExamClue: _isExamClue,
      examClueNotes: _isExamClue ? _examClueNotesController.text.trim() : null,
      updatedAt: DateTime.now(),
    );

    final meetingProvider = context.read<MeetingProvider>();
    final courseProvider = context.read<CourseProvider>();
    await meetingProvider.updateMeetingDetails(updated);
    await courseProvider.refreshAbsentCounts();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Catatan pertemuan dan presensi berhasil disimpan!'),
        backgroundColor: AppColors.zoneSafe,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Keep meeting in sync if provider updates it (e.g. from attachments)
    final meetingProvider = context.watch<MeetingProvider>();
    final found = meetingProvider.meetings.where((m) => m.id == _meeting.id);
    if (found.isNotEmpty) {
      _meeting = found.first;
    }

    final isUts = _meeting.isUts(widget.course.utsMeeting);
    final isUas = _meeting.isUas(widget.course.totalMeetings);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isUts
                  ? 'Pertemuan ${_meeting.meetingNumber} • UTS'
                  : isUas
                      ? 'Pertemuan ${_meeting.meetingNumber} • UAS'
                      : 'Pertemuan ${_meeting.meetingNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            Text(
              widget.course.name,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded, color: AppColors.primary, size: 28),
            tooltip: 'Simpan',
            onPressed: _saveMeeting,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Presensi Section
          _buildSectionHeader('Status Kehadiran', Icons.how_to_reg_outlined),
          const SizedBox(height: 10),
          _buildPresenceSelector(),

          const SizedBox(height: 24),

          // 2. Catatan Materi
          _buildSectionHeader('Catatan & Pokok Bahasan Materi', Icons.note_alt_outlined),
          const SizedBox(height: 10),
          TextField(
            controller: _topicController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Tulis ringkasan materi kuliah, pengumuman dosen, tugas pertemuan ini...',
            ),
          ),

          const SizedBox(height: 24),

          // 3. Kisi-kisi Ujian Toggle & Catatan
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _isExamClue ? AppColors.examClueBg.withValues(alpha: 0.3) : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isExamClue ? AppColors.examClue : AppColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text('🔥 ', style: TextStyle(fontSize: 18)),
                        Text(
                          'Tandai Sebagai Kisi-Kisi Ujian',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isExamClue,
                      activeThumbColor: AppColors.examClue,
                      onChanged: (val) {
                        setState(() => _isExamClue = val);
                      },
                    ),
                  ],
                ),
                if (_isExamClue) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: _examClueNotesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Tulis soal/topik spesifik yang dibocorkan dosen untuk ujian...',
                      labelText: 'Catatan Kisi-Kisi Ujian',
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 4. Brankas Lampiran Foto & Dokumen
          _buildSectionHeader('Brankas Foto Slide & Dokumen', Icons.attachment_rounded),
          const SizedBox(height: 6),
          const Text(
            'Foto papan tulis, slide materi, PDF, atau silabus kuliah.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          MediaAttachmentPicker(
            meetingId: _meeting.id,
            attachments: _meeting.attachments,
            onAttachmentAdded: (att) async {
              await context.read<MeetingProvider>().addAttachment(att);
            },
            onAttachmentRemoved: (att) async {
              await context.read<MeetingProvider>().removeAttachment(_meeting.id, att.id);
            },
          ),

          const SizedBox(height: 32),

          // Tombol Simpan
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _saveMeeting,
              icon: const Icon(Icons.save_rounded, color: Colors.white),
              label: const Text(
                'Simpan Catatan Pertemuan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPresenceSelector() {
    final options = [
      {'status': 'hadir', 'label': 'Hadir', 'color': AppColors.presenceHadir, 'bg': AppColors.presenceHadirBg},
      {'status': 'izin', 'label': 'Izin', 'color': AppColors.presenceIzin, 'bg': AppColors.presenceIzinBg},
      {'status': 'sakit', 'label': 'Sakit', 'color': AppColors.presenceSakit, 'bg': AppColors.presenceSakitBg},
      {'status': 'alpa', 'label': 'Alpa', 'color': AppColors.presenceAlpa, 'bg': AppColors.presenceAlpaBg},
    ];

    return Row(
      children: options.map((opt) {
        final status = opt['status'] as String;
        final label = opt['label'] as String;
        final color = opt['color'] as Color;
        final bg = opt['bg'] as Color;
        final isSelected = _selectedPresence == status;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () {
                setState(() => _selectedPresence = status);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? bg : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? color : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? color : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
