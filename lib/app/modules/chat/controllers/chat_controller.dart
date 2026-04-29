import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:lensaaurora/app/services/gemini_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isStreaming; // Track if message is being streamed
  final Rx<String> streamingText; // For reactive streaming text updates

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isStreaming = false,
  }) : streamingText = text.obs;
}

class ChatController extends GetxController {
  late GeminiService geminiService;
  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final isAnalyzing = false.obs; // Show "analyzing..." indicator
  late TextEditingController messageController;

  @override
  void onInit() {
    super.onInit();
    messageController = TextEditingController();
    geminiService = GeminiService();
  }

  /// Check if question is basic/instant (no API needed)
  String? _getInstantResponse(String input) {
    final lower = input.toLowerCase().trim();
    
    // Basic greetings
    if (lower == 'halo' || lower == 'hai' || lower == 'hello') {
      return 'Hai! 👋 Aku RORAI, teman chatmu yang siap membantu dengan topik Autism. Ada yang ingin kita bahas hari ini?';
    }
    if (lower == 'apa kabar' || lower == 'gimana kabar' || lower == 'kabar') {
      return 'Baik-baik saja, terima kasih sudah bertanya! 😊 Gimana denganmu? Ada yang bisa aku bantu?';
    }
    
    // Math (for testing streaming)
    final mathPattern = RegExp(r'^(\d+)\s*\+\s*(\d+)$');
    final mathMatch = mathPattern.firstMatch(lower);
    if (mathMatch != null) {
      final a = int.parse(mathMatch.group(1)!);
      final b = int.parse(mathMatch.group(2)!);
      return '$a + $b = ${a + b}';
    }
    
    return null;
  }

  void sendMessage(String userInput) async {
    if (userInput.trim().isEmpty) return;

    if (kDebugMode) print('📤 User message: $userInput');

    // Add user message
    messages.add(
      ChatMessage(
        text: userInput,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );

    isLoading.value = true;
    isAnalyzing.value = true;

    // Check if message is related to ASD
    if (!_isASDRelated(userInput)) {
      if (kDebugMode) print('⚠️ Off-topic: Redirecting user');
      isLoading.value = false;
      isAnalyzing.value = false;
      
      messages.add(
        ChatMessage(
          text:
              'Saya khusus membantu dengan topik seputar Autism (ASD). 🧠\n\nApakah ada pertanyaan tentang:\n- Komunikasi sosial\n- Sensitivitas sensor\n- Manajemen emosi\n- Rutinitas harian\n- Memahami perilaku ASD\n\nAku di sini untuk mendampingi perjalanan autisme-mu!',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      return;
    }

    try {
      // Check for instant response (greetings, basic math, etc)
      final instantResponse = _getInstantResponse(userInput);
      
      if (instantResponse != null) {
        if (kDebugMode) print('✨ Instant response: $instantResponse');
        isAnalyzing.value = false;
        
        // Stream the instant response word-by-word
        await _streamMessage(instantResponse);
        isLoading.value = false;
        return;
      }

      if (kDebugMode) print('📡 Analyzing dengan Gemini API...');
      
      // Wait a bit to show "analyzing..." state
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Create streaming message
      final streamingMessage = ChatMessage(
        text: '',
        isUser: false,
        timestamp: DateTime.now(),
        isStreaming: true,
      );
      messages.add(streamingMessage);
      
      // Get AI response stream
      isAnalyzing.value = false;
      
      geminiService.sendMessageStream(userInput).listen(
        (chunk) {
          streamingMessage.streamingText.value += chunk;
          if (kDebugMode) print('📥 Chunk: $chunk');
        },
        onError: (error) {
          if (kDebugMode) print('❌ Streaming error: $error');
          streamingMessage.streamingText.value = 'Maaf, ada kesalahan: $error';
          isLoading.value = false;
        },
        onDone: () {
          if (kDebugMode) print('✅ Stream complete');
          isLoading.value = false;
        },
      );
    } catch (e) {
      if (kDebugMode) print('❌ Error dalam chat_controller: $e');
      isLoading.value = false;
      isAnalyzing.value = false;
      messages.add(
        ChatMessage(
          text: 'Maaf, ada kesalahan saat memproses: ${e.toString()}',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  /// Stream message word-by-word for instant responses
  Future<void> _streamMessage(String text) async {
    final words = text.split(' ');
    final streamingMessage = ChatMessage(
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
      isStreaming: true,
    );
    
    messages.add(streamingMessage);
    
    for (int i = 0; i < words.length; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      streamingMessage.streamingText.value += words[i];
      if (i < words.length - 1) {
        streamingMessage.streamingText.value += ' ';
      }
    }
  }

  // Check if user input is related to ASD topics
  bool _isASDRelated(String input) {
    final lowerInput = input.toLowerCase();
    
    // ASD-related keywords (positive indicators)
    final asdKeywords = [
      'asd', 'autism', 'autis',
      'sosial', 'social', 'interaksi', 'interaction',
      'emosi', 'emotion', 'perasaan', 'feeling',
      'sensor', 'sensori', 'sensory', 'suara', 'cahaya',
      'rutin', 'routine', 'jadwal', 'schedule',
      'komunikasi', 'communication', 'berbicara', 'speak', 'berbahasa', 'language',
      'perilaku', 'behavior', 'kebiasaan', 'habit',
      'keterlambatan', 'delay', 'perkembangan', 'development',
      'sosialisasi', 'socialization', 'persahabatan', 'friendship',
      'bullying', 'perundungan', 'teasing', 'mengejek',
      'kecemasan', 'anxiety', 'kekhawatiran', 'worry',
      'fokus', 'focus', 'konsentrasi', 'concentration',
      'istimewa', 'special', 'berbakat', 'gift', 'hyperfocus',
    ];
    
    // Non-ASD keywords (negative indicators) - common off-topic queries
    final nonAsdKeywords = [
      'resep', 'recipe', 'masak', 'cook', 'makanan', 'food', 'makan', 'eat', 'kue', 'cake',
      'cuaca', 'weather', 'hujan', 'rain', 'panas', 'hot', 'dingin', 'cold',
      'olahraga', 'sports', 'sepak', 'football', 'bola', 'ball', 'permainan', 'game',
      'berita', 'news', 'politics', 'politik', 'presiden', 'president',
      'matematika', 'math', 'hitung', 'count', 'kimia', 'chemistry', 'fisika', 'physics',
      'lirik', 'lyrics', 'lagu', 'song', 'musik', 'music',
      'programming', 'coding', 'javascript', 'python', 'kode', 'code',
      'mobil', 'car', 'motor', 'motorcycle', 'kendaraan', 'vehicle',
      'film', 'movie', 'video', 'serial', 'series', 'tonton', 'watch',
      'gaji', 'salary', 'uang', 'money', 'harga', 'price', 'biaya', 'cost',
    ];
    
    // Check for strong ASD-related keywords
    for (var keyword in asdKeywords) {
      if (lowerInput.contains(keyword)) {
        return true;
      }
    }
    
    // If contains non-ASD keywords, it's likely off-topic
    for (var keyword in nonAsdKeywords) {
      if (lowerInput.contains(keyword)) {
        return false;
      }
    }
    
    // Default: allow if no strong indicators either way
    return true;
  }

  void clearChat() {
    messages.clear();
    messages.add(
      ChatMessage(
        text:
            'Halo! 👋 Aku RORAI, asistanmu yang ramah. Ada yang bisa aku bantu hari ini?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}
