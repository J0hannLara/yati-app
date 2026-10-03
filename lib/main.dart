import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:app_links/app_links.dart'; 
import 'core/theme/app_theme.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/home/main_navigation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/version_service.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // OBTENER ENLACE ANTES DE runApp()
  final appLinks = AppLinks();
  final initialLink = await appLinks.getInitialAppLink();

  runApp(EduConnectApp(initialLink: initialLink));
}
class EduConnectApp extends StatelessWidget {
  final Uri? initialLink;

  const EduConnectApp({super.key, this.initialLink});
 @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthGate(initialLink: initialLink),
      title: "EduConnect",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
    );
  }
}


class AuthGate extends StatefulWidget {
  final Uri? initialLink;

  const AuthGate({super.key, this.initialLink});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _checkedVersion = false;

  @override
  void initState() {
    super.initState();
    _checkAppVersion();
  }

  void _checkAppVersion() async {
    final result = await VersionService.checkVersion();

    if (result["needsUpdate"]) {
      _showUpdateDialog(result["updateUrl"], result["forceUpdate"]);
    } else {
      setState(() {
        _checkedVersion = true; // versión ok
      });
    }
  }

  void _showUpdateDialog(String url, bool forced) {
    showDialog(
      context: context,
      barrierDismissible: !forced,
      builder: (_) {
        return AlertDialog(
          title: const Text("Actualización requerida"),
          content: Text(
            forced
                ? "Debes actualizar la app para continuar."
                : "Hay una nueva versión disponible.",
          ),
          actions: [
            TextButton(
              onPressed: () => launchUrl(Uri.parse(url)),
              child: const Text("Actualizar"),
            ),
            if (!forced)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Ahora no"),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mientras revisa la versión mostramos un loading
    if (!_checkedVersion) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Si versión correcta, sigue con la app
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return MainNavigation(initialLink: widget.initialLink);
        }

        return const LoginPage();
      },
    );
  }
}

