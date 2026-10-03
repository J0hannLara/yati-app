import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../home/main_navigation.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  List<String> selectedCategories = [];
  String? selectedAvatar;

  final List<String> availableCategories = [
    'Programación',
    'Matemáticas',
    'Diseño',
    'Idiomas',
    'Ciencia',
  ];

  final List<String> avatarUrls = [
    'https://i.pravatar.cc/150?img=3',
    'https://i.pravatar.cc/150?img=5',
    'https://i.pravatar.cc/150?img=8',
    'https://i.pravatar.cc/150?img=12',
  ];

  Future<void> saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'name': nameController.text.trim(),
      'description': descController.text.trim(),
      'categories': selectedCategories,
      'photoUrl': selectedAvatar ?? '',
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Completa tu perfil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Selecciona una foto de perfil:", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              children: avatarUrls.map((url) {
                return GestureDetector(
                  onTap: () => setState(() => selectedAvatar = url),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage(url),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Descripción corta'),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            const Text("Selecciona tus categorías favoritas:"),
            Wrap(
              spacing: 8,
              children: availableCategories.map((cat) {
                final selected = selectedCategories.contains(cat);
                return FilterChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        selectedCategories.add(cat);
                      } else {
                        selectedCategories.remove(cat);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: saveProfile,
              child: const Text("Guardar perfil"),
            ),
          ],
        ),
      ),
    );
  }
}
