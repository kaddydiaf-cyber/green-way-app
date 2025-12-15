import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green_way_new/auth_service.dart';
import 'package:green_way_new/features/chat/chat_screen.dart';
import 'package:green_way_new/features/rating/rating_dialog.dart';

class MyRequestsScreen extends ConsumerWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final userId = authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلباتي'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }

          final requests = snapshot.data?.docs ?? [];

          if (requests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('لا توجد طلبات', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];
              final request = doc.data() as Map<String, dynamic>;
              return _buildRequestCard(context, doc.id, request);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, String docId, Map<String, dynamic> request) {
    final wasteTypes = {
      'plastic': {'name': 'بلاستيك', 'icon': Icons.local_drink, 'color': Colors.blue},
      'paper': {'name': 'ورق وكرتون', 'icon': Icons.description, 'color': Colors.brown},
      'glass': {'name': 'زجاج', 'icon': Icons.wine_bar, 'color': Colors.green},
      'metal': {'name': 'معادن', 'icon': Icons.settings, 'color': Colors.grey},
      'electronics': {'name': 'إلكترونيات', 'icon': Icons.devices, 'color': Colors.purple},
      'organic': {'name': 'عضوية', 'icon': Icons.eco, 'color': Colors.lightGreen},
    };

    final statusColors = {
      'pending': Colors.orange,
      'accepted': Colors.blue,
      'completed': Colors.green,
      'sold': Colors.purple,
      'cancelled': Colors.red,
    };

    final statusNames = {
      'pending': 'قيد الانتظار',
      'accepted': 'تم القبول',
      'completed': 'مكتمل',
      'sold': 'تم البيع',
      'cancelled': 'ملغي',
    };

    final wasteType = wasteTypes[request['wasteType']] ?? wasteTypes['plastic']!;
    final status = request['status'] ?? 'pending';
    final showChat = status == 'accepted' || status == 'completed';
    final showRating = status == 'completed' && request['isRated'] != true;
    final hasNewMessage = request['hasNewMessageForCitizen'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (wasteType['color'] as Color).withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    wasteType['icon'] as IconData,
                    color: wasteType['color'] as Color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wasteType['name'] as String,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${request['quantity']} كجم',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (statusColors[status] ?? Colors.grey).withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusNames[status] ?? status,
                    style: TextStyle(
                      color: statusColors[status] ?? Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    request['address'] ?? '',
                    style: const TextStyle(color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // أزرار الإجراءات
            if (showChat || showRating) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  // زر الدردشة مع النقطة الحمراء
                  if (showChat)
                    Expanded(
                      child: Stack(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      requestId: docId,
                                      otherUserName: request['collectorName'] ?? 'الجامع',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.chat, size: 18),
                              label: const Text('محادثة'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF4CAF50),
                                side: const BorderSide(color: Color(0xFF4CAF50)),
                              ),
                            ),
                          ),
                          // النقطة الحمراء
                          if (hasNewMessage)
                            Positioned(
                              right: 5,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  '!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  if (showChat && showRating) const SizedBox(width: 8),

                  // زر التقييم
                  if (showRating)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => RatingDialog(
                              requestId: docId,
                              ratedUserId: request['collectorId'] ?? '',
                              ratedUserName: request['collectorName'] ?? 'الجامع',
                            ),
                          );
                        },
                        icon: const Icon(Icons.star, size: 18),
                        label: const Text('تقييم'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ],

            // عرض التقييم إذا تم
            if (request['isRated'] == true) ...[
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green),
                  SizedBox(width: 4),
                  Text('تم التقييم', style: TextStyle(color: Colors.green, fontSize: 12)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}