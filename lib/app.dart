import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green_way_new/services/user_service.dart';
import 'features/auth/auth_screen.dart';
import 'features/citizen/citizen_home_screen.dart';
import 'features/collector/collector_home_screen.dart';
import 'features/collection_point/collection_point_home_screen.dart';
import 'features/factory/factory_home_screen.dart';
import 'package:green_way_new/features/admin/admin_dashboard_screen.dart';
import 'package:green_way_new/l10n/app_translations.dart';
import 'package:green_way_new/theme/app_theme.dart';
import 'package:green_way_new/theme/app_colors.dart';
import 'package:green_way_new/widgets/offline_banner.dart';


final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>(
      (ref) => LanguageNotifier(),
);

class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(const Locale('ar')) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language') ?? 'ar';
    state = Locale(langCode);
  }

  Future<void> setLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);
    state = Locale(langCode);
  }
}

class GreenWayApp extends ConsumerWidget {
  const GreenWayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);

    return MaterialApp(
      title: 'Green Way',
      debugShowCheckedModeBanner: false,
      locale: locale,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      builder: (context, child) => OfflineBanner(child: child ?? const SizedBox()),
      home: const AuthWrapper(),
    );
  }
}

// ============ التحقق من حالة المستخدم ============
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // جاري التحميل
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // المستخدم مسجل دخول
        if (snapshot.hasData && snapshot.data != null) {
          return StreamBuilder<DocumentSnapshot>(
            stream: UserService.getUserStream(snapshot.data!.uid),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                final role = userData['role'] ?? 'citizen';
                print('========== ROLE: $role ==========');

                // توجيه حسب نوع الحساب
                switch (role) {
                  case 'citizen':
                    return const CitizenHomeScreen();
                  case 'collector':
                    return const CollectorHomeScreen();
                  case 'collection_point':
                    return const CollectionPointHomeScreen();
                  case 'factory':
                    return const FactoryHomeScreen();
                  case 'admin':
                    return const AdminDashboardScreen();
                  default:
                    return const CitizenHomeScreen();
                }
              }

              // لا يوجد بيانات المستخدم
              return const WelcomeScreen();
            },
          );
        }

        // المستخدم غير مسجل
        return const WelcomeScreen();
      },
    );
  }
}

// ============ شاشة التحميل ============
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // اللوجو
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(30),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: const Icon(
                Icons.eco,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Green Way',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'الطريق الأخضر',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}

// ============ شاشة الترحيب ============
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppTranslations.get(ref.watch(languageProvider).languageCode);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // زر اللغة
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.language, color: Colors.white),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_drop_down, color: Colors.white),
                        ],
                      ),
                      onSelected: (lang) =>
                          ref.read(languageProvider.notifier).setLanguage(lang),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'ar', child: Text('العربية 🇩🇿')),
                        const PopupMenuItem(value: 'fr', child: Text('Français 🇫🇷')),
                        const PopupMenuItem(value: 'en', child: Text('English 🇬🇧')),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // الأيقونة الرئيسية
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.eco,
                  size: 70,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 30),

              // اسم التطبيق
              const Text(
                'Green Way',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t['welcome_subtitle']!,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 40),

              // الميزات
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    _buildFeature(Icons.delete_outline_rounded, t['welcome_feature1']!),
                    const SizedBox(height: 16),
                    _buildFeature(Icons.local_shipping_rounded, t['welcome_feature2']!),
                    const SizedBox(height: 16),
                    _buildFeature(Icons.payments_rounded, t['welcome_feature3']!),
                  ],
                ),
              ),

              const Spacer(),

              // زر البدء
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const AuthScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black.withAlpha(50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          t['welcome_start']!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward_rounded, size: 22),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // الشعار
              Text(
                t['welcome_slogan']!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(30),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

}
