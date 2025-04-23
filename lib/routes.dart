import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/tutor/tutor_dashboard.dart';
import 'screens/tutor/create_course_screen.dart';
import 'screens/student/student_dashboard.dart';
import 'screens/student/course_detail_screen.dart';
import 'screens/student/lesson_view_screen.dart';
import 'screens/common/error_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const SplashScreen(),
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),

  '/tutorDashboard': (context) {
    final uid = ModalRoute.of(context)?.settings.arguments as String?;
    return uid != null ? TutorDashboard(tutorId: uid) : const ErrorScreen();
  },

  '/createCourse': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    // No longer passing params in constructor
    return (args != null && args.containsKey('tutorId'))
        ? const CreateCourseScreen()
        : const ErrorScreen();
  },

  '/studentDashboard': (context) => const StudentDashboard(), // No studentId needed
  '/courseDetail': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return (args != null && args.containsKey('courseId'))
        ? CourseDetailScreen(courseId: args['courseId'])
        : const ErrorScreen();
  },

  '/lessonView': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return (args != null && args.containsKey('lessonId'))
        ? LessonViewScreen(lessonId: args['lessonId'])
        : const ErrorScreen();
  },
};
