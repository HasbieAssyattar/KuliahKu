import 'package:flutter/material.dart';
import 'package:kuliahku/core/constants/app_colors.dart';
import 'package:kuliahku/core/constants/app_constants.dart';
import 'package:kuliahku/core/utils/date_time_helper.dart';
import 'package:kuliahku/presentation/providers/course_provider.dart';
import 'package:kuliahku/presentation/screens/course/course_detail_screen.dart';
import 'package:kuliahku/presentation/screens/course/course_form_screen.dart';
import 'package:kuliahku/presentation/widgets/course_card.dart';
import 'package:kuliahku/presentation/widgets/today_schedule_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.school_rounded, color: AppColors.primary, size: 28),
            SizedBox(width: 10),
            Text(
              'KuliahKu',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            tooltip: 'Segarkan',
            onPressed: () {
              context.read<CourseProvider>().loadCourses();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<CourseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final courses = provider.courses;
          final todayCourses = provider.todayCourses;
          final filteredCourses = provider.filteredCoursesByDay;

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadCourses();
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // 1. Stats Card (Overview SKS & Matkul)
                _buildSemesterStats(provider.totalSks, courses.length),
                const SizedBox(height: 20),

                // 2. Jadwal Hari Ini Section
                Row(
                  children: [
                    const Icon(Icons.today_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Jadwal Hari Ini (${DateTimeHelper.getDayName(DateTimeHelper.getTodayDayOfWeek())})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (todayCourses.isEmpty)
                  _buildNoTodaySchedule()
                else
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: todayCourses.length,
                      itemBuilder: (context, index) {
                        final course = todayCourses[index];
                        return TodayScheduleCard(
                          course: course,
                          absentCount: provider.getAbsentCount(course.id),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CourseDetailScreen(course: course),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 24),

                // 3. Filter Hari Chips
                _buildDayFilterChips(context, provider),

                const SizedBox(height: 16),

                // 4. Header Daftar Matkul
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      provider.selectedDayFilter == 0
                          ? 'Semua Mata Kuliah (${filteredCourses.length})'
                          : 'Kuliah ${DateTimeHelper.getDayName(provider.selectedDayFilter)} (${filteredCourses.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 5. Course List
                if (filteredCourses.isEmpty)
                  _buildEmptyCourseState(provider.selectedDayFilter)
                else
                  ...filteredCourses.map(
                    (course) => CourseCard(
                      course: course,
                      absentCount: provider.getAbsentCount(course.id),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CourseDetailScreen(course: course),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 60), // Space for FAB
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CourseFormScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        tooltip: 'Tambah Mata Kuliah',
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildSemesterStats(int totalSks, int totalCourses) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text(
                'Total SKS',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalSks SKS',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            height: 36,
            width: 1,
            color: Colors.white24,
          ),
          Column(
            children: [
              const Text(
                'Total Mata Kuliah',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalCourses Matkul',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoTodaySchedule() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.weekend_rounded, color: AppColors.accent, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tidak ada jadwal kuliah hari ini. Waktunya istirahat atau review materi! 🎉',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayFilterChips(BuildContext context, CourseProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            label: 'Semua',
            isSelected: provider.selectedDayFilter == 0,
            onSelected: () => provider.setSelectedDayFilter(0),
          ),
          const SizedBox(width: 8),
          ...List.generate(AppConstants.days.length, (index) {
            final dayNumber = index + 1;
            final dayName = AppConstants.days[index];
            final isToday = dayNumber == DateTimeHelper.getTodayDayOfWeek();
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(
                label: isToday ? '$dayName (Hari ini)' : dayName,
                isSelected: provider.selectedDayFilter == dayNumber,
                onSelected: () => provider.setSelectedDayFilter(dayNumber),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primaryLight,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false,
    );
  }

  Widget _buildEmptyCourseState(int filterDay) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 56,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            filterDay == 0
                ? 'Belum ada mata kuliah yang didaftarkan.'
                : 'Tidak ada kuliah di hari ${DateTimeHelper.getDayName(filterDay)}.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tekan tombol "+" di bawah untuk menambahkan mata kuliah.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
