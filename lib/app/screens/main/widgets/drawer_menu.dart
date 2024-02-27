import 'package:flutter/material.dart';
import 'package:flutter_iptv/domain/entities/entity_user.dart';
import 'package:flutter_iptv/misc/app_colors.dart';

class MenuItem {
  MenuItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.callback,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final Function callback;
}

class DrawerMenu extends Drawer {
  const DrawerMenu({
    super.key,
    required this.menuItems,
    required this.user,
  });

  final List<MenuItem> menuItems;
  final EntityUser user;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const LinearBorder(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.bgMain,
                    AppColors.fgMain,
                  ],
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: AspectRatio(
                  aspectRatio: 3,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: FlutterLogo(
                      size: 96,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.bgMain,
                    AppColors.fgMain,
                  ],
                ),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 48.0,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${user.code} : ${user.fullName}"),
                      Text(
                        "${user.email}",
                        style: const TextStyle(
                          color: AppColors.bgMainLighter80,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ...List.generate(
              menuItems.length,
              (index) => Column(
                children: [
                  InkWell(
                    onTap: () {
                      Scaffold.of(context).closeDrawer();
                      menuItems[index].callback();
                    },
                    overlayColor: MaterialStateColor.resolveWith(
                      (_) => AppColors.bgMainLighter40,
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Icon(
                              menuItems[index].icon,
                              color: menuItems[index].isActive
                                  ? AppColors.fgMain
                                  : AppColors.bgMainLighter80,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            menuItems[index].label,
                            style: TextStyle(
                              color: menuItems[index].isActive
                                  ? Colors.white
                                  : AppColors.bgMainLighter80,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.bgMainLighter20,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
