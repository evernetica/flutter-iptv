import 'package:flutter_cache_manager/flutter_cache_manager.dart';
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
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class ScreenMain extends StatelessWidget {
  const ScreenMain({
    super.key,
    required this.user,
  });

  final EntityUser user;

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
              bloc.setUser(user);
              await bloc.getCategories(providerApi);
              await bloc.getWebsite(providerApi);
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
                        if (state.websiteUrl.visible == "1")
                          MenuItem(
                            icon: Icons.public,
                            label: state.websiteUrl.content,
                            isActive: state.stage == StagesScreenMain.about,
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
                                        user: state.user,
                                        back: bloc.clearChannels,
                                      );
                                    case StagesScreenMain.radio:
                                      return DemoRadioWrap(
                                        radioStations: state.radioStations,
                                      );
                                    case StagesScreenMain.favorites:
                                      return DemoFavoritesWrap(
                                        favorites: state.favorites,
                                        user: state.user,
                                      );
                                    case StagesScreenMain.settings:
                                      return DemoSettingsList(
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

class DemoSettingsList extends StatelessWidget {
  const DemoSettingsList({
    super.key,
    required this.user,
    required this.bloc,
  });

  final EntityUser user;
  final CubitMain bloc;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGroupTitle(
              label: "Application",
              icon: Icons.android,
            ),
            _settingsButton(
              title: "${user.isParentalControlActive == "1" ? "Dis" : "En"}"
                  "able the parental control",
              icon: Icons.wc,
              onTap: () async {
                if (user.isParentalControlActive == "0") {
                  bool? result = await Provider.of<ProviderApiInteractions>(
                    context,
                    listen: false,
                  ).setTrueToParentalControl(user.code ?? "");

                  if (result != true) return;

                  bloc.setUser(
                    EntityUser(
                      code: user.code,
                      deviceId: user.deviceId,
                      email: user.email,
                      fullName: user.fullName,
                      ip: user.ip,
                      registered: user.registered,
                      idSerial: user.idSerial,
                      purchase: user.purchase,
                      trialStartTime: user.trialStartTime,
                      trialFinishTime: user.trialFinishTime,
                      deviceId2: user.deviceId2,
                      deviceId3: user.deviceId3,
                      isParentalControlActive: "1",
                      passParentalControl: user.passParentalControl,
                    ),
                  );
                  return;
                }

                String warning = "";
                TextEditingController controller = TextEditingController();

                BuildContext navContext = context;

                bool? result = await showDialog(
                  context: context,
                  builder: (context) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pop(false);
                      },
                      child: SafeArea(
                        child: Scaffold(
                          backgroundColor: Colors.transparent,
                          body: StatefulBuilder(
                            builder: (context, setState) {
                              return DefaultTextStyle(
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                                child: Center(
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "Disable the parental control",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 16.0),
                                              const Text(
                                                "Put the password of the parental control"
                                                " to disable it",
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 8.0),
                                              Text(
                                                warning,
                                                style: const TextStyle(
                                                    color: Colors.red),
                                              ),
                                              const SizedBox(height: 8.0),
                                              ConstrainedBox(
                                                constraints:
                                                    const BoxConstraints(
                                                  minWidth: 200.0,
                                                  maxWidth: 200.0,
                                                ),
                                                child: Material(
                                                  child: TextField(
                                                    controller: controller,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    textAlign: TextAlign.center,
                                                    onChanged: (text) {
                                                      if (warning.isNotEmpty) {
                                                        setState(() {
                                                          warning = "";
                                                        });
                                                      }
                                                    },
                                                    decoration:
                                                        const InputDecoration(
                                                      border:
                                                          UnderlineInputBorder(),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 16.0),
                                              Theme(
                                                data: ThemeData(
                                                  elevatedButtonTheme:
                                                      ElevatedButtonThemeData(
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateColor
                                                              .resolveWith(
                                                        (_) => AppColors.fgMain,
                                                      ),
                                                      foregroundColor:
                                                          MaterialStateColor
                                                              .resolveWith(
                                                        (_) => Colors.white,
                                                      ),
                                                      overlayColor:
                                                          MaterialStateColor
                                                              .resolveWith(
                                                        (_) => Colors.white38,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(
                                                          context,
                                                          rootNavigator: true,
                                                        ).pop(false);
                                                      },
                                                      child:
                                                          const Text("Cancel"),
                                                    ),
                                                    const SizedBox(width: 16.0),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        print("pressed");

                                                        if (controller.text
                                                                .trim() !=
                                                            user.passParentalControl) {
                                                          setState(() {
                                                            warning =
                                                                "Wrong pass code!";
                                                          });
                                                          return;
                                                        }

                                                        bool? result =
                                                            await Provider.of<
                                                                ProviderApiInteractions>(
                                                          navContext,
                                                          listen: false,
                                                        ).setFalseToParentalControl(
                                                          user.code ?? "",
                                                        );

                                                        if (result != true) {
                                                          setState(() {
                                                            warning =
                                                                "Something went wrong!";
                                                          });
                                                        }

                                                        if (context.mounted) {
                                                          if (result == true) {
                                                            bloc.setUser(
                                                              EntityUser(
                                                                code: user.code,
                                                                deviceId: user
                                                                    .deviceId,
                                                                email:
                                                                    user.email,
                                                                fullName: user
                                                                    .fullName,
                                                                ip: user.ip,
                                                                registered: user
                                                                    .registered,
                                                                idSerial: user
                                                                    .idSerial,
                                                                purchase: user
                                                                    .purchase,
                                                                trialStartTime:
                                                                    user.trialStartTime,
                                                                trialFinishTime:
                                                                    user.trialFinishTime,
                                                                deviceId2: user
                                                                    .deviceId2,
                                                                deviceId3: user
                                                                    .deviceId3,
                                                                isParentalControlActive:
                                                                    "0",
                                                                passParentalControl:
                                                                    user.passParentalControl,
                                                              ),
                                                            );

                                                            Navigator.of(
                                                              context,
                                                              rootNavigator:
                                                                  true,
                                                            ).pop(true);
                                                          }
                                                        }
                                                      },
                                                      child:
                                                          const Text("Confirm"),
                                                    ),
                                                  ],
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
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
                print(result);
              },
            ),
            _settingsButton(
              title: "Rate Giptv",
              icon: Icons.star_half,
              onTap: () async {
                PackageInfo packageInfo = await PackageInfo.fromPlatform();

                launchUrl(
                  Uri.parse(
                    "market://details?id=${packageInfo.packageName}",
                  ),
                );
              },
            ),
            _settingsButton(
              title: "Share Giptv",
              icon: Icons.screen_share,
              onTap: () async {
                PackageInfo packageInfo = await PackageInfo.fromPlatform();

                Share.share(
                  "I invite to download this app to watch best TV Live Channels "
                  "(G-ip.tv) https://play.google.com/store/apps/details?id=${packageInfo.packageName}",
                );
              },
            ),
            _settingsButton(
              title: "Clear Cache",
              icon: Icons.delete_forever,
              onTap: () async {
                await DefaultCacheManager().emptyCache();
              },
            ),
            _settingsButton(
              title: "Logout",
              icon: Icons.power_settings_new,
              onTap: () {
                BlocProvider.of<CubitDashboard>(context).openLoginPage();
              },
            ),
            _settingsButton(
              title: "Delete Account",
              icon: Icons.sentiment_dissatisfied,
              onTap: () async {
                bool? result = await showDialog(
                  context: context,
                  builder: (context) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pop(false);
                      },
                      child: SafeArea(
                        child: Scaffold(
                          backgroundColor: Colors.transparent,
                          body: DefaultTextStyle(
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            child: Center(
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.sentiment_dissatisfied,
                                              ),
                                              SizedBox(width: 8.0),
                                              Text(
                                                "Alert",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16.0),
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxWidth: 300.0,
                                            ),
                                            child: const Text(
                                              "if you click on yes, you will remove your account immediately from this application Giptv, and your information will removed, and you will can't log in again.",
                                              textAlign: TextAlign.center,
                                              softWrap: true,
                                            ),
                                          ),
                                          const SizedBox(height: 16.0),
                                          Theme(
                                            data: ThemeData(
                                              elevatedButtonTheme:
                                                  ElevatedButtonThemeData(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateColor
                                                          .resolveWith(
                                                    (_) => AppColors.fgMain,
                                                  ),
                                                  foregroundColor:
                                                      MaterialStateColor
                                                          .resolveWith(
                                                    (_) => Colors.white,
                                                  ),
                                                  overlayColor:
                                                      MaterialStateColor
                                                          .resolveWith(
                                                    (_) => Colors.white38,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(
                                                      context,
                                                      rootNavigator: true,
                                                    ).pop(false);
                                                  },
                                                  child: const Text("Cancel"),
                                                ),
                                                const SizedBox(width: 16.0),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    print("pressed");
                                                    Navigator.of(
                                                      context,
                                                      rootNavigator: true,
                                                    ).pop(true);
                                                  },
                                                  child: const Text("Yes"),
                                                ),
                                              ],
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
                        ),
                      ),
                    );
                  },
                );

                if (result == true) {
                  if (!context.mounted) return;

                  bool? isAccountRemoved =
                      await Provider.of<ProviderApiInteractions>(
                    context,
                    listen: false,
                  ).removeAccount(
                    user.code ?? "",
                  );

                  if (isAccountRemoved == true) {
                    if (!context.mounted) return;

                    BlocProvider.of<CubitDashboard>(context).openLoginPage();
                  }
                }
              },
            ),
            _buildGroupTitle(
              label: "Legal",
              icon: Icons.folder_shared,
            ),
            _settingsButton(
              title: "Privacy Policy",
              icon: Icons.gavel,
              onTap: () async {
                String text = await DefaultAssetBundle.of(context).loadString(
                  'assets/text/Privacy Policy',
                );

                if (!context.mounted) return;
                showDialog(
                  context: context,
                  builder: (context) {
                    return Scaffold(
                      backgroundColor: Colors.white,
                      body: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          child: Text(
                            text,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            _buildGroupTitle(
              label: "Contact us",
              icon: Icons.contact_mail,
            ),
            _settingsButton(
              title: "Send a message to support",
              icon: Icons.send,
              onTap: () async {
                TextEditingController controller = TextEditingController();
                String text = "";
                BuildContext navContext = context;

                bool? result = await showDialog(
                  context: context,
                  builder: (context) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pop(false);
                      },
                      child: SafeArea(
                        child: Scaffold(
                          backgroundColor: Colors.transparent,
                          body: DefaultTextStyle(
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            child: Center(
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Support",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 16.0),
                                          const Text(
                                            "Send us your message or contact on G-ip.tv",
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 16.0),
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              minWidth: 200.0,
                                            ),
                                            child: Material(
                                              child: TextField(
                                                minLines: 10,
                                                maxLines: 50,
                                                controller: controller,
                                                textAlign: TextAlign.start,
                                                decoration:
                                                    const InputDecoration(
                                                  border:
                                                      UnderlineInputBorder(),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16.0),
                                          Theme(
                                            data: ThemeData(
                                              elevatedButtonTheme:
                                                  ElevatedButtonThemeData(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateColor
                                                          .resolveWith(
                                                    (_) => AppColors.fgMain,
                                                  ),
                                                  foregroundColor:
                                                      MaterialStateColor
                                                          .resolveWith(
                                                    (_) => Colors.white,
                                                  ),
                                                  overlayColor:
                                                      MaterialStateColor
                                                          .resolveWith(
                                                    (_) => Colors.white38,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(
                                                      context,
                                                      rootNavigator: true,
                                                    ).pop(false);
                                                  },
                                                  child: const Text("Cancel"),
                                                ),
                                                const SizedBox(width: 16.0),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    text = controller.text;

                                                    Navigator.of(
                                                      context,
                                                      rootNavigator: true,
                                                    ).pop(true);
                                                  },
                                                  child: const Text("Confirm"),
                                                ),
                                              ],
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
                        ),
                      ),
                    );
                  },
                );

                if (result == true) {
                  if (!navContext.mounted) return;

                  Provider.of<ProviderApiInteractions>(
                    navContext,
                    listen: false,
                  ).sendSupport(
                    user.idSerial ?? "",
                    text,
                  );
                }
              },
            ),
            const SizedBox(height: 16.0),
            Image.asset(
              'assets/images/giptv_nobg.png',
              width: 64.0,
              height: 64.0,
            ),
            const SizedBox(height: 16.0),
            const Center(
              child: Text(
                "version 1.0",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.bgMainLighter20,
                ),
              ),
            ),
            const Center(
              child: Text(
                "© Copyright 2023 NetGip Ltd . All rights Reserved.",
                style: TextStyle(
                  color: AppColors.bgMainLighter20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsButton({
    required String title,
    required IconData icon,
    required Function() onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9999),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onTap,
          child: DefaultTextStyle(
            style: const TextStyle(
              color: Colors.black,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(icon),
                  ),
                  Text(
                    title,
                    strutStyle: StrutStyle.disabled,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupTitle({
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.fgMain,
          ),
          const SizedBox(width: 8.0),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.fgMain,
            ),
          ),
        ],
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
