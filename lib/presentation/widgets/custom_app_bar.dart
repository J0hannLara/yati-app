import 'package:flutter/material.dart';
import '../pages/publicaciones/create_publication_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Text(
        "YATI",
        style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Buscar',
          onPressed: () {
            // TODO: Navegar a página de búsqueda
          },
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          tooltip: 'Crear publicación',
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CreatePublicacionPage()),);
          },
        ),
        IconButton(
          icon: const Icon(Icons.forum_outlined),
          tooltip: 'Comunidades / Mensajes',
          onPressed: () {
            // TODO: Ir a comunidades o mensajes
          },
        ),
      ],
    );
  }
}
