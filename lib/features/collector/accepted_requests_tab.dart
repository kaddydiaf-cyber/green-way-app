import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green_way_new/services/request_service.dart';
import 'package:green_way_new/notification_service.dart';
import 'package:green_way_new/utils/time_utils.dart';
import 'package:green_way_new/sound_service.dart';
import 'package:green_way_new/features/chat/chat_screen.dart';
import 'package:green_way_new/features/rating/rating_dialog.dart';
import 'package:green_way_new/theme/app_colors.dart';

class AcceptedRequestsTab extends StatefulWidget {
  final String collectorId;
  final Map<String, String> t;
  final String langCode;

  const AcceptedRequestsTab({super.key, required this.collectorId, required this.t, required this.langCode});

  @override
  State<AcceptedRequestsTab> createState() => _AcceptedRequestsTabState();
}

class _AcceptedRequestsTabState extends State<AcceptedRequestsTab> {
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
      stream: RequestService.getCollectorRequests(widget.collectorId),
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
                  child: Icon(Icons.assignment_rounded, size: 60, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 20),
                Text(
                  t['no_requests']!,
                  style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  t['accept_first_tab']!,
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
            return _buildAcceptedCard(context, doc.id, request);
          },
        );
      },
    );
  }

  String _getTimeText(Map<String, dynamic> request) {
    final status = request['status'] ?? 'accepted';

    if (status == 'completed') {
      return '${t['completed_since']!} ${TimeUtils.getTimeAgo(request['completedAt'] as Timestamp?, langCode: langCode)}';
    } else {
      return '${t['accepted_since']!} ${TimeUtils.getTimeAgo(request['acceptedAt'] as Timestamp?, langCode: langCode)}';
    }
  }

  Widget _buildAcceptedCard(BuildContext context, String docId, Map<String, dynamic> request) {
    final wasteType = _wasteTypes[request['wasteType']] ?? _wasteTypes['plastic']!;
    final color = wasteType['color'] as Color;
    final hasNewMessage = request['hasNewMessageForCollector'] == true;
    final status = request['status'] ?? 'accepted';
    final isCompleted = status == 'completed';
    final isRatedByCollector = request['isRatedByCollector'] == true;

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
                        color: isCompleted
                            ? Colors.green.withAlpha(25)
                            : Colors.blue.withAlpha(25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCompleted
                                ? Icons.check_circle_rounded
                                : Icons.hourglass_top_rounded,
                            color: isCompleted ? Colors.green : Colors.blue,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isCompleted ? t['completed_label']! : t['accepted_label']!,
                            style: TextStyle(
                              color: isCompleted ? Colors.green : Colors.blue,
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
                _buildInfoRow(Icons.access_time_rounded, _getTimeText(request)),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.location_on_rounded, request['address'] ?? ''),
                if (request['description'] != null && request['description'].toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.note_rounded, request['description']),
                ],

                if (isCompleted && isRatedByCollector) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          t['citizen_rated']!,
                          style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
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
            child: Column(
              children: [
                if (isCompleted) ...[
                  if (!isRatedByCollector)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showRatingDialog(context, docId, request),
                        icon: const Icon(Icons.star_rounded),
                        label: Text(t['rate_citizen']!),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
                    ),
                ] else ...[
                  Row(
                    children: [
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
                                        otherUserName: request['userName'] ?? t['the_citizen']!,
                                        langCode: langCode,
                                        otherUserId: request['userId'],
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.chat_rounded),
                                label: Text(t['conversation']!),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _completeRequest(context, docId, request),
                          icon: const Icon(Icons.done_all_rounded),
                          label: Text(t['collection_done']!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _cancelAcceptance(context, docId, request),
                      icon: const Icon(Icons.undo_rounded, size: 18),
                      label: Text(t['undo_acceptance']!),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

  void _showRatingDialog(BuildContext context, String docId, Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (_) => RatingDialog(
        requestId: docId,
        ratedUserId: request['userId'] ?? '',
        ratedUserName: request['userName'] ?? t['the_citizen']!,
        raterType: 'collector',
        langCode: langCode,
      ),
    );
  }

  Future<void> _cancelAcceptance(BuildContext context, String docId, Map<String, dynamic> request) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.undo_rounded, color: Colors.orange),
            ),
            const SizedBox(width: 12),
            Text(t['undo_acceptance_title']!),
          ],
        ),
        content: Text(
          t['undo_acceptance_message']!,
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t['no_keep_it']!),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                if (request['userId'] != null) {
                  await NotificationService.sendNotificationToUser(
                    receiverUserId: request['userId'],
                    title: t['collector_undo_title']!,
                    body: t['collector_undo_body']!,
                  );
                }
                await RequestService.undoAcceptance(docId);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(t['undo_success']!),
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
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(t['yes_undo']!),
          ),
        ],
      ),
    );
  }

  Future<void> _completeRequest(BuildContext context, String docId, Map<String, dynamic> request) async {
    try {
      await RequestService.completeRequest(docId);

      // تشغيل صوت النجاح
      await SoundService.playSuccessSound();

      if (request['userId'] != null) {
        await NotificationService.sendNotificationToUser(
          receiverUserId: request['userId'],
          title: t['collection_complete_title']!,
          body: t['collection_complete_body']!,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text(t['request_complete_success']!),
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
