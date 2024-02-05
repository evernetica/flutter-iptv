import 'package:equatable/equatable.dart';
import 'package:giptv_flutter/domain/entities/entity_category.dart';
import 'package:giptv_flutter/domain/entities/entity_channel.dart';
import 'package:giptv_flutter/domain/entities/entity_fav_channel.dart';
import 'package:giptv_flutter/domain/entities/entity_radio_station.dart';

enum StagesScreenMain {
  liveTv,
  radio,
  settings,
  favorites,
  about,
}

class StateMain extends Equatable {
  const StateMain({
    this.stage = StagesScreenMain.liveTv,
    this.channels = const [],
    this.categories = const [],
    this.radioStations = const [],
    this.favorites = const [],
    this.videoUrl = "",
    this.selectedChannel = -1,
  });

  StateMain copyWith({
    StagesScreenMain? stage,
    List<EntityChannel>? channels,
    List<EntityCategory>? categories,
    List<EntityRadioStation>? radioStations,
    List<EntityFavChannel>? favorites,
    String? videoUrl,
    int? selectedChannel,
  }) {
    return StateMain(
      stage: stage ?? this.stage,
      channels: channels ?? this.channels,
      categories: categories ?? this.categories,
      radioStations: radioStations ?? this.radioStations,
      favorites: favorites ?? this.favorites,
      videoUrl: videoUrl ?? this.videoUrl,
      selectedChannel: selectedChannel ?? this.selectedChannel,
    );
  }

  final StagesScreenMain stage;

  final List<EntityChannel> channels;
  final List<EntityCategory> categories;
  final List<EntityRadioStation> radioStations;
  final List<EntityFavChannel> favorites;
  final String videoUrl;
  final int selectedChannel;

  @override
  List<Object?> get props => [
        stage,
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
        selectedChannel,
      ];
}
