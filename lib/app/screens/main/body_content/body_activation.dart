import 'package:flutter/material.dart';
import 'package:giptv_flutter/domain/entities/entity_user.dart';
import 'package:url_launcher/url_launcher.dart';

class BodyActivation extends StatelessWidget {
  const BodyActivation({super.key, required this.user});

  final EntityUser user;

  @override
  Widget build(BuildContext context) {
    bool isActivated = user.registered == "1";

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        GestureDetector(
          onTap: () {
            launchUrl(Uri.parse("https://www.giptv.ro"));
          },
          child: Image.asset(
            "assets/images/qc1.png",
            width: 128.0,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            isActivated ? "Activated" : "Activation",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          isActivated
              ? "Application is now activated"
              : "Welcome to the Giptv application!\nScan or click the code for "
                  "activation, or access the website www.giptv.ro",
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
