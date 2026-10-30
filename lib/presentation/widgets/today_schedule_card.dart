import 'package:flutter/material.dart';
import 'package:kuliahku/core/constants/app_colors.dart';
import 'package:kuliahku/data/models/course_model.dart';

class TodayScheduleCard extends StatelessWidget {
  final CourseModel course;
  final int absentCount;
  final VoidCallback? onTap;

  const TodayScheduleCard({
    super.key,
    required this.course,
    required this.absentCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final remainingQuota = course.calculateRemainingQuota(absentCount);
    final zone = course.calculateZone(absentCount);

    Color badgeColor;
    Color badgeBg;
    String badgeText;
    IconData badgeIcon;

    switch (zone) {
      case SecurityZone.safe:
        badgeColor = AppColors.zoneSafe;
        badgeBg = AppColors.zoneSafeBg;
        badgeText = 'Sisa Bolos: $remainingQuota';
        badgeIcon = Icons.check_circle_outline;
        break;
      case SecurityZone.warning:
        badgeColor = AppColors.zoneWarning;
        badgeBg = AppColors.zoneWarningBg;
        badgeText = 'Sisa Bolos: $remainingQuota (Waspada)';
        badgeIcon = Icons.warning_amber_rounded;
        break;
      case SecurityZone.danger:
        badgeColor = AppColors.zoneDanger;
        badgeBg = AppColors.zoneDangerBg;
        badgeText = 'Sisa Bolos: $remainingQuota (Bahaya!)';
        badgeIcon = Icons.error_outline;
        break;
      case SecurityZone.overdue:
        badgeColor = AppColors.zoneOverdue;
        badgeBg = AppColors.zoneOverdueBg;
        badgeText = 'Jatah Bolos Habis!';
        badgeIcon = Icons.cancel_outlined;
        break;
    }

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${course.sks} SKS',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(badgeIcon, size: 12, color: badgeColor),
                              const SizedBox(width: 4),
                              Text(
                                badgeText,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: badgeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      course.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'PJ/Dosen: ${course.lecturer}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${course.startTime} - ${course.endTime}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.room_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          course.room ?? '-',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
