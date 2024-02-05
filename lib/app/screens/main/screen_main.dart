import 'package:giptv_flutter/app/dashboard/cubit/cubit_dashboard.dart';
import 'package:giptv_flutter/app/screens/main/cubit/cubit_main.dart';
import 'package:giptv_flutter/app/screens/main/cubit/state_main.dart';
import 'package:giptv_flutter/app/screens/main/widgets/drawer_menu.dart';
import 'package:giptv_flutter/app/screens/screen_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giptv_flutter/domain/entities/entity_category.dart';
import 'package:giptv_flutter/domain/entities/entity_channel.dart';
import 'package:giptv_flutter/domain/entities/entity_fav_channel.dart';
import 'package:giptv_flutter/domain/entities/entity_radio_station.dart';
import 'package:giptv_flutter/domain/entities/entity_user.dart';
import 'package:giptv_flutter/domain/providers/provider_api_interactions.dart';
import 'package:giptv_flutter/misc/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ScreenMain extends StatelessWidget {
  const ScreenMain({
    super.key,
    required this.user,
  });

  final EntityUser user;

  @override
  Widget build(BuildContext context) {
    ProviderApiInteractions providerApi =
        Provider.of<ProviderApiInteractions>(context);

    return BlocProvider(
      create: (_) => CubitMain(),
      child: Builder(
        builder: (context) {
          CubitMain bloc = BlocProvider.of<CubitMain>(context);
          WidgetsBinding.instance.addPostFrameCallback(
            (_) async {
              await bloc.getCategories(providerApi);
              await bloc.getRadioStations(providerApi, user.code ?? "");
              await bloc.getFavorites(providerApi, user.idSerial ?? "");
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
                      user: user,
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
                          icon: Icons.settings,
                          label: 'Settings',
                          isActive: state.stage == StagesScreenMain.settings,
                          callback: bloc.goToSettingsStage,
                        ),
                        MenuItem(
                          icon: Icons.favorite,
                          label: 'Favorites',
                          isActive: state.stage == StagesScreenMain.favorites,
                          callback: () => bloc.goToFavoritesStage(
                            providerApi,
                            "${user.idSerial}",
                          ),
                        ),
                        MenuItem(
                          icon: Icons.info,
                          label: 'About',
                          isActive: state.stage == StagesScreenMain.about,
                          callback: bloc.goToAboutStage,
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
                                      return DemoChannelsWrap(
                                        categories: state.categories,
                                        channels: state.channels,
                                        categoryCallback: (catId) =>
                                            bloc.getChannels(
                                          providerApi,
                                          catId,
                                        ),
                                        favChannels: state.favorites,
                                        user: user,
                                        back: bloc.clearChannels,
                                      );
                                    case StagesScreenMain.radio:
                                      return DemoRadioWrap(
                                        radioStations: state.radioStations,
                                      );
                                    case StagesScreenMain.favorites:
                                      return DemoFavoritesWrap(
                                        favorites: state.favorites,
                                        user: user,
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
}

class DemoFavoritesWrap extends StatefulWidget {
  const DemoFavoritesWrap({
    super.key,
    required this.favorites,
    required this.user,
  });

  final List<EntityFavChannel> favorites;
  final EntityUser user;

  @override
  State<DemoFavoritesWrap> createState() => _DemoFavoritesWrapState();
}

class _DemoFavoritesWrapState extends State<DemoFavoritesWrap> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 16.0,
            runAlignment: WrapAlignment.spaceEvenly,
            runSpacing: 16.0,
            children: List.generate(
              widget.favorites.length,
              (i) => InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                overlayColor: MaterialStateColor.resolveWith(
                  (_) => AppColors.fgMain,
                ),
                onTap: () {
                  Provider.of<CubitDashboard>(
                    context,
                    listen: false,
                  ).openVideoPage(
                    videoUrl: widget.favorites[i].linkChannel,
                    idSerial: "${widget.user.idSerial}",
                    title: widget.favorites[i].titleChannel,
                    channelId: widget.favorites[i].channelId,
                    isFavourite: true,
                  );
                },
                child: SizedBox(
                  width: 120,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          //color: Colors.white12,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          border: Border.all(
                            color: AppColors.bgMainLighter20,
                          ),
                        ),
                        height: 90,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              'assets/images/radio_logo.png',
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: AspectRatio(
                          aspectRatio: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                widget.favorites[i].titleChannel,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.0,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DemoRadioWrap extends StatefulWidget {
  const DemoRadioWrap({
    super.key,
    required this.radioStations,
  });

  final List<EntityRadioStation> radioStations;

  @override
  State<DemoRadioWrap> createState() => _DemoRadioWrapState();
}

class _DemoRadioWrapState extends State<DemoRadioWrap> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 16.0,
            runAlignment: WrapAlignment.spaceEvenly,
            runSpacing: 16.0,
            children: List.generate(
              widget.radioStations.length,
              (i) => InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                overlayColor: MaterialStateColor.resolveWith(
                  (_) => AppColors.fgMain,
                ),
                onTap: () {
                  Provider.of<CubitDashboard>(
                    context,
                    listen: false,
                  ).openRadioPage(widget.radioStations[i]);
                },
                child: SizedBox(
                  width: 120,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          //color: Colors.white12,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          border: Border.all(
                            color: AppColors.bgMainLighter20,
                          ),
                        ),
                        height: 90,
                        child: Center(
                          child: Image.network(
                            widget.radioStations[i].radioImgLink,
                            width: 48,
                            height: 48,
                            errorBuilder: (_, __, ___) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                'assets/images/radio_logo.png',
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: AspectRatio(
                          aspectRatio: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                widget.radioStations[i].radioName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.0,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//TODO: refactor
class DemoChannelsWrap extends StatefulWidget {
  const DemoChannelsWrap({
    super.key,
    required this.categories,
    required this.channels,
    required this.favChannels,
    required this.user,
    required this.categoryCallback,
    required this.back,
  });

  final List<EntityCategory> categories;
  final List<EntityChannel> channels;
  final List<EntityFavChannel> favChannels;
  final EntityUser user;
  final Function(String) categoryCallback;
  final Function() back;

  @override
  State<DemoChannelsWrap> createState() => _DemoChannelsWrapState();
}

class _DemoChannelsWrapState extends State<DemoChannelsWrap> {
  FocusNode backButtonFocus = FocusNode();
  bool backButtonPressed = false;
  bool isLoadingChannels = false;

  @override
  Widget build(BuildContext context) {
    if (isLoadingChannels) {
      return SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              scrolledUnderElevation: 0.0,
              leading: StatefulBuilder(
                builder: (context, setState) {
                  return InkWell(
                    focusNode: backButtonFocus,
                    borderRadius: BorderRadius.circular(9999),
                    onTap: widget.back,
                    onTapDown: (_) {
                      setState(() {
                        backButtonPressed = true;
                      });
                    },
                    onTapUp: (_) {
                      setState(() {
                        backButtonPressed = false;
                      });
                    },
                    overlayColor: MaterialStateColor.resolveWith(
                      (_) => Colors.white24,
                    ),
                    onFocusChange: (_) => setState(() {}),
                    child: Icon(
                      Icons.arrow_back,
                      color: backButtonFocus.hasFocus || backButtonPressed
                          ? AppColors.fgMain
                          : Colors.white,
                    ),
                  );
                },
              ),
            ),
            Shimmer(
              gradient: const LinearGradient(
                colors: [
                  Colors.white12,
                  Colors.white38,
                ],
              ),
              loop: 1,
              child: Wrap(
                alignment: WrapAlignment.start,
                spacing: 16.0,
                runAlignment: WrapAlignment.spaceEvenly,
                runSpacing: 16.0,
                children: List.filled(
                  48,
                  SizedBox(
                    width: 120,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          ),
                          height: 90,
                          child: const Center(
                            child: Icon(
                              Icons.live_tv_outlined,
                              size: 48.0,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                        Flexible(
                          child: AspectRatio(
                            aspectRatio: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Container(
                                  width: 100.0,
                                  height: 16.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white54,
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (widget.categories.isEmpty) {
      return const Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    if (widget.channels.isNotEmpty) {
      return SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              scrolledUnderElevation: 0.0,
              leading: StatefulBuilder(
                builder: (context, setState) {
                  return InkWell(
                    focusNode: backButtonFocus,
                    borderRadius: BorderRadius.circular(9999),
                    onTap: widget.back,
                    onTapDown: (_) {
                      setState(() {
                        backButtonPressed = true;
                      });
                    },
                    onTapUp: (_) {
                      setState(() {
                        backButtonPressed = false;
                      });
                    },
                    overlayColor: MaterialStateColor.resolveWith(
                      (_) => Colors.white24,
                    ),
                    onFocusChange: (_) => setState(() {}),
                    child: Icon(
                      Icons.arrow_back,
                      color: backButtonFocus.hasFocus || backButtonPressed
                          ? AppColors.fgMain
                          : Colors.white,
                    ),
                  );
                },
              ),
            ),
            Wrap(
              alignment: WrapAlignment.start,
              spacing: 16.0,
              runAlignment: WrapAlignment.spaceEvenly,
              runSpacing: 16.0,
              children: List.generate(
                widget.channels.length,
                (i) {
                  return InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    overlayColor: MaterialStateColor.resolveWith(
                      (_) => AppColors.fgMain,
                    ),
                    onTap: () {
                      Provider.of<CubitDashboard>(
                        context,
                        listen: false,
                      ).openVideoPage(
                        videoUrl: widget.channels[i].videoUrl,
                        idSerial: "${widget.user.idSerial}",
                        title: widget.channels[i].name,
                        channelId: "${widget.channels[i].epgChannelId}",
                        isFavourite: widget.favChannels.any(
                          (f) => f.linkChannel == widget.channels[i].videoUrl,
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 120,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              //color: Colors.white12,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              border: Border.all(
                                color: AppColors.bgMainLighter20,
                              ),
                            ),
                            height: 90,
                            child: Center(
                              child: Image.network(
                                widget.channels[i].streamIcon,
                                width: 48,
                                height: 48,
                                errorBuilder: (_, __, ___) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                    'assets/images/giptv_nobg.png',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            child: AspectRatio(
                              aspectRatio: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    widget.channels[i].name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10.0,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    if (widget.categories.isNotEmpty) {
      return ListView(
        children: List.generate(
          widget.categories.length,
          (i) => Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              overlayColor: MaterialStateColor.resolveWith(
                (_) => AppColors.fgMain,
              ),
              onTap: () async {
                setState(() {
                  isLoadingChannels = true;
                });

                await widget.categoryCallback(widget.categories[i].categoryId);

                setState(() {
                  isLoadingChannels = false;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  //color: Colors.white12,
                  border: Border.all(color: AppColors.bgMainLighter20),
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        widget.categories[i].categoryName,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container();
  }
}
