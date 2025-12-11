import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:green_way_new/auth_service.dart';
import 'package:green_way_new/data/wilayas.dart';
import 'package:green_way_new/features/chat/chat_screen.dart';
import 'package:green_way_new/features/wallet/wallet_screen.dart';
import 'package:green_way_new/features/profile/profile_screen.dart';
import 'package:green_way_new/notification_service.dart';

class CollectorHomeScreen extends ConsumerStatefulWidget {
  const CollectorHomeScreen({super.key});

  @override
  ConsumerState<CollectorHomeScreen> createState() => _CollectorHomeScreenState();
}

class _CollectorHomeScreenState extends ConsumerState<CollectorHomeScreen> {
  String? userWilaya;
  String? userWilayaName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserWilaya();
  }

  Future<void> _loadUserWilaya() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        userWilaya = userDoc.data()?['wilaya'] ?? '';
        userWilayaName = Wilayas.getNameByCode(userWilaya ?? '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.read(authServiceProvider);
    final userName = authService.currentUser?.displayName ?? 'جامع';
    final collectorId = authService.currentUser?.uid ?? '';

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 220,
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(40),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_city, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'طلبات ولاية $userWilayaName',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                bottom: TabBar(
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    const Tab(text: 'طلبات متاحة', icon: Icon(Icons.list_alt)),
                    // تبويب طلباتي مع Badge
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('requests')
                          .where('collectorId', isEqualTo: collectorId)
                          .where('status', isEqualTo: 'accepted')
                          .snapshots(),
                      builder: (context, snapshot) {
                        int unreadCount = 0;
                        if (snapshot.hasData) {
                          for (var doc in snapshot.data!.docs) {
                            final data = doc.data() as Map<String, dynamic>;
                            if (data['hasNewMessageForCollector'] == true) {
                              unreadCount++;
                            }
                          }
                        }
                        return Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.assignment_turned_in),
                              const SizedBox(width: 4),
                              const Text('طلباتي'),
                              if (unreadCount > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$unreadCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _AvailableRequestsTab(wilaya: userWilaya ?? ''),
              _MyAcceptedRequestsTab(collectorId: collectorId),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== طلبات متاحة ====================
class _AvailableRequestsTab extends StatelessWidget {
  final String wilaya;

  const _AvailableRequestsTab({required this.wilaya});

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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where('status', isEqualTo: 'pending')
          .where('wilaya', isEqualTo: wilaya)
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
                  'لا توجد طلبات متاحة في ولايتك',
                  style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
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
            return _buildRequestCard(context, doc.id, request);
          },
        );
      },
    );
  }

  Widget _buildRequestCard(BuildContext context, String docId, Map<String, dynamic> request) {
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
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(request['userName'] ?? 'مستخدم', style: TextStyle(color: Colors.grey.shade600)),
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
              onPressed: () => _acceptRequest(context, docId, request),
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

  Future<void> _acceptRequest(BuildContext context, String docId, Map<String, dynamic> request) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('requests').doc(docId).update({
        'status': 'accepted',
        'collectorId': user?.uid ?? '',
        'collectorName': user?.displayName ?? 'جامع',
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      await NotificationService.showNotification(
        title: 'تم قبول الطلب ✅',
        body: 'لقد قبلت طلب ${request['userName'] ?? 'المواطن'}',
      );

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

// ==================== طلباتي المقبولة ====================
class _MyAcceptedRequestsTab extends StatelessWidget {
  final String collectorId;

  const _MyAcceptedRequestsTab({required this.collectorId});

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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where('status', isEqualTo: 'accepted')
          .where('collectorId', isEqualTo: collectorId)
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
            return _buildAcceptedCard(context, doc.id, request);
          },
        );
      },
    );
  }

  Widget _buildAcceptedCard(BuildContext context, String docId, Map<String, dynamic> request) {
    final wasteType = wasteTypes[request['wasteType']] ?? wasteTypes['plastic']!;
    final hasNewMessage = request['hasNewMessageForCollector'] == true;

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
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(request['userName'] ?? 'مستخدم', style: TextStyle(color: Colors.grey.shade600)),
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
                // زر المحادثة مع Badge
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
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _completeRequest(context, docId, request),
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

  Future<void> _completeRequest(BuildContext context, String docId, Map<String, dynamic> request) async {
    try {
      await FirebaseFirestore.instance.collection('requests').doc(docId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });

      await NotificationService.showNotification(
        title: 'تم إكمال الجمع ✅',
        body: 'أحسنت! تم جمع النفايات من ${request['userName'] ?? 'المواطن'}',
      );

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