import 'package:fitness_app/core/contants/chat_prompts_and_schemas.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatPromptsAndSchemas.buildSystemPrompt', () {
    test('returns only the base prompt when the profile is empty', () {
      expect(
        ChatPromptsAndSchemas.buildSystemPrompt(),
        equals(ChatPromptsAndSchemas.baseSystemPrompt),
      );
    });

    test('includes name, age and gender with the rest of the profile', () {
      final prompt = ChatPromptsAndSchemas.buildSystemPrompt(
        name: 'Maha',
        age: 24,
        gender: 'female',
        goal: 'Gain weight',
        activityLevel: 'level2',
        weight: 70,
        height: 170,
      );

      expect(prompt, startsWith(ChatPromptsAndSchemas.baseSystemPrompt));
      expect(prompt, contains('USER PROFILE: '));
      expect(prompt, contains('Name: Maha.'));
      expect(prompt, contains('Age: 24.'));
      expect(prompt, contains('Gender: female.'));
      expect(prompt, contains('Goal: Gain weight.'));
      expect(prompt, contains('Level: level2.'));
      expect(prompt, contains('Weight: 70kg.'));
      expect(prompt, contains('Height: 170cm.'));
    });

    test('adds the profile section when only the name is known', () {
      final prompt = ChatPromptsAndSchemas.buildSystemPrompt(name: 'Maha');

      expect(prompt, contains('USER PROFILE: Name: Maha.'));
      expect(prompt, isNot(contains('Goal:')));
    });

    test('skips empty name and gender', () {
      final prompt = ChatPromptsAndSchemas.buildSystemPrompt(
        name: '',
        gender: '',
        age: 30,
      );

      expect(prompt, isNot(contains('Name:')));
      expect(prompt, isNot(contains('Gender:')));
      expect(prompt, contains('Age: 30.'));
    });
  });
}
