import 'package:fitness_app/features/exercise/data/models/difficulty_level_model.dart';
import 'package:fitness_app/features/exercise/data/models/difficulty_levels_response_model.dart';
import 'package:fitness_app/features/exercise/data/models/muscle_group_model.dart';
import 'package:fitness_app/features/exercise/data/models/muscle_group_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DifficultyLevelModel —', () {
    test('reads the _id key sent by the API', () {
      final model = DifficultyLevelModel.fromJson({
        '_id': 'level-1',
        'name': 'Beginner',
      });

      expect(model.id, 'level-1');
      expect(model.name, 'Beginner');
    });

    test('accepts a plain id key as well', () {
      final model = DifficultyLevelModel.fromJson({
        'id': 'level-2',
        'name': 'Intermediate',
      });

      expect(model.id, 'level-2');
    });

    test('maps into a DifficultyLevelEntity', () {
      final entity = DifficultyLevelModel.fromJson({
        '_id': 'level-1',
        'name': 'Beginner',
      }).toEntity();

      expect(entity.id, 'level-1');
      expect(entity.name, 'Beginner');
    });

    test('falls back to empty strings when fields are missing', () {
      final entity = DifficultyLevelModel.fromJson(const {}).toEntity();

      expect(entity.id, isEmpty);
      expect(entity.name, isEmpty);
    });

    test('round-trips through toJson', () {
      const model = DifficultyLevelModel(id: 'level-1', name: 'Beginner');

      expect(model.toJson(), {'_id': 'level-1', 'name': 'Beginner'});
    });
  });

  group('DifficultyLevelsResponseModel —', () {
    test('parses the difficulty_levels list', () {
      final response = DifficultyLevelsResponseModel.fromJson({
        'message': 'success',
        'totalLevels': 2,
        'difficulty_levels': [
          {'_id': 'level-1', 'name': 'Beginner'},
          {'_id': 'level-2', 'name': 'Intermediate'},
        ],
      });

      expect(response.message, 'success');
      expect(response.totalLevels, 2);
      expect(response.difficultyLevels, hasLength(2));
      expect(response.toEntities().map((level) => level.name), [
        'Beginner',
        'Intermediate',
      ]);
    });

    test('accepts the legacy levels key and derives totalLevels', () {
      final response = DifficultyLevelsResponseModel.fromJson({
        'levels': [
          {'id': 'level-1', 'name': 'Beginner'},
        ],
      });

      expect(response.totalLevels, 1);
      expect(response.toEntities().single.id, 'level-1');
    });

    test('returns an empty entity list when the payload has no levels', () {
      final response = DifficultyLevelsResponseModel.fromJson(const {});

      expect(response.difficultyLevels, isNull);
      expect(response.toEntities(), isEmpty);
    });

    test('round-trips through toJson', () {
      const model = DifficultyLevelsResponseModel(
        message: 'success',
        totalLevels: 1,
        difficultyLevels: [
          DifficultyLevelModel(id: 'level-1', name: 'Beginner'),
        ],
      );

      final json = model.toJson();

      expect(json['difficulty_levels'], hasLength(1));
      expect(json['totalLevels'], 1);
    });
  });

  group('MuscleGroupModel —', () {
    test('reads the _id key and maps into an entity', () {
      final entity = MuscleGroupModel.fromJson({
        '_id': 'muscle-1',
        'name': 'Chest',
      }).toEntity();

      expect(entity.id, 'muscle-1');
      expect(entity.name, 'Chest');
    });

    test('falls back to empty strings when fields are missing', () {
      final entity = MuscleGroupModel.fromJson(const {}).toEntity();

      expect(entity.id, isEmpty);
      expect(entity.name, isEmpty);
    });
  });

  group('MusclesGroupResponse —', () {
    test('parses the musclesGroup list', () {
      final response = MusclesGroupResponse.fromJson({
        'message': 'success',
        'musclesGroup': [
          {'_id': 'muscle-1', 'name': 'Chest'},
          {'_id': 'muscle-2', 'name': 'Back'},
        ],
      });

      expect(response.message, 'success');
      expect(response.musclesGroup, hasLength(2));
      expect(response.musclesGroup!.first.name, 'Chest');
    });

    test('keeps the list null when the payload omits it', () {
      final response = MusclesGroupResponse.fromJson(const {});

      expect(response.message, isNull);
      expect(response.musclesGroup, isNull);
    });
  });
}
