import 'package:fitness_app/core/youtube/youtube_video_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const id = 'dQw4w9WgXcQ';

  group('extractYoutubeVideoId —', () {
    test('reads a raw 11-character id', () {
      expect(extractYoutubeVideoId(id), id);
      expect(extractYoutubeVideoId('  $id  '), id);
      expect(extractYoutubeVideoId('AbC-def_123'), 'AbC-def_123');
    });

    test('a matching id is only a text shape, not an existing video', () {
      expect(extractYoutubeVideoId('not-a-video'), 'not-a-video');
    });

    test('reads watch, short, embed, shorts, and live URLs', () {
      expect(extractYoutubeVideoId('https://www.youtube.com/watch?v=$id'), id);
      expect(extractYoutubeVideoId('https://youtube.com/watch?v=$id&t=43'), id);
      expect(extractYoutubeVideoId('http://m.youtube.com/watch?v=$id'), id);
      expect(extractYoutubeVideoId('https://youtu.be/$id'), id);
      expect(extractYoutubeVideoId('https://www.youtu.be/$id?si=share'), id);
      expect(
        extractYoutubeVideoId('https://www.youtube.com/embed/$id?start=10'),
        id,
      );
      expect(extractYoutubeVideoId('https://m.youtube.com/shorts/$id'), id);
      expect(extractYoutubeVideoId('https://www.youtube.com/live/$id'), id);
    });

    test('rejects empty, malformed, and non-YouTube values', () {
      expect(extractYoutubeVideoId(''), isNull);
      expect(extractYoutubeVideoId('   '), isNull);
      expect(extractYoutubeVideoId('not a url'), isNull);
      expect(extractYoutubeVideoId('dQw4w9WgXc'), isNull);
      expect(extractYoutubeVideoId('dQw4w9WgXcQQ'), isNull);
      expect(extractYoutubeVideoId('dQw4w9WgXc!'), isNull);
      expect(extractYoutubeVideoId('https://example.com/watch?v=$id'), isNull);
      expect(
        extractYoutubeVideoId('https://youtube.com/watch?v=short'),
        isNull,
      );
      expect(extractYoutubeVideoId('https://youtube.com/watch'), isNull);
      expect(extractYoutubeVideoId('https://youtu.be/'), isNull);
      expect(extractYoutubeVideoId('https://youtube.com/embed/'), isNull);
      expect(
        extractYoutubeVideoId('https://youtube.com/channel/UCxxxxxxxx'),
        isNull,
      );
      expect(extractYoutubeVideoId('javascript:alert(1)'), isNull);
    });
  });
}
