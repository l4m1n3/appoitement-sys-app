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
import 'package:appointement_app/screens/auth/login/login_screen.dart';
import 'package:appointement_app/screens/home/pointage_screen.dart';
import 'package:appointement_app/controllers/auth_controller.dart';
import 'package:appointement_app/controllers/pointage_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final box = GetStorage();
  String? get _token => box.read('token');

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'App Pointage GPS',
      debugShowCheckedModeBanner: false,
      initialRoute: _token != null ? '/pointage' : '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => LoginScreen(),
          binding: BindingsBuilder(() {
            Get.put(AuthController()); // AuthController pour login
          }),
        ),
        GetPage(
          name: '/pointage',
          page: () => PointageScreen(),
          binding: BindingsBuilder(() {
            Get.put(AuthController());     // Si besoin
            Get.put(PointageController()); // OBLIGATOIRE ICI
          }),
        ),
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
    );
  }
}