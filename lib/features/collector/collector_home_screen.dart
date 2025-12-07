import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:green_way_new/auth_service.dart';
import 'package:green_way_new/features/auth/auth_screen.dart';
import 'package:green_way_new/features/chat/chat_screen.dart';
import 'package:green_way_new/features/wallet/wallet_screen.dart';
import 'package:green_way_new/features/profile/profile_screen.dart';

class CollectorHomeScreen extends ConsumerWidget {
  const CollectorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;
    final userName = user?.displayName ?? 'جامع';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.account_balance_wallet),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white.withAlpha(50),
                                    child: const Icon(Icons.local_shipping, color: Colors.white, size: 30),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'مرحباً $userName 👋',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Text(
                                      'اجمع النفايات واكسب المال',
                                      style: TextStyle(color: Colors.white70, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            // إحصائيات سريعة
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('requests')
                                  .where('status', isEqualTo: 'accepted')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                final acceptedCount = snapshot.data?.docs.length ?? 0;
                                return Row(
                                  children: [
                                    _buildMiniStat(Icons.assignment, '$acceptedCount', 'طلبات نشطة'),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                bottom: const TabBar(
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(text: 'طلبات متاحة', icon: Icon(Icons.list_alt)),
                    Tab(text: 'طلباتي', icon: Icon(Icons.assignment_turned_in)),
                  ],
                ),
              ),
            ];
          },
          body: const TabBarView(
            children: [
              _AvailableRequestsTab(),
              _MyAcceptedRequestsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(40),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            '$value $label',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _AvailableRequestsTab extends StatelessWidget {
  const _AvailableRequestsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where('status', isEqualTo: 'pending')
          .snapshots(),
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
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.inbox, size: 60, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 16),
                const Text(
                  'لا توجد طلبات متاحة',
                  style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                const Text(
                  'سيتم إشعارك عند وجود طلبات جديدة',
                  style: TextStyle(color: Colors.grey),
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
            return _RequestCard(docId: doc.id, request: request);
          },
        );
      },
    );
  }
}

class _RequestCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> request;

  const _RequestCard({required this.docId, required this.request});

  final wasteTypes = const {
    'plastic': {'name': 'بلاستيك', 'icon': Icons.local_drink, 'color': Colors.blue},
    'paper': {'name': 'ورق وكرتون', 'icon': Icons.description, 'color': Colors.brown},
    'glass': {'name': 'زجاج', 'icon': Icons.wine_bar, 'color': Colors.green},
    'metal': {'name': 'معادن', 'icon': Icons.settings, 'color': Colors.grey},
    'electronics': {'name': 'إلكترونيات', 'icon': Icons.devices, 'color': Colors.purple},
    'organic': {'name': 'عضوية', 'icon': Icons.eco, 'color': Colors.lightGreen},
  };

  @override
  Widget build(BuildContext context) {
    final wasteType = wasteTypes[request['wasteType']] ?? wasteTypes['plastic']!;

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
                        color: (wasteType['color'] as Color).withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
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
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.scale, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                '${request['quantity']} كجم',
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
                        color: Colors.orange.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'جديد',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      request['userName'] ?? 'مستخدم',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        request['address'] ?? '',
                        style: TextStyle(color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: ElevatedButton.icon(
              onPressed: () => _acceptRequest(context),
              icon: const Icon(Icons.check_circle),
              label: const Text('قبول الطلب'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptRequest(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('requests').doc(docId).update({
        'status': 'accepted',
        'collectorId': user?.uid ?? '',
        'collectorName': user?.displayName ?? 'جامع',
        'acceptedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم قبول الطلب بنجاح!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

class _MyAcceptedRequestsTab extends StatelessWidget {
  const _MyAcceptedRequestsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where('status', isEqualTo: 'accepted')
          .snapshots(),
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
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.assignment, size: 60, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 16),
                const Text(
                  'لا توجد طلبات مقبولة',
                  style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                const Text(
                  'اقبل طلباً من قائمة الطلبات المتاحة',
                  style: TextStyle(color: Colors.grey),
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
            return _AcceptedCard(docId: doc.id, request: request);
          },
        );
      },
    );
  }
}

class _AcceptedCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> request;

  const _AcceptedCard({required this.docId, required this.request});

  final wasteTypes = const {
    'plastic': {'name': 'بلاستيك', 'icon': Icons.local_drink, 'color': Colors.blue},
    'paper': {'name': 'ورق وكرتون', 'icon': Icons.description, 'color': Colors.brown},
    'glass': {'name': 'زجاج', 'icon': Icons.wine_bar, 'color': Colors.green},
    'metal': {'name': 'معادن', 'icon': Icons.settings, 'color': Colors.grey},
    'electronics': {'name': 'إلكترونيات', 'icon': Icons.devices, 'color': Colors.purple},
    'organic': {'name': 'عضوية', 'icon': Icons.eco, 'color': Colors.lightGreen},
  };

  @override
  Widget build(BuildContext context) {
    final wasteType = wasteTypes[request['wasteType']] ?? wasteTypes['plastic']!;

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
                        color: (wasteType['color'] as Color).withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
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
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.scale, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                '${request['quantity']} كجم',
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
                        color: Colors.blue.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'تم القبول',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      request['userName'] ?? 'مستخدم',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        request['address'] ?? '',
                        style: TextStyle(color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            requestId: docId,
                            otherUserName: request['userName'] ?? 'المواطن',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('محادثة'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4CAF50),
                      side: const BorderSide(color: Color(0xFF4CAF50)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _completeRequest(context),
                    icon: const Icon(Icons.done_all),
                    label: const Text('تم الجمع'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeRequest(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('requests').doc(docId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إكمال الطلب بنجاح!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
      );
    }
  }
}