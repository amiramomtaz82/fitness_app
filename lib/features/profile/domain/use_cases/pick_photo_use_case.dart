import 'package:injectable/injectable.dart';
import '../../../../core/base_response/base_response.dart';
import '../../../../core/base_response/safe_call.dart';
import '../services/photo_picker.dart';

@injectable
class PickPhotoUseCase {
  final PhotoPicker _photoPicker;

  const PickPhotoUseCase(this._photoPicker);

  Future<BaseResponse<String?>> call() => safeCall(_photoPicker.pickPhoto);
}
