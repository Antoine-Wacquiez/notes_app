import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';
import 'note_storage_exception.dart';

/// Persistance des notes en JSON via [SharedPreferences].
class NoteLocalStorage {
  NoteLocalStorage({SharedPreferences? preferences}) : _prefs = preferences;

  static const _keyNotes = 'notes_app_v1_notes';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _instance() async {
    try {
      return _prefs ??= await SharedPreferences.getInstance();
    } catch (e, st) {
      debugPrint('NoteLocalStorage._instance: $e\n$st');
      throw NoteStorageException(
        'Accès au stockage local impossible. Réessaie après redémarrage de l’app.',
      );
    }
  }

  Future<List<Note>> load() async {
    try {
      final prefs = await _instance();
      final raw = prefs.getString(_keyNotes);
      if (raw == null || raw.isEmpty) {
        return [];
      }
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        throw const FormatException('payload n’est pas une liste');
      }
      final list = <Note>[];
      for (final item in decoded) {
        if (item is! Map) {
          continue;
        }
        try {
          list.add(Note.fromJson(Map<String, dynamic>.from(item)));
        } catch (e, st) {
          debugPrint('Note ignorée (JSON invalide): $e\n$st');
        }
      }
      return list;
    } on NoteStorageException {
      rethrow;
    } on FormatException catch (e, st) {
      debugPrint('NoteLocalStorage.load FormatException: $e\n$st');
      throw NoteStorageException(
        'Les données enregistrées sont corrompues ou incompatibles.',
      );
    } catch (e, st) {
      debugPrint('NoteLocalStorage.load: $e\n$st');
      throw NoteStorageException(
        'Impossible de lire tes notes en local.',
      );
    }
  }

  Future<void> save(List<Note> notes) async {
    try {
      final prefs = await _instance();
      final payload = jsonEncode(notes.map((n) => n.toJson()).toList());
      final ok = await prefs.setString(_keyNotes, payload);
      if (!ok) {
        throw NoteStorageException(
          'L’enregistrement sur cet appareil a échoué.',
        );
      }
    } on NoteStorageException {
      rethrow;
    } catch (e, st) {
      debugPrint('NoteLocalStorage.save: $e\n$st');
      throw NoteStorageException(
        'Impossible d’enregistrer tes notes en local.',
      );
    }
  }
}
