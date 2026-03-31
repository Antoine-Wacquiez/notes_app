import 'dart:math';

import 'package:flutter/material.dart';

import '../models/note.dart';
import '../repositories/note_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/barre_recherche_notes.dart';
import '../widgets/note_list_tile.dart';
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
  final NoteRepository _repository = NoteRepository();
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
      final notes = await _repository.recupererNotes();
      if (!mounted) return;
      setState(() {
        _notesLocales = notes;
        _notesFiltrees = List.from(notes);
        _chargement = false;
      });
    } catch (e) {
      if (!mounted) return;
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
        Note(id: Random().nextInt(100000) + 1000, title: '', content: '');
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

    if (!mounted) return;
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
        content: const Text('Note supprimée'),
        action: SnackBarAction(
          label: 'Annuler',
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
  void dispose() {
    _rechercheCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final couleurTexte = widget.isDark ? Colors.white : Colors.black;
    final couleurFondListe = widget.isDark
        ? AppColors.carteSombre
        : Colors.white;
    final aucuneNote = _notesLocales.isEmpty;
    final aucunResultat = _notesFiltrees.isEmpty;

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
                color: AppColors.jauneNotes,
              ),
              SizedBox(width: 5),
              Text(
                'Dossiers',
                style: TextStyle(fontSize: 17, color: AppColors.jauneNotes),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_horiz_rounded,
              color: AppColors.jauneNotes,
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
                child: const Text('Réessayer'),
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
                        'Notes',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: couleurTexte,
                        ),
                      ),
                      const SizedBox(height: 10),
                      BarreRechercheNotes(
                        controller: _rechercheCtrl,
                        isDark: widget.isDark,
                        couleurTexte: couleurTexte,
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
                        child: aucunResultat
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        aucuneNote
                                            ? Icons.note_alt_outlined
                                            : Icons.search_off,
                                        color: Colors.grey.shade500,
                                        size: 42,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        aucuneNote
                                            ? 'Aucune note pour le moment'
                                            : 'Aucun resultat pour cette recherche',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: couleurTexte,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        aucuneNote
                                            ? 'Appuie sur le bouton en bas a droite pour creer ta premiere note.'
                                            : 'Essaie avec un autre mot-clé.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.separated(
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
                                    child: NoteListTile(
                                      note: note,
                                      couleurTexte: couleurTexte,
                                      onTap: () =>
                                          _ouvrirEditeur(noteExistant: note),
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
                      ? AppColors.carteSombre
                      : AppColors.fondClair,
                  child: SafeArea(
                    top: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 24),
                        Text(
                          '${_notesLocales.length} Notes',
                          style: TextStyle(fontSize: 12, color: couleurTexte),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit_square,
                            color: AppColors.jauneNotes,
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
