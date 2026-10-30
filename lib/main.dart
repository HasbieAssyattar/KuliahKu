import 'package:flutter/material.dart';
import 'package:kuliahku/core/theme/app_theme.dart';
import 'package:kuliahku/presentation/providers/course_provider.dart';
import 'package:kuliahku/presentation/providers/grade_provider.dart';
import 'package:kuliahku/presentation/providers/meeting_provider.dart';
import 'package:kuliahku/presentation/screens/home/home_screen.dart';
import 'package:kuliahku/services/notification_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi alarm pengingat kuliah
  try {
    await NotificationService.instance.init();
  } catch (_) {
    // Graceful handling jika device membatasi background alarm
  }

  runApp(const KuliahKuApp());
}

class KuliahKuApp extends StatelessWidget {
  const KuliahKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => MeetingProvider()),
        ChangeNotifierProvider(create: (_) => GradeProvider()),
      ],
      child: MaterialApp(
        title: 'KuliahKu',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
