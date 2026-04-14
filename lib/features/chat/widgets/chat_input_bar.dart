import 'package:flutter/material.dart';
import 'package:green_way_new/theme/app_colors.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController messageController;
  final bool isUploading;
  final Map<String, String> t;
  final VoidCallback onSendMessage;
  final VoidCallback onPickImage;

  const ChatInputBar({
    super.key,
    required this.messageController,
    required this.isUploading,
    required this.t,
    required this.onSendMessage,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: isUploading ? null : onPickImage,
                icon: Icon(
                  Icons.image,
                  color: isUploading ? Colors.grey : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: t['type_message']!,
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: onSendMessage,
                icon: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
