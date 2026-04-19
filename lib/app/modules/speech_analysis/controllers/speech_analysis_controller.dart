import 'package:get/get.dart';
import 'package:flutter/material.dart';

enum SpeechTestState { idle, reading, completed }

class SpeechAnalysisController extends GetxController {
  final testState = SpeechTestState.idle.obs;
  
  final currentParagraphIndex = 0.obs;
  final nervousnessScore = 0.obs; // 0-100
  final stutteringScore = 0.obs; // 0-100
  final readingSpeedScore = 0.obs; // 0-100
  
  final isRecording = false.obs;
  final recordingExists = false.obs;

  final paragraphs = [
    'Kucing adalah hewan peliharaan yang sangat populer di seluruh dunia. Mereka dikenal karena kelincahannya, rasa ingin tahu yang tinggi, dan kemampuan berburu yang luar biasa. Kucing domestik biasanya tidur hingga 16 jam sehari dan sangat suka bermain.',
    'Pohon adalah komponen penting dari ekosistem kami. Mereka menyediakan oksigen, menyimpan karbon, menstabilkan tanah, dan memberikan kehidupan untuk satwa liar. Selain itu, pohon juga memberikan manfaat langsung kepada manusia seperti buah, kayu, dan tempat berteduh.',
    'Inovasi teknologi telah mengubah cara kita berkomunikasi dan bekerja. Internet memungkinkan orang dari berbagai belahan dunia untuk terhubung secara instan. Kecerdasan buatan semakin banyak digunakan untuk meningkatkan efisiensi dalam berbagai industri.',
  ];

  void startSpeechTest() {
    testState.value = SpeechTestState.reading;
    // Di sini bisa ditambahkan logic untuk recording audio
  }

  void completeSpeechTest() {
    // Calculate scores dari audio yang direcord
    nervousnessScore.value = 35; // Placeholder
    stutteringScore.value = 15; // Placeholder
    readingSpeedScore.value = 72; // Placeholder
    
    testState.value = SpeechTestState.completed;
  }

  void skipToNextParagraph() {
    if (currentParagraphIndex.value < paragraphs.length - 1) {
      currentParagraphIndex.value++;
      // Reset recording state for next paragraph
      isRecording.value = false;
      recordingExists.value = false;
    } else {
      completeSpeechTest();
    }
  }

  void completeTest() {
    completeSpeechTest();
  }

  void toggleRecording() {
    if (isRecording.value) {
      // Stop recording
      isRecording.value = false;
      recordingExists.value = true;
      // TODO: Save audio recording
      Get.snackbar(
        'Audio Tersimpan',
        'Suara telah direkam dan disimpan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      // Start recording
      isRecording.value = true;
      // TODO: Start audio recording
    }
  }

  void restartRecording() {
    isRecording.value = false;
    recordingExists.value = false;
    // TODO: Delete previous recording
  }
}
