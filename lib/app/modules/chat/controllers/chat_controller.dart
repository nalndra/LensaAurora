import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:lensaaurora/app/services/gemini_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatController extends GetxController {
  late GeminiService geminiService;
  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    geminiService = GeminiService();
    // Add welcome message
    messages.add(
      ChatMessage(
        text:
            'Halo! 👋 Aku RORAI, asistanmu yang ramah. Ada yang bisa aku bantu hari ini?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
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

    // Check if message is related to ASD
    if (!_isASDRelated(userInput)) {
      if (kDebugMode) print('⚠️ Off-topic: Redirecting user');
      // Show topical boundary message
      messages.add(
        ChatMessage(
          text:
              'Saya khusus membantu dengan topik seputar Autism (ASD). 🧠\n\nApakah ada pertanyaan tentang:\n- Komunikasi sosial\n- Sensitivitas sensor\n- Manajemen emosi\n- Rutinitas harian\n- Memahami perilaku ASD\n\nAku di sini untuk mendampingi perjalanan autisme-mu!',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      isLoading.value = false;
      return;
    }

    try {
      if (kDebugMode) print('📡 Mengirim ke Gemini API...');
      // Get AI response
      final response = await geminiService.sendMessage(userInput);
      if (kDebugMode) print('📥 Response: ${response.substring(0, 50)}...');
      
      messages.add(
        ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      if (kDebugMode) print('❌ Error dalam chat_controller: $e');
      messages.add(
        ChatMessage(
          text: 'Maaf, ada kesalahan saat memproses: ${e.toString()}',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    }

    isLoading.value = false;
  }

  // Check if user input is related to ASD topics
  bool _isASDRelated(String input) {
    final lowerInput = input.toLowerCase();
    
    // ASD-related keywords (positive indicators)
    final asdKeywords = [
      'asd', 'autism', 'autis',
      'sosial', 'social', 'interaksi', 'interaction',
      'emosi', 'emotion', 'perasaan', 'feeling',
      'sensor', 'sensori', 'sensory', 'suara', 'cahaya', 'cahaya',
      'rutin', 'routine', 'jadwal', 'schedule',
      'komunikasi', 'communication', 'berbicara', 'speak', 'berbahasa', 'language',
      'perilaku', 'behavior', 'kebiasaan', 'habit',
      'keterlambatan', 'delay', 'perkembangan', 'development',
      'interaksi', 'interaction', 'sosialisasi', 'socialization', 'persahabatan', 'friendship',
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
    // (could be genuine ASD question in different words)
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
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
