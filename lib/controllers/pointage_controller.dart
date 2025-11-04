// controllers/pointage_controller.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import '../controllers/auth_controller.dart';

class PointageController extends GetxController {
  final ApiService _api = ApiService();
  final AuthController _auth = Get.find<AuthController>();

  // États observables
  var isLoading = false.obs;
  var message = "".obs;
  var lastPointage = Rxn<Map<String, dynamic>>();
  var isInsideZone = false.obs;

  // Configuration de la zone autorisée
  static const double entrepriseLat = 13.5116;
  static const double entrepriseLng = 2.1254;
  static const double rayonMetres = 100.0;

  @override
  void onInit() {
    super.onInit();
    _checkPermissionAndLoad();
  }

  /// Vérifie les permissions et charge le dernier pointage
  Future<void> _checkPermissionAndLoad() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      message.value = "Veuillez activer la localisation";
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        message.value = "Permission de localisation refusée";
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      message.value = "Permission bloquée définitivement";
      return;
    }

    await fetchLastPointage();
  }

  /// Récupère le dernier pointage
  Future<void> fetchLastPointage() async {
    final token = _auth.token;
    final employeId = _auth.userId;
    if (token == null || employeId == null) return;
    try {
      final pointage = await _api.getDernierPointage(
        token: token,
        employeId: employeId,
      );
      lastPointage.value = pointage;
    } catch (e) {
      // Silencieux si pas de pointage
    }
  }

  /// Récupère la position actuelle
  Future<Position?> _getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      message.value = "Impossible d'obtenir la position GPS";
      return null;
    }
  }

  /// Effectue un pointage
  Future<void> pointer(String type) async {
    final token = _auth.token;
    if (token == null) {
      message.value = "Non authentifié";
      return;
    }

    isLoading.value = true;
    message.value = "Récupération de la position...";

    final position = await _getCurrentPosition();
    if (position == null) {
      isLoading.value = false;
      return;
    }

    // Calcul de la distance
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      entrepriseLat,
      entrepriseLng,
    );

    if (distance > rayonMetres) {
      message.value = "Hors zone (${distance.toStringAsFixed(0)} m)";
      isInsideZone.value = false;
      isLoading.value = false;
      return;
    }

    isInsideZone.value = true;

    try {
      final response = await _api.pointerGps(
        token: token,
        type: type,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      final pointage = response.data;
      lastPointage.value = pointage;
      message.value = "Pointage ${pointage['type']} à ${pointage['date_heure']}";
    } on DioException catch (e) {
      String error = e.message ?? "Erreur serveur";
      if (e.response?.data is Map && e.response!.data['error'] != null) {
        error = e.response!.data['error'];
      }
      message.value = error;
    } catch (e) {
      message.value = "Erreur inattendue";
    } finally {
      isLoading.value = false;
    }
  }
}