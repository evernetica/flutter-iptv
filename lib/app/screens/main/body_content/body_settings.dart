import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_iptv/app/dashboard/cubit/cubit_dashboard.dart';
import 'package:flutter_iptv/app/screens/main/cubit/cubit_main.dart';
import 'package:flutter_iptv/app/widgets/modal_dialog.dart';
import 'package:flutter_iptv/domain/entities/entity_user.dart';
import 'package:flutter_iptv/domain/providers/provider_api_interactions.dart';
import 'package:flutter_iptv/misc/app_colors.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class BodySettings extends StatefulWidget {
  const BodySettings({
    super.key,
    required this.user,
    required this.bloc,
  });

  final EntityUser user;
  final CubitMain bloc;

  @override
  State<BodySettings> createState() => _BodySettingsState();
}

class _BodySettingsState extends State<BodySettings> {
  String version = "-";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      version = (await PackageInfo.fromPlatform()).version;

      setState(() {});
    });
  }

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
              title:
                  "${widget.user.isParentalControlActive == "1" ? "Dis" : "En"}"
                  "able the parental control",
              icon: Icons.wc,
              onTap: _toggleParentalControl,
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
              onTap: _deleteAccount,
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
              onTap: _messageToSupport,
            ),
            const SizedBox(height: 16.0),
            const FlutterLogo(size: 64.0),
            const SizedBox(height: 16.0),
            Center(
              child: Text(
                "version $version",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
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
    bool isFocused = false;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9999),
        clipBehavior: Clip.hardEdge,
        child: StatefulBuilder(builder: (context, setState) {
          return InkWell(
            onTap: onTap,
            onFocusChange: (focused) {
              setState(() {
                isFocused = focused;
              });
            },
            overlayColor:
                MaterialStateColor.resolveWith((_) => AppColors.fgMain),
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
                      child: Icon(
                        icon,
                        color: isFocused ? Colors.white : null,
                      ),
                    ),
                    Text(
                      title,
                      strutStyle: StrutStyle.disabled,
                      style: TextStyle(
                        color: isFocused ? Colors.white : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
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

  Future _toggleParentalControl() async {
    if (widget.user.isParentalControlActive == "0") {
      bool? result = await Provider.of<ProviderApiInteractions>(
        context,
        listen: false,
      ).setTrueToParentalControl(widget.user.code ?? "");

      if (result != true) return;

      widget.bloc.setUser(
        EntityUser(
          code: widget.user.code,
          deviceId: widget.user.deviceId,
          email: widget.user.email,
          fullName: widget.user.fullName,
          ip: widget.user.ip,
          registered: widget.user.registered,
          idSerial: widget.user.idSerial,
          purchase: widget.user.purchase,
          trialStartTime: widget.user.trialStartTime,
          trialFinishTime: widget.user.trialFinishTime,
          deviceId2: widget.user.deviceId2,
          deviceId3: widget.user.deviceId3,
          isParentalControlActive: "1",
          passParentalControl: widget.user.passParentalControl,
        ),
      );
      return;
    }

    TextEditingController controller = TextEditingController();

    BuildContext navContext = context;

    late ModalDialog dialog;
    dialog = ModalDialog.custom(
      titleText: "Disable the parental control",
      bodyText: "Put the password of the parental control to disable it",
      customBodyWidgets: [
        Material(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            onChanged: (_) {
              dialog.setWarning();
            },
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
            ),
          ),
        ),
      ],
      customButtons: [
        DialogAction.cancel(),
        DialogAction(
          label: "Confirm",
          shouldPop: false,
          callback: () async {
            if (controller.text.trim() != widget.user.passParentalControl) {
              dialog.setWarning(warning: "Wrong pass code!");
              return;
            }

            bool? result = await Provider.of<ProviderApiInteractions>(
              navContext,
              listen: false,
            ).setFalseToParentalControl(
              widget.user.code ?? "",
            );

            if (result != true) {
              dialog.setWarning(warning: "Something went wrong!");
            }

            if (context.mounted) {
              if (result == true) {
                widget.bloc.setUser(
                  EntityUser(
                    code: widget.user.code,
                    deviceId: widget.user.deviceId,
                    email: widget.user.email,
                    fullName: widget.user.fullName,
                    ip: widget.user.ip,
                    registered: widget.user.registered,
                    idSerial: widget.user.idSerial,
                    purchase: widget.user.purchase,
                    trialStartTime: widget.user.trialStartTime,
                    trialFinishTime: widget.user.trialFinishTime,
                    deviceId2: widget.user.deviceId2,
                    deviceId3: widget.user.deviceId3,
                    isParentalControlActive: "0",
                    passParentalControl: widget.user.passParentalControl,
                  ),
                );

                dialog.popWithValue(value: true);
              }
            }
          },
        ),
      ],
    );

    bool? result = await showDialog(
      context: context,
      builder: (context) {
        return dialog;
      },
    );

    if (result == true) {
      widget.bloc.setUser(
        EntityUser(
          code: widget.user.code,
          deviceId: widget.user.deviceId,
          email: widget.user.email,
          fullName: widget.user.fullName,
          ip: widget.user.ip,
          registered: widget.user.registered,
          idSerial: widget.user.idSerial,
          purchase: widget.user.purchase,
          trialStartTime: widget.user.trialStartTime,
          trialFinishTime: widget.user.trialFinishTime,
          deviceId2: widget.user.deviceId2,
          deviceId3: widget.user.deviceId3,
          isParentalControlActive: "0",
          passParentalControl: widget.user.passParentalControl,
        ),
      );
    }
  }

  Future _deleteAccount() async {
    bool? result = await showDialog(
      context: context,
      builder: (context) {
        return ModalDialog.custom(
          customBodyWidgets: [
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
                "if you click on yes, you will remove your account immediately "
                "from this application Giptv, and your information will "
                "removed, and you will can't log in again.",
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
            const SizedBox(height: 16.0),
          ],
          customButtons: [
            DialogAction.cancel(),
            DialogAction.yes(),
          ],
        );
      },
    );

    if (result == true) {
      if (!context.mounted) return;

      bool? isAccountRemoved = await Provider.of<ProviderApiInteractions>(
        context,
        listen: false,
      ).removeAccount(
        widget.user.code ?? "",
      );

      if (isAccountRemoved == true) {
        if (!context.mounted) return;

        BlocProvider.of<CubitDashboard>(context).openLoginPage();
      }
    }
  }

  Future _messageToSupport() async {
    TextEditingController controller = TextEditingController();
    String text = "";
    BuildContext navContext = context;

    bool? result = await showDialog(
      context: context,
      builder: (context) {
        return ModalDialog.custom(
          titleText: "Support",
          bodyText: "Send us your message or contact on G-ip.tv",
          customBodyWidgets: [
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
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                  ),
                ),
              ),
            ),
          ],
          customButtons: [
            DialogAction.cancel(),
            DialogAction(
              label: "Confirm",
              callback: () {
                print("confirm pressed");
                text = controller.text;
              },
              popReturn: true,
            ),
          ],
        );
      },
    );

    if (result == true) {
      if (!navContext.mounted) return;

      Provider.of<ProviderApiInteractions>(
        navContext,
        listen: false,
      ).sendSupport(
        widget.user.idSerial ?? "",
        text,
      );
    }
  }
}
