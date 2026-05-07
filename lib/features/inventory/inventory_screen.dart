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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GlobalState(),
      builder: (context, _) {
        final state = GlobalState();
        final inventory = state.inventory;
        
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
                            },
                            child: _buildItemSlot(
                              count: item['count'] as int,
                              isSelected: _selectedItemIndex == index,
                              imageColor: item['imageColor'] as Color,
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
                                    selectedItem['name'].toString().toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.5),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Text('Use', style: TextStyle(color: QuestlingsTheme.brownAction, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
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

  Widget _buildItemSlot({required int count, required Color imageColor, bool isSelected = false}) {
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