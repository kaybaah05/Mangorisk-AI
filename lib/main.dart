import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'router.dart';
import 'providers/app_provider.dart';
import 'theme/theme.dart';

// ── Supabase credentials ─
const String supabaseUrl = 'https://jvrujrbjctvumuibzosg.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp2cnVqcmJqY3R2dW11aWJ6b3NnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMxODE4NzMsImV4cCI6MjA4ODc1Nzg3M30.5x0ruKGbvB2Y5IZ0lIyPpCk0tmfL5dFwDg0NPd9A-g4';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

 
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: const MangoRiskApp(),
    ),
  );
}

class MangoRiskApp extends StatelessWidget {
  const MangoRiskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MangoRisk AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: appRouter,
    );
  }
}
