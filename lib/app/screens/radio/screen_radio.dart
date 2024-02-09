import 'dart:async';

import 'package:flutter/material.dart';
import 'package:giptv_flutter/app/screens/screen_base.dart';
import 'package:giptv_flutter/domain/entities/entity_radio_station.dart';
import 'package:giptv_flutter/misc/app_colors.dart';
import 'package:video_player/video_player.dart';

class ScreenRadio extends StatefulWidget {
  const ScreenRadio({super.key, required this.radioStation});

  final EntityRadioStation radioStation;

  @override
  State<ScreenRadio> createState() => _ScreenRadioState();
}

class _ScreenRadioState extends State<ScreenRadio> {
  late VideoPlayerController controller;
  late Future init;
  late Function() listener = () {
    setState(() {});
  };

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.radioStation.radioStreamUrl),
    );

    init = controller.initialize();
    controller.play();
    controller.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (_) {
        controller.removeListener(listener);
        controller.dispose();
      },
      child: ScreenBase(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.fgMain,
                AppColors.bgMain,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              FutureBuilder(
                future: init,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return SizedBox.shrink(child: VideoPlayer(controller));
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    color: Colors.white12,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      overlayColor: MaterialStateColor.resolveWith(
                        (_) => Colors.white24,
                      ),
                      borderRadius: BorderRadius.circular(9999),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 32.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset('assets/images/radio_logo.png'),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.radioStation.radioName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Material(
                      shape: const CircleBorder(),
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        onTap: () {
                          if (controller.value.isPlaying) {
                            controller.pause();
                          } else {
                            controller.play();
                          }
                        },
                        overlayColor: MaterialStateColor.resolveWith(
                          (_) => AppColors.fgMain,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 32.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
