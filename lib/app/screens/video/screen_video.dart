import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giptv_flutter/app/screens/screen_base.dart';
import 'package:giptv_flutter/app/widgets/inkwell_button.dart';
import 'package:giptv_flutter/domain/entities/entity_channel.dart';
import 'package:giptv_flutter/domain/entities/entity_fav_channel.dart';
import 'package:giptv_flutter/domain/entities/entity_user.dart';
import 'package:giptv_flutter/domain/providers/provider_api_interactions.dart';
import 'package:giptv_flutter/misc/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class ScreenVideo extends StatefulWidget {
  //TODO: refactor with cubit
  const ScreenVideo({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.channelId,
    required this.isFavourite,
    required this.user,
    required this.channels,
    required this.favChannels,
  });

  final String videoUrl;
  final String title;
  final String channelId;
  final bool isFavourite;

  final EntityUser user;
  final List<EntityChannel> channels;
  final List<EntityFavChannel> favChannels;

  @override
  State<ScreenVideo> createState() => _ScreenVideoState();
}

class _ScreenVideoState extends State<ScreenVideo> {
  late String videoUrl = widget.videoUrl;
  final String mockVideo = "https://content.uplynk.com/channel/aa92b664ac5941de81cd410803329da2.m3u8";
  late String title = widget.title;
  late String channelId = widget.channelId;
  late bool isFavourite = widget.isFavourite;

  late VideoPlayerController controller;
  late Future init;
  late bool isPortraitMode = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.networkUrl(
      Uri.parse(mockVideo),
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
    List<Widget> row2Widgets = [
      InkWellButton(
        onTap: () async {
          ProviderApiInteractions p = Provider.of<ProviderApiInteractions>(
            context,
            listen: false,
          );

          isFavourite
              ? await p.removeFav(
                  idSerial: "${widget.user.idSerial}",
                  link: videoUrl,
                )
              : await p.addFav(
                  idSerial: "${widget.user.idSerial}",
                  title: title,
                  link: videoUrl,
                  channelId: channelId,
                );

          setState(() {
            isFavourite = !isFavourite;
          });
        },
        icon: isFavourite ? Icons.favorite : Icons.favorite_border,
      ),
      const SizedBox(width: 8.0),
      InkWellButton(
        onTap: () {
          _onPop();
          Navigator.of(context).pop();
        },
        icon: Icons.text_snippet_outlined,
      ),
      const SizedBox(width: 8.0),
      InkWellButton(
        onTap: () {
          _onPop();
          Navigator.of(context).pop();
        },
        icon: Icons.cast,
      ),
      const SizedBox(width: 8.0),
      InkWellButton(
        onTap: () {
          _onPop();
          Navigator.of(context).pop();
        },
        icon: Icons.add_circle_outline,
      ),
      const SizedBox(width: 8.0),
      InkWellButton(
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
        icon: Icons.screen_rotation,
      ),
    ];

    return ScreenBase(
      scaffoldKey: scaffoldKey,
      drawer: Drawer(
        backgroundColor: AppColors.bgMain.withOpacity(0.3),
        shape: const ContinuousRectangleBorder(),
        child: ListView(
          children: List.generate(
            widget.channels.length,
            (i) => Material(
              color: Colors.transparent,
              child: InkWell(
                overlayColor: MaterialStateColor.resolveWith(
                  (_) => AppColors.fgMain,
                ),
                onTap: () {
                  setState(() {
                    videoUrl = widget.channels[i].videoUrl;
                    title = widget.channels[i].name;
                    channelId = "${widget.channels[i].epgChannelId}";
                    isFavourite = widget.favChannels.any(
                      (f) => f.linkChannel == widget.channels[i].videoUrl,
                    );

                    controller.dispose();
                    controller = VideoPlayerController.networkUrl(
                      Uri.parse(mockVideo),
                    );

                    init = controller.initialize();
                  });
                },
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.network(
                        widget.channels[i].streamIcon,
                        width: 32.0,
                        height: 32.0,
                        errorBuilder: (_, __, ___) => const FlutterLogo(
                          size: 32,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.channels[i].name,
                        maxLines: 1,
                        softWrap: false,
                        style: const TextStyle(fontSize: 20),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.black,
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
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    InkWellButton(
                      onTap: () {
                        _onPop();
                        Navigator.of(context).pop();
                      },
                      icon: Icons.arrow_back,
                    ),
                    const SizedBox(width: 8.0),
                    InkWellButton(
                      onTap: () {
                        ScaffoldState? scaffold = scaffoldKey.currentState;
                        if (!(scaffold?.isDrawerOpen ?? true)) {
                          scaffold?.openDrawer();
                        }
                      },
                      icon: Icons.list,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        softWrap: false,
                        style: const TextStyle(
                          fontSize: 24.0,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    if (!isPortraitMode) ...row2Widgets,
                  ],
                ),
              ),
            ),
            if (isPortraitMode)
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: row2Widgets,
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
