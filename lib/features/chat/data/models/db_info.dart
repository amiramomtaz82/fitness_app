class DbInfo {
  final int version;
  final String hash;

  DbInfo({required this.version, required this.hash});

  factory DbInfo.fromJson(Map<String, dynamic> json) {
    return DbInfo(version: json['version'], hash: json['hash']);
  }
}
