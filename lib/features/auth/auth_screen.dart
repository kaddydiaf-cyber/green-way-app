import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:green_way_new/app.dart';
import 'package:green_way_new/auth_service.dart';
import 'package:green_way_new/features/citizen/citizen_home_screen.dart';
import 'package:green_way_new/features/collector/collector_home_screen.dart';
import 'package:green_way_new/features/factory/factory_home_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool isLogin = true;
  String? selectedRole;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // الأيقونة
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(30),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.recycling,
                      size: 60,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // اسم التطبيق
                  const Text(
                    'Green Way',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'الطريق الأخضر',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // بطاقة النموذج
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // تبديل تسجيل/إنشاء
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => isLogin = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isLogin ? const Color(0xFF4CAF50) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'تسجيل الدخول',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isLogin ? Colors.white : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => isLogin = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: !isLogin ? const Color(0xFF4CAF50) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'حساب جديد',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: !isLogin ? Colors.white : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // اختيار نوع الحساب
                        if (!isLogin) ...[
                          const Text(
                            'اختر نوع الحساب',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildRoleCard('citizen', Icons.person, 'مواطن'),
                              const SizedBox(width: 8),
                              _buildRoleCard('collector', Icons.local_shipping, 'جامع'),
                              const SizedBox(width: 8),
                              _buildRoleCard('factory', Icons.factory, 'مصنع'),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _nameController,
                            label: 'الاسم الكامل',
                            icon: Icons.person_outline,
                            validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                          ),
                          const SizedBox(height: 16),
                        ],

                        _buildTextField(
                          controller: _emailController,
                          label: 'البريد الإلكتروني',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                        ),
                        const SizedBox(height: 16),

                        if (!isLogin) ...[
                          _buildTextField(
                            controller: _phoneController,
                            label: 'رقم الهاتف',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                        ],

                        _buildTextField(
                          controller: _passwordController,
                          label: 'كلمة المرور',
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (v) => v!.length < 6 ? 'كلمة المرور قصيرة' : null,
                        ),
                        const SizedBox(height: 24),

                        // زر الدخول
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                              isLogin ? 'تسجيل الدخول' : 'إنشاء حساب',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // نص الشعار
                  const Text(
                    'حوّل نفاياتك إلى أموال',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF4CAF50)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
      ),
    );
  }

  Widget _buildRoleCard(String role, IconData icon, String title) {
    final isSelected = selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4CAF50).withAlpha(30) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade200,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!isLogin && selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر نوع الحساب'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);

      if (isLogin) {
        await authService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        final role = await authService.getUserRole(authService.currentUser!.uid);
        _goToHome(role);
      } else {
        await authService.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          role: selectedRole!,
        );
        _goToHome(selectedRole);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _goToHome(String? role) {
    Widget screen;
    switch (role) {
      case 'citizen':
        screen = const CitizenHomeScreen();
        break;
      case 'collector':
        screen = const CollectorHomeScreen();
        break;
      case 'factory':
        screen = const FactoryHomeScreen();
        break;
      default:
        screen = const CitizenHomeScreen();
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => screen),
          (route) => false,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}