import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DetalleCursoPage extends StatefulWidget {
  final String titulo;
  final String descripcion;
  final String? imagenUrl;
  final String estado;

  // Nuevos campos opcionales
  final String? fechaClase;
  final String? tipoClase;
  final String? linkReunion;

  // Indica si el usuario está inscrito
  final bool estaInscrito;

  const DetalleCursoPage({
    super.key,
    required this.titulo,
    required this.descripcion,
    this.imagenUrl,
    required this.estado,
    this.fechaClase,
    this.tipoClase,
    this.linkReunion,
    this.estaInscrito = false,
  });

  @override
  State<DetalleCursoPage> createState() => _DetalleCursoPageState();
}

class _DetalleCursoPageState extends State<DetalleCursoPage> {
  bool inscrito = false;

  @override
  void initState() {
    super.initState();
    inscrito = widget.estaInscrito;
  }

  Future<void> _abrirEnlace(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo abrir el enlace")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorEstado = widget.estado == 'aprobado'
        ? Colors.green
        : widget.estado == 'rechazado'
        ? Colors.red
        : Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Curso'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen del curso con Hero animation
            if (widget.imagenUrl != null)
              Hero(
                tag: widget.imagenUrl!,
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                        Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Image.network(
                        widget.imagenUrl!,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            child: Icon(
                              Icons.school_rounded,
                              size: 80,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          );
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Theme.of(
                                context,
                              ).colorScheme.background.withOpacity(0.9),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.school_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),

            // Contenido principal
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      widget.titulo,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 20,
                          ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Estado con badge mejorado
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: colorEstado.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorEstado.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getEstadoIcon(widget.estado),
                          color: colorEstado,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Estado de inscripción',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onBackground.withOpacity(0.7),
                                ),
                              ),
                              Text(
                                widget.estado.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: colorEstado,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Descripción
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
                                Icons.description_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Descripción del Curso",
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.descripcion,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Theme.of(
                                context,
                              ).colorScheme.onBackground.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Información adicional
                  if (widget.fechaClase != null &&
                          widget.fechaClase!.isNotEmpty ||
                      widget.tipoClase != null &&
                          widget.tipoClase!.isNotEmpty ||
                      widget.linkReunion != null &&
                          widget.linkReunion!.isNotEmpty)
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
                                  Icons.info_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Información de la Clase",
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Fecha de clase
                            if (widget.fechaClase != null &&
                                widget.fechaClase!.isNotEmpty)
                              _infoRow(
                                Icons.calendar_today_rounded,
                                "Fecha de clase:",
                                widget.fechaClase!,
                              ),

                            // Tipo de clase
                            if (widget.tipoClase != null &&
                                widget.tipoClase!.isNotEmpty)
                              _infoRow(
                                Icons.video_library_rounded,
                                "Tipo de clase:",
                                widget.tipoClase!,
                              ),

                            // Link de reunión
                            if (widget.linkReunion != null &&
                                widget.linkReunion!.isNotEmpty)
                              GestureDetector(
                                onTap: () => _abrirEnlace(widget.linkReunion!),
                                child: _infoRow(
                                  Icons.link_rounded,
                                  "Reunión:",
                                  "Haz clic para unirte",
                                  isLink: true,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),

                  // Botón de inscripción o aviso
                  widget.estaInscrito
                      ? _botonEstado(
                          "Ya estás inscrito en este curso",
                          Icons.check_circle_rounded,
                          Theme.of(context).colorScheme.primary,
                        )
                      : ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 24,
                            ),
                            elevation: 4,
                            shadowColor: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                          ),
                          onPressed: () {
                            setState(() => inscrito = true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Te has inscrito correctamente.',
                                ),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.school_rounded, size: 24),
                          label: const Text(
                            "Inscribirme a este curso",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Función auxiliar para obtener icono según estado
  IconData _getEstadoIcon(String estado) {
    switch (estado) {
      case 'aprobado':
        return Icons.check_circle_rounded;
      case 'rechazado':
        return Icons.cancel_rounded;
      default:
        return Icons.pending_actions_rounded;
    }
  }

  // Widget auxiliar para mostrar los datos de la clase
  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    bool isLink = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: isLink
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.onBackground.withOpacity(0.8),
                    decoration: isLink
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    fontWeight: isLink ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _botonEstado(String texto, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(
            texto,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
