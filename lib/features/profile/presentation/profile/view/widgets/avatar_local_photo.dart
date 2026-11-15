import 'dart:io';

import 'package:flutter/material.dart';

class AvatarLocalPhoto extends StatelessWidget {
  final String localPath;
  final Widget fallback;

  const AvatarLocalPhoto({
    super.key,
    required this.localPath,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(localPath),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}
