import 'package:get/get.dart';
import '../models/social_scenario_model.dart';

class SocialInteractionTrainingController extends GetxController {
  late RxList<SocialScenario> scenarios;
  late RxList<JointAttentionScenario> jointAttentionScenarios;

  final currentScenarioIndex = 0.obs;
  final selectedResponseId = Rx<String?>(null);
  final showFeedback = false.obs;
  final score = 0.obs;
  final totalCompleted = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeScenarios();
  }

  void _initializeScenarios() {
    scenarios = RxList<SocialScenario>([
      SocialScenario(
        id: '1',
        title: 'Greeting a Friend',
        description: 'Belajar menyapa teman dengan benar',
        situation:
            'Kamu bertemu teman di sekolah. Teman siap menyapa dengan tersenyum.',
        responses: [
          SocialResponse(
            id: 'r1',
            text: 'Tersenyum dan berkata "Hai! Apa kabar?"',
            isAppropriate: true,
            explanation:
                'Sempurna! Tersenyum dan bertanya kabar adalah cara yang baik untuk menyapa.',
          ),
          SocialResponse(
            id: 'r2',
            text: 'Lewat begitu saja tanpa melihat',
            isAppropriate: false,
            explanation:
                'Kurang tepat. Teman merasa diabaikan. Lebih baik membalasnya dengan ramah.',
          ),
          SocialResponse(
            id: 'r3',
            text: 'Berteriak "HEY!"',
            isAppropriate: false,
            explanation:
                'Terlalu keras. Coba dengan nada yang lebih sopan dan ramah.',
          ),
        ],
        correctResponseId: 'r1',
      ),
      SocialScenario(
        id: '2',
        title: 'Meminta Maaf',
        description: 'Cara yang tepat untuk meminta maaf kepada teman',
        situation: 'Kamu secara tidak sengaja mendorong teman saat bermain.',
        responses: [
          SocialResponse(
            id: 'r1',
            text: 'Berkata "Maaf, aku tidak sengaja. Kamu baik-baik saja?"',
            isAppropriate: true,
            explanation:
                'Sangat baik! Meminta maaf dan menunjukkan kepedulian adalah hal yang benar.',
          ),
          SocialResponse(
            id: 'r2',
            text: 'Diam saja dan terus bermain',
            isAppropriate: false,
            explanation:
                'Teman merasa tidak dihargai. Selalu minta maaf untuk kesalahan.',
          ),
          SocialResponse(
            id: 'r3',
            text: 'Berkata "Itu bukan salahku"',
            isAppropriate: false,
            explanation:
                'Tidak jujur. Lebih baik jujur mengakui kesalahan dan meminta maaf.',
          ),
        ],
        correctResponseId: 'r1',
      ),
      SocialScenario(
        id: '3',
        title: 'Berbagi dengan Teman',
        description: 'Belajar berbagi barang dengan teman',
        situation:
            'Teman meminta untuk mencoba mainan favoritmu selama sebentar.',
        responses: [
          SocialResponse(
            id: 'r1',
            text: 'Memberikan mainan dan berkata "Tentu! Pakai dulu"',
            isAppropriate: true,
            explanation:
                'Bagus! Berbagi adalah cara yang baik untuk memperkuat persahabatan.',
          ),
          SocialResponse(
            id: 'r2',
            text: 'Menolak dan berkata "Itu milikku, tidak boleh"',
            isAppropriate: false,
            explanation:
                'Terlalu posesif. Sesekali berbagi dapat memperkuat hubungan pertemanan.',
          ),
          SocialResponse(
            id: 'r3',
            text: 'Menjauh tanpa menjawab',
            isAppropriate: false,
            explanation:
                'Teman merasa ditolak. Lebih baik berkomunikasi dengan jelas.',
          ),
        ],
        correctResponseId: 'r1',
      ),
    ]);

    jointAttentionScenarios = RxList<JointAttentionScenario>([
      JointAttentionScenario(
        id: 'ja1',
        title: 'Lihat ke Atas',
        description: 'Ikuti arah pandangan untuk joint attention',
        targetObject: 'Burung di Atas Pohon',
        targetDirection: 'Arah Pandangan: ATAS ⬆️',
        instruction:
            'Temanmu menunjuk ke atas. Coba lihat ke arah yang sama. Lihat? Ada burung di atas pohon!',
      ),
      JointAttentionScenario(
        id: 'ja2',
        title: 'Lihat ke Kanan',
        description: 'Fokus pada objek di arah yang ditunjukkan',
        targetObject: 'Mobil di Jalan Raya',
        targetDirection: 'Arah Pandangan: KANAN ➡️',
        instruction:
            'Temanmu menunjuk ke kanan. Mari lihat bersama. Mobil merah lewat!',
      ),
      JointAttentionScenario(
        id: 'ja3',
        title: 'Lihat ke Bawah',
        description: 'Mengikuti arahan untuk melihat hal menarik',
        targetObject: 'Semut di Tanah',
        targetDirection: 'Arah Pandangan: BAWAH ⬇️',
        instruction:
            'Temanmu menunjuk ke bawah. Lihat itu! Ada rombongan semut yang berjalan.',
      ),
    ]);
  }

  void selectResponse(String responseId) {
    selectedResponseId.value = responseId;
    showFeedback.value = true;

    // Check if response is correct
    final scenario = scenarios[currentScenarioIndex.value];
    final response = scenario.responses.firstWhere((r) => r.id == responseId);

    if (response.isAppropriate) {
      score.value += 10;
    }
  }

  void nextScenario() {
    if (currentScenarioIndex.value < scenarios.length - 1) {
      currentScenarioIndex.value++;
      selectedResponseId.value = null;
      showFeedback.value = false;
    } else {
      // Semua skenario selesai
      totalCompleted.value++;
      _resetScenarios();
    }
  }

  void _resetScenarios() {
    currentScenarioIndex.value = 0;
    selectedResponseId.value = null;
    showFeedback.value = false;
  }

  void resetScore() {
    score.value = 0;
    currentScenarioIndex.value = 0;
    selectedResponseId.value = null;
    showFeedback.value = false;
  }

  @override
  void onClose() {
    super.onClose();
  }
}
