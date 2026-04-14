import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green_way_new/services/request_service.dart';
import 'package:green_way_new/services/user_service.dart';
import 'package:green_way_new/services/collection_point_service.dart';

class AdminStatisticsPage extends StatelessWidget {
  final Map<String, String> t;
  const AdminStatisticsPage({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t['overview']!,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // إحصائيات المستخدمين
          Row(
            children: [
              Expanded(child: _buildStatCard(t['citizens']!, 'citizen', Icons.person_rounded, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(t['collectors']!, 'collector', Icons.local_shipping_rounded, Colors.purple)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard(t['collection_points']!, 'collection_point', Icons.store_rounded, Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(t['factories']!, 'factory', Icons.precision_manufacturing_rounded, Colors.teal)),
            ],
          ),

          const SizedBox(height: 24),
          Text(
            t['request_statistics']!,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // إحصائيات الطلبات
          Row(
            children: [
              Expanded(child: _buildRequestStatCard(t['pending_status']!, 'pending', Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _buildRequestStatCard(t['accepted_status']!, 'accepted', Colors.blue)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildRequestStatCard(t['completed_status']!, 'completed', Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _buildRequestStatCard(t['cancelled_status']!, 'cancelled', Colors.red)),
            ],
          ),

          const SizedBox(height: 24),
          Text(
            t['pending_collection_points']!,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildPendingCollectionPoints(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String role, IconData icon, Color color) {
    return StreamBuilder<QuerySnapshot>(
      stream: UserService.getUsersByRole(role),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(20),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequestStatCard(String title, String status, Color color) {
    return StreamBuilder<QuerySnapshot>(
      stream: RequestService.getRequestsByStatus(status),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withAlpha(50)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(40),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.assignment_rounded, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPendingCollectionPoints() {
    return StreamBuilder<QuerySnapshot>(
      stream: CollectionPointService.getPendingPoints(),
      builder: (context, snapshot) {
        final points = snapshot.data?.docs ?? [];

        if (points.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                t['no_pending_requests']!,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.orange.withAlpha(20),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.withAlpha(50)),
          ),
          child: Row(
            children: [
              const Icon(Icons.pending_actions_rounded, color: Colors.orange, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${points.length} ${t['pending_requests_count']!}',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.orange, size: 16),
            ],
          ),
        );
      },
    );
  }
}
