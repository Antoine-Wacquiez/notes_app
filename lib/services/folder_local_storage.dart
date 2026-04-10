import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/dossier.dart';
import 'note_storage_exception.dart';

class FolderLocalStorage {
  FolderLocalStorage({SharedPreferences? preferences}) : _prefs = preferences;

  static const _keyFolders = 'notes_app_v1_folders';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _instance() async {
    try {
      return _prefs ??= await SharedPreferences.getInstance();
    } catch (e, st) {
      debugPrint('FolderLocalStorage._instance: $e\n$st');
      throw NoteStorageException(
        'Accès au stockage des dossiers impossible.',
      );
    }
  }

  static const Dossier dossierNotesDefaut =
      Dossier(id: 'notes', name: 'Notes', noteCount: 0);

  Future<List<Dossier>> load() async {
    try {
      final prefs = await _instance();
      final raw = prefs.getString(_keyFolders);
      if (raw == null || raw.isEmpty) {
        await save(const [dossierNotesDefaut]);
        return const [dossierNotesDefaut];
      }
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        throw const FormatException('dossiers : payload invalide');
      }
      final list = <Dossier>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        final m = Map<String, dynamic>.from(item);
        final id = (m['id'] ?? '') as String;
        final name = (m['name'] ?? '') as String;
        if (id.isEmpty || name.isEmpty) continue;
        list.add(Dossier(id: id, name: name, noteCount: 0));
      }
      if (list.isEmpty) {
        await save(const [dossierNotesDefaut]);
        return const [dossierNotesDefaut];
      }
      if (!list.any((d) => d.id == 'notes')) {
        list.insert(0, dossierNotesDefaut);
        await save(list);
      }
      return list;
    } on NoteStorageException {
      rethrow;
    } on FormatException catch (e, st) {
      debugPrint('FolderLocalStorage.load FormatException: $e\n$st');
      throw NoteStorageException('Données dossiers corrompues ou incompatibles.');
    } catch (e, st) {
      debugPrint('FolderLocalStorage.load: $e\n$st');
      throw NoteStorageException('Impossible de lire les dossiers.');
    }
  }

  Future<void> save(List<Dossier> folders) async {
    try {
      final prefs = await _instance();
      final payload = jsonEncode(
        folders
            .map((f) => {
                  'id': f.id,
                  'name': f.name,
                })
            .toList(),
      );
      final ok = await prefs.setString(_keyFolders, payload);
      if (!ok) {
        throw NoteStorageException('Enregistrement des dossiers échoué.');
      }
    } on NoteStorageException {
      rethrow;
    } catch (e, st) {
      debugPrint('FolderLocalStorage.save: $e\n$st');
      throw NoteStorageException('Impossible d’enregistrer les dossiers.');
    }
  }
}
