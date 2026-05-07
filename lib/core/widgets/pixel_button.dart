import 'package:flutter/material.dart';
import '../theme.dart';

class PixelButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double width;
  final double height;
  final Widget? icon;

  const PixelButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor = QuestlingsTheme.surface,
    this.textColor = QuestlingsTheme.shadow,
    this.width = double.infinity,
    this.height = 48.0,
    this.icon,
  });

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) {
        setState(() => _isPressed = false);
        widget.onPressed!();
      },
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      child: Container(
        width: widget.width,
        height: widget.height,
        margin: EdgeInsets.only(
          top: _isPressed ? 4 : 0,
          left: _isPressed ? 4 : 0,
          bottom: _isPressed ? 0 : 4,
          right: _isPressed ? 0 : 4,
        ),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey[300] : widget.backgroundColor,
          border: Border.all(color: QuestlingsTheme.shadow, width: 2),
          boxShadow: _isPressed || isDisabled
              ? []
              : const [
                  BoxShadow(
                    color: QuestlingsTheme.shadow,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 8),
              ],
              Text(
                widget.text.toUpperCase(),
                style: TextStyle(
                  color: widget.textColor,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
