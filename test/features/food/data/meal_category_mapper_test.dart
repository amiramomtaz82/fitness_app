import 'package:fitness_app/features/food/data/mapper/meal_category_mapper.dart';
import 'package:fitness_app/features/food/data/models/meal_categories_response_dto.dart';
import 'package:fitness_app/features/food/data/models/meal_category_dto.dart';
import 'package:fitness_app/features/food/domain/entities/meal_category_entity.dart';
import 'package:flutter_test/flutter_test.dart';

/// Trimmed copy of a real `categories.php` response.
const _apiJson = {
  'categories': [
    {
      'idCategory': '1',
      'strCategory': 'Beef',
      'strCategoryThumb': 'https://www.themealdb.com/images/category/beef.png',
      'strCategoryDescription': 'Beef is the culinary name for meat.',
    },
    {
      'idCategory': '2',
      'strCategory': 'Chicken',
      'strCategoryThumb':
          'https://www.themealdb.com/images/category/chicken.png',
      'strCategoryDescription': 'Chicken is a type of domesticated fowl.',
    },
  ],
};

void main() {
  group('MealCategoriesResponseDto —', () {
    test('parses the API json field names', () {
      final dto = MealCategoriesResponseDto.fromJson(_apiJson);

      expect(dto.categories, hasLength(2));
      expect(dto.categories!.first.id, '1');
      expect(dto.categories!.first.name, 'Beef');
      expect(
        dto.categories!.first.thumbnail,
        'https://www.themealdb.com/images/category/beef.png',
      );
      expect(
        dto.categories!.first.description,
        'Beef is the culinary name for meat.',
      );
    });

    test('parses a null categories field', () {
      final dto = MealCategoriesResponseDto.fromJson({'categories': null});

      expect(dto.categories, isNull);
    });
  });

  group('MealCategoryMapper —', () {
    test('maps the full API response to entities', () {
      final entities = MealCategoriesResponseDto.fromJson(
        _apiJson,
      ).toEntities();

      expect(entities.map((e) => e.name), ['Beef', 'Chicken']);
    });

    test('trims text and replaces missing values with empty strings', () {
      const dto = MealCategoryDto(id: '3', name: ' Dessert \r\n');

      expect(
        dto.toEntity(),
        const MealCategoryEntity(
          id: '3',
          name: 'Dessert',
          thumbnail: '',
          description: '',
        ),
      );
    });

    test('drops categories without an id', () {
      const response = MealCategoriesResponseDto(
        categories: [
          MealCategoryDto(name: 'No id'),
          MealCategoryDto(id: '', name: 'Empty id'),
          MealCategoryDto(id: '4', name: 'Lamb'),
        ],
      );

      expect(response.toEntities().map((e) => e.id), ['4']);
    });

    test('returns an empty list when categories is null', () {
      expect(const MealCategoriesResponseDto().toEntities(), isEmpty);
    });
  });
}
