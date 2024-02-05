import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giptv_flutter/app/dashboard/cubit/state_dashboard.dart';
import 'package:giptv_flutter/domain/entities/entity_radio_station.dart';
import 'package:giptv_flutter/domain/entities/entity_user.dart';

class CubitDashboard extends Cubit<StateDashboard> {
  CubitDashboard() : super(const StateDashboard());

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
    required String idSerial,
    required String title,
    required String channelId,
    required bool isFavourite,
  }) {
    Map<DashboardPage, dynamic> newPageData = {...state.pageData}..addAll(
        {
          DashboardPage.video: {
            "videoUrl": videoUrl,
            "idSerial": idSerial,
            "title": title,
            "channelId": channelId,
            "isFavourite": isFavourite,
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
