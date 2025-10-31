// import 'package:dio/dio.dart';
// import 'package:get/get.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import '../services/api_service.dart';
// import '../controllers/auth_controller.dart';
// import 'package:permission_handler/permission_handler.dart';
// class PointageController extends GetxController {
//   final ApiService _api = ApiService();
//   final AuthController _auth = Get.find<AuthController>();

//   var devicesList = <BluetoothDevice>[].obs;
//   var authorizedMacs = <String>[].obs;
//   var selectedDevice = Rxn<BluetoothDevice>();
//   var isScanning = false.obs;
//   var isLoading = false.obs;
//   var message = "".obs;
//   var isConnected = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchAuthorizedPortiques(); // Chargement au démarrage
//   }

//   Future<void> _checkPermissions() async {
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.bluetoothScan,
//       Permission.bluetoothConnect,
//       Permission.location,
//     ].request();

//     if (statuses.values.any((s) => !s.isGranted)) {
//       message.value = "Permissions Bluetooth requises";
//       throw Exception("Permissions manquantes");
//     }
//   }

//   Future<void> fetchAuthorizedPortiques() async {
//     final token = _auth.token;
//     if (token == null) return;

//     try {
//       authorizedMacs.value = await _api.getAuthorizedPortiques(token);
//     } catch (e) {
//       message.value = "Erreur: Portiques non récupérés";
//     }
//   }

//   Future<void> scanDevices() async {
//     devicesList.clear();
//     message.value = "Scan en cours...";
//     isScanning.value = true;

//     try {
//       await _checkPermissions();
//       await fetchAuthorizedPortiques();
//     } catch (e) {
//       isScanning.value = false;
//       return;
//     }

//     await FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
//     FlutterBluePlus.scanResults.listen((results) {
//       for (var r in results) {
//         final device = r.device;
//         final mac = device.remoteId.str;
//         if (authorizedMacs.contains(mac) && !devicesList.any((d) => d.remoteId == device.remoteId)) {
//           devicesList.add(device);
//         }
//       }
//     });

//     await Future.delayed(Duration(seconds: 5));
//     await FlutterBluePlus.stopScan();
//     isScanning.value = false;
//     message.value = "Scan terminé : ${devicesList.length} portique(s) trouvé(s)";
//   }

//   Future<void> connectToDevice(BluetoothDevice device) async {
//     message.value = "Connexion à ${device.platformName}...";
//     isLoading.value = true;
//     try {
//       await device.connect(timeout: Duration(seconds: 10), license: License.free);
//       selectedDevice.value = device;
//       isConnected.value = true;
//       message.value = "Connecté à ${device.platformName}";
//     } catch (e) {
//       message.value = "Échec connexion : $e";
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> disconnect() async {
//     final device = selectedDevice.value;
//     if (device != null) {
//       await device.disconnect();
//       selectedDevice.value = null;
//       isConnected.value = false;
//       message.value = "Déconnecté";
//     }
//   }

//   Future<void> pointer(String action) async {
//   final token = _auth.token;
//   final device = selectedDevice.value;
//   if (token == null || device == null) {
//     message.value = "Connexion ou portique manquant";
//     return;
//   }

//   isLoading.value = true;
//   try {
//     final response = await _api.pointer(token, action, device.remoteId.str);
    
//     // Le backend renvoie le pointage complet
//     final pointage = response.data;
//     message.value = "Pointage ${pointage['type']} enregistré à ${pointage['date_heure']}";
//   } on DioException catch (e) {
//     String error = "Erreur";
//     if (e.response?.data != null) {
//       error = e.response!.data['error'] ?? "Erreur serveur";
//     }
//     message.value = error;
//   } finally {
//     isLoading.value = false;
//   }
// }
// }
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/api_service.dart';
import '../controllers/auth_controller.dart';
import 'package:permission_handler/permission_handler.dart';

class PointageController extends GetxController {
  final ApiService _api = ApiService();
  final AuthController _auth = Get.find<AuthController>();

  var devicesList = <BluetoothDevice>[].obs;
  var authorizedMacs = <String>[].obs;
  var selectedDevice = Rxn<BluetoothDevice>();
  var isScanning = false.obs;
  var isLoading = false.obs;
  var message = "".obs;
  var isConnected = false.obs;

  /// Détermine si on filtre les appareils par les MAC autorisées ou pas
  var filterAuthorizedOnly = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAuthorizedPortiques();
  }

  Future<void> _checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (statuses.values.any((s) => !s.isGranted)) {
      message.value = "Permissions Bluetooth requises";
      throw Exception("Permissions manquantes");
    }
  }

  Future<void> fetchAuthorizedPortiques() async {
    final token = _auth.token;
    if (token == null) return;

    try {
      authorizedMacs.value = await _api.getAuthorizedPortiques(token);
    } catch (e) {
      message.value = "Erreur: Portiques non récupérés";
    }
  }

  Future<void> scanDevices({bool filterOnly = false}) async {
    devicesList.clear();
    message.value = "Scan en cours...";
    isScanning.value = true;
    filterAuthorizedOnly.value = filterOnly;

    try {
      await _checkPermissions();
      await fetchAuthorizedPortiques();
    } catch (e) {
      isScanning.value = false;
      return;
    }

    // Démarre le scan
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) {
      for (var r in results) {
        final device = r.device;
        final mac = device.remoteId.str;

        // ✅ Si on veut tous les périphériques
        if (!filterAuthorizedOnly.value) {
          if (!devicesList.any((d) => d.remoteId == device.remoteId)) {
            devicesList.add(device);
          }
        } 
        // ✅ Sinon, on filtre par les MAC autorisées
        else if (authorizedMacs.contains(mac) &&
            !devicesList.any((d) => d.remoteId == device.remoteId)) {
          devicesList.add(device);
        }
      }
    });

    await Future.delayed(const Duration(seconds: 5));
    await FlutterBluePlus.stopScan();

    isScanning.value = false;
    message.value =
        "Scan terminé : ${devicesList.length} périphérique(s) trouvé(s)";
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    message.value = "Connexion à ${device.platformName}...";
    isLoading.value = true;
    try {
      await device.connect(timeout: const Duration(seconds: 10), license: License.free);
      selectedDevice.value = device;
      isConnected.value = true;
      message.value = "Connecté à ${device.platformName}";
    } catch (e) {
      message.value = "Échec connexion : $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> disconnect() async {
    final device = selectedDevice.value;
    if (device != null) {
      await device.disconnect();
      selectedDevice.value = null;
      isConnected.value = false;
      message.value = "Déconnecté";
    }
  }

  Future<void> pointer(String action) async {
    final token = _auth.token;
    final device = selectedDevice.value;
    if (token == null || device == null) {
      message.value = "Connexion ou portique manquant";
      return;
    }

    isLoading.value = true;
    try {
      final response = await _api.pointer(token, action, device.remoteId.str);
      final pointage = response.data;
      message.value =
          "Pointage ${pointage['type']} enregistré à ${pointage['date_heure']}";
    } on DioException catch (e) {
      String error = "Erreur";
      if (e.response?.data != null) {
        error = e.response!.data['error'] ?? "Erreur serveur";
      }
      message.value = error;
    } finally {
      isLoading.value = false;
    }
  }
}
