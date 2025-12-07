import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green_way_new/auth_service.dart';
import 'package:green_way_new/features/about/about_screen.dart';
import 'package:green_way_new/features/auth/auth_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final name = userData['name'] ?? 'مستخدم';
          final email = userData['email'] ?? '';
          final phone = userData['phone'] ?? '';
          final role = userData['role'] ?? 'citizen';
          final walletBalance = (userData['walletBalance'] ?? 0.0).toDouble();
          final averageRating = (userData['averageRating'] ?? 0.0).toDouble();
          final totalRatings = userData['totalRatings'] ?? 0;

          final roleNames = {
            'citizen': 'مواطن',
            'collector': 'جامع',
            'factory': 'مصنع',
          };

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // صورة الملف الشخصي
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF4CAF50), width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF4CAF50).withAlpha(30),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // الاسم
                Text(
                  name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),

                // نوع الحساب
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    roleNames[role] ?? role,
                    style: const TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // التقييم
                if (averageRating > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < averageRating.round() ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 24,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        '(${totalRatings})',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),

                // بطاقة الرصيد
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'رصيد المحفظة',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$walletBalance د.ج',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // معلومات الحساب
                _buildInfoCard(Icons.email, 'البريد الإلكتروني', email),
                _buildInfoCard(Icons.phone, 'رقم الهاتف', phone.isNotEmpty ? phone : 'غير محدد'),

                const SizedBox(height: 24),

                // الأزرار
                _buildMenuButton(
                  context,
                  Icons.info_outline,
                  'حول التطبيق',
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
                ),
                _buildMenuButton(
                  context,
                  Icons.logout,
                  'تسجيل الخروج',
                      () async {
                    await authService.logout();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                          (route) => false,
                    );
                  },
                  isLogout: true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4CAF50)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: isLogout ? Colors.red : const Color(0xFF4CAF50)),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isLogout ? Colors.red : Colors.black,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: isLogout ? Colors.red.withAlpha(50) : Colors.grey.shade200),
        ),
      ),
    );
  }
}