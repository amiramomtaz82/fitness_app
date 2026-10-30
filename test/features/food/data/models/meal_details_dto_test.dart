import 'package:fitness_app/features/food/data/models/meal_details_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MealDto', mealDtoTests);
  group('MealLookupDto', mealLookupTests);
}

void mealDtoTests() {
  mapsPairedIngredients();
  mapsOneIngredient();
  dropsEmptyIngredientNames();
  dropsNullIngredientNames();
  keepsTheLastSupportedIngredient();
  readsNullOptionalFieldsAsNull();
  readsYoutubeSeparatelyFromThumbnail();
}

void mapsPairedIngredients() {
  test('pairs ingredient 1 with measure 1', () {
    final meal = MealDto.fromJson(pairedMealJson());
    expect(meal.ingredients, hasLength(2));
    expect(meal.ingredients.first.measure, '2 medium');
    expect(meal.ingredients.last.name, 'Salmon');
    expect(meal.toEntity().ingredients.first.name, 'Fennel');
  });
}

void mapsOneIngredient() {
  test('keeps one ingredient with its measure', () {
    final meal = MealDto.fromJson(const {
      'strIngredient1': ' Salmon ',
      'strMeasure1': ' 350g ',
    });
    expect(meal.ingredients, hasLength(1));
    expect(meal.ingredients.single.name, 'Salmon');
    expect(meal.ingredients.single.measure, '350g');
    expect(meal.toEntity().ingredients.single.measure, '350g');
  });
}

void dropsEmptyIngredientNames() {
  test('ignores blank ingredient names and keeps later pairs', () {
    final meal = MealDto.fromJson(pairedMealJson());
    expect(meal.ingredients.map((item) => item.name), ['Fennel', 'Salmon']);
    expect(meal.ingredients.map((item) => item.measure), ['2 medium', '350g']);
  });
}

void dropsNullIngredientNames() {
  test('ignores null names and does not shift later measures', () {
    final meal = MealDto.fromJson(const {
      'strIngredient1': null,
      'strMeasure1': '1 cup',
      'strIngredient2': 'Salt',
      'strMeasure2': '   ',
    });
    expect(meal.ingredients, hasLength(1));
    expect(meal.ingredients.single.name, 'Salt');
    expect(meal.ingredients.single.measure, isNull);
  });
}

void keepsTheLastSupportedIngredient() {
  test('keeps ingredient 20 and ignores ingredient 21', () {
    final meal = MealDto.fromJson(const {
      'strIngredient20': 'Pepper',
      'strMeasure20': '1 tsp',
      'strIngredient21': 'Secret',
      'strMeasure21': '1 pinch',
    });
    expect(meal.ingredients, hasLength(1));
    expect(meal.ingredients.single.name, 'Pepper');
    expect(meal.ingredients.single.measure, '1 tsp');
  });
}

void readsNullOptionalFieldsAsNull() {
  test('treats missing and blank text as null', () {
    final meal = MealDto.fromJson(const {'idMeal': '  ', 'strMeal': 10});
    expect(meal.id, isNull);
    expect(meal.name, isNull);
    expect(meal.instructions, isNull);
    expect(meal.youtubeUrl, isNull);
    expect(meal.ingredients, isEmpty);
  });
}

void readsYoutubeSeparatelyFromThumbnail() {
  keepsAWatchUrl();
  dropsBlankYoutubeValues();
  keepsAnUnsupportedVideoString();
  keepsTheThumbnailOutOfTheVideoUrl();
}

void keepsAWatchUrl() {
  test('reads a YouTube watch URL', () {
    final json = pairedMealJson();
    json['strYoutube'] = 'https://www.youtube.com/watch?v=xvPR2Tfw5k0';
    final meal = MealDto.fromJson(json);
    expect(meal.youtubeUrl, 'https://www.youtube.com/watch?v=xvPR2Tfw5k0');
    expect(meal.toEntity().youtubeUrl, meal.youtubeUrl);
  });
}

void dropsBlankYoutubeValues() {
  test('treats missing, blank, and non-text video URLs as null', () {
    expect(MealDto.fromJson(pairedMealJson()).youtubeUrl, isNull);
    expect(videoUrlFor('   '), isNull);
    expect(videoUrlFor(''), isNull);
    expect(videoUrlFor(10), isNull);
  });
}

void keepsAnUnsupportedVideoString() {
  test('keeps an unsupported video string for the player to reject', () {
    expect(
      videoUrlFor(' https://example.com/watch?v=abc '),
      'https://example.com/watch?v=abc',
    );
  });
}

void keepsTheThumbnailOutOfTheVideoUrl() {
  test('does not use the meal image as the video URL', () {
    final meal = MealDto.fromJson(pairedMealJson());
    expect(meal.thumbnailUrl, isNotNull);
    expect(meal.youtubeUrl, isNull);
    expect(meal.toEntity().thumbnailUrl, meal.thumbnailUrl);
  });
}

String? videoUrlFor(Object? value) {
  return MealDto.fromJson({'strYoutube': value}).youtubeUrl;
}

void mealLookupTests() {
  readsTheFirstMeal();
  returnsNullWhenMealsAreMissing();
}

void readsTheFirstMeal() {
  test('reads the first object in meals', () {
    final lookup = MealLookupDto.fromJson({
      'meals': [
        pairedMealJson(),
        {'strMeal': 'Second'},
      ],
    });
    expect(lookup.meal?.name, 'Baked salmon');
    expect(lookup.meal?.id, '52959');
  });
}

void returnsNullWhenMealsAreMissing() {
  test('returns no meal when meals is missing, null, or empty', () {
    expect(MealLookupDto.fromJson(const {}).meal, isNull);
    expect(MealLookupDto.fromJson(const {'meals': null}).meal, isNull);
    expect(MealLookupDto.fromJson(const {'meals': []}).meal, isNull);
    expect(
      MealLookupDto.fromJson(const {
        'meals': ['bad'],
      }).meal,
      isNull,
    );
  });
}

Map<String, dynamic> pairedMealJson() {
  return {
    'idMeal': '52959',
    'strMeal': 'Baked salmon',
    'strMealThumb':
        'https://www.themealdb.com/images/media/meals/1548772327.jpg',
    'strInstructions': 'Heat the oven.',
    'strCategory': 'Seafood',
    'strArea': 'British',
    'strIngredient1': ' Fennel ',
    'strMeasure1': ' 2 medium ',
    'strIngredient2': '   ',
    'strMeasure2': '1 cup',
    'strIngredient3': '',
    'strMeasure3': 'to serve',
    'strIngredient4': 'Salmon',
    'strMeasure4': '350g',
  };
}
