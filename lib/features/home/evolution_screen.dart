import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

class EvolutionScreen extends StatelessWidget {
  final String gifPath;

  const EvolutionScreen({super.key, required this.gifPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuestlingsTheme.primaryAction,
      body: Stack(
        children: [
          // Background Flashing Effect Simulation
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: CustomPaint(
                painter: _RadialDotPainter(),
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Headline Panel
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 280),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: QuestlingsTheme.surface,
                        border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                        boxShadow: const [
                          BoxShadow(color: QuestlingsTheme.shadow, offset: Offset(2, 2)),
                        ],
                      ),
                      child: const Text(
                        'LEVEL UP!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Spline Sans',
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: QuestlingsTheme.primaryAction,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Central Graphic (GIF)
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // Silhouette glow
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: QuestlingsTheme.lightGreen.withOpacity(0.7),
                                  blurRadius: 40,
                                  spreadRadius: 20,
                                ),
                              ],
                            ),
                          ),
                          // The actual animated GIF
                          Image.asset(
                            gifPath,
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.none, // Keep pixel art crisp
                          ),
                          // Evolution sparks (top right)
                          Positioned(
                            top: -16,
                            right: -16,
                            child: _buildSpark(size: 32, iconSize: 20),
                          ),
                          // Evolution sparks (bottom left)
                          Positioned(
                            bottom: -8,
                            left: -8,
                            child: _buildSpark(size: 24, iconSize: 16),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Secondary Message
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 320),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: QuestlingsTheme.surface,
                        border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                        boxShadow: const [
                          BoxShadow(color: QuestlingsTheme.shadow, offset: Offset(2, 2)),
                        ],
                      ),
                      child: const Text(
                        'Your habit consistency is paying off!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: QuestlingsTheme.shadow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Action Button
                    GestureDetector(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/');
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 280),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: QuestlingsTheme.lightGreen,
                          border: Border.all(color: QuestlingsTheme.shadow, width: 2),
                          boxShadow: const [
                            BoxShadow(color: QuestlingsTheme.shadow, offset: Offset(4, 4)),
                          ],
                        ),
                        child: const Text(
                          'AWESOME',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            color: QuestlingsTheme.shadow,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpark({required double size, required double iconSize}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: QuestlingsTheme.surface,
        shape: BoxShape.circle,
        border: Border.all(color: QuestlingsTheme.shadow, width: 2),
        boxShadow: const [
          BoxShadow(color: QuestlingsTheme.shadow, offset: Offset(2, 2)),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.auto_awesome,
          color: QuestlingsTheme.primaryAction,
          size: iconSize,
        ),
      ),
    );
  }
}

class _RadialDotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = QuestlingsTheme.surface
      ..style = PaintingStyle.fill;
      
    const double spacing = 12.0;
    const double radius = 2.0;
    
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
