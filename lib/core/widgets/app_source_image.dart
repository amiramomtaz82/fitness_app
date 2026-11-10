import 'package:fitness_app/core/widgets/app_image_placeholder.dart';
import 'package:flutter/material.dart';

class AppSourceImage extends StatelessWidget {
  final String? source;
  final BoxFit fit;

  const AppSourceImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final value = source;

    if (value == null) return const AppImagePlaceholder();

    return Image(
      image: value.startsWith('assets/')
          ? AssetImage(value)
          : NetworkImage(value),
      fit: fit,
      errorBuilder: (_, _, _) => const AppImagePlaceholder(),
    );
  }
}
