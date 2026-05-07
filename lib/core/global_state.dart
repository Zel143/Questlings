import 'package:flutter/material.dart';

class GlobalState extends ChangeNotifier {
  static final GlobalState _instance = GlobalState._internal();
  factory GlobalState() => _instance;
  GlobalState._internal();

  int stardust = 1450;
  
  // Basic mock items
  List<Map<String, dynamic>> inventory = [
    {
      'name': 'RED POTION', 
      'count': 5, 
      'desc': 'A medicinal brew that restores 50 HP to a single Monster. Smells faintly of bitter herbs and sweet berries.', 
      'imageColor': const Color(0xFFD32F2F),
      'type': 'ITEM'
    },
    {
      'name': 'EVO STONE', 
      'count': 1, 
      'desc': 'A mysterious stone that pulses with energy.', 
      'imageColor': const Color(0xFF9E9E9E),
      'type': 'ITEM'
    },
    {
      'name': 'BERRIES', 
      'count': 12, 
      'desc': 'Sweet berries found in the nearby forest. Slightly restores HP.', 
      'imageColor': const Color(0xFF4CAF50),
      'type': 'ITEM'
    },
    {
      'name': 'ANCIENT SCROLL', 
      'count': 3, 
      'desc': 'Contains forgotten knowledge that might grant EXP.', 
      'imageColor': const Color(0xFFFFC107),
      'type': 'ITEM'
    },
  ];

  bool buyItem(String name, int price, String desc, Color imageColor, [String type = 'ITEM', String? imagePath]) {
    if (stardust >= price) {
      stardust -= price;
      
      // Check if item exists in inventory
      int index = inventory.indexWhere((item) => item['name'] == name);
      if (index >= 0) {
        inventory[index]['count'] = (inventory[index]['count'] as int) + 1;
      } else {
        inventory.add({
          'name': name,
          'count': 1,
          'desc': desc,
          'imageColor': imageColor,
          'imagePath': imagePath,
          'type': type,
        });
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  void useItem(String name) {
    int index = inventory.indexWhere((item) => item['name'] == name);
    if (index >= 0) {
      inventory[index]['count'] = (inventory[index]['count'] as int) - 1;
      if (inventory[index]['count'] <= 0) {
        inventory.removeAt(index);
      }
      notifyListeners();
    }
  }

  void trashItem(String name) {
    int index = inventory.indexWhere((item) => item['name'] == name);
    if (index >= 0) {
      inventory.removeAt(index);
      notifyListeners();
    }
  }

  void sortItems() {
    inventory.sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
    notifyListeners();
  }
}
