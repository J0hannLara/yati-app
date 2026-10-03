import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth/login_page.dart';
import '../profile/profile_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Perfil del usuario actual ---
          if (user != null)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    user.email != null && user.email!.isNotEmpty
                        ? user.email![0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(user.email ?? 'Usuario desconocido'),
                subtitle: const Text('Cuenta actual'),
              ),
            ),

          const SizedBox(height: 20),

          const Text(
            "Opciones",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          // --- Editar perfil ---
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Editar perfil'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),

          const Divider(),

          // --- Cambiar tema (modo claro/oscuro) ---
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Cambiar tema'),
            onTap: () {
              // Aquí luego puedes integrar Provider o Riverpod para alternar el tema
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cambio de tema próximamente')),
              );
            },
          ),

          const Divider(),

          // --- Soporte o contacto ---
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Centro de ayuda'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Redirigir a soporte...')),
              );
            },
          ),

          const Divider(),

          // --- Cerrar sesión ---
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar sesión'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Cerrar sesión'),
                  content: const Text(
                    '¿Estás seguro de que deseas cerrar sesión?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Cerrar sesión'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
