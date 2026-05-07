import 'package:flutter/material.dart';
import '../../core/widgets/pixel_container.dart';
import '../../core/theme.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildTab('MONSTERS', false)),
              const SizedBox(width: 8),
              Expanded(child: _buildTab('ITEMS', true)),
              const SizedBox(width: 8),
              Expanded(child: _buildTab('GEAR', false)),
            ],
          ),
          const SizedBox(height: 16),
          PixelContainer(
            padding: 12,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('BOX 1', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                      ),
                      child: const Text('14 / 30', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(color: QuestlingsTheme.shadow, thickness: 2),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    _buildItemSlot(count: 5, isSelected: true), // Potion placeholder
                    _buildItemSlot(count: 1), // Stone
                    _buildItemSlot(count: 12), // Berries
                    _buildItemSlot(count: 3), // Scroll
                    for (int i = 0; i < 8; i++) _buildEmptySlot(),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PixelContainer(
            padding: 12,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: QuestlingsTheme.shadow,
                    border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                  ),
                  // Potion image placeholder
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('RED POTION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.5)),
                          Text('Use', style: TextStyle(color: QuestlingsTheme.brownAction, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'A medicinal brew that restores 50 HP to a single Monster. Smells faintly of bitter herbs and sweet berries.',
                        style: TextStyle(color: QuestlingsTheme.shadow.withOpacity(0.8), fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.delete_outline, color: QuestlingsTheme.warning),
                label: const Text('TRASH', style: TextStyle(color: QuestlingsTheme.warning, fontWeight: FontWeight.bold)),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.sort, color: QuestlingsTheme.blueAction),
                label: const Text('SORT', style: TextStyle(color: QuestlingsTheme.blueAction, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? QuestlingsTheme.lightGreen : QuestlingsTheme.surface,
        border: Border.all(color: QuestlingsTheme.shadow, width: 2),
        boxShadow: [
          if (!isSelected)
            const BoxShadow(color: QuestlingsTheme.shadow, offset: Offset(2, 2)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildItemSlot({required int count, bool isSelected = false}) {
    return Container(
      decoration: BoxDecoration(
        color: QuestlingsTheme.shadow,
        border: Border.all(
          color: isSelected ? QuestlingsTheme.primaryAction : QuestlingsTheme.shadow,
          width: isSelected ? 4 : 2,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              color: Colors.white,
              child: Text(
                'x$count',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySlot() {
    return Container(
      color: QuestlingsTheme.surface.withOpacity(0.5),
    );
  }
}