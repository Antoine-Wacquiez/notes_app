import 'package:flutter/material.dart';

import '../models/dossier.dart';
import '../repositories/folder_repository.dart';
import '../theme/app_colors.dart';
import '../utils/app_feedback.dart';
import '../utils/user_messages.dart';
import '../widgets/barre_recherche_notes.dart';
import '../widgets/dossier_tile.dart';
import 'ecran_principal.dart';

class EcranDossiers extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDark;

  const EcranDossiers({
    super.key,
    required this.toggleTheme,
    required this.isDark,
  });

  @override
  State<EcranDossiers> createState() => _EcranDossiersState();
}

class _EcranDossiersState extends State<EcranDossiers> {
  final FolderRepository _folderRepository = FolderRepository();
  final TextEditingController _rechercheCtrl = TextEditingController();
  List<Dossier> _dossiers = [];
  bool _chargement = true;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _rechercheCtrl.addListener(() => setState(() {}));
    _chargerDossiers();
  }

  @override
  void dispose() {
    _rechercheCtrl.dispose();
    super.dispose();
  }

  Future<void> _chargerDossiers() async {
    setState(() {
      _chargement = true;
      _erreur = null;
    });
    try {
      final list = await _folderRepository.recupererDossiersAvecComptage();
      if (!mounted) return;
      setState(() {
        _dossiers = list;
        _chargement = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _chargement = false;
        _erreur = UserMessages.depuisErreur(e);
      });
    }
  }

  List<Dossier> get _dossiersFiltres {
    final q = _rechercheCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _dossiers;
    return _dossiers
        .where((d) => d.name.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _dialogNouveauDossier() async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouveau dossier'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nom du dossier',
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.jauneNotes,
              foregroundColor: Colors.black,
            ),
            child: const Text('Créer'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final nom = ctrl.text.trim();
    if (nom.isEmpty) {
      AppFeedback.showInfo(context, UserMessages.dossierNomVide);
      return;
    }
    try {
      await _folderRepository.ajouterDossier(nom);
      await _chargerDossiers();
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, UserMessages.depuisErreur(e));
      }
    }
  }

  Future<void> _dialogRenommer(Dossier d) async {
    final ctrl = TextEditingController(text: d.name);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Renommer le dossier'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nom',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.jauneNotes,
              foregroundColor: Colors.black,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final nom = ctrl.text.trim();
    if (nom.isEmpty) {
      AppFeedback.showInfo(context, UserMessages.dossierNomVide);
      return;
    }
    try {
      await _folderRepository.renommerDossier(d.id, nom);
      await _chargerDossiers();
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, UserMessages.depuisErreur(e));
      }
    }
  }

  Future<void> _confirmerSupprimer(Dossier d) async {
    if (d.id == 'notes') return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Supprimer « ${d.name} » ?'),
        content: Text(
          d.noteCount > 0
              ? 'Les ${d.noteCount} note${d.noteCount > 1 ? 's' : ''} seront déplacées vers « Notes ».'
              : 'Ce dossier sera supprimé.',
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
    try {
      await _folderRepository.supprimerDossier(d.id);
      if (mounted) {
        AppFeedback.showInfo(
          context,
          UserMessages.dossierSupprimeNotesDeplacees,
        );
      }
      await _chargerDossiers();
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, UserMessages.depuisErreur(e));
      }
    }
  }

  void _menuDossier(Dossier d) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline),
              title: const Text('Renommer'),
              onTap: () {
                Navigator.pop(ctx);
                _dialogRenommer(d);
              },
            ),
            if (d.id != 'notes')
              ListTile(
                leading: Icon(Icons.delete_outline,
                    color: Theme.of(ctx).colorScheme.error),
                title: Text(
                  'Supprimer le dossier',
                  style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmerSupprimer(d);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final couleurTexte = widget.isDark ? Colors.white : Colors.black;
    final filtres = _dossiersFiltres;

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              'Dossiers',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: couleurTexte,
              ),
            ),
            const SizedBox(height: 12),
            BarreRechercheNotes(
              controller: _rechercheCtrl,
              isDark: widget.isDark,
              couleurTexte: couleurTexte,
            ),
            const SizedBox(height: 16),
            if (_erreur != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _erreur!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 13,
                  ),
                ),
              ),
            Expanded(
              child: _chargement
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : filtres.isEmpty
                      ? Center(
                          child: Text(
                            _dossiers.isEmpty
                                ? 'Aucun dossier'
                                : 'Aucun dossier ne correspond à la recherche',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filtres.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 20),
                          itemBuilder: (context, index) {
                            final dossier = filtres[index];
                            return DossierTile(
                              dossier: dossier,
                              isDark: widget.isDark,
                              icone: Icons.folder_rounded,
                              estInteractif: true,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EcranPrincipal(
                                      toggleTheme: widget.toggleTheme,
                                      isDark: widget.isDark,
                                      folderId: dossier.id,
                                      folderName: dossier.name,
                                    ),
                                  ),
                                );
                                await _chargerDossiers();
                              },
                              onLongPress: () => _menuDossier(dossier),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        color: widget.isDark ? AppColors.carteSombre : AppColors.fondClair,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                widget.isDark ? Icons.light_mode : Icons.dark_mode_outlined,
                color: AppColors.jauneNotes,
              ),
              onPressed: widget.toggleTheme,
            ),
            IconButton(
              tooltip: 'Nouveau dossier',
              icon: const Icon(
                Icons.create_new_folder_outlined,
                color: AppColors.jauneNotes,
                size: 28,
              ),
              onPressed: _dialogNouveauDossier,
            ),
          ],
        ),
      ),
    );
  }
}
