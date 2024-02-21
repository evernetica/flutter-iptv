import 'dart:async';

import 'package:flutter/material.dart';
import 'package:giptv_flutter/app/dashboard/cubit/cubit_dashboard.dart';
import 'package:giptv_flutter/app/screens/main/widgets/channel_list_list_view.dart';
import 'package:giptv_flutter/app/screens/main/widgets/media_content_button.dart';
import 'package:giptv_flutter/domain/entities/entity_channel.dart';
import 'package:giptv_flutter/domain/entities/entity_fav_channel.dart';
import 'package:giptv_flutter/domain/entities/entity_user.dart';
import 'package:giptv_flutter/misc/app_strings.dart';
import 'package:provider/provider.dart';

class BodyFavorites extends StatefulWidget {
  const BodyFavorites({
    super.key,
    required this.favorites,
    required this.user,
    required this.searchController,
    this.initialSearchQuery = "",
  });

  final List<EntityFavChannel> favorites;
  final StreamController<String> searchController;
  final String initialSearchQuery;
  final EntityUser user;

  @override
  State<BodyFavorites> createState() => _BodyFavoritesState();
}

class _BodyFavoritesState extends State<BodyFavorites> {
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
    List<EntityFavChannel> finalFavChannels = [];

    if (searchQuery.isEmpty) {
      finalFavChannels.addAll(widget.favorites);
    } else {
      finalFavChannels.addAll(
        widget.favorites.where(
          (element) => element.titleChannel.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
        ),
      );
    }

    return ChannelListListView(
      channels: List.generate(
        finalFavChannels.length,
        (i) {
          bool isForbidden = (widget.user.isParentalControlActive == "1")
              ? AppStrings.adultKeywords.any(
                  (keyword) =>
                      finalFavChannels[i].titleChannel.toLowerCase().contains(
                            keyword,
                          ),
                )
              : false;

          return MediaContentButton(
            title: isForbidden
                ? "This Channel is Protected"
                : finalFavChannels[i].titleChannel,
            iconUrl: "",
            callback: () {
              if (isForbidden) return;

              Provider.of<CubitDashboard>(
                context,
                listen: false,
              ).openVideoPage(
                videoUrl: finalFavChannels[i].linkChannel,
                title: finalFavChannels[i].titleChannel,
                channelId: finalFavChannels[i].channelId,
                isFavourite: true,
                user: widget.user,
                channels: List.generate(
                  widget.favorites.length,
                  (i) => EntityChannel(
                    num: -1,
                    name: widget.favorites[i].titleChannel,
                    streamType: '',
                    streamId: -1,
                    streamIcon: '',
                    epgChannelId: widget.favorites[i].channelId,
                    added: '',
                    customSid: '',
                    tvArchive: -1,
                    directSource: '',
                    tvArchiveDuration: -1,
                    categoryId: '',
                    categoryIds: [],
                    thumbnail: '',
                    videoUrl: widget.favorites[i].linkChannel,
                  ),
                ),
                favChannels: widget.favorites,
              );
            },
          );
        },
      ),
    );
  }
}
