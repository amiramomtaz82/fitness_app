import 'package:fitness_app/features/food/data/mapper/meal_summary_mapper.dart';
import 'package:fitness_app/features/food/data/models/meal_summary_dto.dart';
import 'package:fitness_app/features/food/data/models/meals_response_dto.dart';
import 'package:fitness_app/features/food/domain/entities/meal_summary_entity.dart';
import 'package:flutter_test/flutter_test.dart';

/// Trimmed copy of a real `filter.php?c=Seafood` response.
const _apiJson = {
  'meals': [
    {
      'strMeal': 'Acaraje black-eyed pea fritters with shrimp filling',
      'strMealThumb':
          'https://www.themealdb.com/images/media/meals/dxs5t71782678369.jpg',
      'idMeal': '53483',
      'strArea': null,
      'strCountry': 'Brazil',
    },
    {
      'strMeal': 'Baked salmon with fennel & tomatoes',
      'strMealThumb':
          'https://www.themealdb.com/images/media/meals/1548772327.jpg',
      'idMeal': '52959',
      'strArea': 'British',
      'strCountry': 'United Kingdom',
    },
  ],
};

void main() {
  group('MealsResponseDto —', () {
    test('parses the API json field names', () {
      final dto = MealsResponseDto.fromJson(_apiJson);

      expect(dto.meals, hasLength(2));
      expect(dto.meals!.first.id, '53483');
      expect(
        dto.meals!.first.name,
        'Acaraje black-eyed pea fritters with shrimp filling',
      );
      expect(
        dto.meals!.first.thumbnail,
        'https://www.themealdb.com/images/media/meals/dxs5t71782678369.jpg',
      );
    });

    test('parses a null meals field', () {
      expect(MealsResponseDto.fromJson({'meals': null}).meals, isNull);
    });
  });

  group('MealSummaryMapper —', () {
    test('maps the full API response to entities', () {
      final entities = MealsResponseDto.fromJson(_apiJson).toEntities();

      expect(entities.map((e) => e.id), ['53483', '52959']);
    });

    test('trims the name and replaces missing values with empty strings', () {
      const dto = MealSummaryDto(id: '1', name: ' Sushi ');

      expect(
        dto.toEntity(),
        const MealSummaryEntity(id: '1', name: 'Sushi', thumbnail: ''),
      );
    });

    test('drops meals without an id', () {
      const response = MealsResponseDto(
        meals: [
          MealSummaryDto(name: 'No id'),
          MealSummaryDto(id: '', name: 'Empty id'),
          MealSummaryDto(id: '53065', name: 'Sushi'),
        ],
      );

      expect(response.toEntities().map((e) => e.id), ['53065']);
    });

    test('returns an empty list when meals is null', () {
      expect(const MealsResponseDto().toEntities(), isEmpty);
    });
  });
}
