import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/models/dossier.dart';
import 'package:notes_app/services/folder_local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FolderLocalStorage', () {
    test('préférences vides → dossier Notes par défaut persisté', () async {
      final storage = FolderLocalStorage();
      final loaded = await storage.load();
      expect(loaded.length, greaterThanOrEqualTo(1));
      expect(loaded.any((d) => d.id == 'notes'), isTrue);

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('notes_app_v1_folders');
      expect(raw, isNotNull);
      final list = jsonDecode(raw!) as List<dynamic>;
      expect(list.isNotEmpty, isTrue);
    });

    test('save puis load : round-trip noms', () async {
      final storage = FolderLocalStorage();
      await storage.save(const [
        Dossier(id: 'notes', name: 'Notes', noteCount: 0),
        Dossier(id: 'a', name: 'Travail', noteCount: 0),
      ]);
      final loaded = await storage.load();
      expect(loaded.map((d) => d.name).toList(), containsAll(['Notes', 'Travail']));
    });
  });
}
