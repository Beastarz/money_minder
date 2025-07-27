import 'package:flutter_test/flutter_test.dart';
import 'package:money_minder/models/fast_note.dart';
import 'package:flutter/material.dart';

void main() {
  group('FastNote model', () {
    test('fromMap creates a valid FastNote object', () {
      final map = {
        'id': 1,
        'note': 'Lunch at cafe',
        'icon': Icons.fastfood.codePoint,
        'category_id': 2,
      };

      final fastNote = FastNote.fromMap(map);

      expect(fastNote.id, 1);
      expect(fastNote.note, 'Lunch at cafe');
      expect(fastNote.icon.codePoint, Icons.fastfood.codePoint);
      expect(fastNote.icon.fontFamily, 'MaterialSymbolsOutlined');
      expect(fastNote.categoryId, 2);
    });

    test('insertAsMap returns correct map structure', () {
      final map = FastNote.insertAsMap(
        note: 'Taxi to airport',
        codePoint: Icons.local_taxi.codePoint,
        categoryId: 3,
      );

      expect(map['note'], 'Taxi to airport');
      expect(map['icon'], Icons.local_taxi.codePoint);
      expect(map['category_id'], 3);
    });
  });
}
