import 'package:flutter/material.dart';
import '../theme.dart';

class PixelContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double padding;
  final double? width;
  final double? height;

  const PixelContainer({
    super.key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.padding = 16.0,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(bottom: 4, right: 4), // space for shadow
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: QuestlingsTheme.shadow, width: 2),
        boxShadow: const [
          BoxShadow(
            color: QuestlingsTheme.shadow,
            offset: Offset(4, 4),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: child,
      ),
    );
  }
}
