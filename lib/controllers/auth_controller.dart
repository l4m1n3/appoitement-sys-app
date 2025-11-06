// // import 'package:appointement_app/screens/home/pointage_screen.dart';
// // import 'package:get/get.dart';
// // import 'package:get_storage/get_storage.dart';
// // import '../services/api_service.dart';

// // class AuthController extends GetxController {
// //   final ApiService _api = ApiService();
// //   final box = GetStorage();
// //   var isLoading = false.obs;

// //   Future<void> login(String email, String password) async {
// //     try {
// //       isLoading.value = true;
// //       final response = await _api.login(email, password);
// //       final data = response.data;
// //       print(data);
// //       if (data['access-token'] != null) {
// //         box.write('token', data['access-token']);
// //         Get.offAll(() => PointageScreen());
// //       } else {
// //         Get.snackbar("Erreur", "Identifiants incorrects");
// //       }
// //     } catch (e) {
// //       Get.snackbar("Erreur", "Connexion échouée");
// //     } finally {
// //       isLoading.value = false;
// //     }
// //   }

// //   String? get token => box.read('token');
// // }
// // controllers/auth_controller.dart
// import 'package:appointement_app/screens/home/pointage_screen.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import '../services/api_service.dart';

// class AuthController extends GetxController {
//   final ApiService _api = ApiService();
//   final box = GetStorage();

//   // États observables
//   var isLoading = false.obs;
//   var user = Rxn<Map<String, dynamic>>(); // Ajouté

//   @override
//   void onInit() {
//     super.onInit();
//     _loadUserFromStorage(); // Charger au démarrage
//   }

//   /// Charge le token + user depuis GetStorage
//   void _loadUserFromStorage() {
//     final token = box.read('token');
//     final userData = box.read('user');
//     if (token != null) {
//       this.token = token; // via setter
//       user.value = userData;
//     }
//   }

//   /// Login
//   Future<void> login(String email, String password) async {
//     try {
//       isLoading.value = true;
//       final response = await _api.login(email, password);
//       final data = response.data;

//       print("Réponse login: $data");

//       if (data['access-token'] != null) {
//         final token = data['access-token'];
//         final userData = data['user']; // Assure-toi que le backend renvoie 'user'

//         // Sauvegarde
//         box.write('token', token);
//         box.write('user', userData);

//         // Mise à jour état
//         this.token = token;
//         user.value = userData;

//         Get.offAll(() => PointageScreen());
//       } else {
//         Get.snackbar("Erreur", "Identifiants incorrects");
//       }
//     } catch (e) {
//       Get.snackbar("Erreur", "Connexion échouée : $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   /// Déconnexion
//   void logout() {
//     box.erase(); // ou box.remove('token'); box.remove('user');
//     user.value = null;
//     this.token = null;
//     Get.offAllNamed('/login');
//   }

//   /// Token (avec setter pour mise à jour)
//   String? _token;
//   String? get token => _token ?? box.read('token');
//   set token(String? value) {
//     _token = value;
//     if (value == null) {
//       box.remove('token');
//     } else {
//       box.write('token', value);
//     }
//   }

//   /// ID de l'utilisateur
//   int? get userId => user.value?['id'];
// }
// controllers/auth_controller.dart
import 'package:appointement_app/screens/home/pointage_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/api_service.dart';

class AuthController extends GetxController {
  final ApiService _api = ApiService();
  final box = GetStorage();
  var showPassword = false.obs;
  var errorMessage = "".obs;

  void togglePassword() {
    showPassword.value = !showPassword.value;
  }

  var isLoading = false.obs;
  var user = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final response = await _api.login(email, password);
      final data = response.data;

      print("Réponse login: $data");

      // CORRIGÉ : 'token' au lieu de 'access-token'
      if (data['token'] != null && data['user'] != null) {
        final token = data['token'];
        final userData = data['user'];

        // Sauvegarde
        box.write('token', token);
        box.write('user', userData);

        // Mise à jour état
        this.token = token;
        user.value = userData;

        Get.offAllNamed('/home'); // CORRECT
      } else {
        Get.snackbar("Erreur", "Réponse invalide du serveur");
      }
    } on DioException catch (e) {
      String error = "Connexion échouée";
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        error = errors?['email']?[0] ?? "Identifiants incorrects";
      }
      Get.snackbar(
        "Erreur",
        error,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Erreur", "Erreur inattendue: " + e.toString());
      print(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // --- Token avec persistance ---
  String? _token;
  String? get token => _token ?? box.read('token');
  // Ajoute cette ligne dans AuthController
  bool get isLoggedIn => token != null && user.value != null;
  set token(String? value) {
    _token = value;
    if (value == null) {
      box.remove('token');
    } else {
      box.write('token', value);
    }
  }

  // --- ID utilisateur ---
  int? get userId => user.value?['id'];

  // --- Chargement au démarrage ---
  void _loadUserFromStorage() {
    final token = box.read('token');
    final userData = box.read('user');
    if (token != null && userData != null) {
      this.token = token;
      user.value = userData;
    }
  }

  // --- Déconnexion ---
  void logout() {
    box.erase();
    user.value = null;
    this.token = null;
    Get.offAllNamed('/login');
  }
}
