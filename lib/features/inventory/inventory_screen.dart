import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/widgets/pixel_container.dart';
import '../../core/theme.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  int _selectedItemIndex = 0;
  String _selectedTab = 'ITEMS';
  List<Map<String, dynamic>> _inventory = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  Future<void> _fetchInventory() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _error = 'Not logged in';
        _isLoading = false;
      });
      return;
    }

    try {
      // Join user_items with items to get full item details
      final response = await Supabase.instance.client
          .from('user_items')
          .select('''
            id,
            quantity,
            is_equipped,
            item:items (
              id,
              title,
              description,
              type,
              image_path,
              price
            )
          ''')
          .eq('user_id', user.id);

      final items = List<Map<String, dynamic>>.from(response);
      final enriched = items.map((entry) {
        final itemData = entry['item'] as Map<String, dynamic>;
        return {
          'userItemId': entry['id'],
          'id': itemData['id'],
          'name': itemData['title'],
          'description': itemData['description'] ?? '',
          'type': itemData['type'],
          'imagePath': itemData['image_path'],
          'quantity': entry['quantity'] as int,
          'isEquipped': entry['is_equipped'] as bool? ?? false,
          // For compatibility with existing UI which expects these fields:
          'count': entry['quantity'] as int,
          'imageColor': _getColorForType(itemData['type']),
          'desc': itemData['description'] ?? '',
          // Keep original fields to avoid breaking UI
          'title': itemData['title'],
          'image_path': itemData['image_path'],
        };
      }).toList();

      setState(() {
        _inventory = enriched;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load inventory: $e';
        _isLoading = false;
      });
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'ACCESSORY':
        return const Color(0xFFF2E3B6);
      case 'GEAR':
        return const Color(0xFF26323E);
      case 'EVOLUTION':
        return const Color(0xFF0D131B);
      default:
        return QuestlingsTheme.surface;
    }
  }

  Future<void> _useItem(Map<String, dynamic> item) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final quantity = item['quantity'] as int;
      final userItemId = item['userItemId'] as String;

      if (quantity > 1) {
        // Decrement quantity
        await Supabase.instance.client
            .from('user_items')
            .update({'quantity': quantity - 1})
            .eq('id', userItemId);
      } else {
        // Delete the row
        await Supabase.instance.client
            .from('user_items')
            .delete()
            .eq('id', userItemId);
      }

      // Apply item effect (placeholder – implement based on your game logic)
      // e.g., restore HP, increase EXP, equip gear, etc.
      _applyItemEffect(item);

      // Refresh inventory
      await _fetchInventory();

      if (mounted && quantity == 1) {
        // If the used item was the last in the list, reset selection
        setState(() {
          if (_selectedItemIndex >= _inventory.length) {
            _selectedItemIndex = _inventory.isEmpty ? -1 : 0;
          }
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Used ${item['name']}!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to use item: $e')),
      );
    }
  }

  void _applyItemEffect(Map<String, dynamic> item) {
    // TODO: Implement actual effects based on item type
    // Example: if item['type'] == 'GEAR' -> equip it (update user's equipped gear column)
    // For now, just print.
    debugPrint('Applying effect for ${item['name']}');
  }

  Future<void> _trashItem(Map<String, dynamic> item) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final userItemId = item['userItemId'] as String;
      await Supabase.instance.client
          .from('user_items')
          .delete()
          .eq('id', userItemId);

      await _fetchInventory();

      setState(() {
        if (_selectedItemIndex >= _inventory.length) {
          _selectedItemIndex = _inventory.isEmpty ? -1 : 0;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trashed ${item['name']}.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to trash item: $e')),
      );
    }
  }

  void _sortItems() {
    setState(() {
      _inventory.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
      _selectedItemIndex = _inventory.isNotEmpty ? 0 : -1;
    });
  }

  List<Map<String, dynamic>> _getFilteredInventory() {
    return _inventory.where((item) {
      final type = item['type'] as String;
      if (_selectedTab == 'ITEMS') return type != 'GEAR'; // Actually 'ITEMS' could include everything except monsters? Keep original logic: 'ITEM' type? But our types are ACCESSORY, GEAR, EVOLUTION. We'll map: ITEMS tab shows ACCESSORY and EVOLUTION; GEAR tab shows GEAR; QUESTLINGS shows none (or later).
      if (_selectedTab == 'GEAR') return type == 'GEAR';
      if (_selectedTab == 'QUESTLINGS') return false; // No monsters in user_items for now
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }

    final filtered = _getFilteredInventory();
    if (_selectedItemIndex >= filtered.length) {
      _selectedItemIndex = filtered.isEmpty ? -1 : 0;
    }
    final selectedItem = _selectedItemIndex >= 0 ? filtered[_selectedItemIndex] : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tabs
          Row(
            children: [
              Expanded(child: _buildTab('QUESTLINGS', _selectedTab == 'QUESTLINGS', () => setState(() => _selectedTab = 'QUESTLINGS'))),
              const SizedBox(width: 8),
              Expanded(child: _buildTab('ITEMS', _selectedTab == 'ITEMS', () => setState(() => _selectedTab = 'ITEMS'))),
              const SizedBox(width: 8),
              Expanded(child: _buildTab('GEAR', _selectedTab == 'GEAR', () => setState(() => _selectedTab = 'GEAR'))),
            ],
          ),
          const SizedBox(height: 16),
          // Inventory grid
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
                      child: Text('${filtered.length} / 30', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(color: QuestlingsTheme.shadow, thickness: 2),
                const SizedBox(height: 16),
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 16, // Show 16 slots minimum
                  itemBuilder: (context, index) {
                    if (index < filtered.length) {
                      final item = filtered[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedItemIndex = index;
                          });
                          _showItemPopup(context, item);
                        },
                        child: _buildItemSlot(
                          count: item['quantity'] as int,
                          isSelected: _selectedItemIndex == index,
                          imageColor: _getColorForType(item['type']),
                          imagePath: item['imagePath'],
                        ),
                      );
                    }
                    return _buildEmptySlot();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Selected item details
          if (selectedItem != null)
            PixelContainer(
              padding: 12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _getColorForType(selectedItem['type']),
                      border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                    ),
                    child: selectedItem['imagePath'] != null
                        ? Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.asset(selectedItem['imagePath'], fit: BoxFit.contain),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${selectedItem['name'].toString().toUpperCase()} (${selectedItem['type']})',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.5),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _useItem(selectedItem),
                              child: const Text('Use', style: TextStyle(color: QuestlingsTheme.brownAction, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          selectedItem['description'] ?? '',
                          style: TextStyle(color: QuestlingsTheme.shadow.withOpacity(0.8), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (selectedItem == null)
            const Center(child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Select an item to view details.', style: TextStyle(color: QuestlingsTheme.shadow)),
            )),
          const SizedBox(height: 16),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: selectedItem != null ? () => _trashItem(selectedItem) : null,
                icon: const Icon(Icons.delete_outline, color: QuestlingsTheme.warning),
                label: const Text('TRASH', style: TextStyle(color: QuestlingsTheme.warning, fontWeight: FontWeight.bold)),
              ),
              TextButton.icon(
                onPressed: _sortItems,
                icon: const Icon(Icons.sort, color: QuestlingsTheme.blueAction),
                label: const Text('SORT', style: TextStyle(color: QuestlingsTheme.blueAction, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showItemPopup(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: PixelContainer(
            padding: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _getColorForType(item['type']),
                        border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                      ),
                      child: item['imagePath'] != null
                          ? Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.asset(item['imagePath'], fit: BoxFit.contain),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item['name'].toString().toUpperCase()} (${item['type']})',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['description'] ?? '',
                            style: TextStyle(color: QuestlingsTheme.shadow.withOpacity(0.8), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('CLOSE', style: TextStyle(color: QuestlingsTheme.shadow, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () async {
                        Navigator.of(context).pop();
                        await _useItem(item);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: QuestlingsTheme.primaryAction,
                          border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                          boxShadow: const [BoxShadow(color: QuestlingsTheme.shadow, offset: Offset(2, 2))],
                        ),
                        child: const Text('USE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTab(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }

  Widget _buildItemSlot({required int count, required Color imageColor, bool isSelected = false, String? imagePath}) {
    return Container(
      decoration: BoxDecoration(
        color: imageColor,
        border: Border.all(
          color: isSelected ? QuestlingsTheme.primaryAction : QuestlingsTheme.shadow,
          width: isSelected ? 4 : 2,
        ),
      ),
      child: Stack(
        children: [
          if (imagePath != null)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
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