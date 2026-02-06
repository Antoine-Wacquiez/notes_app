import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note.dart'; // On importe le modèle Note

class NoteService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com/posts';

  Future<List<Note>> recupererNotes() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.take(10).map((json) => Note.fromJson(json)).toList();
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion');
    }
  }
}
