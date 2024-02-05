import 'package:flutter/material.dart';
import 'package:giptv_flutter/misc/app_colors.dart';

class ScreenBase extends StatelessWidget {
  const ScreenBase({
    super.key,
    required this.child,
    this.appBar,
    this.drawer,
    this.backgroundColor = AppColors.bgMain,
    this.extendBodyBehindAppBar = false,
  });

  final Widget child;
  final AppBar? appBar;
  final Drawer? drawer;
  final Color? backgroundColor;
  final bool extendBodyBehindAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: appBar,
      drawer: drawer,
      body: child,
    );
  }
}
