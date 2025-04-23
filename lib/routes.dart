import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/tutor/tutor_dashboard.dart';
import 'screens/tutor/create_course_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const SplashScreen(),
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/tutorDashboard': (context) {
    final uid = ModalRoute.of(context)!.settings.arguments as String;
    return TutorDashboard(tutorId: uid);
  },
  '/createCourse': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return CreateCourseScreen(
      courseId: args['courseId'],
      tutorId: args['tutorId'],
    );
  },
};
