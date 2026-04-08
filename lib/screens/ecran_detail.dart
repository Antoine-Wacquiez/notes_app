import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/citation_service.dart';
import '../theme/app_colors.dart';
import '../utils/app_feedback.dart';
import '../utils/user_messages.dart';

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
  final CitationService _citationService = CitationService();
  late TextEditingController _titreCtrl;
  late TextEditingController _contenuCtrl;
  bool _chargementCitation = false;

  @override
  void initState() {
    super.initState();
    _titreCtrl = TextEditingController(text: widget.note.titre);
    _contenuCtrl = TextEditingController(text: widget.note.contenu);
  }

  void _sauvegarderEtQuitter() {
    final titre = _titreCtrl.text.trim();
    final contenu = _contenuCtrl.text.trim();
    if (titre.isEmpty && contenu.isEmpty) {
      AppFeedback.showInfo(context, UserMessages.noteVide);
      return;
    }
    widget.note.titre = _titreCtrl.text;
    widget.note.contenu = _contenuCtrl.text;
    widget.note.date = DateTime.now();
    Navigator.pop(context, true);
  }

  Future<void> _ajouterCitation() async {
    setState(() => _chargementCitation = true);
    try {
      final citation = await _citationService.recupererAleatoire();
      if (!mounted) return;
      final insertion = citation.asTextePourNote();
      final current = _contenuCtrl.text;
      _contenuCtrl.text = current.isEmpty
          ? insertion
          : '$current\n\n$insertion';
      _contenuCtrl.selection = TextSelection.collapsed(
        offset: _contenuCtrl.text.length,
      );
    } catch (e) {
      if (!mounted) return;
      AppFeedback.showError(context, UserMessages.depuisErreur(e));
    } finally {
      if (mounted) {
        setState(() => _chargementCitation = false);
      }
    }
  }

  @override
  void dispose() {
    _titreCtrl.dispose();
    _contenuCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final couleurFond = widget.isDark ? AppColors.fondSombre : Colors.white;
    final couleurTexte = widget.isDark ? Colors.white : Colors.black;
    final dateAffichee = widget.note.date;

    return Scaffold(
      backgroundColor: couleurFond,
      appBar: AppBar(
        backgroundColor: couleurFond,
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context, false),
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: AppColors.jauneNotes,
          ),
          label: const Text(
            'Notes',
            style: TextStyle(color: AppColors.jauneNotes, fontSize: 17),
          ),
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 10),
          ),
        ),
        actions: [
          IconButton(
            onPressed: null,
            tooltip: 'Partage bientôt disponible',
            icon: Icon(
              Icons.ios_share,
              color: AppColors.jauneNotes.withValues(alpha: 0.45),
            ),
          ),
          TextButton(
            onPressed: _sauvegarderEtQuitter,
            child: const Text(
              'OK',
              style: TextStyle(
                color: AppColors.jauneNotes,
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
              minLines: 1,
              maxLines: 3,
              textInputAction: TextInputAction.next,
            ),
            Text(
              '${dateAffichee.day}/${dateAffichee.month}/${dateAffichee.year} à ${dateAffichee.hour.toString().padLeft(2, '0')}:${dateAffichee.minute.toString().padLeft(2, '0')}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _chargementCitation ? null : _ajouterCitation,
                icon: _chargementCitation
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.jauneNotes,
                        ),
                      )
                    : const Icon(
                        Icons.format_quote_rounded,
                        color: AppColors.jauneNotes,
                        size: 22,
                      ),
                label: Text(
                  'Ajouter une citation',
                  style: TextStyle(
                    color: AppColors.jauneNotes.withValues(
                      alpha: _chargementCitation ? 0.5 : 1,
                    ),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
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
