import 'package:flutter/material.dart';
import '../models/note.dart';

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
    widget.note.titre = _titreCtrl.text;
    widget.note.contenu = _contenuCtrl.text;
    widget.note.date = DateTime.now();
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
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context, false),
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
