import 'package:flutter/material.dart';
import 'package:giptv_flutter/app/dashboard/cubit/cubit_dashboard.dart';
import 'package:giptv_flutter/app/screens/main/widgets/channel_list_list_view.dart';
import 'package:giptv_flutter/app/screens/main/widgets/media_content_button.dart';
import 'package:giptv_flutter/domain/entities/entity_category.dart';
import 'package:giptv_flutter/domain/entities/entity_channel.dart';
import 'package:giptv_flutter/domain/entities/entity_fav_channel.dart';
import 'package:giptv_flutter/domain/entities/entity_user.dart';
import 'package:giptv_flutter/misc/app_colors.dart';
import 'package:giptv_flutter/misc/app_strings.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class BodyLiveTv extends StatefulWidget {
  const BodyLiveTv({
    super.key,
    required this.categories,
    required this.channels,
    required this.favChannels,
    required this.user,
    required this.categoryCallback,
    required this.back,
  });

  final List<EntityCategory> categories;
  final List<EntityChannel> channels;
  final List<EntityFavChannel> favChannels;
  final EntityUser user;
  final Function(String) categoryCallback;
  final Function() back;

  @override
  State<BodyLiveTv> createState() => _BodyLiveTvState();
}

class _BodyLiveTvState extends State<BodyLiveTv> {
  FocusNode backButtonFocus = FocusNode();
  bool backButtonPressed = false;
  bool isLoadingChannels = false;

  @override
  Widget build(BuildContext context) {
    if (isLoadingChannels) {
      return Shimmer(
        gradient: const LinearGradient(
          colors: [
            Colors.white12,
            Colors.white38,
          ],
        ),
        loop: 1,
        child: ChannelListListView(
          channels: List.filled(
            48,
            MediaContentButton.empty(),
          ),
        ),
      );
    }

    if (widget.categories.isEmpty) {
      return SingleChildScrollView(
        child: Column(
          children: List.generate(
            16,
            (i) {
              return Shimmer(
                gradient: const LinearGradient(
                  colors: [
                    Colors.white12,
                    Colors.white38,
                  ],
                ),
                loop: 1,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    left: 8.0,
                    right: 8.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.bgMainLighter20),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: (i % 4 + 1) * 50,
                            height: 16.0,
                            decoration: const BoxDecoration(
                              color: AppColors.bgMainLighter20,
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    if (widget.channels.isNotEmpty) {
      return ChannelListListView(
        channels: List.generate(
          widget.channels.length,
          (i) {
            bool isForbidden = (widget.user.isParentalControlActive == "1")
                ? AppStrings.adultKeywords.any(
                    (keyword) => widget.channels[i].name.toLowerCase().contains(
                          keyword,
                        ),
                  )
                : false;

            return MediaContentButton(
              title: isForbidden
                  ? "This Channel is Protected"
                  : widget.channels[i].name,
              iconUrl: widget.channels[i].streamIcon,
              callback: () {
                if (isForbidden) return;

                Provider.of<CubitDashboard>(
                  context,
                  listen: false,
                ).openVideoPage(
                  videoUrl: widget.channels[i].videoUrl,
                  idSerial: "${widget.user.idSerial}",
                  title: widget.channels[i].name,
                  channelId: "${widget.channels[i].epgChannelId}",
                  isFavourite: widget.favChannels.any(
                    (f) => f.linkChannel == widget.channels[i].videoUrl,
                  ),
                );
              },
            );
          },
        ),
      );
    }

    if (widget.categories.isNotEmpty) {
      return ListView(
        children: List.generate(
          widget.categories.length,
          (i) {
            bool isForbidden = (widget.user.isParentalControlActive == "1")
                ? AppStrings.adultKeywords.any(
                    (keyword) => widget.categories[i].categoryName
                        .toLowerCase()
                        .contains(
                          keyword,
                        ),
                  )
                : false;

            return Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
              child: InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                overlayColor: MaterialStateColor.resolveWith(
                  (_) => AppColors.fgMain,
                ),
                onTap: () async {
                  if (isForbidden) return;

                  setState(() {
                    isLoadingChannels = true;
                  });

                  await widget
                      .categoryCallback(widget.categories[i].categoryId);

                  setState(() {
                    isLoadingChannels = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.bgMainLighter20),
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          isForbidden
                              ? "This Category Content is Protected"
                              : widget.categories[i].categoryName,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return Container();
  }
}
