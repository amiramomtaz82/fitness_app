import 'package:fitness_app/core/theme/app_theme.dart';
import 'package:fitness_app/features/auth/presentation/register/view/muti_steps_regitration/widgets/registration_value_wheel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows the unit and ignores the initial layout selection', (
    tester,
  ) async {
    final changes = <int>[];
    await _pumpWheel(tester, selectedIndex: 1, onChanged: changes.add);
    expect(find.text('Year'), findsOneWidget);
    expect(find.text('17'), findsOneWidget);
    expect(changes, isEmpty);
  });

  testWidgets('a horizontal drag reports a new index', (tester) async {
    final changes = <int>[];
    await _pumpWheel(tester, selectedIndex: 1, onChanged: changes.add);
    await tester.drag(find.byType(ListWheelScrollView), const Offset(-160, 0));
    await tester.pumpAndSettle();
    expect(changes, isNotEmpty);
    expect(changes.last, isNot(1));
    expect(changes.last, inInclusiveRange(0, 4));
  });

  testWidgets('an external index change does not count as a user scroll', (
    tester,
  ) async {
    final probe = _WheelProbe();
    await _pump(tester, _ControlledWheel(probe: probe));
    probe.select(3);
    await tester.pumpAndSettle();
    expect(probe.calls, 0);
    expect(find.text('19'), findsWidgets);
  });
}

class _WheelProbe {
  int calls = 0;
  late ValueChanged<int> select;
}

class _ControlledWheel extends StatefulWidget {
  const _ControlledWheel({required this.probe});

  final _WheelProbe probe;

  @override
  State<_ControlledWheel> createState() => _ControlledWheelState();
}

class _ControlledWheelState extends State<_ControlledWheel> {
  int _index = 1;

  @override
  void initState() {
    super.initState();
    widget.probe.select = (index) => setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return RegistrationValueWheel(
      labels: const ['16', '17', '18', '19', '20'],
      selectedIndex: _index,
      unit: 'Year',
      onChanged: (_) => widget.probe.calls++,
    );
  }
}

Future<void> _pumpWheel(
  WidgetTester tester, {
  required int selectedIndex,
  required ValueChanged<int> onChanged,
}) {
  return _pump(
    tester,
    RegistrationValueWheel(
      labels: const ['16', '17', '18', '19', '20'],
      selectedIndex: selectedIndex,
      unit: 'Year',
      onChanged: onChanged,
    ),
  );
}

Future<void> _pump(WidgetTester tester, Widget wheel) async {
  await tester.binding.setSurfaceSize(const Size(375, 812));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(body: SizedBox(height: 280, child: wheel)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
