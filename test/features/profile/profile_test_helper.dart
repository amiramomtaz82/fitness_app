import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/local/locale_cubit.dart';
import 'package:fitness_app/core/local/locale_preferences.dart';
import 'package:fitness_app/core/local/local_service.dart';
import 'package:fitness_app/core/secure_storage/secure_storage.dart';
import 'package:fitness_app/features/profile/data/client/profile_client.dart';
import 'package:fitness_app/features/profile/data/data_source/profile_remote_data_source.dart';
import 'package:fitness_app/features/profile/data/models/profile_request_dto.dart';
import 'package:fitness_app/features/profile/data/models/profile_response_dto.dart';
import 'package:fitness_app/features/profile/data/models/profile_user_dto.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_entity.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_params.dart';
import 'package:fitness_app/features/profile/domain/repo/profile_repo.dart';
import 'package:fitness_app/features/profile/domain/services/photo_picker.dart';
import 'package:fitness_app/features/profile/domain/use_cases/edit_profile_use_case.dart';
import 'package:fitness_app/features/profile/domain/use_cases/get_profile_use_case.dart';
import 'package:fitness_app/features/profile/domain/use_cases/logout_use_case.dart';
import 'package:fitness_app/features/profile/domain/use_cases/pick_photo_use_case.dart';
import 'package:fitness_app/features/profile/domain/use_cases/upload_photo_use_case.dart';
import 'package:fitness_app/features/profile/presentation/profile/view_model/profile_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockProfileClient extends Mock implements ProfileClient {}

class MockProfileRemoteDataSource extends Mock
    implements ProfileRemoteDataSource {}

class MockProfileRepo extends Mock implements ProfileRepo {}

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

class MockEditProfileUseCase extends Mock implements EditProfileUseCase {}

class MockUploadPhotoUseCase extends Mock implements UploadPhotoUseCase {}

class MockPickPhotoUseCase extends Mock implements PickPhotoUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockSecureStorage extends Mock implements SecureStorage {}

class MockPhotoPicker extends Mock implements PhotoPicker {}

class MockImagePicker extends Mock implements ImagePicker {}

class MockLocaleService extends Mock implements LocaleService {}

class FakeProfileRequestDto extends Fake implements ProfileRequestDto {}

class FakeProfileParams extends Fake implements ProfileParams {}

class FakeMultipartFile extends Fake implements MultipartFile {}

class FakeXFile extends Fake implements XFile {}

const testProfileUserDto = ProfileUserDto(
  id: '123',
  firstName: 'Ahmed',
  lastName: 'Sukkary',
  email: 'ahmed@test.com',
  gender: 'male',
  age: 25,
  weight: 75.5,
  height: 178,
  activityLevel: 'level1',
  goal: 'Gain weight',
  photo: 'uploads/123/photo.jpg',
);

const testProfileResponse = ProfileResponseDto(user: testProfileUserDto);

const testProfileEmptyResponse = ProfileResponseDto();

const Map<String, dynamic> testProfileUserJson = {
  '_id': '123',
  'firstName': 'Ahmed',
  'lastName': 'Sukkary',
  'email': 'ahmed@test.com',
  'gender': 'male',
  'age': 25,
  'weight': 75.5,
  'height': 178,
  'activityLevel': 'level1',
  'goal': 'Gain weight',
  'photo': 'uploads/123/photo.jpg',
};

const testProfileParams = ProfileParams(
  firstName: 'Ahmed',
  lastName: 'Sukkary',
  gender: 'male',
  age: 25,
  weight: 75.5,
  height: 178,
  activityLevel: 'level1',
  goal: 'Gain weight',
);

const testProfileRequestDto = ProfileRequestDto(
  firstName: 'Ahmed',
  lastName: 'Sukkary',
  gender: 'male',
  age: 25,
  weight: 75.5,
  height: 178,
  activityLevel: 'level1',
  goal: 'Gain weight',
);

const testProfileEntity = ProfileEntity(
  id: '123',
  firstName: 'Ahmed',
  lastName: 'Sukkary',
  email: 'ahmed@test.com',
  gender: 'male',
  age: 25,
  weight: 75.5,
  height: 178,
  activityLevel: 'level1',
  goal: 'Gain weight',
  photo: 'uploads/123/photo.jpg',
);

const testProfileEntityNoPhoto = ProfileEntity(
  id: '123',
  firstName: 'Ahmed',
  lastName: 'Sukkary',
  email: 'ahmed@test.com',
  gender: 'male',
  age: 25,
  weight: 75.5,
  height: 178,
  activityLevel: 'level1',
  goal: 'Gain weight',
);

const testProfileEntityEdited = ProfileEntity(
  id: '123',
  firstName: 'Mohamed',
  lastName: 'Sukkary',
  email: 'ahmed@test.com',
  gender: 'male',
  age: 30,
  weight: 80,
  height: 180,
  activityLevel: 'level3',
  goal: 'Lose weight',
  photo: 'uploads/123/photo.jpg',
);

void registerProfileFallbacks() {
  registerFallbackValue(FakeProfileRequestDto());
  registerFallbackValue(FakeProfileParams());
  registerFallbackValue(FakeMultipartFile());
  registerFallbackValue(FakeXFile());
  registerFallbackValue(ImageSource.gallery);
}

List<BaseUiEvent> recordUiEvents(Stream<BaseUiEvent> stream) {
  final events = <BaseUiEvent>[];
  final subscription = stream.listen(events.add);
  addTearDown(subscription.cancel);
  return events;
}

Future<LocalePreferences> localePreferencesWith({String? language}) async {
  SharedPreferences.setMockInitialValues(
    language == null ? const {} : {'app_language_code': language},
  );
  return LocalePreferences(await SharedPreferences.getInstance());
}

ProfileCubit buildProfileCubit(
  GetProfileUseCase getProfile,
  UploadPhotoUseCase uploadPhoto,
  PickPhotoUseCase pickPhoto, {
  LogoutUseCase? logout,
}) {
  return ProfileCubit(
    getProfile,
    uploadPhoto,
    pickPhoto,
    logout ?? MockLogoutUseCase(),
  );
}

LocaleCubit buildLocaleCubit(
  LocalePreferences localePreferences, {
  LocaleService? localeService,
}) {
  return LocaleCubit(localePreferences, localeService ?? MockLocaleService());
}
