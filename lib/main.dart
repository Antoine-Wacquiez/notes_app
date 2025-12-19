import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  runApp(const AppleNoteApp());
}

// ==========================================
// 1. LE MODÈLE
// ==========================================
class Note {
  int id;
  String titre;
  String contenu;
  DateTime date; // Ajout d'une date pour le réalisme

  Note({
    required this.id,
    required this.titre,
    required this.contenu,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      titre: json['title'] ?? 'Sans titre',
      contenu: json['body'] ?? '',
    );
  }
}

// ==========================================
// 2. LE SERVICE API
// ==========================================
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

// ==========================================
// 3. CONFIGURATION DE L'APP
// ==========================================
class AppleNoteApp extends StatefulWidget {
  const AppleNoteApp({super.key});

  @override
  State<AppleNoteApp> createState() => _AppleNoteAppState();
}

class _AppleNoteAppState extends State<AppleNoteApp> {
  bool _modeSombre = false;

  void _toggleTheme() {
    setState(() {
      _modeSombre = !_modeSombre;
    });
  }

  @override
  Widget build(BuildContext context) {
    const couleurJaune = Color(0xFFFFCC00);
    const grisFondClair = Color(0xFFF2F2F7);
    const grisFondSombre = Color(0xFF000000);

    return MaterialApp(
      title: 'Notes',
      debugShowCheckedModeBanner: false,
      themeMode: _modeSombre ? ThemeMode.dark : ThemeMode.light,

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: grisFondClair,
        primaryColor: couleurJaune,
        appBarTheme: const AppBarTheme(
          backgroundColor: grisFondClair,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: couleurJaune,
        ),
      ),

      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: grisFondSombre,
        appBarTheme: const AppBarTheme(
          backgroundColor: grisFondSombre,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: couleurJaune,
        ),
      ),

      home: EcranPrincipal(toggleTheme: _toggleTheme, isDark: _modeSombre),
    );
  }
}

// ==========================================
// 4. ÉCRAN PRINCIPAL (Liste)
// ==========================================
class EcranPrincipal extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDark;

  const EcranPrincipal({
    super.key,
    required this.toggleTheme,
    required this.isDark,
  });

  @override
  State<EcranPrincipal> createState() => _EcranPrincipalState();
}

