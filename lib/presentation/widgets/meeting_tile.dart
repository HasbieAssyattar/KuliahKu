import 'package:flutter/material.dart';
import 'package:kuliahku/core/constants/app_colors.dart';
import 'package:kuliahku/data/models/course_model.dart';
import 'package:kuliahku/data/models/meeting_model.dart';

class MeetingTile extends StatelessWidget {
  final MeetingModel meeting;
  final CourseModel course;
  final ValueChanged<String>? onPresenceChanged;
  final VoidCallback? onTap;

  const MeetingTile({
    super.key,
    required this.meeting,
    required this.course,
    this.onPresenceChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUts = meeting.isUts(course.utsMeeting);
    final isUas = meeting.isUas(course.totalMeetings);

    Color statusColor;
    Color statusBg;
    String statusLabel;

    switch (meeting.presenceStatus) {
      case 'hadir':
        statusColor = AppColors.presenceHadir;
        statusBg = AppColors.presenceHadirBg;
        statusLabel = 'Hadir';
        break;
      case 'izin':
        statusColor = AppColors.presenceIzin;
        statusBg = AppColors.presenceIzinBg;
        statusLabel = 'Izin';
        break;
      case 'sakit':
        statusColor = AppColors.presenceSakit;
        statusBg = AppColors.presenceSakitBg;
        statusLabel = 'Sakit';
        break;
      case 'alpa':
        statusColor = AppColors.presenceAlpa;
        statusBg = AppColors.presenceAlpaBg;
        statusLabel = 'Alpa';
        break;
      default:
        statusColor = AppColors.textMuted;
        statusBg = AppColors.surfaceVariant;
        statusLabel = 'Belum';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isUts || isUas
            ? AppColors.primaryLight.withValues(alpha: 0.3)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUts || isUas ? AppColors.primary.withValues(alpha: 0.4) : AppColors.border,
          width: isUts || isUas ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Meeting Number Circle / Special Badge
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isUts || isUas ? AppColors.primary : AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isUts
                        ? 'UTS'
                        : isUas
                            ? 'UAS'
                            : '${meeting.meetingNumber}',
                    style: TextStyle(
                      fontSize: (isUts || isUas) ? 11 : 14,
                      fontWeight: FontWeight.bold,
                      color: isUts || isUas ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Info: Title, topic, tags
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isUts
                                ? 'Pertemuan ${meeting.meetingNumber} • UTS'
                                : isUas
                                    ? 'Pertemuan ${meeting.meetingNumber} • UAS'
                                    : 'Pertemuan ${meeting.meetingNumber}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isUts || isUas ? AppColors.primaryDark : AppColors.textPrimary,
                            ),
                          ),
                          if (meeting.isExamClue) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.examClueBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '🔥 Kisi-Kisi',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.examClue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        (meeting.topic == null || meeting.topic!.trim().isEmpty)
                            ? 'Belum ada catatan materi'
                            : meeting.topic!,
                        style: TextStyle(
                          fontSize: 12,
                          color: (meeting.topic == null || meeting.topic!.trim().isEmpty)
                              ? AppColors.textMuted
                              : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (meeting.attachments.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.attach_file_rounded, size: 12, color: AppColors.primary),
                            const SizedBox(width: 2),
                            Text(
                              '${meeting.attachments.length} Berkas tersimpan',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Presensi Status Button / PopupMenu
                PopupMenuButton<String>(
                  initialValue: meeting.presenceStatus,
                  tooltip: 'Ubah Presensi',
                  onSelected: (val) {
                    onPresenceChanged?.call(val);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'hadir', child: Text('Hadir (Hijau)')),
                    const PopupMenuItem(value: 'izin', child: Text('Izin (Biru)')),
                    const PopupMenuItem(value: 'sakit', child: Text('Sakit (Oranye)')),
                    const PopupMenuItem(value: 'alpa', child: Text('Alpa (Merah)')),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down, size: 16, color: statusColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
