import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:green_way_new/auth_service.dart';
import 'package:green_way_new/services/request_service.dart';
import 'package:green_way_new/services/user_service.dart';
import 'package:green_way_new/data/wilayas.dart';
import 'package:green_way_new/app.dart';
import 'package:green_way_new/l10n/app_translations.dart';
import 'package:green_way_new/theme/app_colors.dart';

class CreateRequestScreen extends ConsumerStatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  ConsumerState<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends ConsumerState<CreateRequestScreen> {
  String? selectedWasteType;
  String? userWilaya;
  String? userWilayaName;
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingWilaya = true;

  List<Map<String, dynamic>> _getWasteTypes(Map<String, String> t) => [
    {'id': 'plastic', 'name': t['plastic']!, 'icon': Icons.recycling_rounded, 'color': AppColors.wastePlastic},
    {'id': 'paper', 'name': t['paper_cardboard']!, 'icon': Icons.article_rounded, 'color': AppColors.wastePaper},
    {'id': 'wood', 'name': t['wood']!, 'icon': Icons.park_rounded, 'color': AppColors.wasteWood},
    {'id': 'glass', 'name': t['glass']!, 'icon': Icons.liquor_rounded, 'color': AppColors.wasteGlass},
    {'id': 'metal', 'name': t['metal']!, 'icon': Icons.hardware_rounded, 'color': AppColors.wasteMetal},
    {'id': 'electronics', 'name': t['electronics']!, 'icon': Icons.memory_rounded, 'color': AppColors.wasteElectronics},
    {'id': 'organic', 'name': t['organic']!, 'icon': Icons.compost_rounded, 'color': AppColors.wasteOrganic},
    {'id': 'other', 'name': t['other']!, 'icon': Icons.category_rounded, 'color': AppColors.wasteOther},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserWilaya();
  }

  Future<void> _loadUserWilaya() async {
    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;

    if (user != null) {
      final userDoc = await UserService.getUser(user.uid);

      setState(() {
        userWilaya = (userDoc.data() as Map<String, dynamic>?)?['wilaya'] ?? '';
        userWilayaName = Wilayas.getNameByCode(userWilaya ?? '');
        _isLoadingWilaya = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTranslations.get(ref.watch(languageProvider).languageCode);
    final wasteTypes = _getWasteTypes(t);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(t['new_request']!),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.add_circle, color: Colors.white, size: 50),
                  const SizedBox(height: 8),
                  Text(
                    t['create_waste_request']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!_isLoadingWilaya)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_city, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '${t['wilaya']!} $userWilayaName',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t['choose_waste_type']!,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: wasteTypes.length,
                    itemBuilder: (context, index) {
                      final type = wasteTypes[index];
                      final isSelected = selectedWasteType == type['id'];
                      return GestureDetector(
                        onTap: () => setState(() => selectedWasteType = type['id'] as String),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (type['color'] as Color).withAlpha(30)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? type['color'] as Color : Colors.grey.shade200,
                              width: 2,
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: (type['color'] as Color).withAlpha(40),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ] : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                type['icon'] as IconData,
                                size: 32,
                                color: isSelected ? type['color'] as Color : Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                type['name'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? type['color'] as Color : Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  _buildInputCard(
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _quantityController,
                          label: t['quantity_kg']!,
                          icon: Icons.scale,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _addressController,
                          label: t['detailed_address']!,
                          icon: Icons.location_on,
                          hint: t['address_example']!,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _descriptionController,
                          label: t['additional_description']!,
                          icon: Icons.note,
                          maxLines: 3,
                          hint: t['notes_for_collector']!,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : () => _submitRequest(t),
                      icon: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : const Icon(Icons.send),
                      label: Text(
                        _isLoading ? t['sending']! : t['submit_request']!,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Future<void> _submitRequest(Map<String, String> t) async {
    if (selectedWasteType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t['select_waste_type']!), backgroundColor: Colors.red),
      );
      return;
    }

    if (_quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t['enter_quantity']!), backgroundColor: Colors.red),
      );
      return;
    }

    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t['enter_address']!), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final user = authService.currentUser;

      await RequestService.createRequest(
        userId: user?.uid,
        userName: user?.displayName,
        wasteType: selectedWasteType,
        quantity: double.tryParse(_quantityController.text) ?? 0,
        address: _addressController.text,
        description: _descriptionController.text,
        wilaya: userWilaya,
        wilayaName: userWilayaName,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t['request_sent_success']!),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }

    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t['error']!}: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
