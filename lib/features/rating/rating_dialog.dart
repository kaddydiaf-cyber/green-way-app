import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingDialog extends StatefulWidget {
  final String requestId;
  final String ratedUserId;
  final String ratedUserName;

  const RatingDialog({
    super.key,
    required this.requestId,
    required this.ratedUserId,
    required this.ratedUserName,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('تقييم ${widget.ratedUserName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('كيف كانت تجربتك؟'),
          const SizedBox(height: 16),

          // النجوم
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () => setState(() => _rating = index + 1),
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 36,
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          // تعليق
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'تعليق (اختياري)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _rating > 0 && !_isLoading ? _submitRating : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
          ),
          child: _isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          )
              : const Text('إرسال', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> _submitRating() async {
    setState(() => _isLoading = true);

    try {
      // إضافة التقييم
      await FirebaseFirestore.instance.collection('ratings').add({
        'requestId': widget.requestId,
        'ratedUserId': widget.ratedUserId,
        'rating': _rating,
        'comment': _commentController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // تحديث متوسط تقييم المستخدم
      await _updateUserRating();

      // تحديث حالة الطلب
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.requestId)
          .update({'isRated': true});

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('شكراً على تقييمك!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateUserRating() async {
    // جلب جميع تقييمات المستخدم
    final ratings = await FirebaseFirestore.instance
        .collection('ratings')
        .where('ratedUserId', isEqualTo: widget.ratedUserId)
        .get();

    if (ratings.docs.isNotEmpty) {
      double totalRating = 0;
      for (var doc in ratings.docs) {
        totalRating += (doc.data()['rating'] ?? 0).toDouble();
      }
      final averageRating = totalRating / ratings.docs.length;

      // تحديث متوسط التقييم في بيانات المستخدم
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.ratedUserId)
          .update({
        'averageRating': averageRating,
        'totalRatings': ratings.docs.length,
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}