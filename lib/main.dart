// // import 'package:appointement_app/screens/auth/login/login_screen.dart';
// // import 'package:appointement_app/screens/home/pointage_screen.dart';
// // import 'package:appointement_app/controllers/auth_controller.dart';
// // import 'package:appointement_app/controllers/pointage_controller.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:get_storage/get_storage.dart';

// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await GetStorage.init();

// //   final box = GetStorage();
// //   final token = box.read('token');

// //   // ✅ Initialisation des contrôleurs GetX
// //   Get.put(AuthController());
// //   Get.put(PointageController());

// //   runApp(MyApp(initialRoute: token != null ? '/pointage' : '/login'));
// // }

// // class MyApp extends StatelessWidget {
// //   final String initialRoute;
// //   const MyApp({required this.initialRoute, super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return GetMaterialApp(
// //       title: 'App Pointage Bluetooth',
// //       debugShowCheckedModeBanner: false,
// //       initialRoute: initialRoute,
// //       getPages: [
// //         GetPage(name: '/login', page: () => LoginScreen()),
// //         GetPage(name: '/pointage', page: () => PointageScreen()),
// //       ],
// //       theme: ThemeData(primarySwatch: Colors.blue),
// //     );
// //   }
// // }
// // main.dart
// import 'package:appointement_app/screens/auth/login/login_screen.dart';
// import 'package:appointement_app/screens/home/pointage_screen.dart';
// import 'package:appointement_app/controllers/auth_controller.dart';
// import 'package:appointement_app/controllers/pointage_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await GetStorage.init();

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   MyApp({super.key});

//   // Récupérer le token au démarrage
//   final box = GetStorage();
//   String? get _token => box.read('token');

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'App Pointage GPS',
//       debugShowCheckedModeBanner: false,
//       initialRoute: _token != null ? '/pointage' : '/login',
//       getPages: [
//         GetPage(name: '/login', page: () => LoginScreen()),
//         GetPage(
//           name: '/pointage',
//           page: () => PointageScreen(),
//           binding: BindingsBuilder(() {
//             // Initialisation des contrôleurs ici
//             Get.put(AuthController());
//             Get.put(PointageController());
//           }),
//         ),
//       ],
//       theme: ThemeData(
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
//       ),
//     );
//   }
// }
// main.dart
// import 'package:appointement_app/screens/auth/login/login_screen.dart';
// import 'package:appointement_app/screens/home/pointage_screen.dart';
// import 'package:appointement_app/controllers/auth_controller.dart';
// import 'package:appointement_app/controllers/pointage_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await GetStorage.init();

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   MyApp({super.key});

//   final box = GetStorage();
//   String? get _token => box.read('token');

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'App Pointage GPS',
//       debugShowCheckedModeBanner: false,
//       initialRoute: _token != null ? '/pointage' : '/login',
//       getPages: [
//         GetPage(
//           name: '/login',
//           page: () => LoginScreen(),
//           binding: BindingsBuilder(() {
//             Get.put(AuthController()); // AuthController pour login
//           }),
//         ),
//         GetPage(
//           name: '/pointage',
//           page: () => PointageScreen(),
//           binding: BindingsBuilder(() {
//             Get.put(AuthController());     // Si besoin
//             Get.put(PointageController()); // OBLIGATOIRE ICI
//           }),
//         ),
//       ],
//       theme: ThemeData(
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
//       ),
//     );
//   }
// }
// main.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';

// import 'screens/auth/login/login_screen.dart';
// import 'screens/home/pointage_screen.dart';
// import 'controllers/auth_controller.dart';
// import 'controllers/pointage_controller.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await GetStorage.init();
//   runApp(MyApp());
// }

// // ──────────────────────────────────────────────────────────────
// // BINDING GLOBAL
// // ──────────────────────────────────────────────────────────────
// class AppBinding extends Bindings {
//   @override
//   void dependencies() {
//     // AuthController permanent, disponible partout
//     Get.put(AuthController(), permanent: true);

//     // PointageController à la demande, sera recréé si supprimé
//     Get.lazyPut(() => PointageController(), fenix: true);
//   }
// }

// // ──────────────────────────────────────────────────────────────
// // APPLICATION
// // ──────────────────────────────────────────────────────────────
// class MyApp extends StatelessWidget {
//   MyApp({super.key});

//   final box = GetStorage();

//   String? get _token => box.read('token');

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'App Pointage GPS',
//       debugShowCheckedModeBanner: false,

//       // Binding global au démarrage
//       initialBinding: AppBinding(),

//       // Redirection selon token
//       initialRoute: _token != null ? '/pointage' : '/login',

//       getPages: [
//         GetPage(
//           name: '/login',
//           page: () => LoginScreen(),
//         ),
//         GetPage(
//           name: '/pointage',
//           page: () => PointageScreen(),
//         ),
//       ],

//       theme: ThemeData(
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'controllers/auth_controller.dart';
import 'controllers/pointage_controller.dart';
import 'screens/auth/login/login_screen.dart';
import 'screens/home/pointage_screen.dart'; // si tu l’as

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation GetStorage avant tout
  await GetStorage.init();

  // Injection des controllers principaux
  Get.put(AuthController(), permanent: true);
  Get.lazyPut(() => PointageController(), fenix: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.find<AuthController>();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App de Pointage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),

      // --- Détermination de la page initiale ---
      initialRoute: auth.isLoggedIn ? '/home' : '/login',

      // --- Définition des routes ---
      getPages: [
        GetPage(name: '/login', page: () =>  LoginScreen()),
        GetPage(name: '/home', page: () => PointageScreen()),
      ],
    );
  }
}
