import 'package:flutter_test/flutter_test.dart';
import 'package:nutrilens/services/tasty_search_query.dart';

void main() {
  group('tastySearchQueriesFor', () {
    test('returns progressively simpler fallback queries', () {
      final queries = tastySearchQueriesFor(
        'Power Oats & Berries Bowl (High Protein)',
      );

      expect(queries.first, 'Power Oats & Berries Bowl (High Protein)');
      expect(queries, contains('Power Oats & Berries Bowl'));
      expect(queries, contains('Oats Berries Bowl'));
      expect(queries.last, 'Oats Berries');
    });

    test('deduplicates identical queries', () {
      expect(
        tastySearchQueriesFor('Chicken Stir Fry'),
        ['Chicken Stir Fry', 'Chicken Stir'],
      );
    });
  });

  group('tastyTitleSimilarityScore', () {
    test('scores overlapping recipe names higher', () {
      expect(
        tastyTitleSimilarityScore('Chicken Stir Fry', 'Easy Chicken Stir Fry'),
        greaterThan(0.5),
      );
      expect(
        tastyTitleSimilarityScore('Chicken Stir Fry', 'Chocolate Cake'),
        lessThan(0.5),
      );
    });
  });
}
