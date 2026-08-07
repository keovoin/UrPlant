import 'package:flutter/material.dart';

class AppRoutes {
  static const home = '/';
  static const camera = '/camera';
  static const identifying = '/identifying';
  static const result = '/result';
  static const plantDetail = '/plant-detail';
  static const encyclopedia = '/encyclopedia';
  static const profile = '/profile';
  static const achievements = '/achievements';
  static const settings = '/settings';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    // Routes are handled via named navigation + arguments
    // All screens return to use Navigator.pushNamed or push with MaterialPageRoute
    return null;
  }
}