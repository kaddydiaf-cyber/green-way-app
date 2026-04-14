
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:green_way_new/auth_service.dart';
import 'package:green_way_new/features/citizen/citizen_home_screen.dart';
import 'package:green_way_new/features/collector/collector_home_screen.dart';
import 'package:green_way_new/features/factory/factory_home_screen.dart';
import 'package:green_way_new/features/collection_point/collection_point_home_screen.dart';
import 'package:green_way_new/features/admin/admin_dashboard_screen.dart';
import 'package:green_way_new/app.dart';
import 'package:green_way_new/l10n/app_translations.dart';
import 'package:green_way_new/features/auth/widgets/role_selector_card.dart';
import 'package:green_way_new/features/auth/widgets/auth_text_field.dart';
import 'package:green_way_new/features/auth/widgets/wilaya_dropdown.dart';
import 'package:green_way_new/theme/app_colors.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool isLogin = true;
  String? selectedRole;
  String? selectedWilaya;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _addressController = TextEditingController();
  final _workingHoursController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');
    final rememberMe = prefs.getBool('remember_me') ?? false;

    if (rememberMe && savedEmail != null && savedPassword != null) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('saved_email', _emailController.text.trim());
      await prefs.setString('saved_password', _passwordController.text);
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTranslations.get(ref.watch(languageProvider).languageCode);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // اللوجو
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(40),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.eco,
                      size: 50,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // اسم التطبيق
                  Text(
                    t['app_name']!,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    t['app_subtitle']!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // بطاقة النموذج
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(30),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // تبديل تسجيل/إنشاء
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => isLogin = true),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: isLogin ? AppColors.primary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: isLogin
                                          ? [
                                        BoxShadow(
                                          color: AppColors.primary.withAlpha(80),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                          : [],
                                    ),
                                    child: Text(
                                      t['login']!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isLogin ? Colors.white : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => isLogin = false),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: !isLogin ? AppColors.primary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: !isLogin
                                          ? [
                                        BoxShadow(
                                          color: AppColors.primary.withAlpha(80),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                          : [],
                                    ),
                                    child: Text(
                                      t['new_account']!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: !isLogin ? Colors.white : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // اختيار نوع الحساب
                        if (!isLogin) ...[
                          Text(
                            t['choose_account_type']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceLight,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              RoleSelectorCard(
                                role: 'citizen',
                                icon: Icons.person_rounded,
                                title: t['citizen']!,
                                subtitle: t['sell_waste']!,
                                color: AppColors.roleCitizen,
                                isComingSoon: false,
                                isSelected: selectedRole == 'citizen',
                                comingSoonText: t['coming_soon']!,
                                onTap: () => setState(() => selectedRole = 'citizen'),
                              ),
                              const SizedBox(width: 12),
                              RoleSelectorCard(
                                role: 'collector',
                                icon: Icons.local_shipping_rounded,
                                title: t['collector']!,
                                subtitle: t['collect_waste']!,
                                color: AppColors.roleCollector,
                                isComingSoon: false,
                                isSelected: selectedRole == 'collector',
                                comingSoonText: t['coming_soon']!,
                                onTap: () => setState(() => selectedRole = 'collector'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              RoleSelectorCard(
                                role: 'collection_point',
                                icon: Icons.store_rounded,
                                title: t['collection_point']!,
                                subtitle: t['buy_waste']!,
                                color: AppColors.primary,
                                isComingSoon: false,
                                isSelected: selectedRole == 'collection_point',
                                comingSoonText: t['coming_soon']!,
                                onTap: () => setState(() => selectedRole = 'collection_point'),
                              ),
                              const SizedBox(width: 12),
                              RoleSelectorCard(
                                role: 'factory',
                                icon: Icons.precision_manufacturing_rounded,
                                title: t['factory']!,
                                subtitle: t['recycling']!,
                                color: AppColors.roleCollectionPoint,
                                isComingSoon: true,
                                isSelected: selectedRole == 'factory',
                                comingSoonText: t['coming_soon']!,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.schedule, color: Colors.white),
                                          const SizedBox(width: 8),
                                          Text(t['coming_soon']!),
                                        ],
                                      ),
                                      backgroundColor: Colors.orange.shade600,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // حقول نقطة الجمع
                          if (selectedRole == 'collection_point') ...[
                            AuthTextField(
                              controller: _nameController,
                              label: t['admin_name']!,
                              icon: Icons.badge_rounded,
                              validator: (v) => v!.isEmpty ? '' : null,
                            ),
                            const SizedBox(height: 16),
                            AuthTextField(
                              controller: _addressController,
                              label: t['detailed_address']!,
                              icon: Icons.location_on_rounded,
                              validator: (v) => v!.isEmpty ? '' : null,
                            ),
                            const SizedBox(height: 16),
                            // إحداثيات الموقع
                            Text(
                              t['location_on_map']!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: AuthTextField(
                                    controller: _latitudeController,
                                    label: t['latitude']!,
                                    icon: Icons.my_location_rounded,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    validator: (v) => v!.isEmpty ? '' : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AuthTextField(
                                    controller: _longitudeController,
                                    label: t['longitude']!,
                                    icon: Icons.my_location_rounded,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    validator: (v) => v!.isEmpty ? '' : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _getLocationAndPreview(t),
                                icon: const Icon(Icons.my_location_rounded, size: 18),
                                label: Text(t['get_my_location']!),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            AuthTextField(
                              controller: _workingHoursController,
                              label: t['working_hours']!,
                              hint: t['working_hours_example']!,
                              icon: Icons.schedule_rounded,
                            ),
                            const SizedBox(height: 16),
                          ] else ...[
                            AuthTextField(
                              controller: _nameController,
                              label: t['full_name']!,
                              icon: Icons.person_rounded,
                              validator: (v) => v!.isEmpty ? '' : null,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // اختيار الولاية
                          WilayaDropdown(
                            selectedWilaya: selectedWilaya,
                            onChanged: (value) {
                              setState(() => selectedWilaya = value);
                            },
                            translations: t,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // البريد الإلكتروني
                        AuthTextField(
                          controller: _emailController,
                          label: t['email']!,
                          icon: Icons.email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v!.isEmpty ? '' : null,
                        ),
                        const SizedBox(height: 16),

                        // رقم الهاتف
                        if (!isLogin) ...[
                          AuthTextField(
                            controller: _phoneController,
                            label: t['phone']!,
                            icon: Icons.phone_rounded,
                            keyboardType: TextInputType.phone,
                            validator: (v) => v!.isEmpty ? '' : null,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // كلمة المرور
                        AuthTextField(
                          controller: _passwordController,
                          label: t['password']!,
                          icon: Icons.lock_rounded,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                              color: Colors.grey.shade500,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (v) => v!.length < 6 ? t['password_short']! : null,
                        ),

                        // تذكرني
                        if (isLogin) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Transform.scale(
                                scale: 1.1,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() => _rememberMe = value ?? false);
                                  },
                                  activeColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() => _rememberMe = !_rememberMe);
                                },
                                child: Text(
                                  t['remember_me']!,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 24),

                        // زر الدخول
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : () => _submit(t),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              shadowColor: AppColors.primary.withAlpha(100),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                                : Text(
                              isLogin ? t['login']! : _getSubmitButtonText(t),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),

                        // ملاحظة لنقطة الجمع
                        if (!isLogin && selectedRole == 'collection_point') ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_rounded, color: Colors.amber.shade700, size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    t['pending_approval_info']!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // نص أسفل
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.eco, color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        t['convert_waste_to_money']!,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }



  Future<void> _getLocationAndPreview(Map<String, String> t) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t['enable_location']!), backgroundColor: Colors.red),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t['location_denied']!), backgroundColor: Colors.red),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      setState(() {
        _latitudeController.text = position.latitude.toStringAsFixed(6);
        _longitudeController.text = position.longitude.toStringAsFixed(6);
      });

      final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${t['error']!}: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _getSubmitButtonText(Map<String, String> t) {
    if (selectedRole == 'collection_point') {
      return t['register_collection_point']!;
    }
    return t['create_account']!;
  }

  Future<void> _submit(Map<String, String> t) async {
    if (!_formKey.currentState!.validate()) return;

    if (!isLogin && selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text(t['select_account_type']!),
            ],
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (!isLogin && selectedWilaya == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text(t['select_wilaya']!),
            ],
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
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
        await _saveCredentials();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AuthWrapper()),
                (route) => false,
          );
        }
      }else {
        if (selectedRole == 'collection_point') {
          await authService.registerCollectionPoint(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            ownerName: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            wilaya: selectedWilaya!,
            address: _addressController.text.trim(),
            latitude: double.tryParse(_latitudeController.text.trim()) ?? 0,
            longitude: double.tryParse(_longitudeController.text.trim()) ?? 0,
            workingHours: _workingHoursController.text.trim(),
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text(t['registration_submitted']!)),
                  ],
                ),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                duration: const Duration(seconds: 3),
              ),
            );
          }
          _goToHome(selectedRole);
        } else {
          await authService.register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            role: selectedRole!,
            wilaya: selectedWilaya!,
          );
          _goToHome(selectedRole);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('$e')),
            ],
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
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
      case 'collection_point':
        screen = const CollectionPointHomeScreen();
        break;
      case 'factory':
        screen = const FactoryHomeScreen();
        break;
      case 'admin':
        screen = const AdminDashboardScreen();
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
    _latitudeController.dispose();
    _longitudeController.dispose();
    _addressController.dispose();
    _workingHoursController.dispose();
    super.dispose();
  }
}
