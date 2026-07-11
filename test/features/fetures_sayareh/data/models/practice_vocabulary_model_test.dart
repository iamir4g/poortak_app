import 'package:flutter_test/flutter_test.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/practice_vocabulary_model.dart';

void main() {
  group('PracticeVocabularyModel', () {
    test('parses practice response with stats', () {
      final model = practiceVocabularyModelFromJson('''
{
  "ok": true,
  "meta": {},
  "data": {
    "correctWord": {
      "id": "986becba-db6b-4517-983e-e8cc372c54f5",
      "word": "Arch",
      "translation": "آرچ",
      "thumbnail": "17149b1f-42dc-4a25-8515-7a31a1eb62ef",
      "order": 0,
      "createdAt": "2025-05-02T11:53:59.384Z",
      "updatedAt": "2025-05-02T11:53:59.384Z",
      "disabledAt": null,
      "courseId": "429febcd-f613-4413-8657-84ee8a97ddff"
    },
    "wrongWord": {
      "id": "9664ed5e-22d9-491c-af2d-dfcfa76091ac",
      "word": "Renotive",
      "translation": "رنوتیو",
      "thumbnail": "066c89db-352d-4ab3-b461-6b5528ace0f6",
      "order": 0,
      "createdAt": "2025-05-02T11:53:35.612Z",
      "updatedAt": "2025-05-02T11:53:35.612Z",
      "disabledAt": null,
      "courseId": "429febcd-f613-4413-8657-84ee8a97ddff"
    },
    "stats": {
      "total": 5,
      "test": 5,
      "remaining": 5
    }
  }
}
''');

      expect(model.data.stats.total, 5);
      expect(model.data.stats.test, 5);
      expect(model.data.stats.remaining, 5);
      expect(model.data.stats.currentIndex, 0);
    });

    test('currentIndex advances as remaining decreases', () {
      const stats = PracticeStats(total: 5, test: 5, remaining: 2);
      expect(stats.currentIndex, 3);
    });
  });
}
