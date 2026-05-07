import 'package:flutter/material.dart';
<<<<<<< Updated upstream
=======
import '../../core/widgets/pixel_container.dart';
>>>>>>> Stashed changes
import '../../core/theme.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          // Currency display
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: QuestlingsTheme.goldGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.monetization_on, size: 16, color: Colors.black),
                SizedBox(width: 4),
                Text(
                  '2,450',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
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
            // ── Shop Categories ────────────────────────────────────────────
            _CategoryBar(),
            const SizedBox(height: 20),

            // ── Featured Item ──────────────────────────────────────────────
            const _SectionHeader(title: 'Featured'),
            const SizedBox(height: 12),
            _FeaturedItem(),
            const SizedBox(height: 24),

            // ── Items Grid ────────────────────────────────────────────────
            const _SectionHeader(title: 'All Items'),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: _shopItems.length,
              itemBuilder: (context, index) {
                return _ShopItemCard(item: _shopItems[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shop Item Model ────────────────────────────────────────────────────
class _ShopItem {
  final String name;
  final String description;
  final IconData icon;
  final Rarity rarity;
  final int price;
  final String category;
  final bool isNew;
  final bool isLimited;

  const _ShopItem({
    required this.name,
    required this.description,
    required this.icon,
    required this.rarity,
    required this.price,
    required this.category,
    this.isNew = false,
    this.isLimited = false,
  });
}

const _shopItems = [
  _ShopItem(
    name: 'Health Potion',
    description: 'Restore 50 HP instantly',
    icon: Icons.local_drink,
    rarity: Rarity.common,
    price: 50,
    category: 'Consumables',
  ),
  _ShopItem(
    name: 'XP Booster',
    description: '2x XP for 1 hour',
    icon: Icons.bolt,
    rarity: Rarity.rare,
    price: 200,
    category: 'Boosts',
    isNew: true,
  ),
  _ShopItem(
    name: 'Mana Crystal',
    description: 'Restore 30 Mana',
    icon: Icons.diamond,
    rarity: Rarity.uncommon,
    price: 80,
    category: 'Consumables',
  ),
  _ShopItem(
    name: 'Iron Sword',
    description: 'A sturdy blade +5 ATK',
    icon: Icons.gavel,
    rarity: Rarity.rare,
    price: 500,
    category: 'Weapons',
  ),
  _ShopItem(
    name: 'Lucky Charm',
    description: '+10% loot chance',
    icon: Icons.auto_awesome,
    rarity: Rarity.epic,
    price: 1000,
    category: 'Accessories',
    isLimited: true,
  ),
  _ShopItem(
    name: 'Scroll of Wisdom',
    description: '+50 XP instantly',
    icon: Icons.auto_stories,
    rarity: Rarity.rare,
    price: 150,
    category: 'Consumables',
  ),
  _ShopItem(
    name: 'Phoenix Feather',
    description: 'Revive on defeat',
    icon: Icons.air,
    rarity: Rarity.legendary,
    price: 2500,
    category: 'Special',
    isNew: true,
    isLimited: true,
  ),
  _ShopItem(
    name: 'Swift Boots',
    description: '+15% movement speed',
    icon: Icons.directions_walk,
    rarity: Rarity.epic,
    price: 800,
    category: 'Armor',
  ),
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

// ── Category Bar ───────────────────────────────────────────────────────
class _CategoryBar extends StatelessWidget {
  final List<_Category> _categories = const [
    _Category(icon: Icons.grid_view, label: 'All'),
    _Category(icon: Icons.local_drink, label: 'Consumables'),
    _Category(icon: Icons.bolt, label: 'Boosts'),
    _Category(icon: Icons.gavel, label: 'Weapons'),
    _Category(icon: Icons.checkroom, label: 'Armor'),
    _Category(icon: Icons.watch, label: 'Accessories'),
    _Category(icon: Icons.star, label: 'Special'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((cat) {
          final isSelected = cat.label == 'All';
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected ? QuestlingsTheme.primaryGradient : null,
                color: isSelected ? null : QuestlingsTheme.surfaceCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : QuestlingsTheme.surfaceOverlay,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat.icon,
                    size: 16,
                    color: isSelected ? Colors.white : QuestlingsTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : QuestlingsTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Category {
  final IconData icon;
  final String label;

  const _Category({required this.icon, required this.label});
}

// ── Featured Item ──────────────────────────────────────────────────────
class _FeaturedItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            QuestlingsTheme.surfaceOverlay,
            QuestlingsTheme.surfaceCard,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          ...QuestlingsTheme.cardShadow,
          BoxShadow(
            color: QuestlingsTheme.rarityLegendary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 0),
          ),
        ],
        border: Border.all(
          color: QuestlingsTheme.rarityLegendary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Item Icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  QuestlingsTheme.rarityLegendary,
                  QuestlingsTheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: QuestlingsTheme.rarityLegendary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Mystery Box',
                      style: TextStyle(
                        color: QuestlingsTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: QuestlingsTheme.rarityLegendary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'LIMITED',
                        style: TextStyle(
                          color: QuestlingsTheme.rarityLegendary,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Contains random rare to legendary items!',
                  style: TextStyle(
                    color: QuestlingsTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: QuestlingsTheme.goldGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.monetization_on, size: 14, color: Colors.black),
                          SizedBox(width: 4),
                          Text(
                            '500',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: QuestlingsTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: QuestlingsTheme.primaryLight.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Buy Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shop Item Card ─────────────────────────────────────────────────────
class _ShopItemCard extends StatelessWidget {
  final _ShopItem item;

  const _ShopItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = rarityColor(item.rarity);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: QuestlingsTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: QuestlingsTheme.cardShadow,
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with badges
          Row(
            children: [
              if (item.isNew)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: QuestlingsTheme.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: QuestlingsTheme.success,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (item.isLimited) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: QuestlingsTheme.rarityLegendary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'LIMITED',
                    style: TextStyle(
                      color: QuestlingsTheme.rarityLegendary,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const Spacer(),
          // Icon
          Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: color, size: 24),
            ),
          ),
          const SizedBox(height: 8),
          // Name
          Text(
            item.name,
            style: const TextStyle(
              color: QuestlingsTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          // Description
          Text(
            item.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: QuestlingsTheme.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          // Rarity badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              rarityLabel(item.rarity).toUpperCase(),
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Price and Buy
          Row(
            children: [
              const Icon(Icons.monetization_on, size: 14, color: QuestlingsTheme.secondary),
              const SizedBox(width: 4),
              Text(
                '${item.price}',
                style: const TextStyle(
                  color: QuestlingsTheme.secondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: QuestlingsTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}