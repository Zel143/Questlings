import 'package:flutter/material.dart';
import '../../core/theme.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: QuestlingsTheme.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 14, color: QuestlingsTheme.secondary),
                SizedBox(width: 4),
                Text(
                  '24 / 40',
                  style: TextStyle(
                    color: QuestlingsTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Equipment Slots ───────────────────────────────────────────
            const _SectionHeader(title: 'Equipment'),
            const SizedBox(height: 12),
            _EquipmentSlot(
              icon: Icons.shield_outlined,
              label: 'Head',
              item: 'Knight\'s Helm',
              rarity: Rarity.rare,
            ),
            const SizedBox(height: 8),
            _EquipmentSlot(
              icon: Icons.checkroom,
              label: 'Chest',
              item: 'Leather Armor',
              rarity: Rarity.uncommon,
            ),
            const SizedBox(height: 8),
            _EquipmentSlot(
              icon: Icons.gavel,
              label: 'Weapon',
              item: 'Iron Sword +2',
              rarity: Rarity.rare,
            ),
            const SizedBox(height: 8),
            _EquipmentSlot(
              icon: Icons.directions_walk,
              label: 'Boots',
              item: 'Swift Boots',
              rarity: Rarity.epic,
              showGlow: true,
            ),
            const SizedBox(height: 24),

            // ── Inventory Grid ────────────────────────────────────────────
            const _SectionHeader(title: 'Items'),
            const SizedBox(height: 12),
            _ItemFilterBar(),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                return _InventoryItem(
                  name: _itemNames[index],
                  rarity: _rarities[index],
                  icon: _itemIcons[index],
                  quantity: index < 3 ? 1 : (index * 2),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

const _itemNames = [
  'Health Potion', 'Mana Crystal', 'Scroll of Wisdom',
  'Iron Ore', 'Silver Ore', 'Gold Dust',
  'Dragon Scale', 'Phoenix Feather', 'Ancient Rune',
  'Wood Plank', 'Silk Cloth', 'Mystic Gem',
];

const _rarities = [
  Rarity.common, Rarity.uncommon, Rarity.rare,
  Rarity.common, Rarity.common, Rarity.rare,
  Rarity.epic, Rarity.legendary, Rarity.epic,
  Rarity.common, Rarity.uncommon, Rarity.rare,
];

const _itemIcons = [
  Icons.local_drink, Icons.diamond, Icons.auto_stories,
  Icons.handyman, Icons.handyman, Icons.blur_on,
  Icons.energy_savings_leaf, Icons.air, Icons.bolt,
  Icons.build, Icons.water_drop, Icons.star,
];

// ── Section Header ─────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            gradient: QuestlingsTheme.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }
}

// ── Equipment Slot ─────────────────────────────────────────────────────
class _EquipmentSlot extends StatelessWidget {
  final IconData icon;
  final String label;
  final String item;
  final Rarity rarity;
  final bool showGlow;

  const _EquipmentSlot({
    required this.icon,
    required this.label,
    required this.item,
    required this.rarity,
    this.showGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = rarityColor(rarity);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: QuestlingsTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 0),
                ),
                ...QuestlingsTheme.cardShadow,
              ]
            : QuestlingsTheme.cardShadow,
        border: Border.all(
          color: color.withValues(alpha: showGlow ? 0.5 : 0.15),
        ),
      ),
      child: Row(
        children: [
          // Slot Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: QuestlingsTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Rarity badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              rarityLabel(rarity),
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Item Filter Bar ────────────────────────────────────────────────────
class _ItemFilterBar extends StatelessWidget {
  final Set<String> _filters = {
    'All', 'Consumable', 'Material', 'Equipment', 'Special'
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isSelected = filter == 'All';
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? QuestlingsTheme.primaryGradient
                    : null,
                color: isSelected ? null : QuestlingsTheme.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : QuestlingsTheme.surfaceOverlay,
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : QuestlingsTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Inventory Item Grid Tile ───────────────────────────────────────────
class _InventoryItem extends StatelessWidget {
  final String name;
  final Rarity rarity;
  final IconData icon;
  final int quantity;

  const _InventoryItem({
    required this.name,
    required this.rarity,
    required this.icon,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    final color = rarityColor(rarity);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: QuestlingsTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: QuestlingsTheme.cardShadow,
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          // Name
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          // Quantity
          Text(
            'x$quantity',
            style: const TextStyle(
              color: QuestlingsTheme.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}