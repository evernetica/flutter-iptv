import 'package:flutter/material.dart';
import 'package:giptv_flutter/app/dashboard/cubit/cubit_dashboard.dart';
import 'package:giptv_flutter/app/screens/main/widgets/channel_list_list_view.dart';
import 'package:giptv_flutter/app/screens/main/widgets/media_content_button.dart';
import 'package:giptv_flutter/domain/entities/entity_fav_channel.dart';
import 'package:giptv_flutter/domain/entities/entity_user.dart';
import 'package:giptv_flutter/misc/app_strings.dart';
import 'package:provider/provider.dart';

class BodyFavorites extends StatelessWidget {
  const BodyFavorites({
    super.key,
    required this.favorites,
    required this.user,
  });

  final List<EntityFavChannel> favorites;
  final EntityUser user;

  @override
  Widget build(BuildContext context) {
    return ChannelListListView(
      channels: List.generate(
        favorites.length,
        (i) {
          bool isForbidden = (user.isParentalControlActive == "1")
              ? AppStrings.adultKeywords.any(
                  (keyword) => favorites[i].titleChannel.toLowerCase().contains(
                        keyword,
                      ),
                )
              : false;

          return MediaContentButton(
            title: isForbidden
                ? "This Channel is Protected"
                : favorites[i].titleChannel,
            iconUrl: "",
            callback: () {
              if (isForbidden) return;

              Provider.of<CubitDashboard>(
                context,
                listen: false,
              ).openVideoPage(
                videoUrl: favorites[i].linkChannel,
                idSerial: "${user.idSerial}",
                title: favorites[i].titleChannel,
                channelId: favorites[i].channelId,
                isFavourite: true,
              );
            },
          );
        },
      ),
    );
  }
}
