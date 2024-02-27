import 'package:flutter/material.dart';
import 'package:flutter_iptv/misc/app_colors.dart';

class ScreenBase extends StatelessWidget {
  const ScreenBase({
    super.key,
    required this.child,
    this.appBar,
    this.drawer,
    this.backgroundColor = AppColors.bgMain,
    this.drawerScrimColor,
    this.extendBodyBehindAppBar = false,
    this.scaffoldKey,
  });

  final Widget child;
  final AppBar? appBar;
  final Widget? drawer;
  final Color? backgroundColor;
  final Color? drawerScrimColor;
  final bool extendBodyBehindAppBar;
  final GlobalKey? scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: appBar,
      drawer: drawer,
      body: child,
      drawerScrimColor: drawerScrimColor,
    );
  }
}
