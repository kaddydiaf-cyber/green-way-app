import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green_way_new/auth_service.dart';
import 'package:green_way_new/services/request_service.dart';
import 'package:green_way_new/features/chat/chat_screen.dart';
import 'package:green_way_new/features/rating/rating_dialog.dart';
import 'package:green_way_new/notification_service.dart';
import 'package:green_way_new/utils/time_utils.dart';
import 'package:green_way_new/app.dart';
import 'package:green_way_new/l10n/app_translations.dart';
import 'package:green_way_new/theme/app_colors.dart';

class MyRequestsScreen extends ConsumerStatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  ConsumerState<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends ConsumerState<MyRequestsScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = ref.read(authServiceProvider);
    final userId = authService.currentUser?.uid;
    final t = AppTranslations.get(ref.watch(languageProvider).languageCode);
    final langCode = ref.watch(languageProvider).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(t['my_requests']!),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: RequestService.getUserRequests(userId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('${t['error']!}: ${snapshot.error}'));
          }

          final requests = snapshot.data?.docs ?? [];

          if (requests.isEmpty) {
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
                    child: Icon(Icons.inbox_rounded, size: 60, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t['no_requests']!,
                    style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
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
              return _RequestCard(docId: doc.id, request: request, t: t, langCode: langCode);
            },
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> request;
  final Map<String, String> t;
  final String langCode;

  const _RequestCard({required this.docId, required this.request, required this.t, required this.langCode});

  Map<String, Map<String, dynamic>> get wasteTypes => {
    'plastic': {'name': t['plastic']!, 'icon': Icons.recycling_rounded, 'color': AppColors.wastePlastic},
    'paper': {'name': t['paper_cardboard']!, 'icon': Icons.article_rounded, 'color': AppColors.wastePaper},
    'wood': {'name': t['wood']!, 'icon': Icons.park_rounded, 'color': AppColors.wasteWood},
    'glass': {'name': t['glass']!, 'icon': Icons.liquor_rounded, 'color': AppColors.wasteGlass},
    'metal': {'name': t['metal']!, 'icon': Icons.hardware_rounded, 'color': AppColors.wasteMetal},
    'electronics': {'name': t['electronics']!, 'icon': Icons.memory_rounded, 'color': AppColors.wasteElectronics},
    'organic': {'name': t['organic']!, 'icon': Icons.compost_rounded, 'color': AppColors.wasteOrganic},
    'other': {'name': t['other']!, 'icon': Icons.category_rounded, 'color': AppColors.wasteOther},
  };

  final statusColors = const {
    'pending': Colors.orange,
    'accepted': Colors.blue,
    'completed': Colors.green,
    'sold': Colors.purple,
    'cancelled': Colors.red,
  };

  Map<String, String> get statusNames => {
    'pending': t['pending_status'] ?? t['pending']!,
    'accepted': t['accepted_status'] ?? t['accept']!,
    'completed': t['completed_status'] ?? t['completed_requests']!,
    'sold': t['completed_status']!,
    'cancelled': t['cancelled_status'] ?? t['cancel']!,
  };

  String _getStatusTime() {
    final status = request['status'] ?? 'pending';

    switch (status) {
      case 'pending':
        return '${t['created_ago']!} ${TimeUtils.getTimeAgo(request['createdAt'] as Timestamp?, langCode: langCode)}';
      case 'accepted':
        return '${t['accepted_ago']!} ${TimeUtils.getTimeAgo(request['acceptedAt'] as Timestamp?, langCode: langCode)}';
      case 'completed':
        return '${t['completed_ago']!} ${TimeUtils.getTimeAgo(request['completedAt'] as Timestamp?, langCode: langCode)}';
      case 'cancelled':
        return '${t['cancelled_ago']!} ${TimeUtils.getTimeAgo(request['cancelledAt'] as Timestamp?, langCode: langCode)}';
      default:
        return '${t['ago']!} ${TimeUtils.getTimeAgo(request['createdAt'] as Timestamp?, langCode: langCode)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final wasteType = wasteTypes[request['wasteType']] ?? wasteTypes['plastic']!;
    final status = request['status'] ?? 'pending';
    final color = wasteType['color'] as Color;

    final showChat = status == 'accepted' || status == 'completed';
    final showRating = status == 'completed' && request['isRatedByOwner'] != true;
    final hasNewMessage = request['hasNewMessageForCitizen'] == true;
    final showCancel = status == 'pending' || status == 'accepted';

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
                      padding: const EdgeInsets.all(12),
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.scale_rounded, size: 14, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(
                                '${request['quantity']} kg',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (statusColors[status] ?? Colors.grey).withAlpha(25),
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
                    Icon(Icons.access_time_rounded, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(
                      _getStatusTime(),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        request['address'] ?? '',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                if (status == 'accepted' || status == 'completed') ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person_rounded, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 6),
                      Text(
                        '${t['collector_name']!}: ${request['collectorName'] ?? ''}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ],

                if (request['isRatedByOwner'] == true || request['isRated'] == true) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 16, color: Colors.green),
                      const SizedBox(width: 6),
                      Text(
                        t['rated']!,
                        style: const TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          if (showChat || showRating || showCancel)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  if (showChat || showRating)
                    Row(
                      children: [
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
                                            otherUserName: request['collectorName'] ?? t['collector']!,
                                            otherUserId: request['collectorId'],
                                            langCode: langCode,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.chat_rounded, size: 18),
                                    label: Text(t['chat']!),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                if (hasNewMessage)
                                  Positioned(
                                    right: 8,
                                    top: 4,
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

                        if (showChat && showRating) const SizedBox(width: 10),

                        if (showRating)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => RatingDialog(
                                    requestId: docId,
                                    ratedUserId: request['collectorId'] ?? '',
                                    ratedUserName: request['collectorName'] ?? t['collector']!,
                                    raterType: 'citizen',
                                    langCode: langCode,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.star_rounded, size: 18),
                              label: Text(t['rate']!),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                      ],
                    ),

                  if (showCancel) ...[
                    if (showChat || showRating) const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showCancelDialog(context, status),
                        icon: const Icon(Icons.cancel_rounded, size: 18),
                        label: Text(status == 'pending' ? t['cancel_request']! : t['cancel_and_reopen']!),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red, width: 1.5),
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
            ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning_rounded, color: Colors.red),
            ),
            const SizedBox(width: 12),
            Text(t['cancel_request']!),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (status == 'accepted')
              Text(
                t['confirm_cancel_request']!,
                style: const TextStyle(fontSize: 15),
              )
            else
              Text(
                t['confirm_cancel_final']!,
                style: const TextStyle(fontSize: 15),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t['no_keep']!),
          ),
          if (status == 'accepted') ...[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _cancelAndReopen(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(t['reopen_for_another']!),
            ),
          ],
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelRequest(context, status);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(t['cancel_final']!),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelRequest(BuildContext context, String status) async {
    try {
      if (status == 'accepted' && request['collectorId'] != null) {
        await NotificationService.sendNotificationToUser(
          receiverUserId: request['collectorId'],
          title: t['request_cancelled_title']!,
          body: t['citizen_cancelled_request']!,
        );
      }

      await RequestService.cancelRequest(docId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(t['request_cancelled']!),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${t['error']!}: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _cancelAndReopen(BuildContext context) async {
    try {
      if (request['collectorId'] != null) {
        await NotificationService.sendNotificationToUser(
          receiverUserId: request['collectorId'],
          title: t['request_cancelled_title']!,
          body: t['request_cancelled_reopened']!,
        );
      }

      await RequestService.reopenRequest(docId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.refresh_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(t['request_reopened']!),
              ],
            ),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${t['error']!}: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
