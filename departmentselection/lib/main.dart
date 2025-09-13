import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(const DepartmentSelectionApp());
}

class DepartmentSelectionApp extends StatelessWidget {
  const DepartmentSelectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CivicHero - Department Selection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: AppColors.primaryBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
