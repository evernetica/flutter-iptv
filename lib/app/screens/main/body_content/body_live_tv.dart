import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_iptv/app/dashboard/cubit/cubit_dashboard.dart';
import 'package:flutter_iptv/app/screens/main/cubit/cubit_main.dart';
import 'package:flutter_iptv/app/screens/main/widgets/channel_list_list_view.dart';
import 'package:flutter_iptv/app/screens/main/widgets/media_content_button.dart';
import 'package:flutter_iptv/domain/entities/entity_category.dart';
import 'package:flutter_iptv/domain/entities/entity_channel.dart';
import 'package:flutter_iptv/domain/entities/entity_fav_channel.dart';
import 'package:flutter_iptv/domain/entities/entity_user.dart';
import 'package:flutter_iptv/misc/app_colors.dart';
import 'package:flutter_iptv/misc/app_strings.dart';
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
    required this.bloc,
    required this.searchController,
    this.initialSearchQuery = "",
  });

  final List<EntityCategory> categories;
  final List<EntityChannel> channels;
  final List<EntityFavChannel> favChannels;
  final EntityUser user;
  final Function(String) categoryCallback;
  final Function() back;
  final CubitMain bloc;
  final String initialSearchQuery;

  final StreamController<String> searchController;

  @override
  State<BodyLiveTv> createState() => _BodyLiveTvState();
}

class _BodyLiveTvState extends State<BodyLiveTv> {
  FocusNode backButtonFocus = FocusNode();
  bool backButtonPressed = false;
  bool isLoadingChannels = false;
  late String searchQuery = widget.initialSearchQuery;

  @override
  void initState() {
    super.initState();

    widget.searchController.stream.listen(
      (event) {
        setState(() {
          searchQuery = event.trim();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<EntityChannel> finalChannels = [];
    List<EntityCategory> finalCategories = [];

    if (searchQuery.isEmpty) {
      finalChannels.addAll(widget.channels);
      finalCategories.addAll(widget.categories);
    } else {
      finalChannels.addAll(
        widget.channels.where(
          (element) => element.name.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
        ),
      );
      finalCategories.addAll(
        widget.categories.where(
          (element) => element.categoryName.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
        ),
      );
    }

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
                            height: 20.0,
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
          finalChannels.length,
          (i) {
            bool isForbidden = (widget.user.isParentalControlActive == "1")
                ? AppStrings.adultKeywords.any(
                    (keyword) => finalChannels[i].name.toLowerCase().contains(
                          keyword,
                        ),
                  )
                : false;

            return MediaContentButton(
              title: isForbidden
                  ? "This Channel is Protected"
                  : finalChannels[i].name,
              iconUrl: finalChannels[i].streamIcon,
              callback: () {
                if (isForbidden) return;

                Provider.of<CubitDashboard>(
                  context,
                  listen: false,
                ).openVideoPage(
                  videoUrl: finalChannels[i].videoUrl,
                  title: finalChannels[i].name,
                  channelId: "${finalChannels[i].epgChannelId}",
                  isFavourite: widget.favChannels.any(
                    (f) => f.linkChannel == finalChannels[i].videoUrl,
                  ),
                  user: widget.user,
                  channels: widget.channels,
                  favChannels: widget.favChannels,
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
          finalCategories.length,
          (i) {
            bool isForbidden = (widget.user.isParentalControlActive == "1")
                ? AppStrings.adultKeywords.any(
                    (keyword) =>
                        finalCategories[i].categoryName.toLowerCase().contains(
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

                  widget.bloc.setBackButtonVisibility(true);
                  setState(() {
                    isLoadingChannels = true;
                  });

                  await widget.categoryCallback(finalCategories[i].categoryId);

                  if (!context.mounted) return;

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
                              : finalCategories[i].categoryName,
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
