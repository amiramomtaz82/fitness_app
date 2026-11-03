import 'package:fitness_app/core/theme/context.extension.dart';
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

    if (value == null) return ColoredBox(color: context.colors.card);

    return Image(
      image: _provider(value),
      fit: fit,
      errorBuilder: (_, _, _) => ColoredBox(color: context.colors.card),
    );
  }

  ImageProvider _provider(String value) {
    return value.startsWith('assets/')
        ? AssetImage(value)
        : NetworkImage(value);
  }
}
