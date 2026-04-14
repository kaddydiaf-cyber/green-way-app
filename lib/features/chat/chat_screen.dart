import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:green_way_new/notification_service.dart';
import 'package:green_way_new/l10n/app_translations.dart';
import 'package:green_way_new/services/chat_service.dart';
import 'package:green_way_new/services/request_service.dart';
import 'package:green_way_new/services/image_compress_service.dart';
import 'package:green_way_new/features/chat/widgets/message_bubble.dart';
import 'package:green_way_new/features/chat/widgets/full_image_viewer.dart';
import 'package:green_way_new/theme/app_colors.dart';
import 'package:green_way_new/features/chat/widgets/image_source_sheet.dart';
import 'package:green_way_new/features/chat/widgets/chat_input_bar.dart';

class ChatScreen extends StatefulWidget {
  final String requestId;
  final String otherUserName;
  final String? otherUserId;
  final String langCode;

  const ChatScreen({
    super.key,
    required this.requestId,
    required this.otherUserName,
    this.otherUserId,
    this.langCode = 'ar',
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final currentUser = FirebaseAuth.instance.currentUser;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isBlocked = false;
  bool _isBlockedByOther = false;
  bool _isUploading = false;
  String? _otherUserId;

  Map<String, String> get t => AppTranslations.get(widget.langCode);

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
    _getOtherUserId();
  }

  Future<void> _getOtherUserId() async {
    if (widget.otherUserId != null) {
      _otherUserId = widget.otherUserId;
    } else {
      try {
        final requestDoc = await RequestService.getRequest(widget.requestId);

        final requestData = requestDoc.data() as Map<String, dynamic>?;
        if (requestData != null) {
          final isCollector = currentUser?.uid == requestData['collectorId'];
          _otherUserId = isCollector
              ? requestData['citizenId']
              : requestData['collectorId'];
        }
      } catch (e) {
        print('Error getting other user ID: $e');
      }
    }
    _checkBlockStatus();
  }

  Future<void> _checkBlockStatus() async {
    if (_otherUserId == null || currentUser == null) return;

    try {
      final isBlocked = await ChatService.isUserBlocked(currentUserId: currentUser!.uid, otherUserId: _otherUserId!);
      final isBlockedByOther = await ChatService.isBlockedByUser(currentUserId: currentUser!.uid, otherUserId: _otherUserId!);

      setState(() {
        _isBlocked = isBlocked;
        _isBlockedByOther = isBlockedByOther;
      });
    } catch (e) {
      print('Error checking block status: $e');
    }
  }

  Future<void> _markMessagesAsRead() async {
    try {
      final requestDoc = await RequestService.getRequest(widget.requestId);

      final requestData = requestDoc.data() as Map<String, dynamic>?;
      if (requestData != null) {
        final isCollector = currentUser?.uid == requestData['collectorId'];

        await RequestService.markMessagesAsRead(requestId: widget.requestId, isCollector: isCollector);
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // ==================== وظائف الصور ====================

  /// اختيار مصدر الصورة
  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ImageSourceSheet(
        t: t,
        onSourceSelected: _pickImage,
      ),
    );
  }

  /// اختيار صورة
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
      );

      if (image != null) {
        await _uploadAndSendImage(File(image.path));
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t['image_selection_error']!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// رفع الصورة وإرسالها
  Future<void> _uploadAndSendImage(File imageFile) async {
    if (_isBlocked || _isBlockedByOther) return;

    setState(() => _isUploading = true);

    try {
      // ضغط الصورة قبل الرفع
      final compressedFile = await ImageCompressService.compressImage(imageFile);

      // إنشاء اسم فريد للصورة
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${currentUser?.uid}.jpg';
      final ref = FirebaseStorage.instance
          .ref()
          .child('chat_images')
          .child(widget.requestId)
          .child(fileName);

      // رفع الصورة المضغوطة
      await ref.putFile(compressedFile);

      // الحصول على رابط الصورة
      final imageUrl = await ref.getDownloadURL();

      // إرسال الرسالة مع الصورة
      await ChatService.sendImageMessage(requestId: widget.requestId, imageUrl: imageUrl, senderId: currentUser?.uid, senderName: currentUser?.displayName ?? t['user']!);

      // تحديث حالة الرسائل الجديدة
      final requestDoc = await RequestService.getRequest(widget.requestId);

      final requestData = requestDoc.data() as Map<String, dynamic>?;
      if (requestData != null) {
        final isCollector = currentUser?.uid == requestData['collectorId'];

        await RequestService.setNewMessageFlag(requestId: widget.requestId, senderIsCollector: isCollector);
      }

      // إرسال إشعار
      if (_otherUserId != null) {
        await NotificationService.sendNotificationToUser(
          receiverUserId: _otherUserId!,
          title: t['new_image_notif']!,
          body: '${currentUser?.displayName ?? t['user']!} ${t['sent_image']!}',
          chatId: widget.requestId,
        );
      }
    } catch (e) {
      print('Error uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t['image_send_error']!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // ==================== وظائف الحظر والإبلاغ ====================

  Future<void> _blockUser() async {
    if (_otherUserId == null || currentUser == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.block, color: Colors.red),
            const SizedBox(width: 8),
            Text(t['block_user']!),
          ],
        ),
        content: Text(
          '${t['confirm_block_title']!} "${widget.otherUserName}"؟\n\n${t['confirm_block']!}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t['cancel']!),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(t['block']!, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ChatService.blockUser(currentUserId: currentUser!.uid, otherUserId: _otherUserId!, otherUserName: widget.otherUserName);

      setState(() {
        _isBlocked = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t['user_blocked']!} ${widget.otherUserName}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      print('Error blocking user: $e');
    }
  }

  Future<void> _unblockUser() async {
    if (_otherUserId == null || currentUser == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text(t['unblock_user']!),
          ],
        ),
        content: Text('${t['confirm_unblock']!} "${widget.otherUserName}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t['cancel']!),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(t['unblock']!, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ChatService.unblockUser(currentUserId: currentUser!.uid, otherUserId: _otherUserId!);

      setState(() {
        _isBlocked = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t['user_unblocked']!} ${widget.otherUserName}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      print('Error unblocking user: $e');
    }
  }

  Future<void> _reportUser() async {
    if (_otherUserId == null || currentUser == null) return;

    String? selectedReason;
    final TextEditingController detailsController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.flag, color: Colors.orange),
              const SizedBox(width: 8),
              Text(t['report_user_title']!),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${t['report_about']!} ${widget.otherUserName}'),
                const SizedBox(height: 16),
                Text(t['report_reason']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...[
                  t['abusive_content']!,
                  t['fraud']!,
                  t['inappropriate_behavior']!,
                  t['spam']!,
                  t['impersonation']!,
                  t['other_reason']!,
                ].map((reason) => RadioListTile<String>(
                  title: Text(reason, style: const TextStyle(fontSize: 14)),
                  value: reason,
                  groupValue: selectedReason,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedReason = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                )),
                const SizedBox(height: 8),
                TextField(
                  controller: detailsController,
                  decoration: InputDecoration(
                    hintText: t['additional_details']!,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t['cancel']!),
            ),
            ElevatedButton(
              onPressed: selectedReason != null
                  ? () => Navigator.pop(context, true)
                  : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text(t['send_report']!, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (result != true || selectedReason == null) return;

    try {
      await ChatService.reportUser(reporterId: currentUser!.uid, reporterName: currentUser!.displayName ?? t['user']!, reportedUserId: _otherUserId!, reportedUserName: widget.otherUserName, reason: selectedReason!, details: detailsController.text.trim(), chatId: widget.requestId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(t['report_sent']!),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }

      if (!_isBlocked && mounted) {
        final blockToo = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(t['block_user_too']!),
            content: Text(t['block_to_prevent']!),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(t['no']!),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(t['yes_block']!, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );

        if (blockToo == true) {
          await _blockUser();
        }
      }
    } catch (e) {
      print('Error reporting user: $e');
    }
  }

  // ==================== واجهة المستخدم ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withAlpha(50),
                child: Text(
                  widget.otherUserName.isNotEmpty
                      ? widget.otherUserName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  _isBlocked ? t['blocked']! : t['online']!,
                  style: TextStyle(
                    fontSize: 12,
                    color: _isBlocked ? Colors.red.shade200 : Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              switch (value) {
                case 'block':
                  _blockUser();
                  break;
                case 'unblock':
                  _unblockUser();
                  break;
                case 'report':
                  _reportUser();
                  break;
              }
            },
            itemBuilder: (context) => [
              if (_isBlocked)
                PopupMenuItem(
                  value: 'unblock',
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 12),
                      Text(t['unblock_user']!),
                    ],
                  ),
                )
              else
                PopupMenuItem(
                  value: 'block',
                  child: Row(
                    children: [
                      const Icon(Icons.block, color: Colors.red),
                      const SizedBox(width: 12),
                      Text(t['block_user']!),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    const Icon(Icons.flag, color: Colors.orange),
                    const SizedBox(width: 12),
                    Text(t['report_user']!),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isBlockedByOther
          ? _buildBlockedByOtherMessage()
          : Column(
        children: [
          if (_isBlocked)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.red.shade50,
              child: Row(
                children: [
                  const Icon(Icons.block, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${t['user_blocked']!} ${widget.otherUserName}. ${t['blocked_user_message']!}',
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: _unblockUser,
                    child: Text(t['unblock_user']!),
                  ),
                ],
              ),
            ),

          // مؤشر رفع الصورة
          if (_isUploading)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.blue.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(t['sending_image']!, style: const TextStyle(color: Colors.blue)),
                ],
              ),
            ),

          // الرسائل
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ChatService.getMessages(widget.requestId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                if (messages.isEmpty) {
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
                          child: Icon(
                            Icons.chat_bubble_outline,
                            size: 50,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          t['no_messages']!,
                          style: const TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t['start_conversation']!,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    final isMe = message['senderId'] == currentUser?.uid;

                    return MessageBubble(
                      message: message,
                      isMe: isMe,
                      t: t,
                      onImageTap: _showFullImage,
                    );
                  },
                );
              },
            ),
          ),

          // حقل الإرسال
          if (!_isBlocked)
            ChatInputBar(
              messageController: _messageController,
              isUploading: _isUploading,
              t: t,
              onSendMessage: _sendMessage,
              onPickImage: _showImageSourceDialog,
            ),
        ],
      ),
    );
  }

  Widget _buildBlockedByOtherMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.block,
                size: 50,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              t['cannot_send_messages']!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t['user_unavailable']!,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showFullImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullImageViewer(imageUrl: imageUrl, t: t),
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_isBlocked || _isBlockedByOther) return;

    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    await ChatService.sendTextMessage(requestId: widget.requestId, text: text, senderId: currentUser?.uid, senderName: currentUser?.displayName ?? t['user']!);

    try {
      final requestDoc = await RequestService.getRequest(widget.requestId);

      final requestData = requestDoc.data() as Map<String, dynamic>?;
      if (requestData != null) {
        final isCollector = currentUser?.uid == requestData['collectorId'];

        await RequestService.setNewMessageFlag(requestId: widget.requestId, senderIsCollector: isCollector);
      }
    } catch (e) {
      print('Error updating message status: $e');
    }

    if (_otherUserId != null) {
      await NotificationService.sendNotificationToUser(
        receiverUserId: _otherUserId!,
        title: t['new_message_notif']!,
        body: '${currentUser?.displayName ?? t['user']!}: $text',
        chatId: widget.requestId,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}