import 'package:flutter/material.dart';
import '../../core/widgets/pixel_container.dart';
import '../../core/theme.dart';

class PartyScreen extends StatelessWidget {
  const PartyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: QuestlingsTheme.shadow, width: 4)),
                ),
                padding: const EdgeInsets.only(bottom: 4),
                child: const Text('Online Friends', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                ),
                child: const Text('4 / 50', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFriendCard('PixelMaster', 'Lv. 42', 'GUILD:', 'Dragon Slayers', QuestlingsTheme.lightGreen),
          _buildFriendCard('GhostBuster', 'Lv. 38', 'CLAN:', 'Shadow Stalkers', const Color(0xFF6EABDE)),
          _buildFriendCard('AquaQueen', 'Lv. 55', 'GUILD:', 'Ocean Guardians', const Color(0xFFD9B98A)),
          _buildFriendCard('Z-Volt', 'Lv. 29', 'STATUS:', 'Unclanned', QuestlingsTheme.surface),
          
          const SizedBox(height: 16),
          // Invite friends box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.transparent,
              // dotted border simulation or simple dashed
            ),
            child: CustomPaint(
              painter: DashedRectPainter(color: QuestlingsTheme.shadow.withOpacity(0.5), strokeWidth: 2, gap: 5),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.person_add_alt_1, size: 32, color: QuestlingsTheme.shadow.withOpacity(0.5)),
                    const SizedBox(height: 8),
                    Text(
                      'INVITE FRIENDS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: QuestlingsTheme.shadow.withOpacity(0.5),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
          // Guild Mission
          PixelContainer(
            backgroundColor: const Color(0xFFD9B98A),
            padding: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.military_tech),
                    SizedBox(width: 8),
                    Text('GUILD MISSION', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Work with your guild mates to complete the weekly raid and earn legendary rewards!',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Guild Progress', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text('750 / 1000 PT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: QuestlingsTheme.primaryAction)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 24,
                        decoration: BoxDecoration(
                          border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                        ),
                        child: Row(
                          children: [
                            Expanded(flex: 75, child: Container(color: QuestlingsTheme.primaryAction)),
                            Expanded(flex: 25, child: Container(color: QuestlingsTheme.surface)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: QuestlingsTheme.shadow, thickness: 1),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Your Points:'),
                          const Text('+125', style: TextStyle(color: QuestlingsTheme.blueAction, fontWeight: FontWeight.w900, fontSize: 18)),
                        ],
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

  Widget _buildFriendCard(String name, String level, String label, String value, Color avatarColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PixelContainer(
        padding: 12,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                  ),
                  child: const Center(child: Icon(Icons.face, size: 32)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(level, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(color: QuestlingsTheme.shadow, thickness: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(label, style: const TextStyle(color: QuestlingsTheme.blueAction, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(width: 4),
                Text(value, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({required this.color, required this.strokeWidth, required this.gap});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    
    var path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    
    // Simplistic dash implementation for borders
    double dashWidth = 8, dashSpace = 8;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      canvas.drawLine(Offset(startX, size.height), Offset(startX + dashWidth, size.height), paint);
      startX += dashWidth + dashSpace;
    }
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      canvas.drawLine(Offset(size.width, startY), Offset(size.width, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}