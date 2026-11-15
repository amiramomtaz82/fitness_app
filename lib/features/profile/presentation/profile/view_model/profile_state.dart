import 'package:equatable/equatable.dart';
import '../../../../../core/resource/resource.dart';
import '../../../domain/entities/profile_entity.dart';

class ProfileState extends Equatable {
  final Resource<ProfileEntity> profileResource;
  final String? pendingPhotoPath;

  const ProfileState({
    this.profileResource = const Resource.initial(),
    this.pendingPhotoPath,
  });

  ProfileEntity? get profile => profileResource.data;

  bool get hasProfile => profile != null;

  bool get isProfileLoading => profileResource.isLoading;

  bool get isUploadingPhoto => pendingPhotoPath != null;

  ProfileState copyWith({Resource<ProfileEntity>? profileResource}) {
    return ProfileState(
      profileResource: profileResource ?? this.profileResource,
      pendingPhotoPath: pendingPhotoPath,
    );
  }

  ProfileState withUpload(String? photoPath) {
    return ProfileState(
      profileResource: profileResource,
      pendingPhotoPath: photoPath,
    );
  }

  @override
  List<Object?> get props => [profileResource, pendingPhotoPath];
}
