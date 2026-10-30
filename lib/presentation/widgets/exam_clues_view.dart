import 'package:flutter/material.dart';
import 'package:kuliahku/core/constants/app_colors.dart';
import 'package:kuliahku/data/models/course_model.dart';
import 'package:kuliahku/data/models/meeting_model.dart';
import 'package:kuliahku/presentation/providers/meeting_provider.dart';
import 'package:kuliahku/presentation/screens/meeting/meeting_detail_screen.dart';
import 'package:provider/provider.dart';

class ExamCluesView extends StatelessWidget {
  final CourseModel course;

  const ExamCluesView({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Consumer<MeetingProvider>(
      builder: (context, provider, child) {
        final preUtsClues = provider.getPreUtsExamClues(course.utsMeeting);
        final preUasClues = provider.getPreUasExamClues(course.utsMeeting);

        if (preUtsClues.isEmpty && preUasClues.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.examClueBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      size: 48,
                      color: AppColors.examClue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum Ada Kisi-Kisi Ujian',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Buka detail pertemuan dan aktifkan saklar "🔥 Kisi-Kisi Ujian" untuk merangkum catatan penting dan materi yang akan keluar di ujian.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (preUtsClues.isNotEmpty) ...[
              _buildSectionHeader(
                title: 'Kisi-Kisi UTS (Pertemuan 1 - ${course.utsMeeting})',
                badgeText: '${preUtsClues.length} Materi',
              ),
              const SizedBox(height: 10),
              ...preUtsClues.map((m) => _buildClueCard(context, m)),
              const SizedBox(height: 20),
            ],
            if (preUasClues.isNotEmpty) ...[
              _buildSectionHeader(
                title: 'Kisi-Kisi UAS (Pertemuan ${course.utsMeeting + 1} - ${course.totalMeetings})',
                badgeText: '${preUasClues.length} Materi',
              ),
              const SizedBox(height: 10),
              ...preUasClues.map((m) => _buildClueCard(context, m)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader({required String title, required String badgeText}) {
    return Row(
      children: [
        const Icon(Icons.local_fire_department_rounded, size: 20, color: AppColors.examClue),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.examClueBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            badgeText,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.examClue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClueCard(BuildContext context, MeetingModel meeting) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MeetingDetailScreen(
                course: course,
                meeting: meeting,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Pertemuan ${meeting.meetingNumber}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  if (meeting.attachments.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.attach_file, size: 14, color: AppColors.primary),
                        const SizedBox(width: 2),
                        Text(
                          '${meeting.attachments.length} berkas',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                (meeting.topic == null || meeting.topic!.trim().isEmpty)
                    ? 'Pertemuan ${meeting.meetingNumber}'
                    : meeting.topic!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (meeting.examClueNotes != null && meeting.examClueNotes!.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.examClueBg.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.examClue.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🔥 ', style: TextStyle(fontSize: 13)),
                      Expanded(
                        child: Text(
                          meeting.examClueNotes!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
