import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase zaroori hai
import 'package:google_fonts/google_fonts.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/teacher/teacher_dashboard.dart';
import 'screens/student/student_dashboard.dart';
import 'screens/admin/add_teacher_screen.dart';

void main() async {
  //
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const SAMAApp());
}

class SAMAApp extends StatelessWidget {
  const SAMAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAMA - Smart Attendance',
      debugShowCheckedModeBanner: false,

      // Blue & White Pro Theme
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1), // Deep Blue
          primary: const Color(0xFF0D47A1),
          secondary: Colors.blueAccent,
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(), // Professional Font
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D47A1),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),

      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/role': (_) => const RoleSelectionScreen(),
        '/login': (_) => const LoginScreen(),
        '/admin': (_) => const AdminDashboard(),
        '/teacher': (_) => const TeacherDashboard(),
        '/student': (_) => const StudentDashboard(),
        '/add_teacher': (context) => const AddTeacherScreen(),
      },
    );
  }
}