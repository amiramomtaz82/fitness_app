import 'package:flutter/material.dart';
import 'package:fitness_app/core/contants/app_assets.dart';

class AvatarPlaceholder extends StatelessWidget {
  const AvatarPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(AppAssets.person, fit: BoxFit.cover);
  }
}
