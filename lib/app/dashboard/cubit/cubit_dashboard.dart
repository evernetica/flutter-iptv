import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giptv_flutter/app/dashboard/cubit/state_dashboard.dart';
import 'package:giptv_flutter/domain/entities/entity_channel.dart';
import 'package:giptv_flutter/domain/entities/entity_fav_channel.dart';
import 'package:giptv_flutter/domain/entities/entity_radio_station.dart';
import 'package:giptv_flutter/domain/entities/entity_user.dart';

class CubitDashboard extends Cubit<StateDashboard> {
  CubitDashboard() : super(const StateDashboard());

  void openLoginPage({bool shouldClearCache = true}) {
    Map<DashboardPage, dynamic>? newPageData = shouldClearCache ? {} : null;

    emit(state.copyWith(page: DashboardPage.login, pageData: newPageData));
  }

  void openMainPage(EntityUser user) {
    Map<DashboardPage, dynamic> newPageData = {...state.pageData}..addAll(
        {
          DashboardPage.main: user,
        },
      );

    emit(state.copyWith(page: DashboardPage.main, pageData: newPageData));
  }

  void openVideoPage({
    required String videoUrl,
    required String title,
    required String channelId,
    required bool isFavourite,
    required EntityUser user,
    required List<EntityChannel> channels,
    required List<EntityFavChannel> favChannels,
  }) {
    Map<DashboardPage, dynamic> newPageData = {...state.pageData}..addAll(
        {
          DashboardPage.video: {
            "videoUrl": videoUrl,
            "title": title,
            "channelId": channelId,
            "isFavourite": isFavourite,
            "user": user,
            "channels": channels,
            "favChannels": favChannels,
          },
        },
      );

    emit(
      state.copyWith(
        page: DashboardPage.video,
        pageData: newPageData,
      ),
    );
  }

  void openRadioPage(EntityRadioStation radioStation) {
    Map<DashboardPage, dynamic> newPageData = {...state.pageData}..addAll(
        {
          DashboardPage.radio: radioStation,
        },
      );

    emit(
      state.copyWith(
        page: DashboardPage.radio,
        pageData: newPageData,
      ),
    );
  }
}
