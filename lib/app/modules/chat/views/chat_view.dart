import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final messageController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('RORAI Chat'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.clearChat();
              messageController.clear();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: Obx(
              () => controller.messages.isEmpty
                  ? const Center(
                      child: Text('Mulai percakapan...'),
                    )
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.messages.length,
                      itemBuilder: (context, index) {
                        final message = controller.messages[
                            controller.messages.length - 1 - index];
                        return _buildMessageBubble(message);
                      },
                    ),
            ),
          ),
          // Loading indicator
          Obx(
            () => controller.isLoading.value
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'RORAI sedang mengetik...',
                          style: TextStyle(
                            color: AppTheme.textLight,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // Input Field
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    maxLines: null,
                    minLines: 1,
                    enabled: !controller.isLoading.value,
                    decoration: InputDecoration(
                      hintText: 'Ketik pertanyaan...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryBlue,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryBlue,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => FloatingActionButton(
                    mini: true,
                    backgroundColor: AppTheme.primaryBlue,
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (messageController.text.isNotEmpty) {
                              controller.sendMessage(messageController.text);
                              messageController.clear();
                            }
                          },
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(Get.context!).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: message.isUser
              ? AppTheme.primaryBlue
              : AppTheme.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: message.isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Render markdown content
            MarkdownBody(
              data: message.text,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  color: message.isUser ? Colors.white : AppTheme.textDark,
                  fontSize: 14,
                  height: 1.4,
                ),
                strong: TextStyle(
                  color: message.isUser ? Colors.white : AppTheme.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                em: TextStyle(
                  color: message.isUser ? Colors.white : AppTheme.textDark,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
                h1: TextStyle(
                  color: message.isUser ? Colors.white : AppTheme.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                h2: TextStyle(
                  color: message.isUser ? Colors.white : AppTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                h3: TextStyle(
                  color: message.isUser ? Colors.white : AppTheme.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                listBullet: TextStyle(
                  color: message.isUser ? Colors.white : AppTheme.textDark,
                  fontSize: 14,
                ),
                code: TextStyle(
                  color: message.isUser
                      ? Colors.white.withOpacity(0.9)
                      : AppTheme.textDark,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: message.isUser
                    ? Colors.white.withOpacity(0.7)
                    : AppTheme.textLight,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
