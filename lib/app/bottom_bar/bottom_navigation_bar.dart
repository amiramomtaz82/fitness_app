import 'package:fitness_app/app/bottom_bar/bottom_item.dart';
import 'package:fitness_app/app/bottom_bar/floating_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppBottomNavigationBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final selectedTab = branchTabIndexes[navigationShell.currentIndex];

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: FloatingBottomBar(
        items: items,
        selectedIndex: selectedTab,
        onTap: (tab) {
          final pushRoute = items[tab].pushRoute;
          if (pushRoute != null) {
            context.push(pushRoute);
            return;
          }
          navigationShell.goBranch(
            branchTabIndexes.indexOf(tab),
            initialLocation: tab == selectedTab,
          );
        },
      ),
    );
  }
}
