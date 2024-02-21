import 'dart:async';

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
import 'package:giptv_flutter/app/widgets/inkwell_button.dart';
import 'package:giptv_flutter/domain/entities/entity_user.dart';
import 'package:giptv_flutter/domain/providers/provider_api_interactions.dart';
import 'package:giptv_flutter/misc/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ScreenMain extends StatelessWidget {
  ScreenMain({
    super.key,
    required this.initialUser,
  });

  final EntityUser initialUser;
  final StreamController<String> searchController =
      StreamController.broadcast();
  final TextEditingController searchFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ProviderApiInteractions providerApi = Provider.of<ProviderApiInteractions>(
      context,
      listen: false,
    );

    searchFieldController.addListener(() {
      searchController.add(searchFieldController.text);
    });

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
                if (!state.showSearchField) searchFieldController.text = "";

                return OrientationBuilder(
                  builder: (context, orientation) {
                    bool isDrawerClosable = orientation == Orientation.portrait;
                    bool isSearchBarRequired = [
                      StagesScreenMain.liveTv,
                      StagesScreenMain.radio,
                      StagesScreenMain.favorites,
                    ].contains(state.stage);

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
                          ? _buildAppBar(
                              bloc,
                              state,
                            )
                          : null,
                      drawer: isDrawerClosable ? drawer : null,
                      child: Row(
                        children: [
                          if (!isDrawerClosable) drawer,
                          Expanded(
                            flex: 3,
                            child: Builder(
                              builder: (context) {
                                if (isSearchBarRequired && !isDrawerClosable) {
                                  return Column(
                                    children: [
                                      _buildAppBar(bloc, state),
                                      Expanded(
                                        child: _buildBody(
                                          bloc,
                                          state,
                                          providerApi,
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                return _buildBody(bloc, state, providerApi);
                              },
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

  AppBar _buildAppBar(CubitMain bloc, StateMain state) {
    return AppBar(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      scrolledUnderElevation: 0.0,
      iconTheme: const IconThemeData(
        color: AppColors.fgMain,
      ),
      centerTitle: true,
      title: state.showSearchField
          ? Material(
              color: Colors.white,
              child: TextField(
                controller: searchFieldController,
              ),
            )
          : Text(
              _getTitle(state.stage),
              style: const TextStyle(
                color: AppColors.bgMainLighter80,
              ),
            ),
      leading: state.channels.isNotEmpty || state.showBackButton
          ? InkWellButton(
              backgroundColor: Colors.transparent,
              onTap: bloc.clearChannels,
              icon: Icons.arrow_back,
            )
          : null,
      actions: [
        InkWellButton(
          onTap: () {
            searchFieldController.text = "";

            bloc.setSearchFieldVisibility(
              !state.showSearchField,
            );
          },
          icon: Icons.search,
        ),
      ],
    );
  }

  Widget _buildBody(
    CubitMain bloc,
    StateMain state,
    ProviderApiInteractions providerApi,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
      child: Builder(
        builder: (context) {
          switch (state.stage) {
            case StagesScreenMain.liveTv:
              return BodyLiveTv(
                searchController: searchController,
                initialSearchQuery:
                    state.showSearchField ? searchFieldController.text : "",
                categories: state.categories,
                channels: state.channels,
                categoryCallback: (catId) => bloc.getChannels(
                  providerApi,
                  catId,
                  state.categories
                      .firstWhere(
                        (c) => c.categoryId == catId,
                      )
                      .categoryName,
                ),
                favChannels: state.favorites,
                user: state.user,
                back: bloc.clearChannels,
                bloc: bloc,
              );
            case StagesScreenMain.radio:
              return BodyRadio(
                searchController: searchController,
                initialSearchQuery:
                    state.showSearchField ? searchFieldController.text : "",
                radioStations: state.radioStations,
              );
            case StagesScreenMain.favorites:
              return BodyFavorites(
                searchController: searchController,
                initialSearchQuery:
                    state.showSearchField ? searchFieldController.text : "",
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
