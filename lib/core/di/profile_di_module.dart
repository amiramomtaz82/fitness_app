import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import '../../features/profile/data/client/profile_client.dart';

@module
abstract class ProfileDiModule {
  @lazySingleton
  ProfileClient profileClient(Dio dio) => ProfileClient(dio);

  @lazySingleton
  ImagePicker get imagePicker => ImagePicker();
}
