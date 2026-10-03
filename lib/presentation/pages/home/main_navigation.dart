import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../eventos/eventos_page.dart';
import '../estadisticas/estadisticas_page.dart';
import '../reels/reels_page.dart';
import '../notificaciones/notificaciones_page.dart';
import '../publicaciones/publication_detail_page.dart';
import '../settings/settings_page.dart';
import 'home_page.dart';
import 'package:app_links/app_links.dart';

class MainNavigation extends StatefulWidget {
  final Uri? initialLink;

  const MainNavigation({super.key, this.initialLink});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late PageController _pageController;
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _appLinks = AppLinks();

    // App abierta
    _appLinks.uriLinkStream.listen((uri) {
      _handleIncomingLink(uri);
    });

    // App cerrada
    if (widget.initialLink != null) {
      _handleIncomingLink(widget.initialLink);
    }
  }

  void _handleIncomingLink(Uri? uri) {
    if (uri == null) return;

    print("Enlace recibido: $uri");

    // URLs web -> https://yati-app.netlify.app/post/ID
    if (uri.host == "yati-app.netlify.app" && uri.pathSegments.isNotEmpty) {
      if (uri.pathSegments[0] == "post") {
        final postId = uri.pathSegments[1];
        _openPost(postId);
        return;
      }
    }

    // Enlaces internos -> yatiapp://post/ID
    if (uri.scheme == "yatiapp" && uri.host == "post") {
      final postId = uri.pathSegments.first;
      _openPost(postId);
    }
  }

  void _openPost(String postId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PublicacionDetallePage(postId: postId)),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: const [
          HomePage(),
          EventosPage(),
          EstadisticasPage(),
          ReelsPage(),
          NotificacionesPage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Eventos'),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_rate),
            label: 'Puntuaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_fill),
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notificaciones',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}
