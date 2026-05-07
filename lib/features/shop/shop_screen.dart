import 'package:flutter/material.dart';
import '../../core/widgets/pixel_container.dart';
import '../../core/theme.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BAZAAR', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
                  Text('SPEND YOUR STARDUST', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star_border, color: QuestlingsTheme.brownAction, size: 20),
                    SizedBox(width: 8),
                    Text('1,450', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTab('ACCESSORIES', true)),
              const SizedBox(width: 8),
              Expanded(child: _buildTab('GEAR', false)),
              const SizedBox(width: 8),
              Expanded(child: _buildTab('EVOLUTION', false)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildShopItem(
                  title: 'FLAME COLLAR',
                  desc: 'Boosts fire-type stats during battle.',
                  price: '300',
                  buttonColor: QuestlingsTheme.brownAction,
                  imageColor: const Color(0xFFF2E3B6),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildShopItem(
                  title: 'AQUA STONE',
                  desc: 'Triggers evolution for aquatic...',
                  price: '850',
                  buttonColor: QuestlingsTheme.blueAction,
                  imageColor: const Color(0xFF0D131B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildShopItem(
                  title: 'ADVENTURER BAG',
                  desc: 'Expands inventory by 10 slots.',
                  price: '1200',
                  buttonColor: QuestlingsTheme.brownAction,
                  imageColor: const Color(0xFF26323E),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Stack(
                  children: [
                    _buildShopItem(
                      title: 'MYSTERY EGG',
                      desc: 'Who knows what will hatch?',
                      price: '???',
                      buttonColor: QuestlingsTheme.surface,
                      imageColor: QuestlingsTheme.surface,
                    ),
                    Positioned.fill(
                      child: Container(
                        color: Colors.white.withOpacity(0.7),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            color: Colors.grey,
                            child: const Text('SOLD OUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Wandering Trader
          PixelContainer(
            padding: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D2621),
                    border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                  ),
                  child: const Center(child: Icon(Icons.face, color: Colors.white, size: 48)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: QuestlingsTheme.shadow, width: 1),
                        ),
                        child: const Text('WANDERING TRADER', style: TextStyle(color: QuestlingsTheme.primaryAction, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.0)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '"Welcome to my humble Bazaar! Got any Stardust jingling in those pockets? I\'ve got rare evolution items in stock today. Don\'t be shy!"',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? QuestlingsTheme.lightGreen : Colors.white,
        border: Border.all(color: QuestlingsTheme.shadow, width: 2),
        boxShadow: [
          if (!isSelected)
            const BoxShadow(color: QuestlingsTheme.shadow, offset: Offset(2, 2)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }

  Widget _buildShopItem({
    required String title,
    required String desc,
    required String price,
    required Color buttonColor,
    required Color imageColor,
  }) {
    return PixelContainer(
      padding: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: imageColor,
              border: Border.all(color: QuestlingsTheme.shadow, width: 2),
            ),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          const Divider(color: QuestlingsTheme.shadow, thickness: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_border, color: QuestlingsTheme.brownAction, size: 16),
                  const SizedBox(width: 4),
                  Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: buttonColor,
                  border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                ),
                child: const Text('BUY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}