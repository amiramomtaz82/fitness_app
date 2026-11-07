import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:fitness_app/core/local/dbs_asset_installer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';


class MockAssetBundle extends Mock implements AssetBundle {}

void main() {
  late MockAssetBundle bundle;
  late SharedPreferences prefs;
  late Directory tempDir;
  late DBsAssetInstaller installer;

  final exercisesBytes = Uint8List.fromList([1, 2, 3]);
  final mealsBytes = Uint8List.fromList([4, 5, 6]);

  // Same shape as the real manifest.json (uppercase hash)
  String manifest({
    int exercisesVersion = 1,
    int mealsVersion = 1,
    String? exercisesHash,
  }) => jsonEncode({
    'exercises.db': {
      'version': exercisesVersion,
      'hash':
          exercisesHash ??
          sha256.convert(exercisesBytes).toString().toUpperCase(),
    },
    'meals.db': {
      'version': mealsVersion,
      'hash': sha256.convert(mealsBytes).toString().toUpperCase(),
    },
  });

  void stubAssets(String manifestJson) {
    when(() => bundle.loadString(any())).thenAnswer((_) async => manifestJson);
    when(
      () => bundle.load('assets/database/exercises.db'),
    ).thenAnswer((_) async => ByteData.sublistView(exercisesBytes));
    when(
      () => bundle.load('assets/database/meals.db'),
    ).thenAnswer((_) async => ByteData.sublistView(mealsBytes));
  }

  setUp(() async {
    bundle = MockAssetBundle();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    tempDir = Directory.systemTemp.createTempSync('dbs_installer_test');
    installer = DBsAssetInstaller(
      assetBundle: bundle,
      prefs: prefs,
      getDatabasesPath: () async => tempDir.path,
    );
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  test('first run copies both databases and saves their versions', () async {
    stubAssets(manifest());

    await installer.ensureInstalled();

    expect(
      File(p.join(tempDir.path, 'exercises.db')).readAsBytesSync(),
      exercisesBytes,
    );
    expect(
      File(p.join(tempDir.path, 'meals.db')).readAsBytesSync(),
      mealsBytes,
    );
    expect(prefs.getInt(DBsAssetInstaller.versionKey('exercises.db')), 1);
    expect(prefs.getInt(DBsAssetInstaller.versionKey('meals.db')), 1);
  });

  test('accepts an uppercase hash from the manifest', () async {
    stubAssets(manifest());

    await expectLater(installer.ensureInstalled(), completes);
  });

  test('does not leave tmp files after copying', () async {
    stubAssets(manifest());

    await installer.ensureInstalled();

    final tmpFiles = tempDir.listSync().where((f) => f.path.endsWith('.tmp'));
    expect(tmpFiles, isEmpty);
  });

  test('skips copying when version matches and files exist', () async {
    stubAssets(manifest());
    await installer.ensureInstalled();
    clearInteractions(bundle);
    stubAssets(manifest());

    await installer.ensureInstalled();

    verifyNever(() => bundle.load(any()));
  });

  test('copies again when a database file is missing', () async {
    stubAssets(manifest());
    await installer.ensureInstalled();
    File(p.join(tempDir.path, 'meals.db')).deleteSync();

    await installer.ensureInstalled();

    expect(File(p.join(tempDir.path, 'meals.db')).existsSync(), isTrue);
  });

  test('copies only the database whose version changed', () async {
    stubAssets(manifest());
    await installer.ensureInstalled();
    clearInteractions(bundle);

    stubAssets(manifest(mealsVersion: 2));
    await installer.ensureInstalled();

    verify(() => bundle.load('assets/database/meals.db')).called(1);
    verifyNever(() => bundle.load('assets/database/exercises.db'));
    expect(prefs.getInt(DBsAssetInstaller.versionKey('meals.db')), 2);
    expect(prefs.getInt(DBsAssetInstaller.versionKey('exercises.db')), 1);
  });

  test('throws on checksum mismatch and does not save the version', () async {
    stubAssets(manifest(exercisesHash: 'WRONGHASH'));

    await expectLater(installer.ensureInstalled(), throwsStateError);

    expect(prefs.getInt(DBsAssetInstaller.versionKey('exercises.db')), isNull);
    expect(File(p.join(tempDir.path, 'exercises.db')).existsSync(), isFalse);
  });
}
