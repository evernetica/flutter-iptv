import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giptv_flutter/app/dashboard/cubit/cubit_dashboard.dart';
import 'package:giptv_flutter/app/dashboard/cubit/state_dashboard.dart';
import 'package:giptv_flutter/app/screens/login/screen_login.dart';
import 'package:giptv_flutter/app/screens/main/screen_main.dart';
import 'package:giptv_flutter/app/screens/radio/screen_radio.dart';
import 'package:giptv_flutter/app/screens/video/screen_video.dart';
import 'package:giptv_flutter/data/repositories_impl/impl_repository_giptv_api_interactions.dart';
import 'package:giptv_flutter/domain/providers/provider_api_interactions.dart';
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
                    repository: ImplRepositoryGiptvApiInteractions(),
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
              user: state.pageData[DashboardPage.main],
            ),
          ),
        ];
      case DashboardPage.video:
        return [
          MaterialPage(
            child: ScreenMain(
              user: state.pageData[DashboardPage.main],
            ),
          ),
          MaterialPage(
            child: ScreenVideo(
              videoUrl: state.pageData[DashboardPage.video]["videoUrl"],
              idSerial: state.pageData[DashboardPage.video]["idSerial"],
              title: state.pageData[DashboardPage.video]["title"],
              channelId: state.pageData[DashboardPage.video]["channelId"],
              isFavourite: state.pageData[DashboardPage.video]["isFavourite"],
            ),
          ),
        ];
      case DashboardPage.radio:
        return [
          MaterialPage(
            child: ScreenMain(
              user: state.pageData[DashboardPage.main],
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
