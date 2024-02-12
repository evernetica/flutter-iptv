import 'package:giptv_flutter/app/screens/main/cubit/cubit_main.dart';
import 'package:giptv_flutter/app/screens/main/cubit/state_main.dart';
import 'package:giptv_flutter/app/screens/main/body_content/body_activation.dart';
import 'package:giptv_flutter/app/screens/main/body_content/body_favorites.dart';
import 'package:giptv_flutter/app/screens/main/body_content/body_live_tv.dart';
import 'package:giptv_flutter/app/screens/main/body_content/body_radio.dart';
import 'package:giptv_flutter/app/screens/main/body_content/body_settings.dart';
import 'package:giptv_flutter/app/screens/main/widgets/drawer_menu.dart';
import 'package:giptv_flutter/app/screens/screen_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giptv_flutter/domain/entities/entity_user.dart';
import 'package:giptv_flutter/domain/providers/provider_api_interactions.dart';
import 'package:giptv_flutter/misc/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ScreenMain extends StatelessWidget {
  const ScreenMain({
    super.key,
    required this.initialUser,
  });

  final EntityUser initialUser;

  @override
  Widget build(BuildContext context) {
    ProviderApiInteractions providerApi = Provider.of<ProviderApiInteractions>(
      context,
      listen: false,
    );

    return BlocProvider(
      create: (_) => CubitMain(),
      child: Builder(
        builder: (context) {
          CubitMain bloc = BlocProvider.of<CubitMain>(context);
          WidgetsBinding.instance.addPostFrameCallback(
            (_) async {
              bloc.setUser(initialUser);
              await bloc.getCategories(providerApi);
              await bloc.getWebsite(providerApi);
              await bloc.getRadioStations(providerApi, initialUser.code ?? "");
              await bloc.getFavorites(providerApi, initialUser.idSerial ?? "");

              // await providerApi.getUser(user.code ?? "", user.fullName ?? "");
            },
          );
          return PopScope(
            canPop: false,
            onPopInvoked: (_) {
              bloc.clearChannels();
            },
            child: BlocBuilder<CubitMain, StateMain>(
              builder: (context, state) {
                return OrientationBuilder(
                  builder: (context, orientation) {
                    bool isDrawerClosable = orientation == Orientation.portrait;

                    if (!isDrawerClosable) {
                      if (MediaQuery.of(context).size.width < 800) {
                        isDrawerClosable = true;
                      }
                    }

                    Drawer drawer = DrawerMenu(
                      user: state.user,
                      menuItems: [
                        MenuItem(
                          icon: Icons.live_tv_outlined,
                          label: 'Live TV',
                          isActive: state.stage == StagesScreenMain.liveTv,
                          callback: () => bloc.goToLiveTvStage(providerApi),
                        ),
                        MenuItem(
                          icon: Icons.radio,
                          label: 'Radio',
                          isActive: state.stage == StagesScreenMain.radio,
                          callback: bloc.goToRadioStage,
                        ),
                        MenuItem(
                          icon: Icons.favorite,
                          label: 'Favorites',
                          isActive: state.stage == StagesScreenMain.favorites,
                          callback: () => bloc.goToFavoritesStage(
                            providerApi,
                            "${state.user.idSerial}",
                          ),
                        ),
                        MenuItem(
                          icon: Icons.settings,
                          label: 'Settings',
                          isActive: state.stage == StagesScreenMain.settings,
                          callback: bloc.goToSettingsStage,
                        ),
                        MenuItem(
                          icon: Icons.diamond,
                          label: 'Activation',
                          isActive: state.stage == StagesScreenMain.activation,
                          callback: bloc.goToActivationStage,
                        ),
                        if (state.websiteUrl.visible == "1")
                          MenuItem(
                            icon: Icons.public,
                            label: state.websiteUrl.content,
                            isActive: false,
                            callback: () {
                              launchUrl(Uri.parse(state.websiteUrl.name));
                            },
                          ),
                      ],
                    );

                    return ScreenBase(
                      appBar: isDrawerClosable
                          ? AppBar(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              scrolledUnderElevation: 0.0,
                              iconTheme: const IconThemeData(
                                color: AppColors.fgMain,
                              ),
                              title: Text(
                                _getTitle(state.stage),
                                style: const TextStyle(
                                  color: AppColors.bgMainLighter80,
                                ),
                              ),
                              centerTitle: true,
                              leading: state.channels.isNotEmpty ||
                                      state.showBackButton
                                  ? Material(
                                      color: Colors.transparent,
                                      shape: const CircleBorder(),
                                      clipBehavior: Clip.hardEdge,
                                      child: InkWell(
                                        onTap: () {
                                          bloc.goToLiveTvStage(providerApi);
                                        },
                                        overlayColor:
                                            MaterialStateColor.resolveWith(
                                          (_) => Colors.white24,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(9999),
                                        child: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.arrow_back,
                                            color: Colors.white,
                                            size: 32.0,
                                          ),
                                        ),
                                      ),
                                    )
                                  : null,
                            )
                          : null,
                      drawer: isDrawerClosable ? drawer : null,
                      child: Row(
                        children: [
                          if (!isDrawerClosable) drawer,
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Builder(
                                builder: (context) {
                                  switch (state.stage) {
                                    case StagesScreenMain.liveTv:
                                      return BodyLiveTv(
                                        categories: state.categories,
                                        channels: state.channels,
                                        categoryCallback: (catId) =>
                                            bloc.getChannels(
                                          providerApi,
                                          catId,
                                        ),
                                        favChannels: state.favorites,
                                        user: state.user,
                                        back: bloc.clearChannels,
                                        bloc: bloc,
                                      );
                                    case StagesScreenMain.radio:
                                      return BodyRadio(
                                        radioStations: state.radioStations,
                                      );
                                    case StagesScreenMain.favorites:
                                      return BodyFavorites(
                                        favorites: state.favorites,
                                        user: state.user,
                                      );
                                    case StagesScreenMain.activation:
                                      return BodyActivation(
                                        user: state.user,
                                      );
                                    case StagesScreenMain.settings:
                                      return BodySettings(
                                        user: state.user,
                                        bloc: bloc,
                                      );
                                    default:
                                      return const Center(
                                        child: Icon(
                                          Icons.live_tv_outlined,
                                          color: AppColors.bgMainLighter20,
                                          size: 128.0,
                                        ),
                                      );
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _getTitle(StagesScreenMain stage) {
    switch (stage) {
      case StagesScreenMain.liveTv:
        return "Live TV";
      case StagesScreenMain.radio:
        return "Radio";
      case StagesScreenMain.settings:
        return "Settings";
      case StagesScreenMain.favorites:
        return "Favorites";
      case StagesScreenMain.activation:
        return "Activation";
    }
  }
}
