import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/auth_screen.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);

    final t = locale.languageCode == 'ar'
        ? {'title': 'الطريق الأخضر', 'welcome': 'مرحباً بك', 'start': 'ابدأ الآن'}
        : locale.languageCode == 'fr'
        ? {'title': 'Green Way', 'welcome': 'Bienvenue', 'start': 'Commencer'}
        : {'title': 'Green Way', 'welcome': 'Welcome', 'start': 'Get Started'};

    return Scaffold(
      appBar: AppBar(
        title: Text(t['title']!),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (lang) => ref.read(languageProvider.notifier).setLanguage(lang),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'ar', child: Text('العربية 🇩🇿')),
              const PopupMenuItem(value: 'fr', child: Text('Français 🇫🇷')),
              const PopupMenuItem(value: 'en', child: Text('English 🇬🇧')),
            ],
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.recycling, size: 100, color: Color(0xFF4CAF50)),
              const SizedBox(height: 24),
              Text(t['welcome']!, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(t['start']!, style: const TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}