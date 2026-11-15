import 'package:flutter/material.dart';

class AvatarRemotePhoto extends StatelessWidget {
  final String url;
  final Widget fallback;

  const AvatarRemotePhoto({
    super.key,
    required this.url,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}
