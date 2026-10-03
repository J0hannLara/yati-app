import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificacionesPage extends StatelessWidget {
  const NotificacionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notificaciones')
            .where('userIdReceptor', isEqualTo: user.uid)
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No tienes notificaciones aún',
                style: TextStyle(
                  color: colorScheme.onBackground.withOpacity(0.6),
                  fontSize: 16,
                ),
              ),
            );
          }

          final notificaciones = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notificaciones.length,
            itemBuilder: (context, index) {
              final data =
                  notificaciones[index].data() as Map<String, dynamic>;

              final tipo = data['tipo'] ?? '';
              final fecha = data['fecha'] != null
                  ? (data['fecha'] as Timestamp).toDate()
                  : null;
              final userEmisorId = data['userIdEmisor'];

              // 🔹 Cargamos datos del usuario que generó la notificación
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userEmisorId)
                    .get(),
                builder: (context, userSnapshot) {
                  String nombreUsuario = 'Usuario';
                  String? fotoUsuario;

                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    final userData =
                        userSnapshot.data!.data() as Map<String, dynamic>;
                    nombreUsuario = userData['name'] ?? 'Usuario';
                    fotoUsuario = userData['photoUrl'];
                  }

                  String mensaje = '';
                  if (tipo == 'like') {
                    mensaje = '$nombreUsuario le dio "Me gusta" a tu publicación';
                  } else if (tipo == 'comentario') {
                    mensaje =
                        '$nombreUsuario comentó en tu publicación';
                  } else {
                    mensaje = '$nombreUsuario realizó una acción';
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: fotoUsuario != null
                          ? NetworkImage(fotoUsuario)
                          : const AssetImage('assets/img/default_user.png')
                              as ImageProvider,
                    ),
                    title: Text(
                      mensaje,
                      style: TextStyle(
                        color: colorScheme.onBackground,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: fecha != null
                        ? Text(
                            fecha.toString().substring(0, 16),
                            style: TextStyle(
                              color: colorScheme.outline,
                              fontSize: 12,
                            ),
                          )
                        : null,
                    onTap: () {
                      // Aquí puedes navegar al detalle de la publicación
                      // Navigator.push(...);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
