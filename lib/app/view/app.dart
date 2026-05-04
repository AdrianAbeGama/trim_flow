import 'package:flutter/material.dart';
import 'package:trim_flow/core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrimFlow',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const Scaffold(
        body: Center(
          child: Text(
            'TrimFlow',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w200,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
