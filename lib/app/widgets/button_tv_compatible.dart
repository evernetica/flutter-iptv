import 'package:flutter/material.dart';

class ButtonTvCompatible extends StatefulWidget {
  ButtonTvCompatible({
    super.key,
    required this.child,
    this.callback,
    this.style,
    this.isButtonElevated = false,
    FocusNode? focusNode,
  }) : focusNode = focusNode ?? FocusNode();

  final VoidCallback? callback;
  final FocusNode focusNode;
  final ButtonStyle? style;
  final Widget child;
  final bool isButtonElevated;

  @override
  State<ButtonTvCompatible> createState() => _ButtonTvCompatibleState();
}

class _ButtonTvCompatibleState extends State<ButtonTvCompatible> {
  int? timestamp;

  @override
  void initState() {
    super.initState();

    widget.focusNode.onKeyEvent = (node, event) {
      if (event.logicalKey.keyId != 0x10000050c) return KeyEventResult.ignored;

      if (_checkTimestamp()) return KeyEventResult.ignored;

      widget.callback?.call();
      return KeyEventResult.handled;
    };
  }

  @override
  Widget build(BuildContext context) {
    return widget.isButtonElevated
        ? ElevatedButton(
            focusNode: widget.focusNode,
            onPressed: () {
              if (_checkTimestamp()) return;
              widget.callback?.call();
            },
            style: widget.style,
            child: widget.child,
          )
        : TextButton(
            focusNode: widget.focusNode,
            onPressed: () {
              if (_checkTimestamp()) return;
              widget.callback?.call();
            },
            style: widget.style,
            child: widget.child,
          );
  }

  bool _checkTimestamp() {
    int now = DateTime.now().millisecondsSinceEpoch;
    bool isButtonBusy = timestamp != null && now - timestamp! < 50;
    if (!isButtonBusy) timestamp = now;
    return isButtonBusy;
  }
}
