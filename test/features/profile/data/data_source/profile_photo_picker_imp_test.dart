import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/core/contants/upload_constraints.dart';
import 'package:fitness_app/features/profile/data/data_source/profile_photo_picker_imp.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

import '../../profile_test_helper.dart';

void main() {
  late MockImagePicker mockImagePicker;
  late ProfilePhotoPickerImp photoPicker;

  setUpAll(registerProfileFallbacks);

  setUp(() {
    mockImagePicker = MockImagePicker();
    photoPicker = ProfilePhotoPickerImp(mockImagePicker);
  });

  void stubPick(XFile? file) {
    when(
      () => mockImagePicker.pickImage(
        source: any(named: 'source'),
        maxWidth: any(named: 'maxWidth'),
        maxHeight: any(named: 'maxHeight'),
        imageQuality: any(named: 'imageQuality'),
      ),
    ).thenAnswer((_) async => file);
  }

  group('ProfilePhotoPickerImp', () {
    test('returns the path of the picked photo', () async {
      stubPick(XFile('/tmp/gallery/a.jpg'));

      expect(await photoPicker.pickPhoto(), '/tmp/gallery/a.jpg');
    });

    test(
      'downscales and compresses so the upload stays under the size cap',
      () async {
        stubPick(XFile('/tmp/a.jpg'));

        await photoPicker.pickPhoto();

        verify(
          () => mockImagePicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: UploadConstraints.maxPhotoDimension,
            maxHeight: UploadConstraints.maxPhotoDimension,
            imageQuality: UploadConstraints.photoImageQuality,
          ),
        ).called(1);
      },
    );

    test('reports a cancelled pick as a null path', () async {
      stubPick(null);

      expect(await photoPicker.pickPhoto(), isNull);
    });

    test('lets a picker error reach the caller', () async {
      when(
        () => mockImagePicker.pickImage(
          source: any(named: 'source'),
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
          imageQuality: any(named: 'imageQuality'),
        ),
      ).thenThrow(Exception('gallery unavailable'));

      expect(() => photoPicker.pickPhoto(), throwsA(isA<Exception>()));
    });
  });
}
