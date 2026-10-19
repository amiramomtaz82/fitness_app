import '../../domain/entities/user_entity.dart';
import '../models/user_dto.dart';

class UserMapper {
  static UserEntity? toEntity(UserDto? dto) {
    if (dto == null) return null;
    return UserEntity(
      id: dto.id,
      firstName: dto.firstName,
      lastName: dto.lastName,
      email: dto.email,
      gender: dto.gender,
      age: dto.age,
      weight: dto.weight,
      height: dto.height,
      activityLevel: dto.activityLevel,
      goal: dto.goal,
      photo: dto.photo,
    );
  }

  static UserDto? toDto(UserEntity? entity) {
    if (entity == null) return null;
    return UserDto(
      id: entity.id,
      firstName: entity.firstName,
      lastName: entity.lastName,
      email: entity.email,
      gender: entity.gender,
      age: entity.age,
      weight: entity.weight,
      height: entity.height,
      activityLevel: entity.activityLevel,
      goal: entity.goal,
      photo: entity.photo,
    );
  }
}
