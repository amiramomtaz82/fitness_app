import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/contants/upload_constraints.dart';
import '../../../../core/error/failures.dart';
import '../client/profile_client.dart';
import '../models/profile_request_dto.dart';
import '../models/profile_response_dto.dart';
import 'profile_remote_data_source.dart';

@Injectable(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImp implements ProfileRemoteDataSource {
  final ProfileClient _client;

  const ProfileRemoteDataSourceImp(this._client);

  @override
  Future<ProfileResponseDto> getProfile() => _client.getProfile();

  @override
  Future<ProfileResponseDto> editProfile(ProfileRequestDto request) =>
      _client.editProfile(request);

  @override
  Future<ProfileResponseDto> uploadPhoto(String photoPath) async {
    final file = File(photoPath);
    if (!await file.exists()) {
      throw const ValidationFailure();
    }

    final length = await file.length();
    if (length > UploadConstraints.maxProfilePhotoBytes) {
      throw const PhotoTooLargeFailure();
    }

    return _client.uploadPhoto(
      MultipartFile.fromStream(
        file.openRead,
        length,
        filename: _fileNameOf(photoPath),
      ),
    );
  }

  String _fileNameOf(String photoPath) =>
      photoPath.split(RegExp(r'[/\\]')).where((part) => part.isNotEmpty).last;
}
