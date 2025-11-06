// controllers/pointage_controller_mock.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class PointageControllerMock extends GetxController {
  // États observables
  var isLoading = false.obs;
  var message = "".obs;
  var lastPointage = Rxn<Map<String, dynamic>>();
  var isInsideZone = true.obs;

  // Zone simulée
  var mockDistance = 45.0.obs; // mètres
  var rayonMax = 100.0.obs;

  // Historique
  var historique = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void _loadMockData() {
    // Simule un dernier pointage
    Future.delayed(const Duration(seconds: 1), () {
      lastPointage.value = {
        'type': 'entrée',
        'date_heure': '2025-04-05 08:30:00',
      };
      historique.add(lastPointage.value!);
    });
  }

  Future<void> pointer(String type) async {
    isLoading.value = true;
    message.value = "Vérification GPS...";

    await Future.delayed(const Duration(milliseconds: 1200));

    // Simule hors zone si trop loin
    if (mockDistance.value > rayonMax.value) {
      message.value = "Hors zone (${mockDistance.value.toInt()}m)";
      isInsideZone.value = false;
      isLoading.value = false;
      return;
    }

    isInsideZone.value = true;

    final now = DateTime.now();
    final dateHeure =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} "
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:00";

    final pointage = {'type': type, 'date_heure': dateHeure};

    lastPointage.value = pointage;
    historique.insert(0, pointage);

    message.value = "Pointage $type enregistré !";
    isLoading.value = false;

    // Reset message
    Future.delayed(const Duration(seconds: 3), () {
      if (message.value.contains("enregistré")) {
        message.value = "Prêt à pointer";
      }
    });
  }

  void setDistance(double value) {
    mockDistance.value = value;
    isInsideZone.value = value <= rayonMax.value;
  }
}
