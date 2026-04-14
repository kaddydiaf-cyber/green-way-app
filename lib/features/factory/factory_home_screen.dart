import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green_way_new/services/request_service.dart';
import 'package:green_way_new/auth_service.dart';
import 'package:green_way_new/features/wallet/wallet_screen.dart';
import 'package:green_way_new/features/profile/profile_screen.dart';
import 'package:green_way_new/l10n/app_translations.dart';
import 'package:green_way_new/app.dart';
import 'package:green_way_new/theme/app_colors.dart';

class FactoryHomeScreen extends ConsumerWidget {
  const FactoryHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppTranslations.get(ref.watch(languageProvider).languageCode);
    final authService = ref.read(authServiceProvider);
    final userName = authService.currentUser?.displayName ?? t['factory']!;

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
                backgroundColor: AppColors.primary,
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
                        colors: [AppColors.primary, AppColors.primaryDark],
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
                                      '${t['hello_user']!} $userName 👋',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      t['buy_recycled_materials']!,
                                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            StreamBuilder<QuerySnapshot>(
                              stream: RequestService.getCompletedRequests(),
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
                                        '$availableCount ${t['available_materials_count']!}',
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
                bottom: TabBar(
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(text: t['available_materials']!, icon: const Icon(Icons.inventory_2)),
                    Tab(text: t['my_purchases']!, icon: const Icon(Icons.shopping_bag)),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _AvailableMaterialsTab(t: t),
              _MyPurchasesTab(t: t),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvailableMaterialsTab extends StatelessWidget {
  final Map<String, String> t;

  const _AvailableMaterialsTab({required this.t});

  Map<String, Map<String, dynamic>> _getWasteTypes() => {
    'plastic': {'name': t['plastic']!, 'icon': Icons.recycling_rounded, 'color': AppColors.wastePlastic, 'price': 5.0},
    'paper': {'name': t['paper_cardboard']!, 'icon': Icons.article_rounded, 'color': AppColors.wastePaper, 'price': 3.0},
    'wood': {'name': t['wood']!, 'icon': Icons.park_rounded, 'color': AppColors.wasteWood, 'price': 4.0},
    'glass': {'name': t['glass']!, 'icon': Icons.liquor_rounded, 'color': AppColors.wasteGlass, 'price': 4.0},
    'metal': {'name': t['metal']!, 'icon': Icons.hardware_rounded, 'color': AppColors.wasteMetal, 'price': 8.0},
    'electronics': {'name': t['electronics']!, 'icon': Icons.memory_rounded, 'color': AppColors.wasteElectronics, 'price': 15.0},
    'organic': {'name': t['organic']!, 'icon': Icons.compost_rounded, 'color': AppColors.wasteOrganic, 'price': 2.0},
    'other': {'name': t['other']!, 'icon': Icons.category_rounded, 'color': AppColors.wasteOther, 'price': 1.0},
  };

  @override
  Widget build(BuildContext context) {
    final wasteTypes = _getWasteTypes();
    return StreamBuilder<QuerySnapshot>(
      stream: RequestService.getCompletedRequests(),
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
                Text(
                  t['no_materials_available']!,
                  style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  t['will_notify_new_materials']!,
                  style: const TextStyle(color: Colors.grey),
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
            return _MaterialCard(docId: doc.id, request: request, wasteTypes: wasteTypes, t: t);
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
  final Map<String, String> t;

  const _MaterialCard({
    required this.docId,
    required this.request,
    required this.wasteTypes,
    required this.t,
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
                            '$quantity ${t['kg']!}',
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
                      '$totalPrice ${t['da']!}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '$pricePerKg ${t['da_per_kg']!}',
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
              label: Text('${t['buy_for_price']!} $totalPrice ${t['da']!}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
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
      await RequestService.markAsSold(docId: docId, price: price);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t['purchase_success']!), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t['error']!}: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

class _MyPurchasesTab extends StatelessWidget {
  final Map<String, String> t;

  const _MyPurchasesTab({required this.t});

  Map<String, Map<String, dynamic>> _getWasteTypes() => {
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
    final wasteTypes = _getWasteTypes();
    return StreamBuilder<QuerySnapshot>(
      stream: RequestService.getSoldRequests(),
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
                Text(
                  t['no_purchases']!,
                  style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  t['buy_from_available']!,
                  style: const TextStyle(color: Colors.grey),
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
            return _PurchaseCard(request: request, wasteTypes: wasteTypes, t: t);
          },
        );
      },
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final Map<String, Map<String, dynamic>> wasteTypes;
  final Map<String, String> t;

  const _PurchaseCard({required this.request, required this.wasteTypes, required this.t});

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
                  '${request['quantity']} ${t['kg']!}',
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
              '${request['soldPrice']} ${t['da']!}',
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