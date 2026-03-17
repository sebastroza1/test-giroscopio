import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/di.dart';
import 'features/motion_monitor/presentation/controller/motion_controller.dart';
import 'features/motion_monitor/presentation/pages/motion_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();

  runApp(const AcvMotionMonitorApp());
}

class AcvMotionMonitorApp extends StatelessWidget {
  const AcvMotionMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<MotionController>()..initialize(),
      child: MaterialApp(
        title: 'ACV Motion Monitor',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const MotionPage(),
      ),
    );
  }
}
