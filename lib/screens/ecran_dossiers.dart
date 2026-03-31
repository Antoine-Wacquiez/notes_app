import 'package:flutter/material.dart';

import '../models/dossier.dart';
import '../repositories/note_repository.dart';
import '../theme/app_colors.dart';
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
  final NoteRepository _repository = NoteRepository();
  int _nombreNotes = 0;

  @override
  void initState() {
    super.initState();
    _chargerNombreNotes();
  }

  Future<void> _chargerNombreNotes() async {
    try {
      final notes = await _repository.recupererNotes();
      if (!mounted) return;
      setState(() {
        _nombreNotes = notes.length;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _nombreNotes = 0;
      });
    }
  }

  List<Dossier> _buildDossiers() {
    return [
      Dossier(id: 'notes', name: 'Notes', noteCount: _nombreNotes),
      const Dossier(id: 'supprimees', name: 'Supprimés récemment'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final couleurTexte = widget.isDark ? Colors.white : Colors.black;
    final dossiers = _buildDossiers();

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
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: dossiers.length,
                separatorBuilder: (_, _) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final dossier = dossiers[index];
                  return DossierTile(
                    dossier: dossier,
                    isDark: widget.isDark,
                    icone: dossier.id == 'notes'
                        ? Icons.folder
                        : Icons.delete_outline,
                    estInteractif: dossier.id == 'notes',
                    onTap: dossier.id == 'notes'
                        ? () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EcranPrincipal(
                                  toggleTheme: widget.toggleTheme,
                                  isDark: widget.isDark,
                                ),
                              ),
                            );
                            await _chargerNombreNotes();
                          }
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
            const Icon(Icons.folder_open, color: AppColors.jauneNotes),
          ],
        ),
      ),
    );
  }
}
