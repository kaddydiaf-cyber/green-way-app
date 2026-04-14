import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:green_way_new/services/collection_point_service.dart';
import 'package:green_way_new/data/wilayas.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:green_way_new/l10n/app_translations.dart';
import 'package:green_way_new/app.dart';
import 'package:green_way_new/theme/app_colors.dart';

class CollectionPointsScreen extends ConsumerStatefulWidget {
  const CollectionPointsScreen({super.key});

  @override
  ConsumerState<CollectionPointsScreen> createState() => _CollectionPointsScreenState();
}

class _CollectionPointsScreenState extends ConsumerState<CollectionPointsScreen> {
  String? selectedWilaya;
  String sortBy = 'name';

  @override
  Widget build(BuildContext context) {
    final t = AppTranslations.get(ref.watch(languageProvider).languageCode);
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(t['collection_points']!),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(t),
            tooltip: t['filter']!,
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط الفلتر
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.primary,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Text(
                          t['all_wilayas']!,
                          style: TextStyle(color: Colors.white),
                        ),
                        value: selectedWilaya,
                        dropdownColor: AppColors.primary,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(t['all_wilayas']!, style: const TextStyle(color: Colors.white)),
                          ),
                          ...Wilayas.list.map((wilaya) {
                            return DropdownMenuItem<String>(
                              value: wilaya['code'],
                              child: Text(
                                '${wilaya['code']} - ${wilaya['name']}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => selectedWilaya = value);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort, color: Colors.white),
                  tooltip: t['sort']!,
                  onSelected: (value) {
                    setState(() => sortBy = value);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'name', child: Text(t['by_name']!)),
                    PopupMenuItem(value: 'rating', child: Text(t['highest_rating']!)),
                    PopupMenuItem(value: 'materials', child: Text(t['most_materials']!)),
                  ],
                ),
              ],
            ),
          ),

          // قائمة النقاط
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getPointsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var points = snapshot.data?.docs ?? [];

                // فلتر فقط المعتمدة
                points = points.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['status'] == 'approved';
                }).toList();

                // ترتيب
                points.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;

                  if (sortBy == 'name') {
                    return (dataA['pointName'] ?? '').compareTo(dataB['pointName'] ?? '');
                  } else if (sortBy == 'rating') {
                    return (dataB['rating'] ?? 0).compareTo(dataA['rating'] ?? 0);
                  } else if (sortBy == 'materials') {
                    final materialsA = dataA['materials'] as List? ?? [];
                    final materialsB = dataB['materials'] as List? ?? [];
                    return materialsB.length.compareTo(materialsA.length);
                  }
                  return 0;
                });

                if (points.isEmpty) {
                  return _buildEmptyState(t);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: points.length,
                  itemBuilder: (context, index) {
                    final data = points[index].data() as Map<String, dynamic>;
                    return _buildPointCard(data, t);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getPointsStream() {
    return CollectionPointService.getCollectionPoints(wilaya: selectedWilaya);
  }

  Widget _buildEmptyState(Map<String, String> t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.location_off, size: 60, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Text(
            t['no_collection_points']!,
            style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            selectedWilaya != null ? t['in_this_wilaya']! : t['currently']!,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPointCard(Map<String, dynamic> data, Map<String, String> t) {
    final materials = data['materials'] as List? ?? [];
    final wilayaName = Wilayas.getNameByCode(data['wilaya'] ?? '');
    final rating = (data['rating'] ?? 0).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          // الرأس: الولاية + التقييم
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withAlpha(20), AppColors.primary.withAlpha(8)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.location_city_rounded, size: 18, color: AppColors.primaryDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    wilayaName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // المحتوى
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // العنوان
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data['address'] ?? '-',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // أوقات العمل
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      data['workingHours'] ?? '08:00 - 18:00',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // المواد والأسعار
                if (materials.isNotEmpty) ...[
                  Text(
                    t['materials_and_prices_label']!,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: materials.map((material) {
                      final name = material['name'] ?? '';
                      final price = material['price'] ?? 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$name  $price ${t['da']!}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.grey, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          t['prices_not_added']!,
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // أزرار التواصل
          Container(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                // زر الخريطة
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => _openInMaps(data),
                    icon: const Icon(Icons.map_rounded, size: 18),
                    label: Text(t['open_in_maps']!, style: const TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // زر الاتصال
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _callPhone(data['phone']),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Icon(Icons.phone_rounded, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                // زر واتساب
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _openWhatsApp(data['phone']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Icon(Icons.message_rounded, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(Map<String, String> t) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t['filter_points']!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(t['choose_wilaya_label']!),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedWilaya,
                  hint: Text(t['all_wilayas']!),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(t['all_wilayas']!),
                    ),
                    ...Wilayas.list.map((wilaya) {
                      return DropdownMenuItem<String>(
                        value: wilaya['code'],
                        child: Text('${wilaya['code']} - ${wilaya['name']}'),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => selectedWilaya = value);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _callPhone(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openInMaps(Map<String, dynamic> data) async {
    final lat = data['latitude'];
    final lng = data['longitude'];
    Uri uri;
    if (lat != null && lng != null && lat != 0 && lng != 0) {
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    } else {
      final address = data['address'] ?? '';
      final wilaya = Wilayas.getNameByCode(data['wilaya'] ?? '');
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('$address, $wilaya, Algeria')}');
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openWhatsApp(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    String formattedPhone = phone.replaceAll(' ', '');
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '213${formattedPhone.substring(1)}';
    }
    final uri = Uri.parse('https://wa.me/$formattedPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}