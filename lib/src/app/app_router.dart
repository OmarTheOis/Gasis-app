import 'package:flutter/material.dart';

class AppRouter {
  static Route<T> route<T>(Widget page) {
    return MaterialPageRoute<T>(
      builder: (_) => page,
    );
  }
}
