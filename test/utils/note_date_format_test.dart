import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/utils/note_date_format.dart';

void main() {
  group('formatDateRelativeListe', () {
    test('même jour → Aujourd\'hui', () {
      final ref = DateTime(2026, 4, 10, 18, 0);
      final d = DateTime(2026, 4, 10, 9, 30);
      expect(formatDateRelativeListe(d, ref), 'Aujourd\'hui');
    });

    test('même mois → jour + mois court', () {
      final ref = DateTime(2026, 4, 15);
      final d = DateTime(2026, 4, 9);
      expect(formatDateRelativeListe(d, ref), '9 avr.');
    });

    test('même année autre mois → nom du mois', () {
      final ref = DateTime(2026, 4, 15);
      final d = DateTime(2026, 2, 1);
      expect(formatDateRelativeListe(d, ref), 'février');
    });

    test('autre année → année', () {
      final ref = DateTime(2026, 4, 15);
      final d = DateTime(2024, 8, 1);
      expect(formatDateRelativeListe(d, ref), '2024');
    });
  });

  group('titreSectionMois', () {
    test('même année que la référence → mois capitalisé', () {
      final ref = DateTime(2026, 4, 10);
      expect(titreSectionMois(2026, 3, ref), 'Mars');
    });

    test('autre année → mois + année', () {
      final ref = DateTime(2026, 4, 10);
      expect(titreSectionMois(2024, 3, ref), 'Mars 2024');
    });
  });
}
