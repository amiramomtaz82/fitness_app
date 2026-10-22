import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/theme/context.extension.dart';

class RegistrationValueWheel extends StatefulWidget {
  const RegistrationValueWheel({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.unit,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final String unit;
  final ValueChanged<int> onChanged;

  @override
  State<RegistrationValueWheel> createState() => _RegistrationValueWheelState();
}

class _RegistrationValueWheelState extends State<RegistrationValueWheel> {
  late final FixedExtentScrollController _controller;
  bool _handleScroll = false;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(initialItem: _index);
  }

  int get _index {
    final last = widget.labels.length - 1;
    if (last < 0) return 0;
    return widget.selectedIndex.clamp(0, last);
  }

  @override
  void didUpdateWidget(RegistrationValueWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncIndex(oldWidget.selectedIndex);
  }

  void _syncIndex(int previous) {
    if (previous == widget.selectedIndex || _handleScroll) {
      return;
    }
    if (!_controller.hasClients) {
      return;
    }
    _controller.jumpToItem(_index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.unit, style: context.textTheme.bodyMedium),
        SizedBox(height: 8.h),
        Expanded(child: _WheelList(state: this)),
      ],
    );
  }
}

class _WheelList extends StatelessWidget {
  const _WheelList({required this.state});

  final _RegistrationValueWheelState state;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<UserScrollNotification>(
      onNotification: state._onUserScroll,
      child: RotatedBox(
        quarterTurns: 3,
        child: ListWheelScrollView.useDelegate(
          controller: state._controller,
          itemExtent: 64.w,
          physics: const FixedExtentScrollPhysics(),
          diameterRatio: 1.6,
          onSelectedItemChanged: state._onSelected,
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: state.widget.labels.length,
            builder: (context, index) =>
                _WheelLabel(state: state, index: index),
          ),
        ),
      ),
    );
  }
}

class _WheelLabel extends StatelessWidget {
  const _WheelLabel({required this.state, required this.index});

  final _RegistrationValueWheelState state;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selected = index == state._index;
    return RotatedBox(
      quarterTurns: 1,
      child: Center(
        child: Text(
          state.widget.labels[index],
          style: context.textTheme.headlineLarge?.copyWith(
            color: selected ? colors.primary : colors.grey,
          ),
        ),
      ),
    );
  }
}

extension on _RegistrationValueWheelState {
  bool _onUserScroll(UserScrollNotification notification) {
    _handleScroll = notification.direction != ScrollDirection.idle;
    return false;
  }

  void _onSelected(int index) {
    if (!_handleScroll || index == widget.selectedIndex) {
      return;
    }
    widget.onChanged(index);
  }
}
