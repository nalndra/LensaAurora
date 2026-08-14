import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/widgets/chat_fab.dart';
import 'package:lensaaurora/app/modules/game/widgets/game_catalog_card.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import '../controllers/game_controller.dart';

class GameView extends GetView<GameController> {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text(
          'Games',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Obx(
        () => SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
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
                        color: AppTheme.textDark,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: AppTheme.space12),
                    const Text(
                      'Latihan kognitif dan motorik yang dirancang untuk memperkuat jalur saraf melalui permainan interaktif.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textLight,
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
                    prefixIcon:
                        const Icon(Icons.search, color: AppTheme.textLight),
                    filled: true,
                    fillColor: AppTheme.fieldFill,
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
                ),
              ),
              const SizedBox(height: AppTheme.space20),

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
                          const Text(
                            'Game tidak ditemukan',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textLight,
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
                isActive ? AppTheme.accentGreen : AppTheme.surfaceTint,
            borderRadius: AppTheme.brPill,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppTheme.accentGreen,
              ),
            ),
          ),
        ),
      );
    });
  }
}

