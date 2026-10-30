import 'package:flutter/material.dart';
import 'package:kuliahku/core/constants/app_colors.dart';
import 'package:kuliahku/core/utils/date_time_helper.dart';
import 'package:kuliahku/data/models/course_model.dart';
import 'package:kuliahku/presentation/providers/course_provider.dart';
import 'package:kuliahku/presentation/providers/meeting_provider.dart';
import 'package:kuliahku/presentation/screens/course/course_form_screen.dart';
import 'package:kuliahku/presentation/screens/meeting/meeting_detail_screen.dart';
import 'package:kuliahku/presentation/widgets/exam_clues_view.dart';
import 'package:kuliahku/presentation/widgets/grade_simulator_view.dart';
import 'package:kuliahku/presentation/widgets/meeting_tile.dart';
import 'package:provider/provider.dart';

class CourseDetailScreen extends StatefulWidget {
  final CourseModel course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late CourseModel _currentCourse;

  @override
  void initState() {
    super.initState();
    _currentCourse = widget.course;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeetingProvider>().loadMeetingsForCourse(_currentCourse.id);
    });
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Hapus Mata Kuliah?'),
        content: Text(
          'Mata kuliah "${_currentCourse.name}" beserta seluruh 16 jurnal pertemuan, foto catatan, dan simulasi nilainya akan dihapus secara permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await context.read<CourseProvider>().deleteCourse(_currentCourse.id);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mata kuliah berhasil dihapus.'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.zoneDanger),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Keep course reference updated if modified in CourseProvider
    final courseProvider = context.watch<CourseProvider>();
    final found = courseProvider.courses.where((c) => c.id == _currentCourse.id);
    if (found.isNotEmpty) {
      _currentCourse = found.first;
    }

    final absentCount = courseProvider.getAbsentCount(_currentCourse.id);
    final remainingQuota = _currentCourse.calculateRemainingQuota(absentCount);
    final zone = _currentCourse.calculateZone(absentCount);
    final dayName = DateTimeHelper.getDayName(_currentCourse.dayOfWeek);

    Color zoneColor;
    Color zoneBg;
    String zoneText;

    switch (zone) {
      case SecurityZone.safe:
        zoneColor = AppColors.zoneSafe;
        zoneBg = AppColors.zoneSafeBg;
        zoneText = 'Sisa $remainingQuota Bolos (Aman)';
        break;
      case SecurityZone.warning:
        zoneColor = AppColors.zoneWarning;
        zoneBg = AppColors.zoneWarningBg;
        zoneText = 'Sisa $remainingQuota Bolos (Waspada)';
        break;
      case SecurityZone.danger:
        zoneColor = AppColors.zoneDanger;
        zoneBg = AppColors.zoneDangerBg;
        zoneText = 'Sisa $remainingQuota Bolos (Bahaya!)';
        break;
      case SecurityZone.overdue:
        zoneColor = AppColors.zoneOverdue;
        zoneBg = AppColors.zoneOverdueBg;
        zoneText = 'Jatah Bolos Habis!';
        break;
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            _currentCourse.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Mata Kuliah',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CourseFormScreen(course: _currentCourse),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.zoneDanger),
              tooltip: 'Hapus Mata Kuliah',
              onPressed: _confirmDelete,
            ),
          ],
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(icon: Icon(Icons.view_agenda_outlined), text: 'Jurnal'),
              Tab(icon: Icon(Icons.local_fire_department_rounded), text: 'Kisi-Kisi'),
              Tab(icon: Icon(Icons.calculate_outlined), text: 'Simulasi Nilai'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Header Info Bar (PJ/Dosen, SKS, Ruang, Jam, Zona Bolos)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.surface,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'PJ / Dosen: ${_currentCourse.lecturer}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${_currentCourse.sks} SKS',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '$dayName, ${_currentCourse.startTime} - ${_currentCourse.endTime}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.room_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            _currentCourse.room ?? '-',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: zoneBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          zoneText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: zoneColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            // Tab Views
            Expanded(
              child: TabBarView(
                children: [
                  _buildJournalTab(context),
                  ExamCluesView(course: _currentCourse),
                  GradeSimulatorView(course: _currentCourse),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalTab(BuildContext context) {
    return Consumer<MeetingProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final utsNum = _currentCourse.utsMeeting;
        final totalNum = _currentCourse.totalMeetings;

        final preUtsMeetings = provider.getPreUtsMeetings(utsNum);
        final utsMeeting = provider.getUtsMeeting(utsNum);
        final preUasMeetings = provider.getPreUasMeetings(utsNum, totalNum);
        final uasMeeting = provider.getUasMeeting(totalNum);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Section: Pra-UTS
            _buildSectionHeader('Sesi Perkuliahan Pra-UTS (1 - ${utsNum - 1})'),
            const SizedBox(height: 8),
            ...preUtsMeetings.map((m) => _buildMeetingTile(context, m, provider)),

            const SizedBox(height: 16),

            // Section: Ujian Tengah Semester (UTS)
            _buildSectionHeader('Pelaksanaan UTS (Pertemuan $utsNum)'),
            const SizedBox(height: 8),
            if (utsMeeting != null) _buildMeetingTile(context, utsMeeting, provider),

            const SizedBox(height: 16),

            // Section: Pra-UAS
            _buildSectionHeader('Sesi Perkuliahan Pra-UAS (${utsNum + 1} - ${totalNum - 1})'),
            const SizedBox(height: 8),
            ...preUasMeetings.map((m) => _buildMeetingTile(context, m, provider)),

            const SizedBox(height: 16),

            // Section: Ujian Akhir Semester (UAS)
            _buildSectionHeader('Pelaksanaan UAS (Pertemuan $totalNum)'),
            const SizedBox(height: 8),
            if (uasMeeting != null) _buildMeetingTile(context, uasMeeting, provider),

            const SizedBox(height: 40),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMeetingTile(BuildContext context, dynamic meeting, MeetingProvider provider) {
    return MeetingTile(
      meeting: meeting,
      course: _currentCourse,
      onPresenceChanged: (newStatus) async {
        await provider.updatePresence(meeting.id, newStatus);
        if (context.mounted) {
          await context.read<CourseProvider>().refreshAbsentCounts();
        }
      },
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MeetingDetailScreen(
              course: _currentCourse,
              meeting: meeting,
            ),
          ),
        );
      },
    );
  }
}
