import 'package:flutter/material.dart';
import '../../core/widgets/pixel_container.dart';
import '../../core/theme.dart';
import '../../core/global_state.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  int _selectedItemIndex = 0;
  String _selectedTab = 'ITEMS';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GlobalState(),
      builder: (context, _) {
        final state = GlobalState();
        final rawInventory = state.inventory;
        final inventory = rawInventory.where((item) {
          final type = item['type'] ?? 'ITEM';
          if (_selectedTab == 'ITEMS') return type == 'ITEM';
          if (_selectedTab == 'GEAR') return type == 'GEAR' || type == 'ACCESSORY';
          if (_selectedTab == 'QUESTLINGS') return type == 'MONSTER';
          return false;
        }).toList();
        
        // Ensure selected index is valid
        if (_selectedItemIndex >= inventory.length) {
          _selectedItemIndex = inventory.isEmpty ? -1 : 0;
        }

        final selectedItem = _selectedItemIndex >= 0 ? inventory[_selectedItemIndex] : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          child: Text('${inventory.length} / 30', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                        if (index < inventory.length) {
                          final item = inventory[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedItemIndex = index;
                              });
                              _showItemPopup(context, item);
                            },
                            child: _buildItemSlot(
                              count: item['count'] as int,
                              isSelected: _selectedItemIndex == index,
                              imageColor: item['imageColor'] as Color,
                              imagePath: item['imagePath'] as String?,
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
                          color: selectedItem['imageColor'] as Color,
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
                                    '${selectedItem['name'].toString().toUpperCase()} (${selectedItem['type'] ?? 'ITEM'})',
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.5),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    state.useItem(selectedItem['name']);
                                  },
                                  child: const Text('Use', style: TextStyle(color: QuestlingsTheme.brownAction, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              selectedItem['desc'].toString(),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      if (selectedItem != null) {
                        state.trashItem(selectedItem['name']);
                        setState(() {
                          _selectedItemIndex = 0;
                        });
                      }
                    },
                    icon: const Icon(Icons.delete_outline, color: QuestlingsTheme.warning),
                    label: const Text('TRASH', style: TextStyle(color: QuestlingsTheme.warning, fontWeight: FontWeight.bold)),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      state.sortItems();
                    },
                    icon: const Icon(Icons.sort, color: QuestlingsTheme.blueAction),
                    label: const Text('SORT', style: TextStyle(color: QuestlingsTheme.blueAction, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        );
      }
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
                        color: item['imageColor'] as Color,
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
                            '${item['name'].toString().toUpperCase()} (${item['type'] ?? 'ITEM'})',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['desc'].toString(),
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
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('CLOSE', style: TextStyle(color: QuestlingsTheme.shadow, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        GlobalState().useItem(item['name']);
                        Navigator.of(context).pop();
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