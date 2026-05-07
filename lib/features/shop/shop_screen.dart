import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/widgets/pixel_container.dart';
import '../../core/theme.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _selectedTab = 'ACCESSORIES';
  int _stardust = 0;
  bool _isLoadingStardust = true;
  bool _isLoadingItems = true;
  String? _error;

  // Items grouped by category (type)
  Map<String, List<Map<String, dynamic>>> _itemsByCategory = {
    'ACCESSORIES': [],
    'GEAR': [],
    'EVOLUTION': [],
  };

  @override
  void initState() {
    super.initState();
    _fetchStardust();
    _fetchItems();
  }

  Future<void> _fetchStardust() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _error = 'Not logged in';
        _isLoadingStardust = false;
      });
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('stardust')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          _stardust = response['stardust'] ?? 0;
          _isLoadingStardust = false;
        });
      } else {
        setState(() {
          _error = 'Could not load stardust.';
          _isLoadingStardust = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load stardust: $e';
        _isLoadingStardust = false;
      });
    }
  }

  Future<void> _fetchItems() async {
    try {
      final response = await Supabase.instance.client
          .from('items')
          .select('*')
          .order('title');

      final items = List<Map<String, dynamic>>.from(response);

      // Group items by type
      final Map<String, List<Map<String, dynamic>>> grouped = {
        'ACCESSORIES': [],
        'GEAR': [],
        'EVOLUTION': [],
      };

      for (var item in items) {
        final type = item['type'] as String;
        if (grouped.containsKey(type)) {
          grouped[type]!.add(item);
        }
      }

      if (mounted) {
        setState(() {
          _itemsByCategory = grouped;
          _isLoadingItems = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load items: $e';
        _isLoadingItems = false;
      });
    }
  }

  Future<void> _buyItem(Map<String, dynamic> item) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final isSoldOut = item['sold_out'] == true;
    final cost = item['price'] as int? ?? 0;

    if (isSoldOut || cost == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This item is sold out!')),
      );
      return;
    }

    if (_stardust < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough Stardust!')),
      );
      return;
    }

    setState(() => _isLoadingStardust = true);

    try {
      final newStardust = _stardust - cost;

      // 1. Deduct stardust
      await Supabase.instance.client
          .from('users')
          .update({'stardust': newStardust})
          .eq('id', user.id);

      // 2. Insert or update user_items
      final itemId = item['id'] as String;
      final existing = await Supabase.instance.client
          .from('user_items')
          .select('quantity')
          .eq('user_id', user.id)
          .eq('item_id', itemId)
          .maybeSingle();

      if (existing != null) {
        final newQuantity = (existing['quantity'] as int) + 1;
        await Supabase.instance.client
            .from('user_items')
            .update({'quantity': newQuantity})
            .eq('user_id', user.id)
            .eq('item_id', itemId);
      } else {
        await Supabase.instance.client.from('user_items').insert({
          'user_id': user.id,
          'item_id': itemId,
          'quantity': 1,
          'is_equipped': false,
        });
      }

      setState(() {
        _stardust = newStardust;
        _isLoadingStardust = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully bought ${item['title']}!')),
      );
    } catch (e) {
      setState(() => _isLoadingStardust = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingStardust || _isLoadingItems) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Stardust display
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
                    Text('$_stardust', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tabs
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
          _buildItemsGrid(),
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

  Widget _buildItemsGrid() {
    final items = _itemsByCategory[_selectedTab] ?? [];
    List<Widget> rows = [];
    for (int i = 0; i < items.length; i += 2) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildItemWidget(items[i]),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: i + 1 < items.length ? _buildItemWidget(items[i + 1]) : const SizedBox(),
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

  Widget _buildItemWidget(Map<String, dynamic> item) {
    final bool isSoldOut = item['sold_out'] == true;
    Widget shopItem = _buildShopItem(item);

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

  Widget _buildShopItem(Map<String, dynamic> item) {
    final title = item['title'] as String;
    final desc = item['description'] as String? ?? '';
    final price = item['price'] as int? ?? 0;
    final imagePath = item['image_path'] as String?;
    final buttonColor = item['type'] == 'EVOLUTION'
        ? QuestlingsTheme.blueAction
        : QuestlingsTheme.brownAction;

    return PixelContainer(
      padding: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.transparent,
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
                  Text('$price', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              GestureDetector(
                onTap: () => _buyItem(item),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: buttonColor,
                    border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                  ),
                  child: const Text('BUY',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}