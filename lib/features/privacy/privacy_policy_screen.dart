import 'package:flutter/material.dart';
import 'package:green_way_new/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سياسة الخصوصية'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.privacy_tip,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'سياسة الخصوصية',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Center(
              child: Text(
                'آخر تحديث: ديسمبر 2024',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              'مقدمة',
              'مرحباً بك في تطبيق Green Way (الطريق الأخضر). نحن نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية. توضح سياسة الخصوصية هذه كيفية جمع واستخدام وحماية معلوماتك.',
            ),

            _buildSection(
              'البيانات التي نجمعها',
              '• الاسم الكامل\n'
                  '• البريد الإلكتروني\n'
                  '• رقم الهاتف\n'
                  '• الولاية/المنطقة\n'
                  '• عنوان الجمع\n'
                  '• نوع وكمية النفايات',
            ),

            _buildSection(
              'كيف نستخدم بياناتك',
              '• تقديم خدمات جمع النفايات\n'
                  '• التواصل معك بخصوص طلباتك\n'
                  '• تحسين خدماتنا\n'
                  '• إرسال إشعارات مهمة\n'
                  '• إدارة حسابك ومحفظتك',
            ),

            _buildSection(
              'مشاركة البيانات',
              'نحن لا نبيع أو نشارك بياناتك الشخصية مع أطراف ثالثة إلا في الحالات التالية:\n\n'
                  '• مشاركة معلومات الطلب مع الجامعين لإتمام الخدمة\n'
                  '• الامتثال للمتطلبات القانونية\n'
                  '• حماية حقوقنا وسلامة المستخدمين',
            ),

            _buildSection(
              'أمان البيانات',
              'نستخدم تقنيات أمان متقدمة لحماية بياناتك، بما في ذلك:\n\n'
                  '• تشفير البيانات أثناء النقل\n'
                  '• تخزين آمن على خوادم Firebase\n'
                  '• حماية كلمات المرور بالتشفير',
            ),

            _buildSection(
              'حقوقك',
              '• الوصول إلى بياناتك الشخصية\n'
                  '• تصحيح البيانات غير الدقيقة\n'
                  '• حذف حسابك وبياناتك\n'
                  '• الانسحاب من الإشعارات',
            ),

            _buildSection(
              'ملفات تعريف الارتباط',
              'نستخدم ملفات تعريف الارتباط وتقنيات مشابهة لتحسين تجربتك في التطبيق.',
            ),

            _buildSection(
              'التغييرات على السياسة',
              'قد نقوم بتحديث سياسة الخصوصية من وقت لآخر. سنخطرك بأي تغييرات جوهرية عبر التطبيق أو البريد الإلكتروني.',
            ),

            _buildSection(
              'اتصل بنا',
              'إذا كانت لديك أي أسئلة حول سياسة الخصوصية، يرجى التواصل معنا:\n\n'
                  '📧 البريد الإلكتروني: green_way@gmail.com\n'
                  '📱 الهاتف: +213 726 60 23 83 ',
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.eco, color: AppColors.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'شكراً لاستخدامك Green Way ومساهمتك في الحفاظ على البيئة! 🌱',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}