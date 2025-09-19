import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart'; // Your existing login screen
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        useMaterial3: true,
      ),
      
      // 🔥 THIS IS THE KEY FIX - Replace static LoginScreen with StreamBuilder
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          
          // Show loading while Firebase checks authentication state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: AppColors.lightGrey,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.primaryBlue,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading CivicHero...',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.darkGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          // ✅ If user is logged in, show HomeScreen (PERSISTENT LOGIN!)
          if (snapshot.hasData && snapshot.data != null) {
            print('User authenticated: ${snapshot.data!.email}'); // Debug log
            return const HomeScreen();
          } 
          
          // ❌ If no user is logged in, show LoginScreen
          print('No user found, showing LoginScreen'); // Debug log
          return const LoginScreen();
        },
      ),
      
      debugShowCheckedModeBanner: false,
    );
  }
}
