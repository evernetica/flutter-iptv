import 'package:flutter/material.dart';

class InkWellButton extends StatefulWidget {
  InkWellButton({
    super.key,
    required this.onTap,
    required this.icon,
    this.iconSize = 32.0,
    this.backgroundColor = Colors.white12,
    FocusNode? focusNode,
  }) : focusNode = focusNode ?? FocusNode();

  final VoidCallback onTap;
  final FocusNode focusNode;
  final IconData icon;
  final double iconSize;
  final Color backgroundColor;

  @override
  State<InkWellButton> createState() => _InkWellButtonState();
}

class _InkWellButtonState extends State<InkWellButton> {
  int? timestamp;

  @override
  void initState() {
    super.initState();

    widget.focusNode.onKeyEvent = (node, event) {
      if (event.logicalKey.keyId != 0x10000050c) return KeyEventResult.ignored;

      if (_checkTimestamp()) return KeyEventResult.ignored;

      widget.onTap.call();
      return KeyEventResult.handled;
    };
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.backgroundColor,
      shape: const CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          if (_checkTimestamp()) return;
          widget.onTap.call();
        },
        overlayColor: MaterialStateColor.resolveWith(
          (_) => Colors.white24,
        ),
        borderRadius: BorderRadius.circular(9999),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: widget.iconSize,
          ),
        ),
      ),
    );
  }

  bool _checkTimestamp() {
    int now = DateTime.now().millisecondsSinceEpoch;
    bool isButtonBusy = timestamp != null && now - timestamp! < 50;
    if (!isButtonBusy) timestamp = now;
    return isButtonBusy;
  }
}
