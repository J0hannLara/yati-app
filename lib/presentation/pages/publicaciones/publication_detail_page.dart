import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../profile/visitor_profile_page.dart';

class PublicacionDetallePage extends StatefulWidget {
  final String postId;

  const PublicacionDetallePage({super.key, required this.postId});

  @override
  State<PublicacionDetallePage> createState() => _PublicacionDetallePageState();
}

class _PublicacionDetallePageState extends State<PublicacionDetallePage> {
  final TextEditingController _comentarioCtrl = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  bool isLiked = false;
  int likeCount = 0;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
    _loadLikeCount();
    _checkIfSubscribed();
  }

  Future<void> _checkIfSubscribed() async {
    final doc = await FirebaseFirestore.instance
        .collection('publicaciones')
        .doc(widget.postId)
        .collection('inscripciones')
        .doc(user!.uid)
        .get();
    setState(() {
      _isSubscribed = doc.exists;
    });
  }

  Future<void> inscribirseCurso() async {
    final user = FirebaseAuth.instance.currentUser!;
    final data =
        (await FirebaseFirestore.instance
                    .collection('publicaciones')
                    .doc(widget.postId)
                    .get())
                .data()
            as Map<String, dynamic>;

    final ownerId = data['userId'] ?? '';
    final inscripcionRef = FirebaseFirestore.instance
        .collection('publicaciones')
        .doc(widget.postId)
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
          'publicacionId': widget.postId,
          'fecha': FieldValue.serverTimestamp(),
          'mensaje': 'Un usuario quiere inscribirse a tu curso',
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te has inscrito correctamente.')),
      );
    }
  }

  Future<void> agregarComentario(String texto) async {
    final data =
        (await FirebaseFirestore.instance
                    .collection('publicaciones')
                    .doc(widget.postId)
                    .get())
                .data()
            as Map<String, dynamic>;

    final ownerId = data['userId'] ?? '';
    final user = FirebaseAuth.instance.currentUser!;
    final comentarioRef = FirebaseFirestore.instance
        .collection('publicaciones')
        .doc(widget.postId)
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
        'publicacionId': widget.postId,
        'fecha': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _checkIfLiked() async {
    final user = FirebaseAuth.instance.currentUser!;
    final doc = await FirebaseFirestore.instance
        .collection('publicaciones')
        .doc(widget.postId)
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
        .doc(widget.postId)
        .collection('likes')
        .get();
    setState(() {
      likeCount = likesSnapshot.docs.length;
    });
  }

  Future<void> _compartirPublicacion(Map<String, dynamic> data) async {
    try {
      final contenido = data['contenido'] ?? data['descripcion'] ?? '';
      final titulo = data['titulo'] ?? 'Publicación en YATI';
      final deepLink = "https://yati-app.pages.dev/post/${widget.postId}";

      String textoCompartir =
          '📚 *¡Mira esta publicación en YATI!* 📚\n\n'
          '✏$titulo✏\n'
          '📒 *Contenido:* $contenido\n\n'
          '👇 *Ver publicación:*\n $deepLink';

      await Share.share(textoCompartir, subject: 'Publicación de YATI');
    } catch (e) {
      print('Error al compartir: $e');
    }
  }

  void _mostrarDialogoInscripcion() {
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
                        setState(() => noMostrarMas = value ?? false);
                      },
                    ),
                    const Expanded(
                      child: Text("No mostrar este mensaje otra vez"),
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
                  await inscribirseCurso();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Sí, inscribirme"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> toggleLike() async {
    final data =
        (await FirebaseFirestore.instance
                    .collection('publicaciones')
                    .doc(widget.postId)
                    .get())
                .data()
            as Map<String, dynamic>;

    final ownerId = data['userId'] ?? '';
    final user = FirebaseAuth.instance.currentUser!;
    final likeRef = FirebaseFirestore.instance
        .collection('publicaciones')
        .doc(widget.postId)
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
      if (ownerId != user.uid) {
        await FirebaseFirestore.instance.collection('notificaciones').add({
          'userIdReceptor': ownerId,
          'userIdEmisor': user.uid,
          'tipo': 'like',
          'publicacionId': widget.postId,
          'fecha': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final postRef = FirebaseFirestore.instance
        .collection('publicaciones')
        .doc(widget.postId);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Publicación"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: postRef.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          if (!snap.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    "La publicación no existe",
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final data = snap.data!.data() as Map<String, dynamic>;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Tarjeta de contenido principal
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (data['imagenUrl'] != null &&
                                data['imagenUrl'] != "")
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    data['imagenUrl'],
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 200,
                                        width: double.infinity,
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 200,
                                        width: double.infinity,
                                        color: Colors.grey[200],
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.broken_image,
                                              size: 48,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Error al cargar imagen',
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                            const SizedBox(height: 20),

                            // Título con estilo mejorado
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                data['titulo'] ?? '',
                                style: Theme.of(context).textTheme.headlineLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Descripción
                            Text(
                              data['descripcion'] ?? '',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontSize: 16, height: 1.5),
                            ),

                            const SizedBox(height: 16),

                            // Información adicional (fecha, categoría, etc.)
                            if (data['fechaCreacion'] != null)
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    (data['fechaCreacion'] as Timestamp)
                                        .toDate()
                                        .toString()
                                        .substring(0, 16),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),

                            const SizedBox(height: 16),

                            // Botones de interacción
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  // Botón Like
                                  _buildActionButton(
                                    icon: isLiked
                                        ? Icons.thumb_up
                                        : Icons.thumb_up_alt_outlined,
                                    label: 'Me gusta',
                                    count: likeCount,
                                    isActive: isLiked,
                                    onPressed: toggleLike,
                                  ),

                                  // Botón Comentarios
                                  StreamBuilder<QuerySnapshot>(
                                    stream: postRef
                                        .collection("comentarios")
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      final commentCount =
                                          snapshot.data?.docs.length ?? 0;
                                      return _buildActionButton(
                                        icon: Icons.comment_outlined,
                                        label: 'Comentar',
                                        count: commentCount,
                                        isActive: false,
                                        onPressed: () {
                                          // El comentario ya se maneja en el input inferior
                                        },
                                      );
                                    },
                                  ),

                                  // Botón Unirme
                                  _buildActionButton(
                                    icon: _isSubscribed
                                        ? Icons.school
                                        : Icons.school_outlined,
                                    label: _isSubscribed
                                        ? 'Inscrito'
                                        : 'Unirme',
                                    count: null,
                                    isActive: _isSubscribed,
                                    onPressed: _isSubscribed
                                        ? null
                                        : _mostrarDialogoInscripcion,
                                  ),

                                  // Botón Compartir
                                  _buildActionButton(
                                    icon: Icons.share,
                                    label: 'Compartir',
                                    count: null,
                                    isActive: false,
                                    onPressed: () =>
                                        _compartirPublicacion(data),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Sección de comentarios
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.comment,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Comentarios",
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            StreamBuilder<QuerySnapshot>(
                              stream: postRef
                                  .collection("comentarios")
                                  .orderBy("fecha", descending: true)
                                  .snapshots(),
                              builder: (context, comSnap) {
                                if (!comSnap.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  );
                                }

                                final comentarios = comSnap.data!.docs;

                                if (comentarios.isEmpty) {
                                  return Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.chat_bubble_outline,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Sé el primero en comentar",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return Column(
                                  children: comentarios.map((doc) {
                                    final c =
                                        doc.data() as Map<String, dynamic>;
                                    final userId = c["userId"];

                                    return FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance
                                          .collection("users")
                                          .doc(userId)
                                          .get(),
                                      builder: (context, userSnap) {
                                        String nombre = "Usuario";
                                        String? foto;

                                        if (userSnap.hasData &&
                                            userSnap.data!.exists) {
                                          final u =
                                              userSnap.data!.data()
                                                  as Map<String, dynamic>;
                                          nombre = u["name"] ?? "Usuario";
                                          foto = u["photoUrl"];
                                        }

                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.background,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey[200]!,
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          VisitorProfilePage(
                                                            userId:
                                                                c["userId"], // Ajusta según tu estructura
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: CircleAvatar(
                                                  radius: 20,
                                                  backgroundImage: foto != null
                                                      ? NetworkImage(foto)
                                                      : const AssetImage(
                                                              "assets/images/default_user.png",
                                                            )
                                                            as ImageProvider,
                                                ),
                                              ),

                                              const SizedBox(width: 12),

                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      nombre,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      c["texto"] ?? "",
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    if (c["fecha"] != null)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 4,
                                                            ),
                                                        child: Text(
                                                          (c["fecha"]
                                                                  as Timestamp)
                                                              .toDate()
                                                              .toString()
                                                              .substring(0, 16),
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors
                                                                .grey[500],
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Caja para escribir comentario mejorada
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.grey[300]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _comentarioCtrl,
                            decoration: InputDecoration(
                              hintText: "Escribe un comentario...",
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              hintStyle: TextStyle(color: Colors.grey[500]),
                            ),
                            maxLines: null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: () async {
                            final texto = _comentarioCtrl.text.trim();
                            if (texto.isEmpty) return;

                            await postRef.collection("comentarios").add({
                              "texto": texto,
                              "userId": user!.uid,
                              "fecha": FieldValue.serverTimestamp(),
                            });

                            _comentarioCtrl.clear();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required int? count,
    required bool isActive,
    required VoidCallback? onPressed,
  }) {
    return Expanded(
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[700],
                ),
                if (count != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[700],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
