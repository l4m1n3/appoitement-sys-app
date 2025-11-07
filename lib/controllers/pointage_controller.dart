// import 'package:dio/dio.dart';
// import 'package:get/get.dart';
// import 'package:geolocator/geolocator.dart';
// import '../services/api_service.dart';
// import '../controllers/auth_controller.dart';

// class PointageController extends GetxController {
//   final ApiService _api = ApiService();
//   AuthController? _auth; // ⚠️ Nullable pour éviter le crash

//   var isLoading = false.obs;
//   var message = "".obs;
//   var lastPointage = Rxn<Map<String, dynamic>>();
//   var isInsideZone = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     _checkPermissionAndLoad();
//   }

//   @override
//   void onReady() {
//     super.onReady();
//     // 🔒 Récupération sécurisée de l'AuthController
//     if (Get.isRegistered<AuthController>()) {
//       _auth = Get.find<AuthController>();
//     } else {
//       message.value = "Non authentifié";
//     }
//   }

//   // ──────────────────────────────────────────────────────────────
//   // VÉRIFICATION GPS ET PERMISSION
//   // ──────────────────────────────────────────────────────────────
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

//   // ──────────────────────────────────────────────────────────────
//   // RÉCUPÉRATION DU DERNIER POINTAGE
//   // ──────────────────────────────────────────────────────────────
//   Future<void> fetchLastPointage() async {
//     final token = _auth?.token;
//     final employeId = _auth?.userId;

//     if (token == null || employeId == null) {
//       message.value = "Utilisateur non authentifié";
//       return;
//     }

//     try {
//       final pointage = await _api.getDernierPointage(
//         token: token,
//         employeId: employeId,
//       );
//       lastPointage.value = pointage;
//     } catch (e) {
//       // Silencieux pour éviter les erreurs à l’ouverture
//     }
//   }

//   // ──────────────────────────────────────────────────────────────
//   // RÉCUPÉRATION DE LA POSITION ACTUELLE
//   // ──────────────────────────────────────────────────────────────
//   Future<Position?> _getCurrentPosition() async {
//     try {
//       return await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//         timeLimit: const Duration(seconds: 10),
//       );
//     } catch (e) {
//       message.value = "Impossible d’obtenir la position GPS";
//       return null;
//     }
//   }

//   // ──────────────────────────────────────────────────────────────
//   // ACTION DE POINTAGE
//   // ──────────────────────────────────────────────────────────────
//   Future<void> pointer(String type) async {
//     final token = _auth?.token;
//     final userId = _auth?.userId;

//     if (token == null || userId == null) {
//       message.value = "Session expirée, reconnectez-vous";
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

//       final pointage = response.data['data'];
//       if (pointage != null) {
//         lastPointage.value = {
//           'type': pointage['type'].toLowerCase(),
//           'date_heure': pointage['date_heure'],
//         };

//         message.value = "Pointage ${pointage['type']} enregistré !";
//         isInsideZone.value = true;
//       } else {
//         message.value = "Aucune donnée reçue du serveur";
//       }
//     } on DioException catch (e) {
//       String error = "Erreur réseau";

//       if (e.response != null) {
//         switch (e.response?.statusCode) {
//           case 403:
//             error = e.response?.data['error'] ?? "Hors zone autorisée";
//             isInsideZone.value = false;
//             break;
//           case 400:
//             error = e.response?.data['error'] ?? "Pointage invalide";
//             break;
//           case 401:
//             error = "Session expirée";
//             break;
//           default:
//             error = e.response?.data['error'] ?? "Serveur indisponible";
//         }
//       }

//       message.value = error;
//     } catch (e) {
//       message.value = "Erreur inattendue : ${e.toString()}";
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }
// pointage_controller.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get_storage/get_storage.dart';
import '../services/api_service.dart';
import '../controllers/auth_controller.dart';

class PointageController extends GetxController {
  final ApiService _api = ApiService();
  AuthController? _auth;

  // Observables
  var isLoading = false.obs;
  var message = "".obs;
  var lastPointage = Rxn<Map<String, dynamic>>();
  var isInsideZone = false.obs;

  // Bluetooth
  var isScanning = false.obs;
  var nearbyPortiques = <String>[].obs;
  var selectedPortique = RxnString();
  FlutterBluePlus flutterBlue = FlutterBluePlus();

  @override
  void onInit() {
    super.onInit();
    _checkAllPermissions();
  }

  @override
  void onReady() {
    super.onReady();
    if (Get.isRegistered<AuthController>()) {
      _auth = Get.find<AuthController>();
    }
    fetchLastPointage();
  }

  // ──────────────────────────────────────────────────────────────
  // PERMISSIONS (GPS + Bluetooth)
  // ──────────────────────────────────────────────────────────────
  Future<void> _checkAllPermissions() async {
    // GPS
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      message.value = "Activez la localisation";
      return;
    }

