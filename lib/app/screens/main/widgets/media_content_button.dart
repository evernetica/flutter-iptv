import 'package:flutter/material.dart';
import 'package:giptv_flutter/misc/app_colors.dart';

class MediaContentButton extends StatelessWidget {
  const MediaContentButton({
    super.key,
    required this.title,
    required this.iconUrl,
    required this.callback,
    this.fallbakcAssetIcon = "assets/images/giptv_nobg.png",
  });

  static const double defaultWidth = 120.0;
  static const double defaultHeight =
      _defaultIconHeight + defaultWidth / _titleWidthFactor;
  static const double _defaultIconHeight = 90.0;
  static const double _titleWidthFactor = 3;

  final String title;
  final String iconUrl;
  final String fallbakcAssetIcon;
  final Function() callback;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: const BorderRadius.all(
          Radius.circular(8.0),
        ),
        overlayColor: MaterialStateColor.resolveWith(
          (_) => AppColors.fgMain,
        ),
        onTap: callback,
        child: _buildWidgetSkeleton(
          icon: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(8.0),
              ),
              border: Border.all(
                color: AppColors.bgMainLighter20,
              ),
            ),
            height: _defaultIconHeight,
            child: Center(
              child: Image.network(
                iconUrl,
                width: 64.0,
                height: 64.0,
                errorBuilder: (_, __, ___) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(fallbakcAssetIcon),
                ),
              ),
            ),
          ),
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10.0,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  static Widget empty() {
    return _buildWidgetSkeleton(
      icon: Container(
        decoration: const BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        height: _defaultIconHeight,
        child: const Center(
          child: Icon(
            Icons.live_tv_outlined,
            size: 48.0,
            color: Colors.white54,
          ),
        ),
      ),
      title: Container(
        width: 100.0,
        height: 16.0,
        decoration: BoxDecoration(
          color: Colors.white54,
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
    );
  }

  static Widget _buildWidgetSkeleton({
    required Widget icon,
    required Widget title,
  }) {
    return SizedBox(
      width: defaultWidth,
      height: defaultHeight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          icon,
          Flexible(
            child: AspectRatio(
              aspectRatio: _titleWidthFactor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: title,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
