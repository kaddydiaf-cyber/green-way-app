import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:green_way_new/services/request_service.dart';
import 'package:green_way_new/notification_service.dart';
import 'package:green_way_new/utils/time_utils.dart';
import 'package:green_way_new/sound_service.dart';
import 'package:green_way_new/theme/app_colors.dart';

class AvailableRequestsTab extends StatefulWidget {
  final String wilaya;
  final Map<String, String> t;
  final String langCode;

  const AvailableRequestsTab({super.key, required this.wilaya, required this.t, required this.langCode});

  @override
  State<AvailableRequestsTab> createState() => _AvailableRequestsTabState();
}

class _AvailableRequestsTabState extends State<AvailableRequestsTab> {
  Map<String, String> get t => widget.t;
  String get langCode => widget.langCode;

  Map<String, Map<String, dynamic>> get _wasteTypes => {
    'plastic': {'name': t['plastic']!, 'icon': Icons.recycling_rounded, 'color': AppColors.wastePlastic},
    'paper': {'name': t['paper_cardboard']!, 'icon': Icons.article_rounded, 'color': AppColors.wastePaper},
    'wood': {'name': t['wood']!, 'icon': Icons.park_rounded, 'color': AppColors.wasteWood},
    'glass': {'name': t['glass']!, 'icon': Icons.liquor_rounded, 'color': AppColors.wasteGlass},
    'metal': {'name': t['metal']!, 'icon': Icons.hardware_rounded, 'color': AppColors.wasteMetal},
    'electronics': {'name': t['electronics']!, 'icon': Icons.memory_rounded, 'color': AppColors.wasteElectronics},
    'organic': {'name': t['organic']!, 'icon': Icons.compost_rounded, 'color': AppColors.wasteOrganic},
    'other': {'name': t['other']!, 'icon': Icons.category_rounded, 'color': AppColors.wasteOther},
  };

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: RequestService.getPendingRequestsByWilaya(widget.wilaya),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data?.docs ?? [];

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.inbox_rounded, size: 60, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 20),
                Text(
                  t['no_requests_available']!,
                  style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  t['in_your_wilaya']!,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final doc = requests[index];
            final request = doc.data() as Map<String, dynamic>;
            return _buildRequestCard(context, doc.id, request);
          },
        );
      },
    );
  }

  Widget _buildRequestCard(BuildContext context, String docId, Map<String, dynamic> request) {
    final wasteType = _wasteTypes[request['wasteType']] ?? _wasteTypes['plastic']!;
    final color = wasteType['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: color.withAlpha(25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        wasteType['icon'] as IconData,
                        color: color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            wasteType['name'] as String,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.scale_rounded, size: 15, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(
                                '${request['quantity']} ${t['kg']!}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.fiber_new_rounded, color: Colors.orange, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            t['new_label']!,
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.person_rounded, request['userName'] ?? t['user']!),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.access_time_rounded,
                  '${t['since']!} ${TimeUtils.getTimeAgo(request['createdAt'] as Timestamp?, langCode: langCode)}',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.location_on_rounded, request['address'] ?? ''),
                if (request['description'] != null && request['description'].toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.note_rounded, request['description']),
                ],
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: ElevatedButton.icon(
              onPressed: () => _acceptRequest(context, docId, request),
              icon: const Icon(Icons.check_circle_rounded),
              label: Text(t['accept_request']!),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Future<void> _acceptRequest(BuildContext context, String docId, Map<String, dynamic> request) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await RequestService.acceptRequest(docId: docId, collectorId: user?.uid ?? '', collectorName: user?.displayName ?? t['collector']!);

      // تشغيل صوت النجاح
      await SoundService.playSuccessSound();

      if (request['userId'] != null) {
        await NotificationService.sendNotificationToUser(
          receiverUserId: request['userId'],
          title: t['request_accept_notif_title']!,
          body: '${user?.displayName ?? t['collector']!} ${t['request_accept_notif_body']!}',
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text(t['request_accept_success']!),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${t['error']!}: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
