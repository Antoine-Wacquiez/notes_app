import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BarreRechercheNotes extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final Color couleurTexte;

  const BarreRechercheNotes({
    super.key,
    required this.controller,
    required this.isDark,
    required this.couleurTexte,
  });

  @override
  Widget build(BuildContext context) {
    final couleurFond = isDark
        ? AppColors.carteSombre
        : AppColors.rechercheClaire;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: couleurFond,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          hintText: 'Rechercher',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
        style: TextStyle(color: couleurTexte),
      ),
    );
  }
}
