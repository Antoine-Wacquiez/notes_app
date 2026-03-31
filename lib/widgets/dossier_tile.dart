import 'package:flutter/material.dart';

import '../models/dossier.dart';
import '../theme/app_colors.dart';

class DossierTile extends StatelessWidget {
  final Dossier dossier;
  final bool isDark;
  final IconData icone;
  final bool estInteractif;
  final VoidCallback? onTap;

  const DossierTile({
    super.key,
    required this.dossier,
    required this.isDark,
    required this.icone,
    this.estInteractif = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final couleurTexte = isDark ? Colors.white : Colors.black;
    final couleurFond = isDark ? AppColors.carteSombre : Colors.white;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        color: couleurFond,
        child: ListTile(
          onTap: estInteractif ? onTap : null,
          leading: Icon(icone, color: AppColors.jauneNotes, size: 30),
          title: Text(
            dossier.name,
            style: TextStyle(
              color: couleurTexte,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: estInteractif
              ? Text(
                  '${dossier.noteCount} notes',
                  style: TextStyle(color: Colors.grey.shade500),
                )
              : null,
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey.shade400,
            size: 16,
          ),
        ),
      ),
    );
  }
}
