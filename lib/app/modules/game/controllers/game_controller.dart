import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/controllers/navigation_controller.dart';
import '../models/game_model.dart';

class GameController extends GetxController {
  late RxList<GameModel> games;
  late RxList<GameModel> filteredGames;
  RxString searchQuery = ''.obs;
  RxString selectedCategory = 'all'.obs;
  late TextEditingController searchController;

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    _initializeGames();
    ever(searchQuery, (_) => _updateFilteredGames());
    ever(selectedCategory, (_) => _updateFilteredGames());
  }

  void _initializeGames() {
    games = RxList<GameModel>([
      GameModel(
        id: '1',
        title: 'Social Interaction Training',
        description:
            'Latih kemampuan komunikasi dan interaksi sosial dengan simulasi percakapan',
        imageUrl: 'assets/boneka_warnawarni.jpg',
        type: 'social_interaction',
        category: 'cognitive',
        difficulty: 2,
      ),
      GameModel(
        id: '2',
        title: 'Collaborative Puzzle Game',
        description: 'Puzzle game yang memerlukan kolaborasi 2 pemain - Enforced Collaboration',
        imageUrl: 'assets/caleb-woods-ecRuhwPIW7c-unsplash.jpg',
        type: 'puzzle',
        category: 'motor',
        difficulty: 2,
      ),
    ]);
    filteredGames = RxList<GameModel>(games);
  }

  void _updateFilteredGames() {
    final query = searchQuery.value.toLowerCase();
    final category = selectedCategory.value;

    filteredGames.value = games.where((game) {
      final matchesSearch = game.title.toLowerCase().contains(query) ||
          game.description.toLowerCase().contains(query);
      final matchesCategory =
          category == 'all' || game.category == category;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void updateSelectedCategory(String category) {
    selectedCategory.value = category;
  }

  void playGame(String gameId) {
    // Set game session active before navigating
    Get.find<NavigationController>().setGameSessionActive(true);
    
    switch (gameId) {
      case '1':
        Get.toNamed('/social-interaction-training');
        break;
      case '2':
        Get.toNamed('/collaborative-puzzle-game');
        break;
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
