import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_iptv/app/dashboard/cubit/cubit_dashboard.dart';
import 'package:flutter_iptv/app/dashboard/cubit/state_dashboard.dart';
import 'package:flutter_iptv/app/screens/login/screen_login.dart';
import 'package:flutter_iptv/app/screens/main/screen_main.dart';
import 'package:flutter_iptv/app/screens/radio/screen_radio.dart';
import 'package:flutter_iptv/app/screens/video/screen_video.dart';
import 'package:flutter_iptv/data/repositories_impl/impl_repository_mockdata_api_interactions.dart';
import 'package:flutter_iptv/data/repositories_impl/impl_repository_shared_prefs_local_storage.dart';
import 'package:flutter_iptv/domain/providers/provider_api_interactions.dart';
import 'package:flutter_iptv/domain/providers/provider_local_storage.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

    return BlocProvider(
      create: (_) => CubitDashboard(),
      child: BlocBuilder<CubitDashboard, StateDashboard>(
        builder: (context, state) {
          CubitDashboard bloc = BlocProvider.of<CubitDashboard>(context);

          return SafeArea(
            child: MultiProvider(
              providers: [
                Provider<ProviderApiInteractions>(
                  create: (_) => ProviderApiInteractions(
                    repository: ImplRepositoryMockDataApiInteractions(),
                  ),
                ),
                Provider<ProviderLocalStorage>(
                  create: (_) => ProviderLocalStorage(
                    repository: ImplRepositorySharedPrefsLocalStorage(),
                  ),
                ),
                Provider<CubitDashboard>(
                  create: (_) => bloc,
                ),
              ],
              child: Scaffold(
                body: PopScope(
                  canPop: false,
                  onPopInvoked: (_) {
                    navigatorKey.currentState?.maybePop();
                  },
                  child: Navigator(
                    key: navigatorKey,
                    pages: _pagesFromState(state),
                    onPopPage: (_, __) {
                      switch (state.page) {
                        case DashboardPage.video:
                          bloc.openMainPage(state.pageData[DashboardPage.main]);
                          break;
                        case DashboardPage.radio:
                          bloc.openMainPage(state.pageData[DashboardPage.main]);
                          break;
                        default:
                          break;
                      }

                      return false;
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<MaterialPage> _pagesFromState(StateDashboard state) {
    switch (state.page) {
      case DashboardPage.login:
        return [
          const MaterialPage(child: ScreenLogin()),
        ];
      case DashboardPage.main:
        return [
          MaterialPage(
            child: ScreenMain(
              initialUser: state.pageData[DashboardPage.main],
            ),
          ),
        ];
      case DashboardPage.video:
        return [
          MaterialPage(
            child: ScreenMain(
              initialUser: state.pageData[DashboardPage.main],
            ),
          ),
          MaterialPage(
            child: ScreenVideo(
              videoUrl: state.pageData[DashboardPage.video]["videoUrl"],
              title: state.pageData[DashboardPage.video]["title"],
              channelId: state.pageData[DashboardPage.video]["channelId"],
              isFavourite: state.pageData[DashboardPage.video]["isFavourite"],
              user: state.pageData[DashboardPage.video]["user"],
              channels: state.pageData[DashboardPage.video]["channels"],
              favChannels: state.pageData[DashboardPage.video]["favChannels"],
            ),
          ),
        ];
      case DashboardPage.radio:
        return [
          MaterialPage(
            child: ScreenMain(
              initialUser: state.pageData[DashboardPage.main],
            ),
          ),
          MaterialPage(
            child: ScreenRadio(
              radioStation: state.pageData[DashboardPage.radio],
            ),
          ),
        ];
    }
  }
}
