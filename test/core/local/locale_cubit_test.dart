import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/contants/app_language.dart';
import 'package:fitness_app/core/local/locale_cubit.dart';
import 'package:fitness_app/core/local/locale_intent.dart';
import 'package:fitness_app/core/local/locale_preferences.dart';
import 'package:fitness_app/core/local/locale_state.dart';
import 'package:fitness_app/core/local/locale_ui_event.dart';
import 'package:fitness_app/core/local/local_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocalePreferences preferences;
  late LocaleService service;
  late LocaleCubit cubit;

  Future<void> seedPreferences(AppLanguage? saved) async {
    SharedPreferences.setMockInitialValues(
      saved == null ? {} : {'app_language_code': saved.code},
    );
    preferences = LocalePreferences(await SharedPreferences.getInstance());
  }

  List<BaseUiEvent> recordEvents() {
    final events = <BaseUiEvent>[];
    final subscription = cubit.eventStream.listen(events.add);
    addTearDown(subscription.cancel);
    return events;
  }

  Future<LocaleCubit> startCubit({AppLanguage? saved}) async {
    await seedPreferences(saved);
    service = LocaleService();
    final cubit = LocaleCubit(preferences, service);
    addTearDown(cubit.close);
    return cubit;
  }

  group('LocaleCubit start', () {
    test('opens on english when nothing was stored', () async {
      cubit = await startCubit();

      expect(cubit.state, const LocaleState());
      expect(cubit.state.language, AppLanguage.english);
    });

    test('opens on the language that was stored', () async {
      cubit = await startCubit(saved: AppLanguage.arabic);

      expect(cubit.state.language, AppLanguage.arabic);
    });
  });

  group('LoadSavedLocaleIntent', () {
    test('syncs the request language and notifies the scope', () async {
      cubit = await startCubit(saved: AppLanguage.arabic);
      final events = recordEvents();

      cubit.doIntent(const LoadSavedLocaleIntent());
      await Future<void>.delayed(Duration.zero);

      expect(service.languageCode, AppLanguage.arabic.code);
      expect(
        events,
        contains(
          isA<LocaleChangedEvent>().having(
            (event) => event.language,
            'language',
            AppLanguage.arabic,
          ),
        ),
      );
    });
  });

  group('ToggleLanguageIntent', () {
    test('flips, saves and notifies', () async {
      cubit = await startCubit();
      final events = recordEvents();

      cubit.doIntent(const ToggleLanguageIntent());
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.language, AppLanguage.arabic);
      expect(preferences.readLanguage(), AppLanguage.arabic);
      expect(service.languageCode, AppLanguage.arabic.code);
      expect(events, hasLength(1));
      expect(
        (events.single as LocaleChangedEvent).language,
        AppLanguage.arabic,
      );
    });

    test('a second flip returns to english', () async {
      cubit = await startCubit();

      cubit.doIntent(const ToggleLanguageIntent());
      await Future<void>.delayed(Duration.zero);
      cubit.doIntent(const ToggleLanguageIntent());
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.language, AppLanguage.english);
      expect(preferences.readLanguage(), AppLanguage.english);
    });
  });

  group('ChangeLocaleIntent', () {
    test('moves to the handed language and persists it', () async {
      cubit = await startCubit();

      cubit.doIntent(const ChangeLocaleIntent(AppLanguage.arabic));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.language, AppLanguage.arabic);
      expect(preferences.readLanguage(), AppLanguage.arabic);
      expect(service.languageCode, AppLanguage.arabic.code);
    });

    test('settling on the current language still notifies', () async {
      cubit = await startCubit(saved: AppLanguage.arabic);
      final events = recordEvents();

      cubit.doIntent(const ChangeLocaleIntent(AppLanguage.arabic));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.language, AppLanguage.arabic);
      expect(events, hasLength(1));
    });
  });
}
