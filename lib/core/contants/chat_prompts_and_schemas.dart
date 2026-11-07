abstract final class ChatPromptsAndSchemas {
  ChatPromptsAndSchemas._();

  static const String baseSystemPrompt =
      'You are the in-app fitness coach for Fitness App. Reply in user locale. '
      'GROUND RULES: 1. Before recommending exercises or meals, call search_exercises or search_meals. '
      'Recommend ONLY items from candidate results. Never invent an id. CATALOG VOCABULARY: '
      'muscle_group: Abdominals | Chest | Glutes | Hamstrings | Shoulders. '
      'equipment: Bodyweight | Dumbbell | Barbell | Cable. '
      'max_difficulty: Beginner=1 | Novice=2 | Intermediate=3 | Advanced=4.';

  static const List<Map<String, dynamic>> toolsSchema = [
    {
      'type': 'function',
      'function': {
        'name': 'search_exercises',
        'description':
            'Find exercises in catalog using exact vocabulary values.',
        'parameters': {
          'type': 'object',
          'properties': {
            'muscle_group': {'type': 'string'},
            'equipment': {'type': 'string'},
            'max_difficulty': {'type': 'integer', 'minimum': 1, 'maximum': 8},
            'limit': {'type': 'integer', 'default': 6},
          },
        },
      },
    },
    {
      'type': 'function',
      'function': {
        'name': 'search_meals',
        'description': 'Find meals in catalog.',
        'parameters': {
          'type': 'object',
          'properties': {
            'category': {'type': 'string'},
            'min_protein': {'type': 'number'},
            'max_kcal': {'type': 'number'},
            'limit': {'type': 'integer', 'default': 6},
          },
        },
      },
    },
  ];

  static const Map<String, dynamic> formatSchema = {
    'type': 'object',
    'properties': {
      'reply': {'type': 'string'},
      'exercise_ids': {
        'type': 'array',
        'items': {'type': 'string'},
      },
      'meal_ids': {
        'type': 'array',
        'items': {'type': 'string'},
      },
    },
    'required': ['reply', 'exercise_ids', 'meal_ids'],
  };

  static String buildSystemPrompt({
    String? goal,
    String? activityLevel,
    num? weight,
    num? height,
  }) {
    final buffer = StringBuffer(baseSystemPrompt);
    if (goal != null ||
        activityLevel != null ||
        weight != null ||
        height != null) {
      buffer.write('\nUSER PROFILE: ');
      if (goal != null && goal.isNotEmpty) buffer.write('Goal: $goal. ');
      if (activityLevel != null && activityLevel.isNotEmpty) {
        buffer.write('Level: $activityLevel. ');
      }
      if (weight != null) buffer.write('Weight: ${weight}kg. ');
      if (height != null) buffer.write('Height: ${height}cm. ');
    }
    return buffer.toString();
  }
}
