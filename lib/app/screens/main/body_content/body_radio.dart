import 'package:flutter/material.dart';
import 'package:giptv_flutter/app/dashboard/cubit/cubit_dashboard.dart';
import 'package:giptv_flutter/app/screens/main/widgets/channel_list_list_view.dart';
import 'package:giptv_flutter/app/screens/main/widgets/media_content_button.dart';
import 'package:giptv_flutter/domain/entities/entity_radio_station.dart';
import 'package:provider/provider.dart';

class BodyRadio extends StatelessWidget {
  const BodyRadio({
    super.key,
    required this.radioStations,
  });

  final List<EntityRadioStation> radioStations;

  @override
  Widget build(BuildContext context) {
    return ChannelListListView(
      channels: List.generate(
        radioStations.length,
        (i) {
          return MediaContentButton(
            title: radioStations[i].radioName,
            iconUrl: radioStations[i].radioImgLink,
            fallbakcAssetIcon: 'assets/images/radio_logo.png',
            callback: () {
              Provider.of<CubitDashboard>(
                context,
                listen: false,
              ).openRadioPage(radioStations[i]);
            },
          );
        },
      ),
    );
  }
}
