import 'package:flutter/material.dart';
import 'ecran_principal.dart';

class EcranDossiers extends StatelessWidget {
  final VoidCallback toggleTheme;
  final bool isDark;

  const EcranDossiers({
    super.key,
    required this.toggleTheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final couleurTexte = isDark ? Colors.white : Colors.black;
    final couleurFondElement = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              "Modifier",
              style: TextStyle(
                color: Color(0xFFFFCC00),
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              "Dossiers",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: couleurTexte,
              ),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: couleurFondElement,
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EcranPrincipal(
                          toggleTheme: toggleTheme,
                          isDark: isDark,
                        ),
                      ),
                    );
                  },
                  leading: const Icon(
                    Icons.folder,
                    color: Color(0xFFFFCC00),
                    size: 30,
                  ),
                  title: Text(
                    "Notes",
                    style: TextStyle(
                      color: couleurTexte,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey.shade400,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: couleurFondElement,
                child: ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFFFCC00),
                    size: 30,
                  ),
                  title: Text(
                    "Supprimés récemment",
                    style: TextStyle(
                      color: couleurTexte,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.shade400,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode_outlined,
                color: const Color(0xFFFFCC00),
              ),
              onPressed: toggleTheme,
            ),
            const Icon(Icons.folder_open, color: Color(0xFFFFCC00)),
          ],
        ),
      ),
    );
  }
}
