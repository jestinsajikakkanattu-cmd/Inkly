import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ProfileImageService {
  ProfileImageService._();

  static final ProfileImageService instance = ProfileImageService._();

  Future<String?> getImagePath(String uid) async {
    final directory = await getApplicationDocumentsDirectory();

    final file = File(
      "${directory.path}/profile_image_$uid.jpg",
    );

    if (await file.exists()) {
      return file.path;
    }

    return null;
  }

  Future<String> saveImage(
    File image,
    String uid,
  ) async {
    final directory = await getApplicationDocumentsDirectory();

    final destination = File(
      "${directory.path}/profile_image_$uid.jpg",
    );

    await image.copy(destination.path);

    return destination.path;
  }

  Future<void> deleteImage(String uid) async {
    final path = await getImagePath(uid);

    if (path == null) return;

    final file = File(path);

    if (await file.exists()) {
      await file.delete();
    }
  }
}