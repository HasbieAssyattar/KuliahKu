import 'package:flutter/material.dart';
import 'package:kuliahku/core/constants/app_colors.dart';
import 'package:kuliahku/data/models/course_model.dart';
import 'package:kuliahku/data/models/course_score_model.dart';
import 'package:kuliahku/presentation/providers/grade_provider.dart';
import 'package:provider/provider.dart';

class GradeSimulatorView extends StatefulWidget {
  final CourseModel course;

  const GradeSimulatorView({super.key, required this.course});

  @override
  State<GradeSimulatorView> createState() => _GradeSimulatorViewState();
}

class _GradeSimulatorViewState extends State<GradeSimulatorView> {
  late TextEditingController _presenceController;
  late TextEditingController _assignmentController;
  late TextEditingController _utsController;
  late TextEditingController _uasController;

  late String _targetGrade;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _targetGrade = widget.course.targetGrade;
    _presenceController = TextEditingController();
    _assignmentController = TextEditingController();
    _utsController = TextEditingController();
    _uasController = TextEditingController();

    _presenceController.addListener(() => setState(() {}));
    _assignmentController.addListener(() => setState(() {}));
    _utsController.addListener(() => setState(() {}));
    _uasController.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final gradeProvider = context.read<GradeProvider>();
      gradeProvider.loadScore(widget.course.id).then((_) {
        final score = gradeProvider.currentScore;
        if (score != null && mounted) {
          if (score.scorePresence != null) {
            _presenceController.text = score.scorePresence!.toStringAsFixed(0);
          }
          if (score.scoreAssignment != null) {
            _assignmentController.text = score.scoreAssignment!.toStringAsFixed(0);
          }
          if (score.scoreUts != null) {
            _utsController.text = score.scoreUts!.toStringAsFixed(0);
          }
          if (score.scoreUas != null) {
            _uasController.text = score.scoreUas!.toStringAsFixed(0);
          }
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _presenceController.dispose();
    _assignmentController.dispose();
    _utsController.dispose();
    _uasController.dispose();
    super.dispose();
  }

  double? _parseDouble(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  double _calculateCurrentTotal() {
    final p = _parseDouble(_presenceController) ?? 0.0;
    final a = _parseDouble(_assignmentController) ?? 0.0;
    final uts = _parseDouble(_utsController) ?? 0.0;
    final uas = _parseDouble(_uasController) ?? 0.0;

    return (p * widget.course.weightPresence / 100) +
        (a * widget.course.weightAssignment / 100) +
        (uts * widget.course.weightUts / 100) +
        (uas * widget.course.weightUas / 100);
  }

  double? _calculateNeededUas() {
    if (widget.course.weightUas <= 0) return null;

    final gradeProvider = context.read<GradeProvider>();
    final minScore = gradeProvider.getMinTargetScore(_targetGrade);

    final p = _parseDouble(_presenceController) ?? 0.0;
    final a = _parseDouble(_assignmentController) ?? 0.0;
    final uts = _parseDouble(_utsController) ?? 0.0;

    final currentWithoutUas = (p * widget.course.weightPresence / 100) +
        (a * widget.course.weightAssignment / 100) +
        (uts * widget.course.weightUts / 100);

    final needed = minScore - currentWithoutUas;
    final uasRequired = needed / (widget.course.weightUas / 100);
    return uasRequired;
  }

  Future<void> _saveScores() async {
    final p = _parseDouble(_presenceController);
    final a = _parseDouble(_assignmentController);
    final uts = _parseDouble(_utsController);
    final uas = _parseDouble(_uasController);

    await context.read<GradeProvider>().updateScore(
          course: widget.course,
          scorePresence: p,
          scoreAssignment: a,
          scoreUts: uts,
          scoreUas: uas,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nilai berhasil disimpan secara permanen!'),
          backgroundColor: AppColors.zoneSafe,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTotal = _calculateCurrentTotal();
    final currentLetter = CourseScoreModel.getGradeLetter(currentTotal);
    final neededUas = _calculateNeededUas();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Kartu Ringkasan Proyeksi Nilai
        Container(
          padding: const EdgeInsets.all(18),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Akumulasi Nilai Saat Ini',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currentTotal.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Target Mata Kuliah: $_targetGrade',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white30, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  currentLetter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 2. Kalkulator Target UAS Minimal
        _buildNeededUasCard(neededUas),

        const SizedBox(height: 20),

        // 3. Input Nilai Komponen
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Input Komponen Nilai',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            DropdownButton<String>(
              value: _targetGrade,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'A', child: Text('Target A (>=80)')),
                DropdownMenuItem(value: 'B+', child: Text('Target B+ (>=75)')),
                DropdownMenuItem(value: 'B', child: Text('Target B (>=70)')),
                DropdownMenuItem(value: 'C+', child: Text('Target C+ (>=65)')),
                DropdownMenuItem(value: 'C', child: Text('Target C (>=60)')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _targetGrade = val);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Form Fields (Presensi, Tugas, UTS, UAS)
        _buildScoreField(
          label: 'Presensi (${widget.course.weightPresence.toStringAsFixed(0)}%)',
          controller: _presenceController,
          hint: '0 - 100',
        ),
        const SizedBox(height: 10),
        _buildScoreField(
          label: 'Tugas / Praktikum (${widget.course.weightAssignment.toStringAsFixed(0)}%)',
          controller: _assignmentController,
          hint: '0 - 100',
        ),
        const SizedBox(height: 10),
        _buildScoreField(
          label: 'Ujian Tengah Semester / UTS (${widget.course.weightUts.toStringAsFixed(0)}%)',
          controller: _utsController,
          hint: '0 - 100',
        ),
        const SizedBox(height: 10),
        _buildScoreField(
          label: 'Ujian Akhir Semester / UAS (${widget.course.weightUas.toStringAsFixed(0)}%)',
          controller: _uasController,
          hint: '0 - 100 (kosongkan jika belum)',
        ),

        const SizedBox(height: 24),

        // Simpan Nilai Button
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _saveScores,
            icon: const Icon(Icons.save_rounded, color: Colors.white),
            label: const Text(
              'Simpan Nilai Perkuliahan',
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
    );
  }

  Widget _buildNeededUasCard(double? neededUas) {
    if (neededUas == null) return const SizedBox.shrink();

    Color cardBg;
    Color borderColor;
    Color textColor;
    IconData icon;
    String statusTitle;
    String statusDesc;

    if (neededUas <= 0) {
      cardBg = AppColors.zoneSafeBg;
      borderColor = AppColors.zoneSafe;
      textColor = AppColors.zoneSafe;
      icon = Icons.check_circle_rounded;
      statusTitle = 'Target $_targetGrade Sudah Terkunci!';
      statusDesc = 'Bahkan tanpa nilai UAS (0), total nilai kamu sudah mencukupi target grade $_targetGrade 🎉';
    } else if (neededUas <= 80) {
      cardBg = AppColors.zoneSafeBg;
      borderColor = AppColors.zoneSafe;
      textColor = AppColors.zoneSafe;
      icon = Icons.flag_rounded;
      statusTitle = 'Target Skor UAS: ${neededUas.toStringAsFixed(1)}';
      statusDesc = 'Raih minimal nilai ${neededUas.toStringAsFixed(1)} pada UAS untuk mendapatkan huruf mutu $_targetGrade.';
    } else if (neededUas <= 100) {
      cardBg = AppColors.zoneWarningBg;
      borderColor = AppColors.zoneWarning;
      textColor = AppColors.zoneWarning;
      icon = Icons.warning_amber_rounded;
      statusTitle = 'Target Skor UAS: ${neededUas.toStringAsFixed(1)}';
      statusDesc = 'Skor UAS cukup tinggi! Kamu perlu persiapan ekstra intensif agar tembus target $_targetGrade ⚡';
    } else {
      cardBg = AppColors.zoneDangerBg;
      borderColor = AppColors.zoneDanger;
      textColor = AppColors.zoneDanger;
      icon = Icons.error_outline_rounded;
      statusTitle = 'Target Membutuhkan UAS: ${neededUas.toStringAsFixed(1)}';
      statusDesc = 'Secara matematis target $_targetGrade membutuhkan nilai UAS di atas 100. Disarankan membidik target grade satu tingkat di bawahnya.';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusTitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusDesc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: hint,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
