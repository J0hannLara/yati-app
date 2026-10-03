import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/comentarios/comentarios_bottom_sheet.dart';
import '../pages/profile/visitor_profile_page.dart';
import '../pages/publicaciones/publication_detail_page.dart';

class PublicacionCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String publicacionId;
  final String ownerId;
  final String nombreUsuario;
  final String? fotoUsuario;
  final VoidCallback? onShare; // Nuevo parámetro

  const PublicacionCard({
    super.key,
    required this.data,
    required this.publicacionId,
    required this.ownerId,
    required this.nombreUsuario,
    this.fotoUsuario,
    this.onShare,
  });

  @override
  State<PublicacionCard> createState() => _PublicacionCardState();
}

class _PublicacionCardState extends State<PublicacionCard> {
  bool isLiked = false;
  int likeCount = 0;
  bool isSubscribed = false;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
    _loadLikeCount();
  }

  Future<void> inscribirseCurso(String publicacionId, String ownerId) async {
    final user = FirebaseAuth.instance.currentUser!;
    final inscripcionRef = FirebaseFirestore.instance
        .collection('publicaciones')
        .doc(publicacionId)
        .collection('inscripciones')
        .doc(user.uid);

    final doc = await inscripcionRef.get();

    if (doc.exists) {
      // Ya estaba inscrito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ya estás inscrito en este curso.')),
      );
    } else {
      await inscripcionRef.set({
        'userId': user.uid,
        'fecha': FieldValue.serverTimestamp(),
        'estado': 'pendiente', // puede ser 'pendiente', 'aprobado', 'rechazado'
      });

      // Crear notificación para el dueño del curso
      if (ownerId != user.uid) {
        await FirebaseFirestore.instance.collection('notificaciones').add({
          'userIdReceptor': ownerId,
          'userIdEmisor': user.uid,
          'tipo': 'inscripcion',
          'publicacionId': publicacionId,
          'fecha': FieldValue.serverTimestamp(),
          'mensaje': 'Un usuario quiere inscribirse a tu curso',
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te has inscrito correctamente.')),
      );
    }
  }

  Future<void> agregarComentario(
    String publicacionId,
    String ownerId,
    String texto,
  ) async {
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

  Future<void> _checkIfLiked() async {
    final user = FirebaseAuth.instance.currentUser!;
    final doc = await FirebaseFirestore.instance
        .collection('publicaciones')
        .doc(widget.publicacionId)
        .collection('likes')
        .doc(user.uid)
        .get();
    setState(() {
      isLiked = doc.exists;
    });
  }

  Future<void> _loadLikeCount() async {
    final likesSnapshot = await FirebaseFirestore.instance
        .collection('publicaciones')
        .doc(widget.publicacionId)
        .collection('likes')
        .get();
    setState(() {
      likeCount = likesSnapshot.docs.length;
    });
  }

  Future<void> toggleLike() async {
    final user = FirebaseAuth.instance.currentUser!;
    final likeRef = FirebaseFirestore.instance
        .collection('publicaciones')
        .doc(widget.publicacionId)
        .collection('likes')
        .doc(user.uid);

    final doc = await likeRef.get();

    if (doc.exists) {
      await likeRef.delete();
      setState(() {
        isLiked = false;
        likeCount--;
      });
    } else {
      await likeRef.set({'fecha': FieldValue.serverTimestamp()});
      setState(() {
        isLiked = true;
        likeCount++;
      });

      // 🔔 Crear notificación
      if (widget.ownerId != user.uid) {
        await FirebaseFirestore.instance.collection('notificaciones').add({
          'userIdReceptor': widget.ownerId,
          'userIdEmisor': user.uid,
          'tipo': 'like',
          'publicacionId': widget.publicacionId,
          'fecha': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: GestureDetector(
              onTap: () {
                // Navegar a otra página
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VisitorProfilePage(
                      userId: data['userId'], // o el ID que tengas
                    ),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundImage: widget.fotoUsuario != null
                    ? NetworkImage(widget.fotoUsuario!)
                    : const AssetImage('assets/images/default_user.png')
                          as ImageProvider,
              ),
            ),
            title: Text(
              widget.nombreUsuario,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              data['fechaCreacion'] != null
                  ? (data['fechaCreacion'] as Timestamp)
                        .toDate()
                        .toString()
                        .substring(0, 16)
                  : '',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          if (data['imagenUrl'] != null)
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PublicacionDetallePage(postId: widget.publicacionId),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(
                8,
              ), // Opcional: para bordes redondeados
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  8,
                ), // Opcional: si quieres bordes redondeados en la imagen
                child: Image.network(
                  data['imagenUrl'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.broken_image,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['titulo'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data['descripcion'] ?? '',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('publicaciones')
                .doc(widget.publicacionId)
                .collection('likes')
                .snapshots(),
            builder: (context, likeSnapshot) {
              final likesCount = likeSnapshot.data?.docs.length ?? 0;

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('publicaciones')
                    .doc(widget.publicacionId)
                    .collection('comentarios')
                    .snapshots(),
                builder: (context, comSnapshot) {
                  final comCount = comSnapshot.data?.docs.length ?? 0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Text('$likesCount Me gusta • $comCount Comentarios'),
                  );
                },
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,

                  children: [
                    // Botón Like mejorado con card
                    _buildActionCard(
                      context: context,
                      icon: isLiked
                          ? Icons.thumb_up
                          : Icons.thumb_up_alt_outlined,
                      label: 'Me gusta',
                      count: likeCount,
                      isActive: isLiked,
                      onPressed: toggleLike,
                    ),

                    // Botón Comentar mejorado con card
                    _buildActionCard(
                      context: context,
                      icon: Icons.comment_outlined,
                      label: 'Comentar',
                      count:
                          null, // Puedes agregar contador de comentarios si quieres
                      isActive: false,
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => ComentariosBottomSheet(
                            publicacionId: widget.publicacionId,
                            ownerId: widget.ownerId,
                          ),
                        );
                      },
                    ),

                    // Botón Unirme mejorado con card
                    _buildActionCard(
                      context: context,
                      icon: isSubscribed ? Icons.school : Icons.school_outlined,
                      label: isSubscribed ? 'Inscrito' : 'Unirme',
                      count: null,
                      isActive: isSubscribed,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            bool noMostrarMas = false;
                            return StatefulBuilder(
                              builder: (context, setState) => AlertDialog(
                                title: const Text("Inscribirse al curso"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "¿Deseas inscribirte a este curso? "
                                      "Recibirás notificaciones sobre su estado y novedades.",
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: noMostrarMas,
                                          onChanged: (value) {
                                            setState(
                                              () =>
                                                  noMostrarMas = value ?? false,
                                            );
                                          },
                                        ),
                                        const Expanded(
                                          child: Text(
                                            "No mostrar este mensaje otra vez",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancelar"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await inscribirseCurso(
                                        widget.publicacionId,
                                        widget.ownerId,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text("Sí, inscribirme"),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),

                    // Botón Compartir mejorado con card
                    _buildActionCard(
                      context: context,
                      icon: Icons.share,
                      label: 'Compartir',
                      count: null,
                      isActive: false,
                      onPressed: widget.onShare,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int? count,
    required bool isActive,
    required VoidCallback? onPressed,
  }) {
    return Expanded(
      child: Container(
        color: Theme.of(context).colorScheme.background,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: isActive
                    ? Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.3),
                        width: 1,
                      )
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono con badge de contador
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 22,
                        color: isActive
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[700],
                      ),
                      if (count != null && count > 0)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(minWidth: 16),
                            child: Text(
                              count > 99 ? '99+' : count.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
