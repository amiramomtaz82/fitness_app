import 'package:fitness_app/core/di/di.dart';
import 'package:fitness_app/features/profile/presentation/profile/view_model/profile_cubit.dart';
import 'package:fitness_app/features/profile/presentation/profile_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_app.dart';
import '../profile_widget_test_helper.dart';

void main() {
  late ProfileCubit cubit;

  setUp(() async {
    cubit = await startProfileCubit(profile: testProfileEntity);
    getIt.registerSingleton<ProfileCubit>(cubit);
  });

  tearDown(() => getIt.unregister<ProfileCubit>());

  Future<void> pumpScope(WidgetTester tester, Widget child) async {
    await pumpLocalizedWidget(tester, ProfileScope(child: child));
  }

  testWidgets('shares the registered cubit with everything inside it', (
    tester,
  ) async {
    await pumpScope(
      tester,
      Builder(
        builder: (context) =>
            Text(context.read<ProfileCubit>() == cubit ? 'SHARED' : 'OTHER'),
      ),
    );

    expect(find.text('SHARED'), findsOneWidget);
  });

  testWidgets('reads the profile as soon as it is on screen', (tester) async {
    await pumpScope(tester, const SizedBox());

    expect(cubit.state.profile, testProfileEntity);
  });
}
