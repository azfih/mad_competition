import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/tutor/tutor_dashboard.dart';
import 'screens/tutor/create_course_screen.dart';
import 'screens/student/student_dashboard.dart';
import 'screens/student/course_detail_screen.dart';
import 'screens/student/lesson_view_screen.dart';
import 'screens/common/error_screen.dart'; // Import ErrorScreen

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const SplashScreen(),
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/tutorDashboard': (context) {
    final uid = ModalRoute.of(context)?.settings.arguments as String?;
    if (uid == null) {
      return const ErrorScreen();
    }
    return TutorDashboard(tutorId: uid);
  },
  '/createCourse': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null || !args.containsKey('courseId') || !args.containsKey('tutorId')) {
      return const ErrorScreen();
    }
    return CreateCourseScreen(
      courseId: args['courseId'],
      tutorId: args['tutorId'],
    );
  },
  // Student Routes
  '/studentDashboard': (context) {
    final uid = ModalRoute.of(context)?.settings.arguments as String?;
    if (uid == null) {
      return const ErrorScreen();
    }
    return StudentDashboard(studentId: uid);
  },
  '/courseDetail': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null || !args.containsKey('courseId')) {
      return const ErrorScreen();
    }
    return CourseDetailScreen(courseId: args['courseId']);
  },
  '/lessonView': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null || !args.containsKey('lessonId')) {
      return const ErrorScreen();
    }
    return LessonViewScreen(lessonId: args['lessonId']);
  },
};
