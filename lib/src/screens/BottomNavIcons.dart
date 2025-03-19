import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:senzepact/src/screens/volunteering/Events.dart';
import 'package:senzepact/src/screens/Health/Health.dart';
import 'package:senzepact/src/screens/Settings/Settings.dart';
import 'Responsive/FormFactor.dart';
import 'Home/Home.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Volunteering/Volunteering.dart';

class BottomNavIcons extends StatefulWidget {
  const BottomNavIcons({Key? key}) : super(key: key);

  @override
  State<BottomNavIcons> createState() => _BottomNavIconsState();
}

class _BottomNavIconsState extends State<BottomNavIcons> {
  late PersistentTabController _controller;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller = PersistentTabController();
  }

  List<Widget> _buildScreens() => [
        const HomePage(),
        // const EventsPage(),
        // const VolunteeringAlertsPage(),
        const VolunteeringPage(),
        const HealthPage(),
        const SettingsPage(),
      ];

  List<PersistentBottomNavBarItem> _navBarsItems() => [
        PersistentBottomNavBarItem(
            icon: const Icon(Icons.home),
            title: "HOME".tr(),
            activeColorPrimary: Colors.blue,
            inactiveColorPrimary: Colors.grey),
        // PersistentBottomNavBarItem(
        //   icon: const Icon(Icons.calendar_month),
        //   title: "EVENTS".tr(),
        //   activeColorPrimary: Colors.blue,
        //   inactiveColorPrimary: Colors.grey,
        // ),
        // PersistentBottomNavBarItem(
        //   icon: const Icon(Icons.doorbell),
        //   title: "ALERTS".tr(),
        //   activeColorPrimary: Colors.blue,
        //   inactiveColorPrimary: Colors.grey,
        // ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.handshake),
          title: "Volunteering".tr(),
          activeColorPrimary: Colors.blue,
          inactiveColorPrimary: Colors.grey,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.health_and_safety),
          title: "Health".tr(),
          activeColorPrimary: Colors.blue,
          inactiveColorPrimary: Colors.grey,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.settings),
          title: "SETTINGS".tr(),
          activeColorPrimary: Colors.blue,
          inactiveColorPrimary: Colors.grey,
        ),
      ];

  Future<void> launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.shortestSide;

    return Scaffold(
      body: deviceWidth > FormFactor.desktop
          ? Row(
              children: [
                NavigationRail(
                    selectedIndex: _selectedIndex,
                    destinations: _buildDestinations(),
                    onDestinationSelected: (int index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    labelType: NavigationRailLabelType.all),
                if (_selectedIndex == 0)
                  const Expanded(
                    child: Center(child: HomePage()),
                  ),
                // if (_selectedIndex == 1)
                //   const Expanded(
                //     child: Center(child: EventsPage()),
                //   ),
                if (_selectedIndex == 1)
                  const Expanded(
                    child: Center(child: VolunteeringPage()),
                  ),
                if (_selectedIndex == 2)
                  const Expanded(
                    child: Center(child: HealthPage()),
                  ),
                if (_selectedIndex == 3)
                  const Expanded(
                    child: Center(child: SettingsPage()),
                  ),
              ],
            )
          : Center(
              child: PersistentTabView(
                context,
                controller: _controller,
                screens: _buildScreens(),
                items: _navBarsItems(),
                // resizeToAvoidBottomInset: true,
                navBarHeight: MediaQuery.of(context).viewInsets.bottom > 0
                    ? 0.0
                    : kBottomNavigationBarHeight,
                bottomScreenMargin: 0,
                backgroundColor: Colors.white,
                hideNavigationBar: false,
                  popAllScreensOnTapAnyTabs:true,
                decoration:
                    const NavBarDecoration(colorBehindNavBar: Colors.blue),
                itemAnimationProperties: const ItemAnimationProperties(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.ease,
                ),
                screenTransitionAnimation: const ScreenTransitionAnimation(
                  animateTabTransition: true,
                ),
                navBarStyle: NavBarStyle
                    .style6, // Choose the nav bar style with this property
              ),
            ),
    );
  }

  List<NavigationRailDestination> _buildDestinations() {
    return [
      NavigationRailDestination(
        icon: const Icon(Icons.home),
        label: Text("HOME".tr()),
      ),
      // NavigationRailDestination(
      //   icon: const Icon(Icons.calendar_month),
      //   label: Text("EVENTS".tr()),
      // ),
      NavigationRailDestination(
        icon: const Icon(Icons.handshake),
        label: Text("Volunteering".tr()),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.health_and_safety),
        label: Text("Health".tr()),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.settings),
        label: Text("SETTINGS".tr()),
      ),
    ];
  }
}
