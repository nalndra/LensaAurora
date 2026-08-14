import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.bgLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
            color: AppTheme.textDark,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'RORAI',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: AppTheme.textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List or Empty State
          Expanded(
            child: Obx(
              () => controller.messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.messages.length,
                      itemBuilder: (context, index) {
                        final message = controller.messages[
                            controller.messages.length - 1 - index];
                        return _buildMessageBubble(message);
                      },
                    ),
            ),
          ),
          // Typing indicator or analyzing state
          Obx(
            () {
              if (controller.isAnalyzing.value) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'RORAI sedang berpikir',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textLight,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(width: 4),
                      _buildTypingIndicator(),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Input Field
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.bgLight,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryDark.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.messageController,
                      maxLines: null,
                      minLines: 1,
                      enabled: !controller.isLoading.value,
                      decoration: InputDecoration(
                        hintText: 'Ketik sesuatu...',
                        hintStyle: TextStyle(
                          color: AppTheme.textLight.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: AppTheme.fieldFill,
                        prefixIcon: const Icon(Icons.add, color: AppTheme.textLight),
                        border: OutlineInputBorder(
                          borderRadius: AppTheme.brPill,
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppTheme.brPill,
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppTheme.brPill,
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty && !controller.isLoading.value) {
                          controller.sendMessage(value);
                          controller.messageController.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Obx(
                    () => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.accentGradient,
                        boxShadow: AppTheme.shadowButton(AppTheme.accentGreen),
                      ),
                      child: IconButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                if (controller.messageController.text
                                    .trim()
                                    .isNotEmpty) {
                                  controller.sendMessage(
                                    controller.messageController.text,
                                  );
                                  controller.messageController.clear();
                                }
                              },
                        icon: Icon(
                          controller.isLoading.value
                              ? Icons.pause_rounded
                              : Icons.send_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Stack(
      children: [
        // Decorative circle background
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.lightCyan.withValues(alpha: 0.35),
            ),
          ),
        ),
        // Content
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo - brand tinted image
              Image.asset(
                'assets/logo/RoraiChatbot.png',
                width: 80,
                height: 80,
                fit: BoxFit.contain,
                color: AppTheme.accentGreenDark,
                colorBlendMode: BlendMode.srcIn,
              ),
              const SizedBox(height: AppTheme.space24),
              // Greeting
              Text(
                'Hallo, Teman Aurora...',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(height: AppTheme.space16),
              // Main prompt
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: const Text(
                  'Apa yang akan kita bahas hari ini?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    if (message.isUser) {
      // User message (right-aligned)
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(Get.context!).size.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.accentGreenDark,
            borderRadius: AppTheme.br20,
            boxShadow: AppTheme.shadowButton(AppTheme.accentGreenDark),
          ),
          child: Text(
            message.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      );
    } else {
      // AI message (left-aligned) - with streaming support
      final styleSheet = MarkdownStyleSheet(
        p: const TextStyle(
          color: AppTheme.textDark,
          fontSize: 14,
          height: 1.4,
        ),
        strong: const TextStyle(
          color: AppTheme.textDark,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        em: const TextStyle(
          color: AppTheme.textDark,
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
      );

      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(Get.context!).size.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppTheme.br20,
            boxShadow: AppTheme.shadowCard,
          ),
          child: message.isStreaming
              // Streaming message - update reactively
              ? Obx(
                  () => MarkdownBody(
                    data: message.streamingText.value,
                    selectable: true,
                    styleSheet: styleSheet,
                  ),
                )
              // Non-streaming message - static
              : MarkdownBody(
                  data: message.text,
                  selectable: true,
                  styleSheet: styleSheet,
                ),
        ),
      );
    }
  }

  // Typing indicator animation dots
  Widget _buildTypingIndicator() {
    return SizedBox(
      width: 20,
      height: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _TypingDot(delay: 0),
          _TypingDot(delay: 150),
          _TypingDot(delay: 300),
        ],
      ),
    );
  }
}

/// Animated typing indicator dot
class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Animation<double> _animation = const AlwaysStoppedAnimation<double>(0);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Delay start based on position
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -6 * _animation.value),
          child: Container(
            width: 3,
            height: 3,
            decoration: const BoxDecoration(
              color: AppTheme.textLight,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
