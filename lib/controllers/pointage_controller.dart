// // controllers/pointage_controller.dart
// import 'package:dio/dio.dart';
// import 'package:get/get.dart';
// import 'package:geolocator/geolocator.dart';
// import '../services/api_service.dart';
// import '../controllers/auth_controller.dart';

// class PointageController extends GetxController {
//   final ApiService _api = ApiService();
//   final AuthController _auth = Get.find<AuthController>();

//   var isLoading = false.obs;
//   var message = "".obs;
//   var lastPointage = Rxn<Map<String, dynamic>>();
//   var isInsideZone = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     _checkPermissionAndLoad();
//   }

//   Future<void> _checkPermissionAndLoad() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       message.value = "Activez la localisation";
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         message.value = "Permission refusée";
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       message.value = "Permission bloquée";
//       return;
//     }

//     await fetchLastPointage();
//   }

//   Future<void> fetchLastPointage() async {
//     final token = _auth.token;
//     final employeId = _auth.userId;
//     if (token == null || employeId == null) return;

//     try {
//       final pointage = await _api.getDernierPointage(
//         token: token,
//         employeId: employeId,
//       );
//       lastPointage.value = pointage;
//     } catch (e) {
//       // Silencieux
//     }
//   }

//   Future<Position?> _getCurrentPosition() async {
//     try {
//       return await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//         timeLimit: const Duration(seconds: 10),
//       );
//     } catch (e) {
//       message.value = "Impossible d'obtenir le GPS";
//       return null;
//     }
//   }

//   /// POINTAGE : envoie GPS au serveur, laisse le backend décider
//   Future<void> pointer(String type) async {
//     final token = _auth.token;
//     if (token == null) {
//       message.value = "Non authentifié";
//       return;
//     }

//     isLoading.value = true;
//     message.value = "Envoi du pointage...";

//     final position = await _getCurrentPosition();
//     if (position == null) {
//       isLoading.value = false;
//       return;
//     }

//     try {
//       final response = await _api.pointerGps(
//         token: token,
//         type: type,
//         latitude: position.latitude,
//         longitude: position.longitude,
//       );

//       final pointage = response.data['data']; // Laravel renvoie 'data'
//       lastPointage.value = {
//         'type': pointage['type'].toLowerCase(),
//         'date_heure': pointage['date_heure'],
//       };

//       message.value = "Pointage ${pointage['type']} enregistré !";
//       isInsideZone.value = true;

//     } on DioException catch (e) {
//       String error = "Erreur inconnue";

//       if (e.response?.statusCode == 403) {
//         error = e.response?.data['error'] ?? "Hors zone autorisée";
//         isInsideZone.value = false;
//       } else if (e.response?.statusCode == 400) {
//         error = e.response?.data['error'] ?? "Pointage invalide";
//       } else if (e.response?.statusCode == 401) {
//         error = "Session expirée";
//       } else {
//         error = e.response?.data['error'] ?? "Serveur indisponible";
//       }

//       message.value = error;

//     } catch (e) {
//       message.value = "Erreur réseau";
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import '../controllers/auth_controller.dart';

class PointageController extends GetxController {
  final ApiService _api = ApiService();
  AuthController? _auth; // ⚠️ Nullable pour éviter le crash

  var isLoading = false.obs;
  var message = "".obs;
  var lastPointage = Rxn<Map<String, dynamic>>();
  var isInsideZone = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkPermissionAndLoad();
  }

  @override
  void onReady() {
    super.onReady();
    // 🔒 Récupération sécurisée de l'AuthController
    if (Get.isRegistered<AuthController>()) {
      _auth = Get.find<AuthController>();
    } else {
      message.value = "Non authentifié";
    }
  }

  // ──────────────────────────────────────────────────────────────
  // VÉRIFICATION GPS ET PERMISSION
  // ──────────────────────────────────────────────────────────────
  Future<void> _checkPermissionAndLoad() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      message.value = "Activez la localisation";
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        message.value = "Permission refusée";
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      message.value = "Permission bloquée";
      return;
    }

    await fetchLastPointage();
  }

  // ──────────────────────────────────────────────────────────────
  // RÉCUPÉRATION DU DERNIER POINTAGE
  // ──────────────────────────────────────────────────────────────
  Future<void> fetchLastPointage() async {
    final token = _auth?.token;
    final employeId = _auth?.userId;

    if (token == null || employeId == null) {
      message.value = "Utilisateur non authentifié";
      return;
    }

    try {
      final pointage = await _api.getDernierPointage(
        token: token,
        employeId: employeId,
      );
      lastPointage.value = pointage;
    } catch (e) {
      // Silencieux pour éviter les erreurs à l’ouverture
    }
  }

  // ──────────────────────────────────────────────────────────────
  // RÉCUPÉRATION DE LA POSITION ACTUELLE
  // ──────────────────────────────────────────────────────────────
  Future<Position?> _getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      message.value = "Impossible d’obtenir la position GPS";
      return null;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // ACTION DE POINTAGE
  // ──────────────────────────────────────────────────────────────
  Future<void> pointer(String type) async {
    final token = _auth?.token;
    final userId = _auth?.userId;

    if (token == null || userId == null) {
      message.value = "Session expirée, reconnectez-vous";
      return;
    }

    isLoading.value = true;
    message.value = "Envoi du pointage...";

    final position = await _getCurrentPosition();
    if (position == null) {
      isLoading.value = false;
      return;
    }

    try {
      final response = await _api.pointerGps(
        token: token,
        type: type,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      final pointage = response.data['data'];
      if (pointage != null) {
        lastPointage.value = {
          'type': pointage['type'].toLowerCase(),
          'date_heure': pointage['date_heure'],
        };

        message.value = "Pointage ${pointage['type']} enregistré !";
        isInsideZone.value = true;
      } else {
        message.value = "Aucune donnée reçue du serveur";
      }
    } on DioException catch (e) {
      String error = "Erreur réseau";

      if (e.response != null) {
        switch (e.response?.statusCode) {
          case 403:
            error = e.response?.data['error'] ?? "Hors zone autorisée";
            isInsideZone.value = false;
            break;
          case 400:
            error = e.response?.data['error'] ?? "Pointage invalide";
            break;
          case 401:
            error = "Session expirée";
            break;
          default:
            error = e.response?.data['error'] ?? "Serveur indisponible";
        }
      }

      message.value = error;
    } catch (e) {
      message.value = "Erreur inattendue : ${e.toString()}";
    } finally {
      isLoading.value = false;
    }
  }
}
