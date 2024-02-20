import 'package:flutter/services.dart';
import 'package:giptv_flutter/app/dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:giptv_flutter/misc/app_colors.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: AppColors.fgMain,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Colors.white,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: InputBorder.none,
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateColor.resolveWith(
              (_) => Colors.black,
            ),
            overlayColor: MaterialStateColor.resolveWith(
              (_) => Colors.red,
            ),
          ),
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: AppColors.bgMain,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
          LogicalKeySet(LogicalKeyboardKey.goBack): const DismissIntent(),
        },
        child: const Dashboard(),
      ),
    );
  }
}
