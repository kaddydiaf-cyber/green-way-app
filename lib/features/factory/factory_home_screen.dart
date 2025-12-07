import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green_way_new/auth_service.dart';
import 'package:green_way_new/features/auth/auth_screen.dart';
import 'package:green_way_new/features/wallet/wallet_screen.dart';
import 'package:green_way_new/features/profile/profile_screen.dart';

class FactoryHomeScreen extends ConsumerWidget {
  const FactoryHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final userName = authService.currentUser?.displayName ?? 'مصنع';

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
                        colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
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
                                    child: const Icon(Icons.factory, color: Colors.white, size: 30),
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
                                      'اشترِ المواد المعاد تدويرها',
                                      style: TextStyle(color: Colors.white70, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('requests')
                                  .where('status', isEqualTo: 'completed')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                final availableCount = snapshot.data?.docs.length ?? 0;
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(40),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.inventory, color: Colors.white, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$availableCount مادة متاحة للشراء',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
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
                    Tab(text: 'مواد متاحة', icon: Icon(Icons.inventory_2)),
                    Tab(text: 'مشترياتي', icon: Icon(Icons.shopping_bag)),
                  ],
                ),
              ),
            ];
          },
          body: const TabBarView(
            children: [
              _AvailableMaterialsTab(),
              _MyPurchasesTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvailableMaterialsTab extends StatelessWidget {
  const _AvailableMaterialsTab();

  final wasteTypes = const {
    'plastic': {'name': 'بلاستيك', 'icon': Icons.local_drink, 'color': Colors.blue, 'price': 5.0},
    'paper': {'name': 'ورق وكرتون', 'icon': Icons.description, 'color': Colors.brown, 'price': 3.0},
    'glass': {'name': 'زجاج', 'icon': Icons.wine_bar, 'color': Colors.green, 'price': 4.0},
    'metal': {'name': 'معادن', 'icon': Icons.settings, 'color': Colors.grey, 'price': 8.0},
    'electronics': {'name': 'إلكترونيات', 'icon': Icons.devices, 'color': Colors.purple, 'price': 15.0},
    'organic': {'name': 'عضوية', 'icon': Icons.eco, 'color': Colors.lightGreen, 'price': 2.0},
  };

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where('status', isEqualTo: 'completed')
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
                  child: Icon(Icons.inventory_2, size: 60, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 16),
                const Text(
                  'لا توجد مواد متاحة للشراء',
                  style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                const Text(
                  'سيتم إشعارك عند توفر مواد جديدة',
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
            return _MaterialCard(docId: doc.id, request: request, wasteTypes: wasteTypes);
          },
        );
      },
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> request;
  final Map<String, Map<String, dynamic>> wasteTypes;

  const _MaterialCard({
    required this.docId,
    required this.request,
    required this.wasteTypes,
  });

  @override
  Widget build(BuildContext context) {
    final wasteType = wasteTypes[request['wasteType']] ?? wasteTypes['plastic']!;
    final quantity = (request['quantity'] ?? 0).toDouble();
    final pricePerKg = wasteType['price'] as double;
    final totalPrice = quantity * pricePerKg;

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
            child: Row(
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
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
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
                            '$quantity كجم',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$totalPrice د.ج',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    Text(
                      '$pricePerKg د.ج/كجم',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
              onPressed: () => _buyMaterial(context, totalPrice),
              icon: const Icon(Icons.shopping_cart),
              label: Text('شراء بـ $totalPrice د.ج'),
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

  Future<void> _buyMaterial(BuildContext context, double price) async {
    try {
      await FirebaseFirestore.instance.collection('requests').doc(docId).update({
        'status': 'sold',
        'soldAt': FieldValue.serverTimestamp(),
        'soldPrice': price,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الشراء بنجاح!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

class _MyPurchasesTab extends StatelessWidget {
  const _MyPurchasesTab();

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
          .where('status', isEqualTo: 'sold')
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
                  child: Icon(Icons.shopping_bag, size: 60, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 16),
                const Text(
                  'لا توجد مشتريات',
                  style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                const Text(
                  'اشترِ مواد من قائمة المواد المتاحة',
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
            final request = requests[index].data() as Map<String, dynamic>;
            return _PurchaseCard(request: request, wasteTypes: wasteTypes);
          },
        );
      },
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final Map<String, Map<String, dynamic>> wasteTypes;

  const _PurchaseCard({required this.request, required this.wasteTypes});

  @override
  Widget build(BuildContext context) {
    final wasteType = wasteTypes[request['wasteType']] ?? wasteTypes['plastic']!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
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
          const SizedBox(width: 16),
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
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${request['soldPrice']} د.ج',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}