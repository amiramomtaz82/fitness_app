import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_entity.dart';
import 'package:fitness_app/features/exercise/presentation/home/view/widgets/home_horizontal_section.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidgetUnderTest({
    required String title,
    required Resource<List<MuscleEntity>> resource,
    void Function(MuscleEntity item)? onItemTap,
  }) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MaterialApp(
          home: Scaffold(
            body: HomeHorizontalSection<MuscleEntity>(
              title: title,
              resource: resource,
              getTitle: (item) => item.name,
              getImage: (item) => item.imageUrl,
              onItemTap: onItemTap,
            ),
          ),
        );
      },
    );
  }

  group('HomeHorizontalSection', () {
    testWidgets('renders title when initial', (tester) async {
      // Arrange
      const resource = Resource<List<MuscleEntity>>.initial();

      // Act
      await tester.pumpWidget(
        createWidgetUnderTest(title: 'Muscle of the day', resource: resource),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Muscle of the day'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      // Arrange
      const resource = Resource<List<MuscleEntity>>.loading();

      // Act
      await tester.pumpWidget(
        createWidgetUnderTest(title: 'Muscle of the day', resource: resource),
      );
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('shows error message when error', (tester) async {
      // Arrange
      const resource = Resource<List<MuscleEntity>>.error(
        ServerFailure(serverMessage: 'Something went wrong'),
      );

      // Act
      await tester.pumpWidget(
        createWidgetUnderTest(title: 'Muscle of the day', resource: resource),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text(LocaleKeys.errors_something_went_wrong.tr()),
        findsOneWidget,
      );
    });

    testWidgets('shows items when success', (tester) async {
      // Arrange
      const resource = Resource<List<MuscleEntity>>.success([
        MuscleEntity(
          id: 'm_1',
          name: 'Chest',
          imageUrl: 'https://example.com/chest.png',
        ),
      ]);
      void onItemTap(MuscleEntity _) {}

      // Act
      await tester.pumpWidget(
        createWidgetUnderTest(
          title: 'Muscle of the day',
          resource: resource,
          onItemTap: onItemTap,
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Chest'), findsOneWidget);
    });

    testWidgets('shows nothing when success with empty list', (tester) async {
      // Arrange
      const resource = Resource<List<MuscleEntity>>.success([]);

      // Act
      await tester.pumpWidget(
        createWidgetUnderTest(title: 'Muscle of the day', resource: resource),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ListView), findsNothing);
      expect(find.text('Muscle of the day'), findsOneWidget);
    });
  });
}
