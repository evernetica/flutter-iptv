import 'package:flutter/material.dart';

class InkWellButton extends StatelessWidget {
  const InkWellButton({
    super.key,
    required this.onTap,
    required this.icon,
    this.iconSize = 32.0,
  });

  final VoidCallback onTap;
  final IconData icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white12,
      shape: const CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        overlayColor: MaterialStateColor.resolveWith(
          (_) => Colors.white24,
        ),
        borderRadius: BorderRadius.circular(9999),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: Colors.white,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
