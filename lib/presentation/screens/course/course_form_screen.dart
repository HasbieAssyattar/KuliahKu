import 'package:flutter/material.dart';
import 'package:kuliahku/core/constants/app_colors.dart';
import 'package:kuliahku/core/constants/app_constants.dart';
import 'package:kuliahku/core/utils/date_time_helper.dart';
import 'package:kuliahku/data/models/course_model.dart';
import 'package:kuliahku/presentation/providers/course_provider.dart';
import 'package:kuliahku/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CourseFormScreen extends StatefulWidget {
  final CourseModel? course;

  const CourseFormScreen({super.key, this.course});

  @override
  State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _sksController;
  late TextEditingController _lecturerController;
  late TextEditingController _roomController;
  late TextEditingController _maxAbsenceController;
  late TextEditingController _utsMeetingController;
  late TextEditingController _totalMeetingsController;

  // Controllers untuk 4 komponen bobot penilaian manual
  late TextEditingController _weightPresenceController;
  late TextEditingController _weightAssignmentController;
  late TextEditingController _weightUtsController;
  late TextEditingController _weightUasController;

  late int _selectedDayOfWeek;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late String _targetGrade;

  bool get _isEditMode => widget.course != null;

  @override
  void initState() {
    super.initState();
    final c = widget.course;

    _nameController = TextEditingController(text: c?.name ?? '');
    _sksController = TextEditingController(text: (c?.sks ?? 3).toString());
    _lecturerController = TextEditingController(text: c?.lecturer ?? '');
    _roomController = TextEditingController(text: c?.room ?? '');
    _maxAbsenceController = TextEditingController(text: (c?.maxAbsence ?? 4).toString());
    _utsMeetingController = TextEditingController(text: (c?.utsMeeting ?? 8).toString());
    _totalMeetingsController = TextEditingController(text: (c?.totalMeetings ?? 16).toString());

    _weightPresenceController = TextEditingController(
      text: (c?.weightPresence ?? AppConstants.defaultWeightPresence).toStringAsFixed(0),
    );
    _weightAssignmentController = TextEditingController(
      text: (c?.weightAssignment ?? AppConstants.defaultWeightAssignment).toStringAsFixed(0),
    );
    _weightUtsController = TextEditingController(
      text: (c?.weightUts ?? AppConstants.defaultWeightUts).toStringAsFixed(0),
    );
    _weightUasController = TextEditingController(
      text: (c?.weightUas ?? AppConstants.defaultWeightUas).toStringAsFixed(0),
    );

    _selectedDayOfWeek = c?.dayOfWeek ?? DateTimeHelper.getTodayDayOfWeek().clamp(1, 6);
    _startTime = c != null ? DateTimeHelper.parseTimeOfDay(c.startTime) : const TimeOfDay(hour: 8, minute: 0);
    _endTime = c != null ? DateTimeHelper.parseTimeOfDay(c.endTime) : const TimeOfDay(hour: 10, minute: 30);
    _targetGrade = c?.targetGrade ?? 'A';

    _weightPresenceController.addListener(() => setState(() {}));
    _weightAssignmentController.addListener(() => setState(() {}));
    _weightUtsController.addListener(() => setState(() {}));
    _weightUasController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sksController.dispose();
    _lecturerController.dispose();
    _roomController.dispose();
    _maxAbsenceController.dispose();
    _utsMeetingController.dispose();
    _totalMeetingsController.dispose();
    _weightPresenceController.dispose();
    _weightAssignmentController.dispose();
    _weightUtsController.dispose();
    _weightUasController.dispose();
    super.dispose();
  }

  double get _totalWeight {
    final wp = double.tryParse(_weightPresenceController.text) ?? 0.0;
    final wa = double.tryParse(_weightAssignmentController.text) ?? 0.0;
    final wuts = double.tryParse(_weightUtsController.text) ?? 0.0;
    final wuas = double.tryParse(_weightUasController.text) ?? 0.0;
    return wp + wa + wuts + wuas;
  }

  bool get _isWeightValid => (_totalWeight - 100.0).abs() < 0.01;

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isWeightValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Total bobot penilaian harus tepat 100%! (Saat ini: ${_totalWeight.toStringAsFixed(0)}%)',
          ),
          backgroundColor: AppColors.zoneDanger,
        ),
      );
      return;
    }

    final id = widget.course?.id ?? const Uuid().v4();
    final name = _nameController.text.trim();
    final sks = int.parse(_sksController.text.trim());
    final lecturer = _lecturerController.text.trim();
    final room = _roomController.text.trim();
    final maxAbsence = int.parse(_maxAbsenceController.text.trim());
    final utsMeeting = int.parse(_utsMeetingController.text.trim());
    final totalMeetings = int.parse(_totalMeetingsController.text.trim());

    final wp = double.parse(_weightPresenceController.text.trim());
    final wa = double.parse(_weightAssignmentController.text.trim());
    final wuts = double.parse(_weightUtsController.text.trim());
    final wuas = double.parse(_weightUasController.text.trim());

    final startTimeStr = DateTimeHelper.formatTimeOfDay(_startTime);
    final endTimeStr = DateTimeHelper.formatTimeOfDay(_endTime);

    final updatedCourse = CourseModel(
      id: id,
      name: name,
      sks: sks,
      lecturer: lecturer,
      room: room,
      dayOfWeek: _selectedDayOfWeek,
      startTime: startTimeStr,
      endTime: endTimeStr,
      maxAbsence: maxAbsence,
      utsMeeting: utsMeeting,
      totalMeetings: totalMeetings,
      weightPresence: wp,
      weightAssignment: wa,
      weightUts: wuts,
      weightUas: wuas,
      targetGrade: _targetGrade,
      createdAt: widget.course?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final provider = context.read<CourseProvider>();
    if (_isEditMode) {
      await provider.updateCourse(updatedCourse);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mata kuliah berhasil diperbarui!'),
          backgroundColor: AppColors.zoneSafe,
        ),
      );
    } else {
      await provider.addCourse(updatedCourse);
      // Jadwalkan notifikasi kuliah (30 menit sebelumnya)
      NotificationService.instance.scheduleClassReminder(
        id: updatedCourse.name.hashCode,
        title: 'Pengingat Kuliah: ${updatedCourse.name}',
        body: 'Kelas dimulai dalam 30 menit (${updatedCourse.startTime}) di ruang ${updatedCourse.room ?? '-'}',
        dayOfWeek: updatedCourse.dayOfWeek,
        startTime: _startTime,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mata kuliah berhasil ditambahkan beserta 16 sesi pertemuan!'),
          backgroundColor: AppColors.zoneSafe,
        ),
      );
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Mata Kuliah' : 'Tambah Mata Kuliah',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // 1. Kartu Identitas Mata Kuliah
            _buildFormCard(
              title: 'Informasi Perkuliahan',
              icon: Icons.school_outlined,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Mata Kuliah *',
                    hintText: 'Misal: Pemrograman Mobile Lanjut',
                  ),
                  validator: (val) =>
                      (val == null || val.trim().isEmpty) ? 'Nama mata kuliah wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lecturerController,
                  decoration: const InputDecoration(
                    labelText: 'Nama PJ / Dosen *',
                    hintText: 'Misal: Pak Budi, M.Kom / PJ: Hasbi',
                  ),
                  validator: (val) =>
                      (val == null || val.trim().isEmpty) ? 'Nama PJ / Dosen wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _sksController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'SKS *',
                          hintText: '3',
                        ),
                        validator: (val) {
                          final n = int.tryParse(val ?? '');
                          if (n == null || n <= 0 || n > 8) return '1-8 SKS';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _roomController,
                        decoration: const InputDecoration(
                          labelText: 'Ruangan Kuliah *',
                          hintText: 'Lab 2 / R.301',
                        ),
                        validator: (val) =>
                            (val == null || val.trim().isEmpty) ? 'Ruang wajib diisi' : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // 2. Kartu Jadwal & Waktu
            _buildFormCard(
              title: 'Jadwal & Waktu Kuliah',
              icon: Icons.access_time_rounded,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: _selectedDayOfWeek,
                  decoration: const InputDecoration(
                    labelText: 'Hari Perkuliahan',
                  ),
                  items: List.generate(AppConstants.days.length, (index) {
                    return DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text(AppConstants.days[index]),
                    );
                  }),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDayOfWeek = val);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickStartTime,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Jam Mulai',
                            suffixIcon: Icon(Icons.schedule, size: 18),
                          ),
                          child: Text(
                            DateTimeHelper.formatTimeOfDay(_startTime),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _pickEndTime,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Jam Selesai',
                            suffixIcon: Icon(Icons.schedule_outlined, size: 18),
                          ),
                          child: Text(
                            DateTimeHelper.formatTimeOfDay(_endTime),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // 3. Kartu Absensi & Pertemuan Fleksibel
            _buildFormCard(
              title: 'Absensi & Posisi Pertemuan',
              icon: Icons.event_note_outlined,
              children: [
                TextFormField(
                  controller: _maxAbsenceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Jatah Bolos Maksimal',
                    helperText: 'Batas toleransi absen satu semester (default: 4x)',
                  ),
                  validator: (val) {
                    final n = int.tryParse(val ?? '');
                    if (n == null || n < 1) return 'Minimal 1 kali';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _utsMeetingController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Pertemuan UTS (Fleksibel)',
                    helperText: 'Sesi pelaksanaan UTS (default pertemuan 8)',
                  ),
                  validator: (val) {
                    final n = int.tryParse(val ?? '');
                    final total = int.tryParse(_totalMeetingsController.text) ?? 16;
                    if (n == null || n <= 1 || n >= total) return 'Harus di antara 2 dan $total';
                    return null;
                  },
                ),
              ],
            ),

            // 4. Kartu Bobot Penilaian Manual
            _buildFormCard(
              title: 'Bobot Penilaian Manual (%)',
              icon: Icons.calculate_outlined,
              children: [
                const Text(
                  'Atur persentase bobot per kelas sesuai kontrak kuliah. Total harus tepat 100%.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                _buildWeightRow(
                  label: 'Presensi / Kehadiran',
                  subtitle: 'Keaktifan absensi kelas',
                  controller: _weightPresenceController,
                ),
                const Divider(height: 14, color: AppColors.borderLight),
                _buildWeightRow(
                  label: 'Tugas & Praktikum',
                  subtitle: 'Kuis, PR, & tugas kelompok',
                  controller: _weightAssignmentController,
                ),
                const Divider(height: 14, color: AppColors.borderLight),
                _buildWeightRow(
                  label: 'Ujian Tengah Semester (UTS)',
                  subtitle: 'Bobot nilai ujian tengah',
                  controller: _weightUtsController,
                ),
                const Divider(height: 14, color: AppColors.borderLight),
                _buildWeightRow(
                  label: 'Ujian Akhir Semester (UAS)',
                  subtitle: 'Bobot nilai ujian akhir',
                  controller: _weightUasController,
                ),
                const SizedBox(height: 14),
                // Indikator Real-time Total Bobot
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _isWeightValid ? AppColors.zoneSafeBg : AppColors.zoneDangerBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isWeightValid ? AppColors.zoneSafe : AppColors.zoneDanger,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isWeightValid ? Icons.check_circle : Icons.warning_amber_rounded,
                        size: 20,
                        color: _isWeightValid ? AppColors.zoneSafe : AppColors.zoneDanger,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Total Bobot: ${_totalWeight.toStringAsFixed(0)}% ${_isWeightValid ? '(Valid 100%)' : '(Wajib tepat 100%)'}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _isWeightValid ? AppColors.zoneSafe : AppColors.zoneDanger,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 5. Kartu Target Huruf Nilai
            _buildFormCard(
              title: 'Target Nilai Akhir',
              icon: Icons.military_tech_outlined,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _targetGrade,
                  decoration: const InputDecoration(
                    labelText: 'Target Huruf Mutu',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'A', child: Text('Target: A (Skor >= 80)')),
                    DropdownMenuItem(value: 'B+', child: Text('Target: B+ (Skor >= 75)')),
                    DropdownMenuItem(value: 'B', child: Text('Target: B (Skor >= 70)')),
                    DropdownMenuItem(value: 'C+', child: Text('Target: C+ (Skor >= 65)')),
                    DropdownMenuItem(value: 'C', child: Text('Target: C (Skor >= 60)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _targetGrade = val);
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 6. Tombol Simpan
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: Text(
                  _isEditMode ? 'Simpan Perubahan' : 'Buat Mata Kuliah Baru',
                  style: const TextStyle(
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
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppColors.borderLight),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildWeightRow({
    required String label,
    required String subtitle,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 85,
            child: TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.primary,
              ),
              decoration: const InputDecoration(
                suffixText: '%',
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                isDense: true,
              ),
              validator: (v) => (double.tryParse(v ?? '') == null) ? 'Angka valid' : null,
            ),
          ),
        ],
      ),
    );
  }
}
