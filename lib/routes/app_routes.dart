import 'package:flutter/material.dart';

import '../screens/login_screen.dart';
import '../screens/main_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String main = '/main';

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    dashboard: (context) => const MainScreen(),
    main: (context) => const MainScreen(),
  };
}
