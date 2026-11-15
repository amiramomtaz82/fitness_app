import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/widgets/app_text_form_field.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_entity.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_params.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view/widgets/edit_tap_field.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view/widgets/number_picker_sheet.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view/widgets/option_picker_sheet.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view_model/edit_profile_field.dart';
import 'package:fitness_app/features/profile/presentation/profile/view/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../../helpers/test_app.dart';
import '../../../../profile_widget_test_helper.dart';

void main() {
  setUpAll(registerProfileFallbacks);

  AppTextFormField lockedField(WidgetTester tester, String name) {
    return tester.widget<AppTextFormField>(find.byKey(Key('${name}Field')));
  }

  String fieldValue(WidgetTester tester, EditProfileField field) {
    return tester
        .widgetList<Text>(
          find.descendant(
            of: find.byKey(Key('field_${field.name}')),
            matching: find.byType(Text),
          ),
        )
        .last
        .data!;
  }

  Future<void> openField(WidgetTester tester, EditProfileField field) async {
    final row = find.byKey(Key('field_${field.name}'));
    await tester.ensureVisible(row);
    await settleUi(tester);
    await tester.tap(row);
    await settleUi(tester);
  }

  Future<void> pickNumber(
    WidgetTester tester,
    int value, {
    required int min,
  }) async {
    final controller = tester
        .widget<PageView>(find.byType(PageView))
        .controller!;
    controller.jumpToPage(value - min);
    await settleUi(tester);
    await tester.tap(find.text('Done'));
    await settleUi(tester, steps: 8);
  }

  Future<void> tapSave(WidgetTester tester) async {
    final button = find.byKey(const Key('editSaveButton'));
    await tester.ensureVisible(button);
    await settleUi(tester);
    await tester.tap(button);
    await settleUi(tester, steps: 8);
  }

  bool saveEnabled(WidgetTester tester) {
    return tester
            .widget<FilledButton>(find.byKey(const Key('editSaveButton')))
            .onPressed !=
        null;
  }

  void stubSave(
    MockEditProfileUseCase editProfile,
    BaseResponse<ProfileEntity> response,
  ) {
    when(() => editProfile.call(any())).thenAnswer((_) async => response);
  }

  testWidgets('keeps the account identity out of reach', (tester) async {
    await startLoadedEditForm(tester);

    expect(lockedField(tester, 'firstName').hintText, 'Ahmed');
    expect(lockedField(tester, 'firstName').enabled, isFalse);
    expect(lockedField(tester, 'lastName').hintText, 'Sukkary');
    expect(lockedField(tester, 'lastName').enabled, isFalse);
    expect(lockedField(tester, 'email').hintText, 'ahmed@test.com');
    expect(lockedField(tester, 'email').enabled, isFalse);
  });

  testWidgets('shows the gender as a locked line the user cannot edit', (
    tester,
  ) async {
    await startLoadedEditForm(tester);

    expect(lockedField(tester, 'gender').hintText, 'Male');
    expect(lockedField(tester, 'gender').enabled, isFalse);
    expect(find.byKey(const Key('field_gender')), findsNothing);
  });

  testWidgets('shows the photo of the account being edited', (tester) async {
    await startLoadedEditForm(tester);

    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.byType(ProfileAvatar), findsOneWidget);
  });

  testWidgets('every field starts on the value the account holds', (
    tester,
  ) async {
    await startLoadedEditForm(tester);

    expect(fieldValue(tester, EditProfileField.age), '25 years');
    expect(fieldValue(tester, EditProfileField.weight), '75.5 kg');
    expect(fieldValue(tester, EditProfileField.height), '178 cm');
    expect(fieldValue(tester, EditProfileField.goal), 'Gain Weight');
    expect(fieldValue(tester, EditProfileField.activityLevel), 'Rookie');
  });

  testWidgets('the save stays asleep until something is edited', (
    tester,
  ) async {
    await startLoadedEditForm(tester);
    expect(saveEnabled(tester), isFalse);

    await openField(tester, EditProfileField.age);
    await pickNumber(tester, 30, min: 10);

    expect(saveEnabled(tester), isTrue);
  });

  testWidgets('a number field opens its own unit and value', (tester) async {
    final cubit = await startLoadedEditForm(tester);

    await openField(tester, EditProfileField.weight);

    expect(find.text('WHAT IS YOUR WEIGHT ?'), findsOneWidget);
    expect(find.byType(NumberPickerSheet), findsOneWidget);
    expect(find.byType(OptionPickerSheet), findsNothing);
    expect(cubit.state.draft?.weight, 75.5);
  });

  testWidgets('a chosen number lands on the row and closes the picker', (
    tester,
  ) async {
    final cubit = await startLoadedEditForm(tester);
    await openField(tester, EditProfileField.age);

    await pickNumber(tester, 30, min: 10);

    expect(fieldValue(tester, EditProfileField.age), '30 years');
    expect(cubit.state.draft?.age, 30);
    expect(find.byType(NumberPickerSheet), findsNothing);
  });

  testWidgets('a choice field opens the list the field accepts', (
    tester,
  ) async {
    await startLoadedEditForm(tester);

    await openField(tester, EditProfileField.goal);

    expect(find.text('WHAT IS YOUR GOAL ?'), findsOneWidget);
    expect(find.byType(OptionPickerSheet), findsOneWidget);
    expect(find.byType(NumberPickerSheet), findsNothing);
    expect(find.text('Get Fitter'), findsOneWidget);
    expect(find.text('Gain More Flexible'), findsOneWidget);
    expect(find.text('Learn The Basic'), findsOneWidget);
  });

  testWidgets('a picked choice lands on the row and closes the picker', (
    tester,
  ) async {
    final cubit = await startLoadedEditForm(tester);
    await openField(tester, EditProfileField.goal);

    await tester.tap(find.text('Lose Weight'));
    await settleUi(tester, steps: 8);

    expect(fieldValue(tester, EditProfileField.goal), 'Lose Weight');
    expect(cubit.state.draft?.goal, 'Lose weight');
    expect(find.byType(OptionPickerSheet), findsNothing);
  });

  testWidgets('the photo on the page hands the picker to the profile', (
    tester,
  ) async {
    final pickPhoto = MockPickPhotoUseCase();
    when(
      () => pickPhoto.call(),
    ).thenAnswer((_) async => const SuccessResponse<String?>(null));
    await startLoadedEditForm(tester, pickPhoto: pickPhoto);

    await tester.tap(find.byKey(avatarKey));
    await settleUi(tester);

    verify(() => pickPhoto.call()).called(1);
  });

  testWidgets('saving sends what the user edited to the server', (
    tester,
  ) async {
    final editProfile = MockEditProfileUseCase();
    stubSave(
      editProfile,
      const SuccessResponse<ProfileEntity>(testProfileEntity),
    );
    await startLoadedEditForm(tester, editProfile: editProfile);
    await openField(tester, EditProfileField.age);
    await pickNumber(tester, 30, min: 10);

    await tapSave(tester);

    verify(
      () => editProfile.call(
        any(
          that: isA<ProfileParams>().having((params) => params.age, 'age', 30),
        ),
      ),
    ).called(1);
  });

  testWidgets('a saved change hands the profile back to the list', (
    tester,
  ) async {
    final editProfile = MockEditProfileUseCase();
    stubSave(
      editProfile,
      const SuccessResponse<ProfileEntity>(testProfileEntityEdited),
    );
    final cubit = await startLoadedEditForm(tester, editProfile: editProfile);

    await openField(tester, EditProfileField.age);
    await pickNumber(tester, 30, min: 10);
    await tapSave(tester);

    expect(lockedField(tester, 'firstName').hintText, 'Mohamed');
    expect(cubit.state.saved, testProfileEntityEdited);
  });

  testWidgets('a rejected save tells the user and keeps the form', (
    tester,
  ) async {
    final editProfile = MockEditProfileUseCase();
    stubSave(
      editProfile,
      ErrorResponse<ProfileEntity>(failure: const ServerFailure()),
    );
    final cubit = await startLoadedEditForm(tester, editProfile: editProfile);

    await openField(tester, EditProfileField.age);
    await pickNumber(tester, 30, min: 10);
    await tapSave(tester);

    expect(find.byType(SnackBar), findsOneWidget);
    expect(cubit.state.saved, testProfileEntity);
    expect(lockedField(tester, 'firstName').hintText, 'Ahmed');
  });

  testWidgets('an edit that is still invalid never reaches the server', (
    tester,
  ) async {
    final editProfile = MockEditProfileUseCase();
    final cubit = await startLoadedEditForm(
      tester,
      profile: const ProfileEntity(),
      editProfile: editProfile,
    );

    await openField(tester, EditProfileField.age);
    await pickNumber(tester, 20, min: 10);
    await tapSave(tester);

    verifyNever(() => editProfile.call(any()));
    expect(find.byType(SnackBar), findsOneWidget);
    expect(cubit.state.fieldErrors, isNotEmpty);
  });

  testWidgets('a profile the app cannot read leaves the form closed', (
    tester,
  ) async {
    final cubit = await startLoadedEditForm(tester, profile: null);

    expect(cubit.state.draft, isNull);
    expect(find.byType(EditTapField), findsNothing);
    expect(lockedField(tester, 'email').hintText, isEmpty);
    expect(find.byKey(const Key('editSaveButton')), findsOneWidget);
  });
}
