import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lensaaurora/app/theme/app_theme.dart';
import 'package:lensaaurora/app/widgets/bottom_nav_bar.dart';
import 'package:lensaaurora/app/widgets/chat_fab.dart';
import 'package:lensaaurora/app/modules/game/widgets/game_card.dart';
import '../controllers/game_controller.dart';

class GameView extends GetView<GameController> {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Games & Training'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        automaticallyImplyLeading: false,
      ),
      body: Obx(
        () => Container(
          color: AppTheme.bgLight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 340 / 420,
              ),
              itemCount: controller.games.length,
              itemBuilder: (context, index) {
                final game = controller.games[index];
                return GameCard(
                  game: game,
                  onPlayPressed: () => controller.playGame(game.id),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: ChatFAB(),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}

