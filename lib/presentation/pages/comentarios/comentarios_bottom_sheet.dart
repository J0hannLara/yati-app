import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../profile/visitor_profile_page.dart';

class ComentariosBottomSheet extends StatefulWidget {
  final String publicacionId;
  final String ownerId;

  const ComentariosBottomSheet({
    super.key,
    required this.publicacionId,
    required this.ownerId,
  });

  @override
  State<ComentariosBottomSheet> createState() => _ComentariosBottomSheetState();
}

class _ComentariosBottomSheetState extends State<ComentariosBottomSheet> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _agregarComentario() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser!;
    final comentarioRef = FirebaseFirestore.instance
        .collection('publicaciones')
        .doc(widget.publicacionId)
        .collection('comentarios')
        .doc();

    await comentarioRef.set({
      'userId': user.uid,
      'texto': texto,
      'fecha': FieldValue.serverTimestamp(),
    });

    // Crear notificación
    if (widget.ownerId != user.uid) {
      await FirebaseFirestore.instance.collection('notificaciones').add({
        'userIdReceptor': widget.ownerId,
        'userIdEmisor': user.uid,
        'tipo': 'comentario',
        'publicacionId': widget.publicacionId,
        'fecha': FieldValue.serverTimestamp(),
      });
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Indicador superior
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  Text(
                    'Comentarios',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onBackground,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Lista de comentarios
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('publicaciones')
                          .doc(widget.publicacionId)
                          .collection('comentarios')
                          .orderBy('fecha', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final comentarios = snapshot.data!.docs;

                        if (comentarios.isEmpty) {
                          return Center(
                            child: Text(
                              'No hay comentarios aún',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onBackground.withOpacity(
                                  0.6,
                                ),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          itemCount: comentarios.length,
                          itemBuilder: (context, index) {
                            final comentario =
                                comentarios[index].data()
                                    as Map<String, dynamic>;
                            final userId = comentario['userId'];

                            // 🔹 Aquí obtenemos los datos del usuario que comentó
                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .get(),
                              builder: (context, userSnapshot) {
                                String nombreUsuario = 'Usuario desconocido';
                                String? fotoUsuario;

                                if (userSnapshot.hasData &&
                                    userSnapshot.data!.exists) {
                                  final userData =
                                      userSnapshot.data!.data()
                                          as Map<String, dynamic>;
                                  nombreUsuario = userData['name'] ?? 'Usuario';
                                  fotoUsuario = userData['photoUrl'];
                                }

                                return ListTile(
                                  leading: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => VisitorProfilePage(
                                            userId:
                                                comentario['userId'], // Ajusta según tu estructura
                                          ),
                                        ),
                                      );
                                    },
                                    child: CircleAvatar(
                                      backgroundImage: fotoUsuario != null
                                          ? NetworkImage(fotoUsuario)
                                          : const AssetImage(
                                                  'assets/images/default_user.png',
                                                )
                                                as ImageProvider,
                                    ),
                                  ),
                                  title: Text(
                                    nombreUsuario,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onBackground,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comentario['texto'] ?? '',
                                        style: TextStyle(
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      if (comentario['fecha'] != null)
                                        Text(
                                          (comentario['fecha'] as Timestamp)
                                              .toDate()
                                              .toString()
                                              .substring(0, 16),
                                          style: TextStyle(
                                            color: colorScheme.outline,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // Campo para escribir comentario
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: TextStyle(color: colorScheme.onBackground),
                          decoration: InputDecoration(
                            hintText: 'Escribe un comentario...',
                            hintStyle: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: colorScheme.surface.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color: colorScheme.primary),
                        onPressed: _agregarComentario,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
