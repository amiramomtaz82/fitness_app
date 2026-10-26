import 'package:fitness_app/core/youtube/youtube_video_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const id = 'dQw4w9WgXcQ';

  group('youtubeVideoId —', () {
    test('reads a raw 11-character id', () {
      expect(youtubeVideoId(id), id);
      expect(youtubeVideoId('  $id  '), id);
      expect(youtubeVideoId('AbC-def_123'), 'AbC-def_123');
    });

    test('reads watch, short, embed, shorts, and live URLs', () {
      expect(youtubeVideoId('https://www.youtube.com/watch?v=$id'), id);
      expect(youtubeVideoId('https://youtube.com/watch?v=$id&t=43'), id);
      expect(youtubeVideoId('http://m.youtube.com/watch?v=$id'), id);
      expect(youtubeVideoId('https://youtu.be/$id'), id);
      expect(youtubeVideoId('https://www.youtu.be/$id?si=share'), id);
      expect(youtubeVideoId('https://www.youtube.com/embed/$id?start=10'), id);
      expect(youtubeVideoId('https://m.youtube.com/shorts/$id'), id);
      expect(youtubeVideoId('https://www.youtube.com/live/$id'), id);
    });

    test('rejects empty, malformed, and non-YouTube values', () {
      expect(youtubeVideoId(''), isNull);
      expect(youtubeVideoId('   '), isNull);
      expect(youtubeVideoId('not a url'), isNull);
      expect(youtubeVideoId('dQw4w9WgXc'), isNull);
      expect(youtubeVideoId('dQw4w9WgXcQQ'), isNull);
      expect(youtubeVideoId('dQw4w9WgXc!'), isNull);
      expect(youtubeVideoId('https://example.com/watch?v=$id'), isNull);
      expect(youtubeVideoId('https://youtube.com/watch?v=short'), isNull);
      expect(youtubeVideoId('https://youtube.com/watch'), isNull);
      expect(youtubeVideoId('https://youtu.be/'), isNull);
      expect(youtubeVideoId('https://youtube.com/embed/'), isNull);
      expect(youtubeVideoId('https://youtube.com/channel/UCxxxxxxxx'), isNull);
      expect(youtubeVideoId('javascript:alert(1)'), isNull);
    });
  });
}
