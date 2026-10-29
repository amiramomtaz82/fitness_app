import 'package:fitness_app/app/bottom_bar/bottom_item.dart';
import 'package:fitness_app/app/bottom_bar/floating_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppBottomNavigationBar({super.key, required this.navigationShell});
  @override
  Widget build(BuildContext context) {
    final selectedIndex = navigationShell.currentIndex;

    return Scaffold(
      extendBody: true, // <-- Allows the background image to flow behind the floating bar
      body: navigationShell,
      bottomNavigationBar: FloatingBottomBar(
        items: items,
        selectedIndex: selectedIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == selectedIndex,
          );
        },
      ),
    );
  }
}
