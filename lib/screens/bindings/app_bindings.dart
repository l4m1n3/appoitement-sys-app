import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/pointage_controller.dart';
import '../../services/api_service.dart';


class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.put(ApiService(), permanent: true);

    // Controllers globaux
    Get.put(AuthController(), permanent: true);

    // Controllers spécifiques
    Get.lazyPut(() => PointageController(), fenix: true);
  }
}
