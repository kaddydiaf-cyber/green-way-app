import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:green_way_new/services/collection_point_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:green_way_new/data/wilayas.dart';
import 'package:green_way_new/features/profile/profile_screen.dart';
import 'package:green_way_new/l10n/app_translations.dart';
import 'package:green_way_new/app.dart';
import 'package:green_way_new/theme/app_colors.dart';

class CollectionPointHomeScreen extends ConsumerStatefulWidget {
  const CollectionPointHomeScreen({super.key});

  @override
  ConsumerState<CollectionPointHomeScreen> createState() => _CollectionPointHomeScreenState();
}

class _CollectionPointHomeScreenState extends ConsumerState<CollectionPointHomeScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? pointData;
  bool _isLoading = true;

  // قائمة المواد المخصصة
  List<Map<String, dynamic>> materials = [];

  @override
  void initState() {
    super.initState();
    _loadPointData();
  }

  Future<void> _loadPointData() async {
    if (currentUser != null) {
      final doc = await CollectionPointService.getCollectionPoint(currentUser!.uid);

      if (doc.exists) {
        setState(() {
          pointData = doc.data() as Map<String, dynamic>?;
          _isLoading = false;

          // تحميل المواد
          final loadedMaterials = pointData?['materials'];
          if (loadedMaterials != null && loadedMaterials is List) {
            materials = List<Map<String, dynamic>>.from(
              loadedMaterials.map((m) => Map<String, dynamic>.from(m)),
            );
          }
        });
      }
    }
  }

  Future<void> _saveMaterials() async {
    final t = AppTranslations.get(ref.watch(languageProvider).languageCode);
    try {
      await CollectionPointService.updateMaterials(uid: currentUser!.uid, materials: materials);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t['materials_saved']!),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${t['error']!}: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _addMaterial() {
    final t = AppTranslations.get(ref.watch(languageProvider).languageCode);
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t['add_new_material']!),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: t['material_name']!,
                hintText: t['material_example']!,
                prefixIcon: const Icon(Icons.category, color: AppColors.primary),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t['price_per_kg']!,
                hintText: t['price_example']!,
                prefixIcon: const Icon(Icons.attach_money, color: AppColors.primary),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t['cancel']!),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                setState(() {
                  materials.add({
                    'name': nameController.text.trim(),
                    'price': int.tryParse(priceController.text) ?? 0,
                  });
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(t['add']!),
          ),
        ],
      ),
    );
  }

  void _editMaterial(int index) {
    final t = AppTranslations.get(ref.watch(languageProvider).languageCode);
    final nameController = TextEditingController(text: materials[index]['name']);
    final priceController = TextEditingController(text: materials[index]['price'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t['edit_material']!),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: t['material_name']!,
                prefixIcon: const Icon(Icons.category, color: AppColors.primary),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t['price_per_kg']!,
                prefixIcon: const Icon(Icons.attach_money, color: AppColors.primary),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t['cancel']!),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                setState(() {
                  materials[index] = {
                    'name': nameController.text.trim(),
                    'price': int.tryParse(priceController.text) ?? 0,
                  };
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(t['save']!),
          ),
        ],
      ),
    );
  }

  void _deleteMaterial(int index) {
    final t = AppTranslations.get(ref.watch(languageProvider).languageCode);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t['delete_material']!),
        content: Text('${t['confirm_delete']!} "${materials[index]['name']}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t['cancel']!),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                materials.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(t['delete']!),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTranslations.get(ref.watch(languageProvider).languageCode);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final status = pointData?['status'] ?? 'pending';
    final isApproved = status == 'approved';
    final wilayaName = Wilayas.getNameByCode(pointData?['wilaya'] ?? '');

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(pointData?['pointName'] ?? t['collection_point']!),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // حالة الحساب
            _buildStatusCard(status, t),
            const SizedBox(height: 16),

            // معلومات النقطة
            _buildInfoCard(wilayaName, t),
            const SizedBox(height: 16),

            // المواد والأسعار
            if (isApproved) ...[
              _buildMaterialsCard(t),
              const SizedBox(height: 16),

              // الإحصائيات
              _buildStatsCard(t),
            ],

            if (!isApproved) ...[
              _buildPendingMessage(t),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String status, Map<String, String> t) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        statusText = t['approved']!;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = t['rejected']!;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusText = t['pending']!;
        statusIcon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withAlpha(100)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t['account_status']!, style: const TextStyle(color: Colors.grey)),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String wilayaName, Map<String, String> t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t['collection_point_info']!,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          _buildMapsRow(t, pointData?['address'] ?? '', wilayaName),
          _buildInfoRow(Icons.location_city, t['wilaya']!, wilayaName),
          _buildInfoRow(Icons.location_on, t['address']!, pointData?['address'] ?? '-'),
          _buildInfoRow(Icons.phone, t['phone']!, pointData?['phone'] ?? '-'),
          _buildInfoRow(Icons.access_time, t['working_hours']!, pointData?['workingHours'] ?? '-'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapsRow(Map<String, String> t, String address, String wilayaName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () => _openInMaps(address, wilayaName),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.map_rounded, color: Colors.red, size: 20),
              const SizedBox(width: 12),
              Text('${t['location_on_map']}: ', style: const TextStyle(color: Colors.grey)),
              Expanded(
                child: Text(
                  t['open_in_maps']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const Icon(Icons.open_in_new, size: 16, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openInMaps(String address, String wilayaName) async {
    final lat = pointData?['latitude'];
    final lng = pointData?['longitude'];
    Uri uri;
    if (lat != null && lng != null && lat != 0 && lng != 0) {
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    } else {
      final query = '$address, $wilayaName, Algeria';
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildMaterialsCard(Map<String, String> t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t['materials_and_prices']!,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _addMaterial,
                    icon: const Icon(Icons.add_circle, color: AppColors.primary),
                    tooltip: t['add_new_material']!,
                  ),
                  IconButton(
                    onPressed: materials.isNotEmpty ? _saveMaterials : null,
                    icon: Icon(
                      Icons.save,
                      color: materials.isNotEmpty ? AppColors.primary : Colors.grey,
                    ),
                    tooltip: t['save']!,
                  ),
                ],
              ),
            ],
          ),
          const Divider(),

          if (materials.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    t['no_materials_added']!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t['add_materials_instruction']!,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: materials.length,
              itemBuilder: (context, index) {
                final material = materials[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.inventory,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              material['name'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${material['price']} ${t['price_per_kg']!}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _editMaterial(index),
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: t['edit']!,
                      ),
                      IconButton(
                        onPressed: () => _deleteMaterial(index),
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: t['delete']!,
                      ),
                    ],
                  ),
                );
              },
            ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addMaterial,
              icon: const Icon(Icons.add),
              label: Text(t['add_new_material']!),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (materials.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _saveMaterials,
                icon: const Icon(Icons.save),
                label: Text(t['save_changes']!),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsCard(Map<String, String> t) {
    final rating = pointData?['rating'] ?? 0.0;
    final totalRatings = pointData?['totalRatings'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t['statistics']!,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(Icons.star, rating.toStringAsFixed(1), t['rating']!, Colors.amber),
              _buildStatItem(Icons.people, totalRatings.toString(), t['ratings_count']!, Colors.blue),
              _buildStatItem(Icons.inventory, materials.length.toString(), t['materials_count']!, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildPendingMessage(Map<String, String> t) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.hourglass_empty, color: Colors.orange, size: 48),
          const SizedBox(height: 16),
          Text(
            t['request_under_review']!,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t['pending_approval_description']!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(
            t['contact_inquiry']!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                t['support_phone']!,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
