import '../../domain/entities/meal_details_entity.dart';
import '../../domain/entities/meal_ingredient.dart';

class MealIngredientDto {
  final String name;
  final String? measure;

  const MealIngredientDto({required this.name, this.measure});

  MealIngredient toEntity() => MealIngredient(name: name, measure: measure);
}

class MealDto {
  final String? id;
  final String? name;
  final String? thumbnailUrl;
  final String? instructions;
  final String? youtubeUrl;
  final List<MealIngredientDto> ingredients;

  const MealDto({
    this.id,
    this.name,
    this.thumbnailUrl,
    this.instructions,
    this.youtubeUrl,
    this.ingredients = const [],
  });

  factory MealDto.fromJson(Map<String, dynamic> json) {
    return MealDto(
      id: MealDto.readText(json, 'idMeal'),
      name: MealDto.readText(json, 'strMeal'),
      thumbnailUrl: MealDto.readText(json, 'strMealThumb'),
      instructions: MealDto.readText(json, 'strInstructions'),
      youtubeUrl: MealDto.readText(json, 'strYoutube'),
      ingredients: MealDto.readIngredients(json),
    );
  }

  MealDetailsEntity toEntity() {
    return MealDetailsEntity(
      id: id,
      name: name,
      thumbnailUrl: thumbnailUrl,
      instructions: instructions,
      youtubeUrl: youtubeUrl,
      ingredients: ingredients.map((item) => item.toEntity()).toList(),
    );
  }

  static String? readText(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String) return null;
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  static List<MealIngredientDto> readIngredients(Map<String, dynamic> json) {
    final ingredients = <MealIngredientDto>[];
    for (var number = 1; number <= 20; number++) {
      final name = readText(json, 'strIngredient$number');
      if (name == null) continue;
      ingredients.add(
        MealIngredientDto(
          name: name,
          measure: readText(json, 'strMeasure$number'),
        ),
      );
    }
    return ingredients;
  }
}

class MealLookupDto {
  final MealDto? meal;

  const MealLookupDto(this.meal);

  factory MealLookupDto.fromJson(Map<String, dynamic> json) {
    final meals = json['meals'];
    if (meals is! List || meals.isEmpty) return const MealLookupDto(null);
    final meal = meals.first;
    if (meal is! Map) return const MealLookupDto(null);
    return MealLookupDto(MealDto.fromJson(Map<String, dynamic>.from(meal)));
  }
}
