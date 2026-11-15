import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:fitness_app/core/contants/web_pages.dart';
import 'profile_menu_action.dart';
import 'profile_menu_trailing.dart';

class ProfileMenuItem extends Equatable {
  final IconData icon;
  final ProfileMenuAction action;
  final ProfileMenuTrailing trailing;
  final WebPage? page;
  final bool isDestructive;

  const ProfileMenuItem({
    required this.icon,
    required this.action,
    this.trailing = ProfileMenuTrailing.chevron,
    this.page,
    this.isDestructive = false,
  });

  @override
  List<Object?> get props => [icon, action, trailing, page, isDestructive];
}

const List<ProfileMenuItem> profileMenuItems = [
  ProfileMenuItem(
    icon: Icons.person_outline,
    action: ProfileMenuAction.editProfile,
  ),
  ProfileMenuItem(
    icon: Icons.lock_outline,
    action: ProfileMenuAction.changePassword,
  ),
  ProfileMenuItem(
    icon: Icons.language,
    action: ProfileMenuAction.selectLanguage,
    trailing: ProfileMenuTrailing.languageSwitch,
  ),
  ProfileMenuItem(
    icon: Icons.settings_outlined,
    action: ProfileMenuAction.security,
    page: WebPage.security,
  ),
  ProfileMenuItem(
    icon: Icons.privacy_tip_outlined,
    action: ProfileMenuAction.privacyPolicy,
    page: WebPage.privacyPolicy,
  ),
  ProfileMenuItem(
    icon: Icons.help_outline,
    action: ProfileMenuAction.help,
    page: WebPage.help,
  ),
  ProfileMenuItem(
    icon: Icons.logout,
    action: ProfileMenuAction.logout,
    isDestructive: true,
  ),
];
