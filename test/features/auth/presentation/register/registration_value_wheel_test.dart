import 'package:fitness_app/core/theme/app_theme.dart';
import 'package:fitness_app/features/auth/presentation/register/view/muti_steps_regitration/widgets/registration_value_wheel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  wheelTests();
}

void wheelTests() {
  ignoresInitialLayoutSelection();
  horizontalDragReportsNewIndex();
  externalIndexChangeIsNotAScroll();
}

void ignoresInitialLayoutSelection() {
  testWidgets('shows the unit and ignores the initial layout selection', (
    tester,
  ) async {
    final changes = <int>[];
    await _pumpWheel(tester, selectedIndex: 1, onChanged: changes.add);
    expect(find.text('Year'), findsOneWidget);
    expect(find.text('17'), findsOneWidget);
    expect(changes, isEmpty);
  });
}

void horizontalDragReportsNewIndex() {
  testWidgets('a horizontal drag reports a new index', (tester) async {
    final changes = <int>[];
    await _pumpWheel(tester, selectedIndex: 1, onChanged: changes.add);
    await tester.drag(find.byType(ListWheelScrollView), const Offset(-160, 0));
    await tester.pumpAndSettle();
    expect(changes, isNotEmpty);
    expect(changes.last, isNot(1));
    expect(changes.last, inInclusiveRange(0, 4));
  });
}

void externalIndexChangeIsNotAScroll() {
  testWidgets('an external index change does not count as a user scroll', (
    tester,
  ) async {
    final probe = WheelProbe();
    await _pump(tester, ControlledWheel(probe: probe));
    probe.select(3);
    await tester.pumpAndSettle();
    expect(probe.calls, 0);
    expect(find.text('19'), findsWidgets);
  });
}

class WheelProbe {
  int calls = 0;
  late ValueChanged<int> select;
}

class ControlledWheel extends StatefulWidget {
  const ControlledWheel({super.key, required this.probe});

  final WheelProbe probe;

  @override
  State<ControlledWheel> createState() => ControlledWheelState();
}

class ControlledWheelState extends State<ControlledWheel> {
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
