import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/contants/upload_constraints.dart';
import '../../domain/services/photo_picker.dart';

@Injectable(as: PhotoPicker)
class ProfilePhotoPickerImp implements PhotoPicker {
  final ImagePicker _imagePicker;

  const ProfilePhotoPickerImp(this._imagePicker);

  @override
  Future<String?> pickPhoto() {
    return _imagePicker
        .pickImage(
          source: ImageSource.gallery,
          maxWidth: UploadConstraints.maxPhotoDimension,
          maxHeight: UploadConstraints.maxPhotoDimension,
          imageQuality: UploadConstraints.photoImageQuality,
        )
        .then((picked) => picked?.path);
  }
}
