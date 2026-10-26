import '../../domain/entities/user_entity.dart';
import '../models/user_dto.dart';

class UserMapper {
  static UserEntity? toEntity(UserDto? dto) => dto?.toEntity();

  static UserDto? toDto(UserEntity? entity) =>
      entity != null ? UserDto.fromEntity(entity) : null;
}
