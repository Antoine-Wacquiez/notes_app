import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BarreRechercheNotes extends StatefulWidget {
  final TextEditingController controller;
  final bool isDark;
  final Color couleurTexte;
  final bool showClearButton;

  const BarreRechercheNotes({
    super.key,
    required this.controller,
    required this.isDark,
    required this.couleurTexte,
    this.showClearButton = true,
  });

  @override
  State<BarreRechercheNotes> createState() => _BarreRechercheNotesState();
}

class _BarreRechercheNotesState extends State<BarreRechercheNotes> {
  void _onControllerChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant BarreRechercheNotes oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final couleurFond = widget.isDark
        ? AppColors.carteSombre
        : AppColors.rechercheClaire;
    final hasText = widget.controller.text.isNotEmpty;

    return Semantics(
      label: 'Rechercher une note',
      textField: true,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: couleurFond,
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: widget.controller,
          textInputAction: TextInputAction.search,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: widget.showClearButton && hasText
                ? IconButton(
                    tooltip: 'Effacer la recherche',
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    onPressed: () => widget.controller.clear(),
                  )
                : null,
            hintText: 'Rechercher',
            hintStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
          style: TextStyle(color: widget.couleurTexte),
        ),
      ),
    );
  }
}
