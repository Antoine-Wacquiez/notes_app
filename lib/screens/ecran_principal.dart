import 'dart:math';
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import 'ecran_detail.dart';

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

  void _ouvrirEditeur({Note? noteExistant}) async {
    final noteEnCours =
        noteExistant ??
        Note(id: Random().nextInt(100000) + 1000, titre: "", contenu: "");
    final aSauvegarde = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EcranDetail(
          note: noteEnCours,
          isDark: widget.isDark,
          isNew: noteExistant == null,
        ),
      ),
    );

    if (aSauvegarde == true) {
      setState(() {
        if (noteExistant == null) {
          _notesLocales.insert(0, noteEnCours);
        }
        _filtrerNotes();
      });
    }
  }

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
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: false,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: const [
              SizedBox(width: 8),
              Icon(
                Icons.arrow_back_ios_new,
                size: 22,
                color: Color(0xFFFFCC00),
              ),
              SizedBox(width: 5),
              Text(
                "Dossiers",
                style: TextStyle(fontSize: 17, color: Color(0xFFFFCC00)),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_horiz_rounded,
              color: Color(0xFFFFCC00),
            ),
            onPressed: () {},
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
                              key: Key(note.id.toString()),
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
                          onPressed: () => _ouvrirEditeur(),
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
