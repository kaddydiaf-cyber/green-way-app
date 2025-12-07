import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green_way_new/auth_service.dart';

class CreateRequestScreen extends ConsumerStatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  ConsumerState<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends ConsumerState<CreateRequestScreen> {
  String? selectedWasteType;
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;

  final wasteTypes = [
    {'id': 'plastic', 'name': 'بلاستيك', 'icon': Icons.local_drink, 'color': Colors.blue},
    {'id': 'paper', 'name': 'ورق وكرتون', 'icon': Icons.description, 'color': Colors.brown},
    {'id': 'glass', 'name': 'زجاج', 'icon': Icons.wine_bar, 'color': Colors.green},
    {'id': 'metal', 'name': 'معادن', 'icon': Icons.settings, 'color': Colors.grey},
    {'id': 'electronics', 'name': 'إلكترونيات', 'icon': Icons.devices, 'color': Colors.purple},
    {'id': 'organic', 'name': 'عضوية', 'icon': Icons.eco, 'color': Colors.lightGreen},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('طلب جديد'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الهيدر
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.add_circle, color: Colors.white, size: 50),
                  SizedBox(height: 8),
                  Text(
                    'أنشئ طلب جمع نفايات',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
                  // اختيار نوع النفايات
                  const Text(
                    'اختر نوع النفايات',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
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

                  // حقول الإدخال
                  _buildInputCard(
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _quantityController,
                          label: 'الكمية (كجم تقريباً)',
                          icon: Icons.scale,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _addressController,
                          label: 'العنوان',
                          icon: Icons.location_on,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'وصف إضافي (اختياري)',
                          icon: Icons.note,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // زر الإرسال
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submitRequest,
                      icon: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : const Icon(Icons.send),
                      label: Text(
                        _isLoading ? 'جاري الإرسال...' : 'إرسال الطلب',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF4CAF50)),
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

  Future<void> _submitRequest() async {
    if (selectedWasteType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر نوع النفايات'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل الكمية'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل العنوان'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final user = authService.currentUser;

      await FirebaseFirestore.instance.collection('requests').add({
        'userId': user?.uid,
        'userName': user?.displayName,
        'wasteType': selectedWasteType,
        'quantity': double.tryParse(_quantityController.text) ?? 0,
        'address': _addressController.text,
        'description': _descriptionController.text,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 10));

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال الطلب بنجاح!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);

    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
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