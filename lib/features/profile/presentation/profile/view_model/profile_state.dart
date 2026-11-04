import 'package:equatable/equatable.dart';
import '../../../../../core/contants/app_language.dart';
import '../../../../../core/resource/resource.dart';
import '../../../domain/entities/profile_entity.dart';

class ProfileState extends Equatable {
  final Resource<ProfileEntity> profileResource;
  final String? pendingPhotoPath;
  final AppLanguage language;

  const ProfileState({
    this.profileResource = const Resource.initial(),
    this.pendingPhotoPath,
    this.language = AppLanguage.english,
  });

  ProfileEntity? get profile => profileResource.data;

  bool get hasProfile => profile != null;

  bool get isProfileLoading => profileResource.isLoading;

  bool get isUploadingPhoto => pendingPhotoPath != null;

  bool get isLanguageSwitchOn => language == AppLanguage.english;

  ProfileState copyWith({Resource<ProfileEntity>? profileResource}) {
    return ProfileState(
      profileResource: profileResource ?? this.profileResource,
      pendingPhotoPath: pendingPhotoPath,
      language: language,
    );
  }

  ProfileState withUpload(String? photoPath) {
    return ProfileState(
      profileResource: profileResource,
      pendingPhotoPath: photoPath,
      language: language,
    );
  }

  ProfileState withLanguage(AppLanguage language) {
    return ProfileState(
      profileResource: profileResource,
      pendingPhotoPath: pendingPhotoPath,
      language: language,
    );
  }

  @override
  List<Object?> get props => [profileResource, pendingPhotoPath, language];
}
