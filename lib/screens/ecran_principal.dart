import 'dart:math';

import 'package:flutter/material.dart';

import '../models/note.dart';
import '../repositories/note_repository.dart';
import '../theme/app_colors.dart';
import '../utils/app_feedback.dart';
import '../utils/note_date_format.dart';
import '../utils/user_messages.dart';
import '../widgets/barre_recherche_notes.dart';
import '../widgets/note_list_tile.dart';
import 'ecran_detail.dart';

enum _TriNotes { dateModif, dateCreation, titre }

class EcranPrincipal extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDark;
  final String folderId;
  final String folderName;

  const EcranPrincipal({
    super.key,
    required this.toggleTheme,
    required this.isDark,
    required this.folderId,
    required this.folderName,
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
  String? _messageErreur;
  final TextEditingController _rechercheCtrl = TextEditingController();

  _TriNotes _tri = _TriNotes.dateCreation;
  bool _modeSelection = false;
  final Set<int> _idsSelection = {};

  @override
  void initState() {
    super.initState();
    _initialiserDonnees();
    _rechercheCtrl.addListener(_filtrerNotes);
  }

  List<Note> _trierEtFiltrer() {
    final list = _repository.filtrerParRecherche(
      _notesLocales,
      _rechercheCtrl.text,
    );
    switch (_tri) {
      case _TriNotes.dateModif:
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case _TriNotes.dateCreation:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case _TriNotes.titre:
        list.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
    }
    return list;
  }

  void _filtrerNotes() {
    setState(() {
      _notesFiltrees = _trierEtFiltrer();
    });
  }

  void _changerTri(_TriNotes tri) {
    setState(() {
      _tri = tri;
      _notesFiltrees = _trierEtFiltrer();
    });
  }

  Future<void> _initialiserDonnees() async {
    try {
      final toutes = await _repository.recupererNotes();
      final dansDossier = toutes
          .where((n) => n.folderId == widget.folderId)
          .toList();
      if (!mounted) return;
      setState(() {
        _notesLocales = dansDossier;
        _notesFiltrees = _trierEtFiltrer();
        _chargement = false;
        _erreur = false;
        _messageErreur = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erreur = true;
        _chargement = false;
        _messageErreur = UserMessages.depuisErreur(e);
      });
    }
  }

  Future<void> _persisterToutesLesNotes() async {
    try {
      final toutes = await _repository.recupererNotes();
      final autres = toutes
          .where((n) => n.folderId != widget.folderId)
          .toList();
      await _repository.saveNotes([...autres, ..._notesLocales]);
    } catch (e) {
      if (!mounted) return;
      AppFeedback.showError(context, UserMessages.depuisErreur(e));
    }
  }

  Future<void> _ouvrirEditeur({Note? noteExistant}) async {
    final noteEnCours =
        noteExistant ??
        Note(
          id: Random().nextInt(100000) + 1000,
          title: '',
          content: '',
          folderId: widget.folderId,
        );
    if (noteExistant == null) {
      noteEnCours.folderId = widget.folderId;
    }
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
      noteEnCours.folderId = widget.folderId;
      setState(() {
        if (noteExistant == null) {
          _notesLocales.insert(0, noteEnCours);
        }
        _notesFiltrees = _trierEtFiltrer();
      });
      await _persisterToutesLesNotes();
    }
  }

  void _supprimerNote(Note note) {
    final indexBackup = _notesLocales.indexOf(note);
    setState(() {
      _notesLocales.removeWhere((n) => n.id == note.id);
      _notesFiltrees = _trierEtFiltrer();
    });
    _persisterToutesLesNotes();

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
              _notesFiltrees = _trierEtFiltrer();
            });
            _persisterToutesLesNotes();
          },
        ),
      ),
    );
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_idsSelection.contains(id)) {
        _idsSelection.remove(id);
      } else {
        _idsSelection.add(id);
      }
    });
  }

  void _quitterModeSelection() {
    setState(() {
      _modeSelection = false;
      _idsSelection.clear();
    });
  }

  Future<void> _supprimerSelection() async {
    if (_idsSelection.isEmpty) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer les notes ?'),
        content: Text(
          '${_idsSelection.length} note(s) seront supprimées définitivement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final ids = Set<int>.from(_idsSelection);
    setState(() {
      _notesLocales.removeWhere((n) => ids.contains(n.id));
      _modeSelection = false;
      _idsSelection.clear();
      _notesFiltrees = _trierEtFiltrer();
    });
    await _persisterToutesLesNotes();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${ids.length} note(s) supprimée(s)')),
      );
    }
  }

  bool get _triParDate =>
      _tri == _TriNotes.dateModif || _tri == _TriNotes.dateCreation;

  List<({String titre, List<Note> notes})> _grouperNotesParMois(
    List<Note> notes,
  ) {
    if (notes.isEmpty) return [];
    final ref = DateTime.now();
    final titres = <String>[];
    final groupes = <List<Note>>[];
    String? lastKey;

    for (final n in notes) {
      final raw = _tri == _TriNotes.dateCreation ? n.createdAt : n.updatedAt;
      final d = raw.toLocal();
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
      if (key != lastKey) {
        lastKey = key;
        titres.add(titreSectionMois(d.year, d.month, ref));
        groupes.add(<Note>[]);
      }
      groupes.last.add(n);
    }
    return List.generate(
      titres.length,
      (i) => (titre: titres[i], notes: groupes[i]),
    );
  }

  Widget _tuilePourNote(Note note, Color couleurTexte) {
    final tile = NoteListTile(
      note: note,
      couleurTexte: couleurTexte,
      selectionMode: _modeSelection,
      selected: _idsSelection.contains(note.id),
      onTap: () {
        if (_modeSelection) {
          _toggleSelection(note.id);
        } else {
          _ouvrirEditeur(noteExistant: note);
        }
      },
    );
    if (_modeSelection) {
      return tile;
    }
    return Dismissible(
      key: Key('${widget.folderId}_${note.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.jauneNotes,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _supprimerNote(note),
      child: tile,
    );
  }

  void _onMenuOptions(String value) {
    switch (value) {
      case 'tri_modif':
        _changerTri(_TriNotes.dateModif);
        break;
      case 'tri_creation':
        _changerTri(_TriNotes.dateCreation);
        break;
      case 'tri_titre':
        _changerTri(_TriNotes.titre);
        break;
      case 'selection':
        setState(() {
          _modeSelection = true;
          _idsSelection.clear();
        });
        break;
    }
  }

  @override
  void dispose() {
    _rechercheCtrl.dispose();
    super.dispose();
  }

  PreferredSizeWidget _appBarNormal(Color couleurTexte) {
    return AppBar(
      titleSpacing: 0,
      centerTitle: false,
      leadingWidth: 110,
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
            Flexible(
              child: Text(
                'Dossiers',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 17, color: AppColors.jauneNotes),
              ),
            ),
          ],
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_horiz_rounded,
            color: AppColors.jauneNotes,
          ),
          onSelected: _onMenuOptions,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'tri_modif',
              child: Row(
                children: [
                  if (_tri == _TriNotes.dateModif)
                    const Icon(Icons.check, size: 20)
                  else
                    const SizedBox(width: 20),
                  const SizedBox(width: 8),
                  const Text('Trier : date de modification'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'tri_creation',
              child: Row(
                children: [
                  if (_tri == _TriNotes.dateCreation)
                    const Icon(Icons.check, size: 20)
                  else
                    const SizedBox(width: 20),
                  const SizedBox(width: 8),
                  const Text('Trier : date de création'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'tri_titre',
              child: Row(
                children: [
                  if (_tri == _TriNotes.titre)
                    const Icon(Icons.check, size: 20)
                  else
                    const SizedBox(width: 20),
                  const SizedBox(width: 8),
                  const Text('Trier : titre (A–Z)'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'selection',
              child: Text('Sélectionner des notes'),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  PreferredSizeWidget _appBarSelection() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: _quitterModeSelection,
      ),
      title: Text(
        _idsSelection.isEmpty
            ? 'Sélection'
            : '${_idsSelection.length} sélectionnée(s)',
        style: const TextStyle(fontSize: 17),
      ),
      actions: [
        IconButton(
          tooltip: 'Supprimer la sélection',
          icon: const Icon(Icons.delete_outline),
          onPressed: _idsSelection.isEmpty ? null : _supprimerSelection,
        ),
        const SizedBox(width: 4),
      ],
    );
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
      appBar: _modeSelection ? _appBarSelection() : _appBarNormal(couleurTexte),
      body: _chargement
          ? const Center(child: CircularProgressIndicator.adaptive())
          : _erreur
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _messageErreur ?? UserMessages.erreurChargementNotes,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: couleurTexte,
                        fontSize: 16,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _initialiserDonnees,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                  ],
                ),
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
                        widget.folderName,
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
                                            ? 'Aucune note dans ce dossier'
                                            : 'Aucun résultat pour cette recherche',
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
                                            ? 'Appuie sur le bouton en bas à droite pour créer une note.'
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
                            : _triParDate
                            ? ListView(
                                padding: EdgeInsets.zero,
                                physics: const BouncingScrollPhysics(),
                                children: () {
                                  final sections = _grouperNotesParMois(
                                    _notesFiltrees,
                                  );
                                  final out = <Widget>[];
                                  for (var si = 0; si < sections.length; si++) {
                                    final sec = sections[si];
                                    out.add(
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(
                                          16,
                                          si == 0 ? 8 : 14,
                                          16,
                                          6,
                                        ),
                                        child: Text(
                                          sec.titre,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    );
                                    for (
                                      var ni = 0;
                                      ni < sec.notes.length;
                                      ni++
                                    ) {
                                      out.add(
                                        _tuilePourNote(
                                          sec.notes[ni],
                                          couleurTexte,
                                        ),
                                      );
                                      final dernier =
                                          si == sections.length - 1 &&
                                          ni == sec.notes.length - 1;
                                      if (!dernier) {
                                        out.add(
                                          Divider(
                                            height: 1,
                                            indent: 16,
                                            color: Colors.grey.withValues(
                                              alpha: 0.3,
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                  return out;
                                }(),
                              )
                            : ListView.separated(
                                padding: EdgeInsets.zero,
                                physics: const BouncingScrollPhysics(),
                                itemCount: _notesFiltrees.length,
                                separatorBuilder: (c, i) => Divider(
                                  height: 1,
                                  indent: 16,
                                  color: Colors.grey.withValues(alpha: 0.3),
                                ),
                                itemBuilder: (context, index) {
                                  return _tuilePourNote(
                                    _notesFiltrees[index],
                                    couleurTexte,
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
                          onPressed: _modeSelection
                              ? null
                              : () => _ouvrirEditeur(),
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
