import 'package:flutter/material.dart';

class EstadisticasPage extends StatefulWidget {
  const EstadisticasPage({super.key});

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  // Materias simuladas
  final List<String> materias = [
    'Matemáticas',
    'Física',
    'Química',
    'Lengua',
    'Historia',
    'Inglés',
  ];

  // Docentes simulados
  final Map<String, List<Map<String, dynamic>>> docentesPorMateria = {
    'Matemáticas': [
      {'name': 'Juan Pérez', 'puntos': 120, 'photoUrl': 'https://i.pravatar.cc/150?img=10', 'description': 'Experto en álgebra y cálculo'},
      {'name': 'Ana Gómez', 'puntos': 95, 'photoUrl': 'https://i.pravatar.cc/150?img=11', 'description': 'Clases dinámicas de geometría'},
    ],
    'Física': [
      {'name': 'Luis Ramírez', 'puntos': 110, 'photoUrl': 'https://i.pravatar.cc/150?img=12', 'description': 'Apasionado por la física cuántica'},
    ],
    'Química': [
      {'name': 'Marta Díaz', 'puntos': 130, 'photoUrl': 'https://i.pravatar.cc/150?img=13', 'description': 'Clases prácticas de química orgánica'},
    ],
    'Lengua': [
      {'name': 'Pedro Fernández', 'puntos': 90, 'photoUrl': 'https://i.pravatar.cc/150?img=14', 'description': 'Mejora tu redacción y comprensión'},
    ],
    'Historia': [
      {'name': 'Carla Ruiz', 'puntos': 105, 'photoUrl': 'https://i.pravatar.cc/150?img=15', 'description': 'Clases interactivas de historia mundial'},
    ],
    'Inglés': [
      {'name': 'Emily Johnson', 'puntos': 140, 'photoUrl': 'https://i.pravatar.cc/150?img=16', 'description': 'Inglés práctico y conversacional'},
    ],
  };

  String selectedMateria = 'Matemáticas';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final docentesFiltrados = docentesPorMateria[selectedMateria]!
        .where((docente) => docente['name']
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar docente...',
                hintStyle: TextStyle(color: Colors.black),
                focusColor: Colors.black,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.orange.shade50,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          // Selector de materias
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: materias.length,
              itemBuilder: (context, index) {
                final materia = materias[index];
                final isSelected = materia == selectedMateria;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ChoiceChip(
                    label: Text(materia),
                    selected: isSelected,
                    selectedColor: Colors.orange,
                    backgroundColor: Colors.orange.shade100,
                    labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black),
                    onSelected: (_) {
                      setState(() {
                        selectedMateria = materia;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Lista de docentes
          Expanded(
            child: docentesFiltrados.isEmpty
                ? Center(
                    child: Text(
                      'No hay docentes para "$selectedMateria"',
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: docentesFiltrados.length,
                    itemBuilder: (context, index) {
                      final docente = docentesFiltrados[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage(docente['photoUrl']),
                          ),
                          title: Text(docente['name']),
                          subtitle: Text(docente['description']),
                          trailing: Text(
                            '${docente['puntos']} pts',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
