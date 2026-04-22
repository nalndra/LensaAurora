import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import 'package:lensaaurora/app/widgets/bottom_nav_bar.dart';
import 'package:lensaaurora/app/widgets/chat_fab.dart';
import 'package:lensaaurora/app/modules/game/widgets/game_catalog_card.dart';
import '../controllers/game_controller.dart';

class GameView extends GetView<GameController> {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Games',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Obx(
        () => SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aurora-Games\nCatalog',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Latihan kognitif dan motorik yang dirancang untuk memperkuat jalur saraf melalui permainan interaktif.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: controller.searchController,
                  onChanged: (value) => controller.updateSearchQuery(value),
                  decoration: InputDecoration(
                    hintText: 'Cari game...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Category Filter (Horizontal Scroll)
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildCategoryChip('All Exercises', 'all'),
                    const SizedBox(width: 8),
                    _buildCategoryChip('Cognitive', 'cognitive'),
                    const SizedBox(width: 8),
                    _buildCategoryChip('Motor', 'motor'),
                    const SizedBox(width: 8),
                    _buildCategoryChip('Speech', 'speech'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Game List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: controller.filteredGames.isEmpty
                    ? Column(
                        children: [
                          const SizedBox(height: 40),
                          Text(
                            'Game tidak ditemukan',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: List.generate(
                          controller.filteredGames.length,
                          (index) {
                            final game = controller.filteredGames[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: GameCatalogCard(
                                title: game.title,
                                description: game.description,
                                imageUrl: game.imageUrl,
                                onPlayPressed: () =>
                                    controller.playGame(game.id),
                              ),
                            );
                          },
                        ),
                      ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      floatingActionButton: const ChatFAB(),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildCategoryChip(String label, String categoryValue) {
    return Obx(() {
      final isActive = controller.selectedCategory.value == categoryValue;
      return GestureDetector(
        onTap: () => controller.updateSelectedCategory(categoryValue),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color:
                isActive ? const Color(0xFF6338F1) : const Color(0xFFEBE9FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF6338F1),
              ),
            ),
          ),
        ),
      );
    });
  }
}

