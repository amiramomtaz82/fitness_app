import 'package:fitness_app/core/contants/upload_constraints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UploadConstraints', () {
    test('caps the profile photo at four megabytes', () {
      expect(UploadConstraints.maxProfilePhotoBytes, 4 * 1024 * 1024);
    });

    test('resizes the picked photo before it is uploaded', () {
      expect(UploadConstraints.maxPhotoDimension, 1080);
      expect(UploadConstraints.photoImageQuality, 85);
    });

    test('keeps the quality inside the range image pickers accept', () {
      expect(UploadConstraints.photoImageQuality, inInclusiveRange(0, 100));
      expect(UploadConstraints.maxPhotoDimension, greaterThan(0));
    });
  });
}
