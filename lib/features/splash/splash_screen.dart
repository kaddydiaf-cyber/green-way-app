import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green_way_new/app.dart';
import 'package:green_way_new/features/auth/auth_screen.dart';
import 'package:green_way_new/features/citizen/citizen_home_screen.dart';
import 'package:green_way_new/features/collector/collector_home_screen.dart';
import 'package:green_way_new/features/factory/factory_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    await Future.delayed(const Duration(seconds: 2));

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _goTo(const AuthScreen());
    } else {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final role = doc.data()?['role'] ?? 'citizen';

      switch (role) {
        case 'collector':
          _goTo(const CollectorHomeScreen());
          break;
        case 'factory':
          _goTo(const FactoryHomeScreen());
          break;
        default:
          _goTo(const CitizenHomeScreen());
      }
    }
  }

  void _goTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // الأيقونة
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.recycling,
                size: 80,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 24),

            // اسم التطبيق
            const Text(
              'Green Way',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'الطريق الأخضر',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 40),

            // مؤشر التحميل
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}