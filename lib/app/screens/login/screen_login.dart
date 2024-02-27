import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_ip_address/get_ip_address.dart';
import 'package:flutter_iptv/app/dashboard/cubit/cubit_dashboard.dart';
import 'package:flutter_iptv/app/screens/login/cubit/cubit_login.dart';
import 'package:flutter_iptv/app/screens/login/cubit/state_login.dart';
import 'package:flutter_iptv/app/screens/screen_base.dart';
import 'package:flutter_iptv/app/widgets/button_tv_compatible.dart';
import 'package:flutter_iptv/domain/entities/entity_user.dart';
import 'package:flutter_iptv/domain/providers/provider_api_interactions.dart';
import 'package:flutter_iptv/domain/providers/provider_local_storage.dart';
import 'package:flutter_iptv/domain/repo_response.dart';
import 'package:flutter_iptv/misc/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ScreenLogin extends StatelessWidget {
  const ScreenLogin({super.key});

  @override
  Widget build(BuildContext context) {
    Future ipAddress = IpAddress().getIpAddress();

    return BlocProvider(
      create: (_) => CubitLogin(),
      child: Builder(builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) async {
            CubitLogin bloc = BlocProvider.of<CubitLogin>(context);

            bool isBanned = await Provider.of<ProviderApiInteractions>(
              context,
              listen: false,
            ).checkBannedIp(await ipAddress);

            ServicesBinding.instance.keyboard.addHandler((key) {
              print("pressed: ${key.logicalKey}");
              return true;
            });

            if (isBanned) {
              bloc.goToBanStage();
            } else {
              bloc.goToMainStage();
            }

            //TODO: REMOVE!!!!!!!!!!!!!!
            /// TEMPORARY CODE!!!!

            RepoResponse<EntityUser> user = await Provider.of<ProviderApiInteractions>(
              context,
              listen: false,
            ).login("");

            if (context.mounted) {
              //TODO: is this right?
              //if (user.registered == "1") {
                BlocProvider.of<CubitDashboard>(
                  context,
                ).openMainPage(user.output!);
              //}
            }
          },
        );
        return BlocBuilder<CubitLogin, StateLogin>(
          builder: (context, state) {
            CubitLogin bloc = BlocProvider.of<CubitLogin>(context);

            switch (state.stage) {
              case LoginStage.initial:
                return const ScreenBase(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              case LoginStage.main:
                return _buildMainStage(context, bloc);
              case LoginStage.generateCode:
                return _buildGenerateCodeStage(context, bloc, ipAddress);
              case LoginStage.ban:
                return _buildBanStage(context);
            }
          },
        );
      }),
    );
  }

  Widget _buildMainColumn({
    required BuildContext context,
    required Widget child,
  }) {
    Size s = MediaQuery.of(context).size;

    return Center(
      child: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: min(s.height, s.width),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildMainStage(
    BuildContext context,
    CubitLogin bloc,
  ) {
    final FocusNode goButton = FocusNode();
    final TextEditingController controller = TextEditingController();

    return ScreenBase(
      child: _buildMainColumn(
        context: context,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: FlutterLogo(size: 128),
                ),
              ),
              const Text(
                "Welcome to Flutter IPTV application!"
                " You need an activation code :",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              _buildDefaultContainer(
                child: TextButton(
                  onPressed: bloc.goToGenerateCodeStage,
                  style: ButtonStyle(
                    padding: MaterialStateProperty.resolveWith(
                      (_) => const EdgeInsets.all(16.0),
                    ),
                  ),
                  child: const Text("Generate the access code"),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                "Access code :",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              _buildTextField(
                onSubmitted: (text) {
                  goButton.requestFocus();
                },
                keyboardType: TextInputType.number,
                controller: controller,
                hintText: "123XX",
              ),
              const SizedBox(height: 16.0),
              Center(
                child: _buildDefaultContainer(
                  child: ButtonTvCompatible(
                    focusNode: goButton,
                    callback: () async {
                      print(controller.text);

                      ProviderApiInteractions providerApi =
                          Provider.of<ProviderApiInteractions>(
                        context,
                        listen: false,
                      );

                      if (await providerApi.checkBannedIp(
                        await IpAddress().getIpAddress(),
                      )) {
                        bloc.goToBanStage();
                        return;
                      }

                      //TODO:
                      String deviceId = "";
                      String deviceType = "";

                      RepoResponse response = await providerApi.login(
                        controller.text,
                      );

                      //TODO: REMOVE!!!!!!!!!!!!!!
                      /// TEMPORARY CODE!!!!

                      EntityUser user =
                          (await Provider.of<ProviderApiInteractions>(
                        context,
                        listen: false,
                      ).login("11775"))
                              .output!;

                      Provider.of<ProviderApiInteractions>(
                        context,
                        listen: false,
                      ).getFavorites(user.idSerial!);

                      if (context.mounted) {
                        //TODO: is this right?
                        //if (user.registered == "1") {
                        BlocProvider.of<CubitDashboard>(
                          context,
                        ).openMainPage(user);
                        //}
                      }

                      if (response.isFailed) {
                        //TODO: handle failure

                        return;
                      }
                      return;

                      // EntityUser user = response.output;
                      //
                      // if (user.registered == "1") {
                      //   bool isDeviceCorrect = false;
                      //
                      //   if (deviceId != "" && deviceId != "null") {
                      //     switch (deviceType) {
                      //       case ("phone"):
                      //         isDeviceCorrect = true;
                      //       case ("tablet"):
                      //         if (user.deviceId3 == null ||
                      //             user.deviceId3 == deviceId) {
                      //           isDeviceCorrect = true;
                      //         }
                      //         break;
                      //       case ("tv"):
                      //         if (user.deviceId2 == null ||
                      //             user.deviceId2 == deviceId) {
                      //           isDeviceCorrect = true;
                      //         }
                      //         break;
                      //       default:
                      //         //TODO: warning on screen
                      //         // "Wrong device type!"
                      //         // " Allowed device types: [phone, tablet, tv]",
                      //         break;
                      //     }
                      //   }
                      //
                      //   if (!isDeviceCorrect) {
                      //     //TODO: warning on screen
                      //     //"This device not match with first device registered in database"
                      //     return;
                      //   }
                      //
                      //   await providerApi.updateDeviceId(
                      //     user.code!,
                      //     deviceId,
                      //     deviceType,
                      //   );
                      //   //TODO: add saving to shared prefs
                      //
                      //   print("context.mounted :: ${context.mounted}");
                      //   if (context.mounted) {
                      //     print("login");
                      //
                      //     BlocProvider.of<CubitDashboard>(
                      //       context,
                      //     ).openMainPage(user);
                      //   }
                      // } else {
                      //   await providerApi.updateDeviceId(
                      //     user.code!,
                      //     deviceId,
                      //     deviceType,
                      //   );
                      //
                      //   await providerApi.setRegisteredUser(
                      //     user.code!,
                      //     getTrialStartDate(),
                      //     getTrialEndDate(120),
                      //   );
                      //
                      //   print("context.mounted :: ${context.mounted}");
                      //   if (context.mounted) {
                      //     print("login");
                      //
                      //     ProviderLocalStorage providerStorage =
                      //         Provider.of<ProviderLocalStorage>(
                      //       context,
                      //       listen: false,
                      //     );
                      //
                      //     providerStorage.saveData({
                      //       "serial_key": user.code!,
                      //       "fullname": user.fullName!,
                      //       "email": user.email!,
                      //       "key": user.idSerial!,
                      //     });
                      //
                      //     BlocProvider.of<CubitDashboard>(
                      //       context,
                      //     ).openMainPage(user);
                      //   }
                      // }
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.resolveWith(
                        (_) => const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 32.0,
                        ),
                      ),
                    ),
                    child: const Text("Go"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenerateCodeStage(
    BuildContext context,
    CubitLogin bloc,
    Future ipAddress,
  ) {
    FocusNode backButton = FocusNode();
    FocusNode nameField = FocusNode();
    FocusNode emailField = FocusNode();
    FocusNode activateButton = FocusNode();

    TextEditingController emailController = TextEditingController();
    TextEditingController fullNameController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => backButton.requestFocus(),
    );

    return PopScope(
      canPop: false,
      onPopInvoked: (_) {
        bloc.goToMainStage();
      },
      child: ScreenBase(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0.0,
          leading: InkWell(
            focusNode: backButton,
            borderRadius: BorderRadius.circular(9999),
            onTap: () {
              Navigator.of(context).maybePop();
            },
            overlayColor: MaterialStateColor.resolveWith(
              (_) => Colors.white24,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
        child: _buildMainColumn(
          context: context,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16.0),
                const Text("Full name:"),
                _buildTextField(
                  hintText: "Your full name here",
                  focusNode: nameField,
                  controller: fullNameController,
                  onSubmitted: (_) => emailField.requestFocus(),
                ),
                const SizedBox(height: 16.0),
                const Text("Email:"),
                _buildTextField(
                  hintText: "Your email here",
                  focusNode: emailField,
                  controller: emailController,
                  onSubmitted: (_) => activateButton.requestFocus(),
                ),
                const SizedBox(height: 16.0),
                Center(
                  child: _buildDefaultContainer(
                    child: TextButton(
                      onPressed: () async {
                        //TODO: check name

                        //TODO: check email

                        String email = emailController.text;
                        String fullName = fullNameController.text;

                        bool isEmailTaken =
                            await Provider.of<ProviderApiInteractions>(
                          context,
                          listen: false,
                        ).checkRegisteredEmail(email);

                        if (isEmailTaken) {
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Center(
                                  child: Container(
                                    color: AppColors.bgMain,
                                    child: const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text("Email taken"),
                                    ),
                                  ),
                                );
                              },
                            );
                          }

                          return;
                        }

                        String deviceId = "";

                        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                        if (Platform.isIOS) {
                          IosDeviceInfo iosDeviceInfo =
                              await deviceInfo.iosInfo;
                          deviceId = iosDeviceInfo.identifierForVendor ?? "";
                        } else if (Platform.isAndroid) {
                          AndroidDeviceInfo androidDeviceInfo =
                              await deviceInfo.androidInfo;
                          deviceId = androidDeviceInfo.id;
                        }

                        if (!context.mounted) return;

                        String isRegistered =
                            await Provider.of<ProviderApiInteractions>(
                          context,
                          listen: false,
                        ).register(
                          email: email,
                          fullName: fullName,
                          deviceId: deviceId,
                          ip: await ipAddress,
                        );

                        if (context.mounted) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Center(
                                child: Container(
                                  color: AppColors.bgMain,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      "registered: $isRegistered",
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                      focusNode: activateButton,
                      style: ButtonStyle(
                        padding: MaterialStateProperty.resolveWith(
                          (_) => const EdgeInsets.symmetric(
                            vertical: 16.0,
                            horizontal: 32.0,
                          ),
                        ),
                      ),
                      child: const Text("Activate"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBanStage(BuildContext context) {
    return ScreenBase(
      child: _buildMainColumn(
        context: context,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset(
                    "assets/images/interdit.png",
                    width: 128.0,
                  ),
                ),
              ),
              const Text(
                "Unfortunately, you have ban,"
                " contact the administrator  www.G-ip.tv",
              ),
              const SizedBox(height: 8.0),
              const Text("Contact us\ninfo@g-ip.tv"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    FocusNode? focusNode,
    Function(String)? onSubmitted,
    TextEditingController? controller,
    TextInputType? keyboardType,
  }) {
    return _buildDefaultContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextField(
          textInputAction: TextInputAction.go,
          onSubmitted: onSubmitted,
          focusNode: focusNode,
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDefaultContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9999),
      ),
      clipBehavior: Clip.hardEdge,
      child: child,
    );
  }

  String getTrialStartDate() {
    DateTime now = DateTime.now();

    String strDate = DateFormat("yyyy/MM/dd HH:mm").format(now);
    return strDate;
  }

  String getTrialEndDate(int hours) {
    DateTime now = DateTime.now();
    now.add(Duration(hours: hours));

    String strDate = DateFormat("yyyy/MM/dd HH:mm").format(now);
    return strDate;
  }
}
