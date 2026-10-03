import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/publicacion_card.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Stream<QuerySnapshot> getPublicaciones() {
    return FirebaseFirestore.instance
        .collection('publicaciones')
        .orderBy('fechaCreacion', descending: true)
        .snapshots();
  }

  Future<void> toggleLike(String publicacionId, String ownerId) async {
    final user = FirebaseAuth.instance.currentUser!;
    final likeRef = FirebaseFirestore.instance
        .collection('publicaciones')
        .doc(publicacionId)
        .collection('likes')
        .doc(user.uid);

    final doc = await likeRef.get();

    if (doc.exists) {
      await likeRef.delete();
    } else {
      await likeRef.set({'fecha': FieldValue.serverTimestamp()});
      if (ownerId != user.uid) {
        await FirebaseFirestore.instance.collection('notificaciones').add({
          'userIdReceptor': ownerId,
          'userIdEmisor': user.uid,
          'tipo': 'like',
          'publicacionId': publicacionId,
          'fecha': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<void> agregarComentario(
      String publicacionId, String ownerId, String texto) async {
    final user = FirebaseAuth.instance.currentUser!;
    final comentarioRef = FirebaseFirestore.instance
        .collection('publicaciones')
        .doc(publicacionId)
        .collection('comentarios')
        .doc();

    await comentarioRef.set({
      'userId': user.uid,
      'texto': texto,
      'fecha': FieldValue.serverTimestamp(),
    });

    if (ownerId != user.uid) {
      await FirebaseFirestore.instance.collection('notificaciones').add({
        'userIdReceptor': ownerId,
        'userIdEmisor': user.uid,
        'tipo': 'comentario',
        'publicacionId': publicacionId,
        'fecha': FieldValue.serverTimestamp(),
      });
    }
  }

  // Lista de stories estáticos
  static const List<Map<String, String>> storiesEjemplo = [
    {'nombre': 'Juan', 'imagen': 'https://i.pravatar.cc/150?img=1'},
    {'nombre': 'Ana', 'imagen': 'https://i.pravatar.cc/150?img=2'},
    {'nombre': 'Luis', 'imagen': 'https://i.pravatar.cc/150?img=3'},
    {'nombre': 'Marta', 'imagen': 'https://i.pravatar.cc/150?img=4'},
    {'nombre': 'Pedro', 'imagen': 'https://i.pravatar.cc/150?img=5'},
  ];



void mostrarStory(BuildContext context, Map<String, String> story) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.9),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Imagen del story con borde decorativo
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        story['imagen']!,
                        width: 250,
                        height: 250,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 250,
                            height: 250,
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Nombre con estilo mejorado
                  Text(
                    story['nombre']!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Descripción con estilo mejorado
                  Text(
                    story['descripcion'] ?? 'Compartiendo conocimiento',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Botones de acción en el story
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStoryActionButton(
                        context,
                        Icons.favorite_border,
                        'Me gusta',
                        () {
                          // Acción de like
                        },
                      ),
                      const SizedBox(width: 16),
                      _buildStoryActionButton(
                        context,
                        Icons.share,
                        'Compartir',
                        () {
                          _compartirStory(story);
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(width: 16),
                      _buildStoryActionButton(
                        context,
                        Icons.message,
                        'Comentar',
                        () {
                          // Acción de comentar
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

// Widget para botones de acción en stories
Widget _buildStoryActionButton(BuildContext context, IconData icon, String label, VoidCallback onPressed) {
  return Column(
    children: [
      CircleAvatar(
        backgroundColor: Colors.white.withOpacity(0.9),
        child: IconButton(
          icon: Icon(icon, color: Theme.of(context).colorScheme.primary),
          onPressed: onPressed,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
        ),
      ),
    ],
  );
}

// Función para compartir story
void _compartirStory(Map<String, String> story) async {
  try {
    await Share.share(
      '¡Mira este story en YATI! ${story['nombre']} - ${story['descripcion'] ?? "Compartiendo conocimiento educativo"}',
      subject: 'Story de YATI',
    );
  } catch (e) {
    print('Error al compartir: $e');
  }
}

// Función para compartir publicación
void _compartirPublicacion(String postId, Map<String, dynamic> data, String nombreUsuario) async {
  try {
    final contenido = data['descripcion'] ?? '';

    // Link simbólico
    final deepLink = "https://yati-app.pages.dev/post/$postId";


    String textoCompartir = '📚 *¡Mira esta publicación en YATI!* 📚\n\n'
        '👤 *Publicado por:* $nombreUsuario\n'
        '📒 *Contenido:* $contenido\n\n'
        '👇 *Ver publicación:* \n$deepLink';

    await Share.share(
      textoCompartir,
      subject: 'Publicación de YATI',
    );

  } catch (e) {
    print('Error al compartir publicación: $e');
  }
}


@override
Widget build(BuildContext context) {
  final currentUser = FirebaseAuth.instance.currentUser;

  return Scaffold(
    body: StreamBuilder<QuerySnapshot>(
      stream: getPublicaciones(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final publicaciones = snapshot.data?.docs
                .where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['userId'] != currentUser?.uid;
                })
                .toList() ??
            [];

        return RefreshIndicator(
          backgroundColor: Theme.of(context).colorScheme.primary,
          color: Colors.white,
          onRefresh: () async {
            // Recargar datos
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: publicaciones.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Theme.of(
                          context,
                        ).colorScheme.background,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          'Stories',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: storiesEjemplo.length,
                          itemBuilder: (context, storyIndex) {
                            final story = storiesEjemplo[storyIndex];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                children: [
                                  // Story con borde gradiente
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Theme.of(context).colorScheme.primary,
                                          Theme.of(context).colorScheme.secondary,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: GestureDetector(
                                      onTap: () => mostrarStory(context, story),
                                      child: CircleAvatar(
                                        radius: 32,
                                        backgroundColor: Colors.white,
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundImage: NetworkImage(story['imagen']!),
                                          onBackgroundImageError: (exception, stackTrace) {
                                            // Manejar error de imagen
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    story['nombre']!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Publicaciones
              final pub = publicaciones[index - 1];
              final data = pub.data() as Map<String, dynamic>;
              final userId = data['userId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .get(),
                builder: (context, userSnapshot) {
                  String nombreUsuario = 'Usuario desconocido';
                  String? fotoUsuario;

                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    final userData =
                        userSnapshot.data!.data() as Map<String, dynamic>;
                    nombreUsuario = userData['name'] ?? 'Usuario';
                    fotoUsuario = userData['photoUrl'];
                  }

                  return PublicacionCard(
                    data: data,
                    publicacionId: pub.id,
                    ownerId: userId,
                    nombreUsuario: nombreUsuario,
                    fotoUsuario: fotoUsuario,
                    onShare: () => _compartirPublicacion(pub.id, data, nombreUsuario),
                  );
                },
              );
            },
          ),
        );
      },
    ),
  );
}
}