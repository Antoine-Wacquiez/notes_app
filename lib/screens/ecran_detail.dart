import 'dart:math';

import 'package:flutter/material.dart';

import '../models/note.dart';
import '../models/note_check_item.dart';
import '../services/citation_service.dart';
import '../theme/app_colors.dart';
import '../utils/app_feedback.dart';
import '../utils/note_date_format.dart';
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

  final List<NoteCheckItem> _checkItems = [];
  final List<TextEditingController> _checkCtrls = [];

  @override
  void initState() {
    super.initState();
    _titreCtrl = TextEditingController(text: widget.note.titre);
    _contenuCtrl = TextEditingController(text: widget.note.contenu);
    for (final c in widget.note.checklist) {
      _checkItems.add(c.copy());
      _checkCtrls.add(TextEditingController(text: c.label));
    }
  }

  @override
  void dispose() {
    _titreCtrl.dispose();
    _contenuCtrl.dispose();
    for (final c in _checkCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  bool _peutSauvegarder() {
    if (_titreCtrl.text.trim().isNotEmpty ||
        _contenuCtrl.text.trim().isNotEmpty) {
      return true;
    }
    for (var i = 0; i < _checkItems.length; i++) {
      final t = i < _checkCtrls.length ? _checkCtrls[i].text.trim() : '';
      if (t.isNotEmpty || _checkItems[i].checked) return true;
    }
    return false;
  }

  void _syncChecklistDepuisControleurs() {
    for (var i = 0; i < _checkItems.length && i < _checkCtrls.length; i++) {
      _checkItems[i].label = _checkCtrls[i].text;
    }
  }

  void _sauvegarderEtQuitter() {
    if (!_peutSauvegarder()) {
      AppFeedback.showInfo(context, UserMessages.noteVide);
      return;
    }
    _syncChecklistDepuisControleurs();
    widget.note.titre = _titreCtrl.text;
    widget.note.contenu = _contenuCtrl.text;
    widget.note.date = DateTime.now();
    widget.note.checklist = _checkItems
        .where(
          (e) => e.label.trim().isNotEmpty || e.checked,
        )
        .map((e) => e.copy())
        .toList();
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

  void _ajouterLigneTache() {
    final id = Random().nextInt(1 << 30);
    setState(() {
      _checkItems.add(NoteCheckItem(id: id, label: '', checked: false));
      _checkCtrls.add(TextEditingController());
    });
  }

  void _retirerTache(int index) {
    if (index < 0 || index >= _checkItems.length) return;
    setState(() {
      _checkCtrls[index].dispose();
      _checkCtrls.removeAt(index);
      _checkItems.removeAt(index);
    });
  }

  Widget _barreOutilsBas(Color jaune) {
    final barreCouleur = widget.isDark
        ? AppColors.carteSombre
        : const Color(0xFFF2F2F7);

    return Material(
      color: barreCouleur,
      elevation: 0,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(
              height: 1,
              color: Colors.grey.withValues(alpha: 0.35),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    tooltip: 'Liste de tâches',
                    icon: Icon(Icons.check_box_outlined, color: jaune, size: 26),
                    onPressed: _ajouterLigneTache,
                  ),
                  IconButton(
                    tooltip: 'Citation',
                    icon: _chargementCitation
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: jaune,
                            ),
                          )
                        : Icon(Icons.format_quote_rounded,
                            color: jaune, size: 26),
                    onPressed: _chargementCitation ? null : _ajouterCitation,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final couleurFond = widget.isDark ? AppColors.fondSombre : Colors.white;
    final couleurTexte = widget.isDark ? Colors.white : Colors.black;
    final dateAffichee = widget.note.date;
    final jaune = AppColors.jauneNotes;
    final listeTachesFond = widget.isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.grey.withValues(alpha: 0.08);

    return Scaffold(
      backgroundColor: couleurFond,
      appBar: AppBar(
        backgroundColor: couleurFond,
        elevation: 0,
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
          TextButton(
            onPressed: _sauvegarderEtQuitter,
            child: Text(
              'OK',
              style: TextStyle(
                color: jaune,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),  
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: _barreOutilsBas(jaune),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titreCtrl,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: couleurTexte,
                letterSpacing: -0.3,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Titre',
                hintStyle: TextStyle(
                  color: Colors.grey.withValues(alpha: 0.55),
                  fontWeight: FontWeight.bold,
                ),
              ),
              minLines: 1,
              maxLines: 3,
              textInputAction: TextInputAction.next,
            ),
            Text(
              formatDateRelativeDetail(dateAffichee),
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            const SizedBox(height: 12),
            if (_checkItems.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                decoration: BoxDecoration(
                  color: listeTachesFond,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _checkItems.length,
                    itemBuilder: (context, index) {
                      final item = _checkItems[index];
                      final ctrl = _checkCtrls[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Transform.scale(
                            scale: 0.95,
                            child: Checkbox(
                              value: item.checked,
                              activeColor: jaune,
                              checkColor: Colors.black87,
                              onChanged: (v) {
                                setState(() => item.checked = v ?? false);
                              },
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: ctrl,
                              style: TextStyle(color: couleurTexte, fontSize: 16),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Tâche',
                                hintStyle: TextStyle(
                                  color: Colors.grey.withValues(alpha: 0.45),
                                ),
                                isDense: true,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.grey.shade500,
                              size: 20,
                            ),
                            onPressed: () => _retirerTache(index),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Expanded(
              child: TextField(
                controller: _contenuCtrl,
                style: TextStyle(
                  fontSize: 17,
                  color: couleurTexte,
                  height: 1.5,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Tapez ici...',
                  alignLabelWithHint: true,
                  hintStyle: TextStyle(
                    color: Colors.grey.withValues(alpha: 0.45),
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
