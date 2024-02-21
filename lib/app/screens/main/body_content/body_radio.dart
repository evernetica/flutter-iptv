import 'dart:async';

import 'package:flutter/material.dart';
import 'package:giptv_flutter/app/dashboard/cubit/cubit_dashboard.dart';
import 'package:giptv_flutter/app/screens/main/widgets/channel_list_list_view.dart';
import 'package:giptv_flutter/app/screens/main/widgets/media_content_button.dart';
import 'package:giptv_flutter/domain/entities/entity_radio_station.dart';
import 'package:provider/provider.dart';

class BodyRadio extends StatefulWidget {
  const BodyRadio({
    super.key,
    required this.radioStations,
    required this.searchController,
    this.initialSearchQuery = "",
  });

  final List<EntityRadioStation> radioStations;
  final StreamController<String> searchController;
  final String initialSearchQuery;

  @override
  State<BodyRadio> createState() => _BodyRadioState();
}

class _BodyRadioState extends State<BodyRadio> {
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
    List<EntityRadioStation> finalStations = [];

    if (searchQuery.isEmpty) {
      finalStations.addAll(widget.radioStations);
    } else {
      finalStations.addAll(
        widget.radioStations.where(
          (element) => element.radioName.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
        ),
      );
    }

    return ChannelListListView(
      channels: List.generate(
        finalStations.length,
        (i) {
          return MediaContentButton(
            title: finalStations[i].radioName,
            iconUrl: finalStations[i].radioImgLink,
            fallbakcAssetIcon: 'assets/images/radio_logo.png',
            callback: () {
              Provider.of<CubitDashboard>(
                context,
                listen: false,
              ).openRadioPage(finalStations[i]);
            },
          );
        },
      ),
    );
  }
}
