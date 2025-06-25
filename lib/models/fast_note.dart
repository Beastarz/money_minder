import 'package:flutter/material.dart';

class FastNote{
  final int id;
  final String note;
  final IconData icon;
  final int categoryId;

  FastNote({
    required this.id,
    required this.note,
    required this.icon,
    required this.categoryId,
  });

  /// use this to convert map to fast note
  ///
  /// Parameters:
  ///
  /// Map\<String, dynamic\> map: map to be converted
  ///
  /// Returns: FastNote
  factory FastNote.fromMap(Map<String, dynamic> map) {
    return FastNote(
      id: map['id'],
      note: map['note'],
      icon: IconData(
          map['icon'] as int,
          fontFamily: 'MaterialSymbolsOutlined'
      ),
      categoryId: map['category_id']
    );
  }

  /// use this to convert FastNote to map
  ///
  /// Parameters:
  ///
  /// note: note of the fast note
  ///
  /// codePoint: code point of the icon
  ///
  /// mainCategoryId: id of the main category
  ///
  /// Returns: map of fast note
  static Map<String, dynamic> insertAsMap({
    required String note,
    required int codePoint,
    required int categoryId,
  }) {
    return {
      'note': note,
      'icon': codePoint,
      'category_id': categoryId,
    };
  }
}