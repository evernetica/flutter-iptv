import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giptv_flutter/app/screens/screen_base.dart';
import 'package:giptv_flutter/domain/providers/provider_api_interactions.dart';
import 'package:giptv_flutter/misc/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class ScreenVideo extends StatefulWidget {
  //TODO: refactor with cubit
  const ScreenVideo({
    super.key,
    required this.videoUrl,
    required this.idSerial,
    required this.title,
    required this.channelId,
    required this.isFavourite,
  });

  final String videoUrl;
  final String idSerial;
  final String title;
  final String channelId;
  final bool isFavourite;

  @override
  State<ScreenVideo> createState() => _ScreenVideoState();
}

class _ScreenVideoState extends State<ScreenVideo> {
  late VideoPlayerController controller;
  late Future init;
  late bool isFavourite;
  late bool isPortraitMode = false;

  @override
  void initState() {
    super.initState();

    isFavourite = widget.isFavourite;

    controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    init = controller.initialize();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]).then((_) => setState(() {}));
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBase(
      child: PopScope(
        onPopInvoked: (_) => _onPop(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            FutureBuilder(
              future: init,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  controller.play();
                  return AspectRatio(
                    aspectRatio: 16 / 9,
                    child: VideoPlayer(controller),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white70,
                    ),
                  );
                }
              },
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Material(
                      color: Colors.white12,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        onTap: () {
                          _onPop();
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
                    const SizedBox(width: 8.0),
                    Material(
                      shape: const CircleBorder(),
                      clipBehavior: Clip.hardEdge,
                      color: Colors.white12,
                      child: InkWell(
                        onTap: () async {
                          ProviderApiInteractions p =
                              Provider.of<ProviderApiInteractions>(
                            context,
                            listen: false,
                          );

                          isFavourite
                              ? await p.removeFav(
                                  idSerial: widget.idSerial,
                                  link: widget.videoUrl,
                                )
                              : await p.addFav(
                                  idSerial: widget.idSerial,
                                  title: widget.title,
                                  link: widget.videoUrl,
                                  channelId: widget.channelId,
                                );

                          setState(() {
                            isFavourite = !isFavourite;
                          });
                        },
                        overlayColor: MaterialStateColor.resolveWith(
                          (_) => AppColors.fgMain,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            isFavourite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.white,
                            size: 32.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Material(
                      color: Colors.white12,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        onTap: () {
                          if (isPortraitMode) {
                            SystemChrome.setPreferredOrientations([
                              DeviceOrientation.landscapeLeft,
                              DeviceOrientation.landscapeRight,
                            ]).then((_) => setState(() {
                                  isPortraitMode = false;
                                }));
                          } else {
                            SystemChrome.setPreferredOrientations([
                              DeviceOrientation.portraitUp,
                              DeviceOrientation.portraitDown,
                            ]).then((_) => setState(() {
                                  isPortraitMode = true;
                                }));
                          }
                        },
                        overlayColor: MaterialStateColor.resolveWith(
                          (_) => Colors.white24,
                        ),
                        borderRadius: BorderRadius.circular(9999),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.screen_rotation,
                            color: Colors.white,
                            size: 32.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPop() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    controller.dispose();
  }
}
