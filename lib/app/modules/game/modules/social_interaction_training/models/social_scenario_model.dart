class SocialScenario {
  final String id;
  final String title;
  final String description;
  final String situation; // Deskripsi situasi
  final List<SocialResponse> responses;
  final String? correctResponseId;

  SocialScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.situation,
    required this.responses,
    this.correctResponseId,
  });
}

class SocialResponse {
  final String id;
  final String text;
  final bool isAppropriate;
  final String explanation;

  SocialResponse({
    required this.id,
    required this.text,
    required this.isAppropriate,
    required this.explanation,
  });
}

class JointAttentionScenario {
  final String id;
  final String title;
  final String description;
  final String targetObject; // Objek yang perlu diperhatian
  final String targetDirection; // Arah (kiri/kanan/atas/bawah)
  final String instruction;

  JointAttentionScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.targetObject,
    required this.targetDirection,
    required this.instruction,
  });
}
