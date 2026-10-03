import 'package:flutter/material.dart';
import '../pages/home/home_page.dart';
import '../pages/publicaciones/create_publication_page.dart';

class AppRoutes {
  static const String home = '/';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomePage(),
    '/createPublicacion': (context) => const CreatePublicacionPage(),
  };
}
