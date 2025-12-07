import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green_way_new/auth_service.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final userId = authService.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final balance = (userData['walletBalance'] ?? 0.0).toDouble();

          return CustomScrollView(
            slivers: [
              // الهيدر
              SliverAppBar(
                expandedHeight: 280,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(30),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'رصيدك الحالي',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$balance د.ج',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildActionButton(
                                context,
                                icon: Icons.add,
                                label: 'إيداع',
                                onTap: () => _showDepositDialog(context, userId!),
                              ),
                              const SizedBox(width: 20),
                              _buildActionButton(
                                context,
                                icon: Icons.remove,
                                label: 'سحب',
                                onTap: () => _showWithdrawDialog(context, userId!, balance),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // سجل المعاملات
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.history, color: Color(0xFF4CAF50)),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'سجل المعاملات',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              // قائمة المعاملات
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('transactions')
                    .where('userId', isEqualTo: userId)
                    .orderBy('createdAt', descending: true)
                    .limit(20)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return SliverToBoxAdapter(
                      child: _buildEmptyState(),
                    );
                  }

                  final transactions = snapshot.data?.docs ?? [];

                  if (transactions.isEmpty) {
                    return SliverToBoxAdapter(
                      child: _buildEmptyState(),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final transaction = transactions[index].data() as Map<String, dynamic>;
                        return _buildTransactionItem(transaction);
                      },
                      childCount: transactions.length,
                    ),
                  );
                },
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF4CAF50)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'لا توجد معاملات بعد',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final type = transaction['type'] ?? 'deposit';
    final amount = (transaction['amount'] ?? 0.0).toDouble();
    final isDeposit = type == 'deposit';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDeposit ? Colors.green.withAlpha(30) : Colors.red.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isDeposit ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDeposit ? 'إيداع' : 'سحب',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  transaction['description'] ?? '',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${isDeposit ? '+' : '-'}$amount د.ج',
            style: TextStyle(
              color: isDeposit ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _showDepositDialog(BuildContext context, String userId) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.green),
            ),
            const SizedBox(width: 12),
            const Text('إيداع مبلغ'),
          ],
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'المبلغ (د.ج)',
            prefixIcon: const Icon(Icons.attach_money),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text) ?? 0;
              if (amount > 0) {
                await _deposit(userId, amount);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('إيداع', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context, String userId, double currentBalance) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.remove, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('سحب مبلغ'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'المبلغ (د.ج)',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'الرصيد المتاح: $currentBalance د.ج',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text) ?? 0;
              if (amount > 0 && amount <= currentBalance) {
                await _withdraw(userId, amount);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('سحب', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deposit(String userId, double amount) async {
    final batch = FirebaseFirestore.instance.batch();

    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    batch.update(userRef, {
      'walletBalance': FieldValue.increment(amount),
    });

    final transactionRef = FirebaseFirestore.instance.collection('transactions').doc();
    batch.set(transactionRef, {
      'userId': userId,
      'type': 'deposit',
      'amount': amount,
      'description': 'إيداع مبلغ',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> _withdraw(String userId, double amount) async {
    final batch = FirebaseFirestore.instance.batch();

    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    batch.update(userRef, {
      'walletBalance': FieldValue.increment(-amount),
    });

    final transactionRef = FirebaseFirestore.instance.collection('transactions').doc();
    batch.set(transactionRef, {
      'userId': userId,
      'type': 'withdraw',
      'amount': amount,
      'description': 'سحب مبلغ',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}