    LocationPermission locPerm = await Geolocator.checkPermission();
    if (locPerm == LocationPermission.denied) {
      locPerm = await Geolocator.requestPermission();
      if (locPerm == LocationPermission.denied) {
        message.value = "Permission GPS refusée";
        return;
      }
    }

    // Bluetooth
    if (!(await Permission.bluetoothScan.isGranted)) {
      await Permission.bluetoothScan.request();
    }
    if (!(await Permission.bluetoothConnect.isGranted)) {
      await Permission.bluetoothConnect.request();
    }
    if (!(await Permission.locationWhenInUse.isGranted)) {
      await Permission.locationWhenInUse.request();
    }
  }

  // ──────────────────────────────────────────────────────────────
  // DERNIER POINTAGE
  // ──────────────────────────────────────────────────────────────
  Future<void> fetchLastPointage() async {
    final token = _auth?.token ?? GetStorage().read('token');
    final employeId = _auth?.userId ?? GetStorage().read('user_id');

    if (token == null || employeId == null) return;

    try {
      final pointage = await _api.getDernierPointage(
        token: token,
        employeId: employeId,
      );
      lastPointage.value = pointage;
    } catch (e) {
      // Silencieux
    }
  }

  // ──────────────────────────────────────────────────────────────
  // POINTAGE GPS
  // ──────────────────────────────────────────────────────────────
  Future<Position?> _getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      message.value = "GPS indisponible";
      return null;
    }
  }

  Future<void> pointer(String type) async {
    final token = _auth?.token ?? GetStorage().read('token');
    if (token == null) {
      message.value = "Reconnectez-vous";
      return;
    }

    isLoading.value = true;
    message.value = "Pointage GPS...";

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

      if (response.statusCode == 201) {
        message.value = "Pointage GPS enregistré !";
        isInsideZone.value = true;
        await fetchLastPointage();
      }
    } on DioException catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // POINTAGE BLUETOOTH
  // ──────────────────────────────────────────────────────────────
  void startBluetoothScan() async {
    if (isScanning.value) return;

    isScanning.value = true;
    nearbyPortiques.clear();
    message.value = "Scan Bluetooth...";

    try {
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 8));

      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult r in results) {
          final name = r.device.name.toUpperCase();
          final mac = r.device.id.id.toUpperCase();

          // Filtre intelligent : nom ou UUID
          if (name.contains("PORTIQUE") ||
              name.contains("BEACON") ||
              name.contains("DOOR") ||
              r.advertisementData.serviceUuids.isNotEmpty) {
            if (!nearbyPortiques.contains(mac)) {
              nearbyPortiques.add(mac);
            }
          }
        }
      });
    } catch (e) {
      message.value = "Erreur Bluetooth";
    } finally {
      await Future.delayed(Duration(seconds: 9));
      await FlutterBluePlus.stopScan();
      isScanning.value = false;

      if (nearbyPortiques.isEmpty) {
        message.value = "Aucun portique détecté";
      } else {
        message.value = "${nearbyPortiques.length} portique(s) trouvé(s)";
      }
    }
  }

  Future<void> pointerViaBluetooth(String type) async {
    final token = _auth?.token ?? GetStorage().read('token');
    if (token == null) return;

    if (nearbyPortiques.isEmpty) {
      message.value = "Aucun portique";
      return;
    }

    isLoading.value = true;
    message.value = "Vérification portique...";

    try {
      final authorized = await _api.getAuthorizedPortiques(token);
      final validMac = nearbyPortiques.firstWhere(
        (mac) => authorized.contains(mac),
        orElse: () => "",
      );

      if (validMac.isEmpty) {
        message.value = "Portique non autorisé";
        Get.snackbar("Refusé", "Accès interdit", backgroundColor: Colors.red);
        isLoading.value = false;
        return;
      }

      selectedPortique.value = validMac;

      final response = await _api.pointerPortique(
        token: token,
        type: type,
        macAddress: validMac,
      );

      if (response.statusCode == 201) {
        message.value = "Pointage Bluetooth OK !";
        await fetchLastPointage();
        Get.snackbar("Succès", "Pointé via portique", backgroundColor: Colors.green);
      }
    } on DioException catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // GESTION ERREURS
  // ──────────────────────────────────────────────────────────────
  void _handleError(DioException e) {
    String error = "Erreur réseau";

    if (e.response != null) {
      final data = e.response!.data;
      error = data is Map && data['error'] != null
          ? data['error']
          : "Erreur ${e.response!.statusCode}";

      if (e.response!.statusCode == 403) {
        isInsideZone.value = false;
      }
    }

    message.value = error;
  }

  // ──────────────────────────────────────────────────────────────
  // TYPE SUIVANT (entrée → sortie)
  // ──────────────────────────────────────────────────────────────
  String getNextType() {
    final last = lastPointage.value?['type'];
    return last == 'entrée' ? 'sortie' : 'entrée';
  }
}