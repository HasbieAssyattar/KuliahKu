import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kuliahku/core/constants/app_constants.dart';

class DateTimeHelper {
  static String getDayName(int dayOfWeek) {
    if (dayOfWeek >= 1 && dayOfWeek <= AppConstants.days.length) {
      return AppConstants.days[dayOfWeek - 1];
    }
    return 'Lainnya';
  }

  static int getTodayDayOfWeek() {
    return DateTime.now().weekday; // 1 = Monday (Senin), 7 = Sunday
  }

  static String formatDateShort(DateTime? date) {
    if (date == null) return '-';
    try {
      return DateFormat('d MMM yyyy', 'id').format(date);
    } catch (_) {
      return DateFormat('d MMM yyyy').format(date);
    }
  }

  static String formatDateWithDay(DateTime? date) {
    if (date == null) return '-';
    try {
      return DateFormat('EEEE, d MMMM yyyy', 'id').format(date);
    } catch (_) {
      return DateFormat('EEEE, d MMMM yyyy').format(date);
    }
  }

  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static TimeOfDay parseTimeOfDay(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return const TimeOfDay(hour: 8, minute: 0);
    }
  }
}
