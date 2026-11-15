import 'package:flutter/material.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view/widgets/option_tile.dart';
import '../models/picker_option.dart';

class OptionPickerSheet extends StatelessWidget {
  final List<PickerOption> options;
  final String selectedValue;
  final ValueChanged<PickerOption> onSelected;

  const OptionPickerSheet({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final option in options)
          OptionTile(
            label: option.label,
            selected: option.value == selectedValue,
            onTap: () => onSelected(option),
          ),
      ],
    );
  }
}
