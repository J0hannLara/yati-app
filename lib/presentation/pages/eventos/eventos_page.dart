import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../cursos/detalle_curso_page.dart';

class EventosPage extends StatelessWidget {
  const EventosPage({super.key});

  Future<List<Map<String, dynamic>>> obtenerCursosInscritos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    // 🔹 Obtener todas las publicaciones
    final publicacionesSnapshot = await FirebaseFirestore.instance
        .collection('publicaciones')
        .get();

    List<Map<String, dynamic>> cursosInscritos = [];

    // 🔹 Revisar cada publicación si el usuario está inscrito
    for (var pub in publicacionesSnapshot.docs) {
      final inscripcionDoc = await FirebaseFirestore.instance
          .collection('publicaciones')
          .doc(pub.id)
          .collection('inscripciones')
          .doc(user.uid)
          .get();

      if (inscripcionDoc.exists) {
        final data = pub.data();
        final inscripcionData = inscripcionDoc.data();

        cursosInscritos.add({
          'titulo': data['titulo'],
          'descripcion': data['descripcion'],
          'imagenUrl': data['imagenUrl'],
          'fechaClase': data['fechaClase'] != null
              ? (data['fechaClase'] as Timestamp).toDate().toLocal().toString()
              : null,
          'tipoClase': data['tipoClase'],
          'linkReunion': data['linkReunion'],
          'estado': inscripcionData?['estado'] ?? 'pendiente',
        });
      }
    }

    return cursosInscritos;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: obtenerCursosInscritos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Cargando tus cursos...",
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No estás inscrito en ningún curso",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Explora los cursos disponibles e inscríbete",
                    style: TextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navegar a la página de cursos disponibles
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Explorar Cursos"),
                  ),
                ],
              ),
            );
          }

          final cursos = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header informativo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.school_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Mis Cursos Inscritos",
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                            Text(
                              "Total: ${cursos.length} curso${cursos.length != 1 ? 's' : ''}",
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onBackground.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Lista de cursos
                Expanded(
                  child: ListView.builder(
                    itemCount: cursos.length,
                    itemBuilder: (context, index) {
                      final curso = cursos[index];

                      // Determinar color según estado
                      Color estadoColor;
                      IconData estadoIcon;
                      switch (curso['estado']) {
                        case 'aprobado':
                          estadoColor = Colors.green;
                          estadoIcon = Icons.check_circle;
                          break;
                        case 'rechazado':
                          estadoColor = Colors.red;
                          estadoIcon = Icons.cancel;
                          break;
                        default:
                          estadoColor = Theme.of(context).colorScheme.primary;
                          estadoIcon = Icons.pending;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetalleCursoPage(
                                    titulo:
                                        curso['titulo'] ?? 'Curso sin título',
                                    descripcion: curso['descripcion'] ?? '',
                                    imagenUrl: curso['imagenUrl'],
                                    estado: curso['estado'] ?? 'pendiente',
                                    fechaClase:
                                        curso['fechaClase'] ??
                                        'sin fecha de clase',
                                    tipoClase:
                                        curso['tipoClase'] ?? 'no definido',
                                    linkReunion:
                                        curso['linkReunion'] ?? 'no definida',
                                    estaInscrito: true,
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Imagen del curso
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.1),
                                    ),
                                    child: curso['imagenUrl'] != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.network(
                                              curso['imagenUrl'],
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Icon(
                                                      Icons.school_rounded,
                                                      size: 40,
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.primary,
                                                    );
                                                  },
                                            ),
                                          )
                                        : Center(
                                            child: Icon(
                                              Icons.school_rounded,
                                              size: 40,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                          ),
                                  ),

                                  const SizedBox(width: 16),

                                  // Contenido del curso
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Título
                                        Text(
                                          curso['titulo'] ?? 'Curso sin título',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),

                                        const SizedBox(height: 8),

                                        // Descripción
                                        Text(
                                          curso['descripcion'] ??
                                              'Sin descripción',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground
                                                .withOpacity(0.7),
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),

                                        const SizedBox(height: 12),

                                        // Estado y información adicional
                                        Row(
                                          children: [
                                            // Estado
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: estadoColor.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: estadoColor
                                                      .withOpacity(0.3),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    estadoIcon,
                                                    size: 14,
                                                    color: estadoColor,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    curso['estado']
                                                            ?.toString()
                                                            .toUpperCase() ??
                                                        'PENDIENTE',
                                                    style: TextStyle(
                                                      color: estadoColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const Spacer(),

                                            // Indicador de acción
                                            Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 16,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.5),
                                            ),
                                          ],
                                        ),

                                        // Información adicional si está disponible
                                        if (curso['fechaClase'] != null &&
                                            curso['fechaClase'] !=
                                                'sin fecha de clase')
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  size: 12,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  curso['fechaClase'],
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onBackground
                                                        .withOpacity(0.6),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
