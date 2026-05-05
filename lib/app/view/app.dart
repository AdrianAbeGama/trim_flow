import 'package:flutter/material.dart';
import 'package:trim_flow/core/theme/app_theme.dart';
import 'package:trim_flow/features/home/view/home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrimFlow',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
