import 'package:flutter/material.dart';
import '../../core/widgets/pixel_container.dart';
import '../../core/theme.dart';
import '../../core/global_state.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _selectedTab = 'ACCESSORIES';

  final Map<String, List<Map<String, dynamic>>> _shopItems = {
    'ACCESSORIES': [
      {
        'title': 'CHAMPION MEDAL',
        'desc': 'A medal given only to the best of the best.',
        'price': '500',
        'buttonColor': QuestlingsTheme.brownAction,
        'imageColor': Colors.transparent,
        'imagePath': 'assets/items/championsmedal.png',
        'type': 'ACCESSORY',
        'soldOut': false,
      },
      {
        'title': 'WATCH TECH',
        'desc': 'High-tech device to keep track of time and stats.',
        'price': '800',
        'buttonColor': QuestlingsTheme.brownAction,
        'imageColor': Colors.transparent,
        'imagePath': 'assets/items/watchtech.png',
        'type': 'ACCESSORY',
        'soldOut': false,
      },
    ],
    'GEAR': [
      {
        'title': 'MASTER PALLET',
        'desc': 'A pallet filled with magical colors.',
        'price': '1000',
        'buttonColor': QuestlingsTheme.brownAction,
        'imageColor': Colors.transparent,
        'imagePath': 'assets/items/masterpallete.png',
        'type': 'GEAR',
        'soldOut': false,
      },
      {
        'title': 'SCHOLAR BAG',
        'desc': 'A sturdy bag for carrying all your knowledge.',
        'price': '1200',
        'buttonColor': QuestlingsTheme.brownAction,
        'imageColor': Colors.transparent,
        'imagePath': 'assets/items/scholarbag.png',
        'type': 'GEAR',
        'soldOut': false,
      },
    ],
    'EVOLUTION': [
      {
        'title': 'MYSTERY EGG',
        'desc': 'Who knows what will hatch?',
        'price': '???',
        'buttonColor': QuestlingsTheme.surface,
        'imageColor': Colors.transparent,
        'imagePath': 'assets/items/mystery.png',
        'type': 'EVOLUTION',
        'soldOut': true,
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GlobalState(),
      builder: (context, _) {
        final state = GlobalState();
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
                    child: Row(
                      children: [
                        const Icon(Icons.star_border, color: QuestlingsTheme.brownAction, size: 20),
                        const SizedBox(width: 8),
                        Text('${state.stardust}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTab('ACCESSORIES', _selectedTab == 'ACCESSORIES', () => setState(() => _selectedTab = 'ACCESSORIES'))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTab('GEAR', _selectedTab == 'GEAR', () => setState(() => _selectedTab = 'GEAR'))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTab('EVOLUTION', _selectedTab == 'EVOLUTION', () => setState(() => _selectedTab = 'EVOLUTION'))),
                ],
              ),
              const SizedBox(height: 16),
              _buildItemsGrid(context),
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
    );
  }

  Widget _buildItemsGrid(BuildContext context) {
    final items = _shopItems[_selectedTab] ?? [];
    List<Widget> rows = [];
    for (int i = 0; i < items.length; i += 2) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildItemWidget(context, items[i]),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: i + 1 < items.length ? _buildItemWidget(context, items[i + 1]) : const SizedBox(),
              ),
            ],
          ),
        ),
      );
    }
    if (rows.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text('No items in this category yet.', style: TextStyle(color: QuestlingsTheme.shadow, fontWeight: FontWeight.bold)),
      ));
    }
    return Column(children: rows);
  }

  Widget _buildItemWidget(BuildContext context, Map<String, dynamic> item) {
    final bool isSoldOut = item['soldOut'] == true;
    Widget shopItem = _buildShopItem(
      context: context,
      title: item['title'],
      desc: item['desc'],
      price: item['price'],
      buttonColor: item['buttonColor'],
      imageColor: item['imageColor'],
      imagePath: item['imagePath'],
      type: item['type'],
    );

    if (isSoldOut) {
      return Stack(
        children: [
          shopItem,
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
      );
    }
    return shopItem;
  }

  Widget _buildTab(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }

  Widget _buildShopItem({
    required BuildContext context,
    required String title,
    required String desc,
    required String price,
    required Color buttonColor,
    required Color imageColor,
    String? imagePath,
    required String type,
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
            child: imagePath != null
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(imagePath, fit: BoxFit.contain),
                  )
                : null,
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
              GestureDetector(
                onTap: () {
                  if (price == '???') {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This item is sold out!')));
                    return;
                  }
                  int cost = int.tryParse(price) ?? 0;
                  bool success = GlobalState().buyItem(title, cost, desc, imageColor, type, imagePath);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully bought $title!')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not enough Stardust!')));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: buttonColor,
                    border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                  ),
                  child: const Text('BUY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}