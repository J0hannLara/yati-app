<div align="center">

# 🎓 YATI

### Plataforma móvil para la digitalización de contenidos y actividades educativas

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

🥈 **Segundo lugar — Feria de Innovación Tecnológica, Universidad Pública de El Alto (UPEA)**

</div>

---

## 📖 Descripción

**YATI** es una aplicación móvil orientada a la gestión y organización de contenidos y actividades educativas. Nace como respuesta a la necesidad de digitalizar clases virtuales y centralizar el material didáctico en una plataforma accesible, moderna y disponible en tiempo real.

Desarrollada completamente en Flutter, utiliza Firebase como backend para autenticación, almacenamiento y persistencia de datos con una base de datos NoSQL.

---

## ✨ Características principales

- 🔐 **Autenticación de usuarios** con Firebase Auth.
- 📚 **Gestión de contenidos educativos** organizados por categorías.
- 📝 **Actividades y tareas** con seguimiento en tiempo real.
- ☁️ **Almacenamiento de archivos** y recursos didácticos en Firebase Storage.
- ⚡ **Sincronización en tiempo real** con Firebase Realtime / Firestore.
- 📱 **Interfaz intuitiva** diseñada para estudiantes y docentes.
- 🌙 **Modo responsive** y adaptable a distintos tamaños de pantalla.

---

## 🛠️ Stack tecnológico

| Capa | Tecnologías |
|------|-------------|
| **Frontend móvil** | Flutter · Dart |
| **Backend / BaaS** | Firebase |
| **Autenticación** | Firebase Auth |
| **Base de datos** | Cloud Firestore (NoSQL) |
| **Almacenamiento** | Firebase Storage |

---

## 🏗️ Arquitectura
┌─────────────────────┐ ┌──────────────────────┐
│ App Flutter │ ◄─────► │ Firebase │
│ (Android / iOS) │ SDK │ Auth · Firestore │
│ │ │ Storage · Realtime │
└─────────────────────┘ └──────────────────────┘

text

---

## 🚀 Instalación

### Requisitos previos

- Flutter SDK `>=3.0.0`
- Cuenta de Firebase
- Android Studio / VS Code

### Pasos

```bash
# Clonar el repositorio
git clone https://github.com/J0hannLara/yati-app.git
cd yati

# Instalar dependencias
flutter pub get

# Configurar Firebase
# 1. Crea un proyecto en https://console.firebase.google.com
# 2. Agrega las apps Android / iOS
# 3. Descarga google-services.json (Android) y GoogleService-Info.plist (iOS)
# 4. Colócalos en las carpetas correspondientes

# Ejecutar la app
flutter run
```

🎯 Roadmap
☑ Autenticación con Firebase Auth
☑ Gestión de contenidos educativos
☑ Almacenamiento en Firebase Storage
☑ Base de datos NoSQL con Firestore
□ Notificaciones push con FCM
□ Modo offline con caché local
□ Chat en tiempo real entre estudiantes y docentes
□ Panel web para docentes
👨‍💻 Autor
Laradev — Desarrollador Full Stack

<div align="center">
⭐ Si te gustó este proyecto, dale una estrella ⭐

</div> 