class _EcranPrincipalState extends State<EcranPrincipal> {
  final NoteService _service = NoteService();
  List<Note> _notesLocales = [];
  List<Note> _notesFiltrees = [];
  bool _chargement = true;
  bool _erreur = false;
  final TextEditingController _rechercheCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initialiserDonnees();
    _rechercheCtrl.addListener(_filtrerNotes);
  }

  void _initialiserDonnees() async {
    try {
      final notes = await _service.recupererNotes();
      setState(() {
        _notesLocales = notes;
        _notesFiltrees = List.from(notes);
        _chargement = false;
      });
    } catch (e) {
      setState(() {
        _erreur = true;
        _chargement = false;
      });
    }
  }

  void _filtrerNotes() {
    final query = _rechercheCtrl.text.toLowerCase();
    setState(() {
      _notesFiltrees = _notesLocales.where((note) {
        return note.titre.toLowerCase().contains(query) ||
            note.contenu.toLowerCase().contains(query);
      }).toList();
    });
  }

  // --- LOGIQUE CRÉATION / MODIFICATION ---
  void _ouvrirEditeur({Note? noteExistant}) async {
    // Si noteExistant est null, c'est une nouvelle note
    final noteEnCours =
        noteExistant ??
        Note(id: Random().nextInt(100000) + 1000, titre: "", contenu: "");

    // On attend le retour de l'écran d'édition (true si Sauvegardé, null si Annulé)
    final aSauvegarde = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EcranDetail(
          note: noteEnCours,
          isDark: widget.isDark,
          isNew: noteExistant == null, // On précise si c'est nouveau
        ),
      ),
    );

    // Si l'utilisateur a appuyé sur OK
    if (aSauvegarde == true) {
      setState(() {
        if (noteExistant == null) {
          // C'était une nouvelle note, on l'ajoute
          _notesLocales.insert(0, noteEnCours);
        }
        // Si c'était une modif, l'objet est déjà modifié par référence,
        // on a juste besoin de rafraichir la liste
        _filtrerNotes();
      });
    }
  }

  // --- LOGIQUE SUPPRESSION (Corrigée) ---
  void _supprimerNote(Note note) {
    final indexBackup = _notesLocales.indexOf(note);
    setState(() {
      _notesLocales.removeWhere((n) => n.id == note.id);
      _filtrerNotes();
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Note supprimée"),
        action: SnackBarAction(
          label: "Annuler",
          onPressed: () {
            setState(() {
              if (indexBackup >= 0) {
                _notesLocales.insert(indexBackup, note);
              } else {
                _notesLocales.add(note);
              }
              _filtrerNotes();
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final couleurTexte = widget.isDark ? Colors.white : Colors.black;
    final couleurFondListe = widget.isDark
        ? const Color(0xFF1C1C1E)
        : Colors.white;
    final couleurRecherche = widget.isDark
        ? const Color(0xFF1C1C1E)
        : const Color(0xFFE3E3E8);

    return Scaffold(
      // Utilisation d'AppBar pour éviter l'erreur "Overflowed"
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: false,
        title: Row(
          children: const [
            SizedBox(width: 8),
            Icon(Icons.arrow_back_ios_new, size: 22),
            SizedBox(width: 5),
            Text("Dossiers", style: TextStyle(fontSize: 17)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              widget.isDark ? Icons.light_mode : Icons.dark_mode_outlined,
            ),
            onPressed: widget.toggleTheme,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _chargement
          ? const Center(child: CircularProgressIndicator.adaptive())
          : _erreur
          ? Center(
              child: TextButton(
                onPressed: _initialiserDonnees,
                child: const Text("Réessayer"),
              ),
            )
          : Column(
              children: [
                // En-tête "Notes" + Recherche
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Notes",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: couleurTexte,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: couleurRecherche,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: _rechercheCtrl,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            hintText: "Rechercher",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          style: TextStyle(color: couleurTexte),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Liste des notes
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        color: couleurFondListe,
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _notesFiltrees.length,
                          separatorBuilder: (c, i) => Divider(
                            height: 1,
                            indent: 16,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                          itemBuilder: (context, index) {
                            final note = _notesFiltrees[index];
                            return Dismissible(
                              key: Key(
                                note.id.toString(),
                              ), // Clé unique essentielle
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (_) => _supprimerNote(note),
                              child: ListTile(
                                onTap: () => _ouvrirEditeur(noteExistant: note),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                title: Text(
                                  note.titre.isEmpty
                                      ? "Nouvelle note"
                                      : note.titre,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: couleurTexte,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    "${note.date.hour}:${note.date.minute.toString().padLeft(2, '0')}  ${note.contenu.replaceAll('\n', ' ')}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // Footer
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: widget.isDark
                      ? const Color(0xFF1C1C1E)
                      : const Color(0xFFF2F2F7),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 24),
                        Text(
                          "${_notesLocales.length} Notes",
                          style: TextStyle(fontSize: 12, color: couleurTexte),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit_square,
                            color: Color(0xFFFFCC00),
                            size: 28,
                          ),
                          onPressed: () => _ouvrirEditeur(), // Nouvelle note
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ==========================================
// 5. ÉCRAN D'ÉDITION (Detail)
// ==========================================
class EcranDetail extends StatefulWidget {
  final Note note;
  final bool isDark;
  final bool isNew;

  const EcranDetail({
    super.key,
    required this.note,
    required this.isDark,
    required this.isNew,
  });

  @override
  State<EcranDetail> createState() => _EcranDetailState();
}

class _EcranDetailState extends State<EcranDetail> {
  late TextEditingController _titreCtrl;
  late TextEditingController _contenuCtrl;

  @override
  void initState() {
    super.initState();
    _titreCtrl = TextEditingController(text: widget.note.titre);
    _contenuCtrl = TextEditingController(text: widget.note.contenu);
  }

  void _sauvegarderEtQuitter() {
    // 1. On met à jour l'objet Note uniquement ici
    widget.note.titre = _titreCtrl.text;
    widget.note.contenu = _contenuCtrl.text;
    widget.note.date = DateTime.now();

    // 2. On renvoie "true" pour dire qu'on a validé
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _titreCtrl.dispose();
    _contenuCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final couleurFond = widget.isDark ? Colors.black : Colors.white;
    final couleurTexte = widget.isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: couleurFond,
      appBar: AppBar(
        backgroundColor: couleurFond,
        // Bouton Retour (Annuler)
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context, false), // false = Annuler
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Color(0xFFFFCC00),
          ),
          label: const Text(
            "Notes",
            style: TextStyle(color: Color(0xFFFFCC00), fontSize: 17),
          ),
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 10),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.ios_share, color: Color(0xFFFFCC00)),
          ),
          // BOUTON OK (Sauvegarder)
          TextButton(
            onPressed: _sauvegarderEtQuitter,
            child: const Text(
              "OK",
              style: TextStyle(
                color: Color(0xFFFFCC00),
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            TextField(
              controller: _titreCtrl,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: couleurTexte,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Titre',
              ),
              maxLines: null,
            ),
            Text(
              "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} à ${DateTime.now().hour}:${DateTime.now().minute}",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TextField(
                controller: _contenuCtrl,
                style: TextStyle(
                  fontSize: 17,
                  color: couleurTexte,
                  height: 1.5,
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Tapez ici...',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
