import 'package:equatable/equatable.dart';
import 'package:giptv_flutter/domain/entities/entity_category.dart';
import 'package:giptv_flutter/domain/entities/entity_channel.dart';
import 'package:giptv_flutter/domain/entities/entity_fav_channel.dart';
import 'package:giptv_flutter/domain/entities/entity_radio_station.dart';
import 'package:giptv_flutter/domain/entities/entity_user.dart';
import 'package:giptv_flutter/domain/entities/entity_website.dart';

enum StagesScreenMain {
  liveTv,
  radio,
  settings,
  favorites,
  activation,
}

class StateMain extends Equatable {
  const StateMain({
    this.stage = StagesScreenMain.liveTv,
    this.user = const EntityUser(
      code: "",
      deviceId: "",
      email: "",
      fullName: "",
      ip: "",
      registered: "",
      idSerial: "",
      purchase: "",
      trialStartTime: "",
      trialFinishTime: "",
      deviceId2: "",
      deviceId3: "",
      isParentalControlActive: "",
      passParentalControl: "",
    ),
    this.channels = const [],
    this.categories = const [],
    this.radioStations = const [],
    this.favorites = const [],
    this.videoUrl = "",
    this.websiteUrl = const EntityWebsite(
      content: "",
      visible: "0",
      name: "",
    ),
    this.selectedChannel = -1,
  });

  StateMain copyWith({
    StagesScreenMain? stage,
    EntityUser? user,
    List<EntityChannel>? channels,
    List<EntityCategory>? categories,
    List<EntityRadioStation>? radioStations,
    List<EntityFavChannel>? favorites,
    String? videoUrl,
    EntityWebsite? websiteUrl,
    int? selectedChannel,
  }) {
    return StateMain(
      stage: stage ?? this.stage,
      user: user ?? this.user,
      channels: channels ?? this.channels,
      categories: categories ?? this.categories,
      radioStations: radioStations ?? this.radioStations,
      favorites: favorites ?? this.favorites,
      videoUrl: videoUrl ?? this.videoUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      selectedChannel: selectedChannel ?? this.selectedChannel,
    );
  }

  final StagesScreenMain stage;

  final EntityUser user;
  final List<EntityChannel> channels;
  final List<EntityCategory> categories;
  final List<EntityRadioStation> radioStations;
  final List<EntityFavChannel> favorites;
  final String videoUrl;
  final EntityWebsite websiteUrl;
  final int selectedChannel;

  @override
  List<Object?> get props => [
        stage,
        user,
        channels,
        channels.length,
        channels.hashCode,
        categories,
        categories.length,
        categories.hashCode,
        radioStations,
        radioStations.length,
        radioStations.hashCode,
        favorites,
        favorites.length,
        favorites.hashCode,
        videoUrl,
        websiteUrl,
        selectedChannel,
      ];
}
