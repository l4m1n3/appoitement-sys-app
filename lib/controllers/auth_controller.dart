import 'package:appointement_app/screens/home/pointage_screen.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/api_service.dart';

class AuthController extends GetxController {
  final ApiService _api = ApiService();
  final box = GetStorage();
  var isLoading = false.obs;

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final response = await _api.login(email, password);
      final data = response.data;
      print(data);
      if (data['token'] != null) {
        box.write('token', data['token']);
        Get.offAll(() => PointageScreen());
      } else {
        Get.snackbar("Erreur", "Identifiants incorrects");
      }
    } catch (e) {
      Get.snackbar("Erreur", "Connexion échouée");
    } finally {
      isLoading.value = false;
    }
  }

  String? get token => box.read('token');
}
