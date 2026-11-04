import 'package:flutter/material.dart';
import 'avatar_local_photo.dart';
import 'avatar_placeholder.dart';
import 'avatar_remote_photo.dart';

class AvatarPhoto extends StatelessWidget {
  final String? localPath;
  final String? url;

  const AvatarPhoto({super.key, this.localPath, this.url});

  @override
  Widget build(BuildContext context) {
    const placeholder = AvatarPlaceholder();
    final remote = url;
    final remotePhoto = remote == null
        ? placeholder
        : AvatarRemotePhoto(url: remote, fallback: placeholder);
    final path = localPath;
    if (path != null) {
      return AvatarLocalPhoto(localPath: path, fallback: remotePhoto);
    }
    return remotePhoto;
  }
}
