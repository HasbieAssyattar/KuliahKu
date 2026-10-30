import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Akademik & Modern)
  static const Color primary = Color(0xFF2563EB); // Royal Blue
  static const Color primaryDark = Color(0xFF1E3A8A); // Deep Navy
  static const Color primaryLight = Color(0xFFDBEAFE); // Soft Blue

  // Accent
  static const Color accent = Color(0xFF0D9488); // Teal
  static const Color accentLight = Color(0xFFCCFBF1);

  // Background & Surface
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Zona Keamanan Presensi (Jatah Bolos)
  static const Color zoneSafe = Color(0xFF059669); // Hijau (Aman >= 3)
  static const Color zoneSafeBg = Color(0xFFD1FAE5);

  static const Color zoneWarning = Color(0xFFD97706); // Kuning/Amber (Waspada = 2)
  static const Color zoneWarningBg = Color(0xFFFEF3C7);

  static const Color zoneDanger = Color(0xFFDC2626); // Merah (Kritis <= 1)
  static const Color zoneDangerBg = Color(0xFFFEE2E2);

  static const Color zoneOverdue = Color(0xFF991B1B); // Merah Pekat (Jatah Habis <= 0)
  static const Color zoneOverdueBg = Color(0xFFFFCDD2);

  // Status Kehadiran Pertemuan
  static const Color presenceHadir = Color(0xFF059669); // Hijau
  static const Color presenceHadirBg = Color(0xFFECFDF5);

  static const Color presenceIzin = Color(0xFF2563EB); // Biru
  static const Color presenceIzinBg = Color(0xFFEFF6FF);

  static const Color presenceSakit = Color(0xFFD97706); // Oranye
  static const Color presenceSakitBg = Color(0xFFFFFBEB);

  static const Color presenceAlpa = Color(0xFFDC2626); // Merah
  static const Color presenceAlpaBg = Color(0xFFFEF2F2);

  // Penanda Kisi-Kisi Ujian
  static const Color examClue = Color(0xFFEA580C); // Flame Orange
  static const Color examClueBg = Color(0xFFFFEDD5);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
}
