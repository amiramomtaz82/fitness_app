final RegExp _videoIdPattern = RegExp(r'^[A-Za-z0-9_-]{11}$');

const Set<String> _youtubeHosts = {'youtube.com', 'm.youtube.com'};

const Set<String> _pathKinds = {'embed', 'shorts', 'live'};

String? extractYoutubeVideoId(String input) {
  final value = input.trim();
  if (value.isEmpty) return null;
  if (_videoIdPattern.hasMatch(value)) return value;
  return _idFromUri(value);
}

String? _idFromUri(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null || !_isHttp(uri)) return null;
  final host = _bareHost(uri.host);
  if (host == 'youtu.be') return _singleSegmentId(uri.pathSegments);
  if (!_youtubeHosts.contains(host)) return null;
  final fromQuery = uri.queryParameters['v'];
  if (fromQuery != null) return _validId(fromQuery);
  return _kindSegmentId(uri.pathSegments);
}

bool _isHttp(Uri uri) => uri.scheme == 'http' || uri.scheme == 'https';

String _bareHost(String host) {
  final normalized = host.toLowerCase();
  const prefix = 'www.';
  if (!normalized.startsWith(prefix)) return normalized;
  return normalized.substring(prefix.length);
}

String? _singleSegmentId(List<String> segments) {
  if (segments.length != 1) return null;
  return _validId(segments.first);
}

String? _kindSegmentId(List<String> segments) {
  if (segments.length != 2 || !_pathKinds.contains(segments.first)) return null;
  return _validId(segments[1]);
}

String? _validId(String value) {
  if (_videoIdPattern.hasMatch(value)) return value;
  return null;
}
