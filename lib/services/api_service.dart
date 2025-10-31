// import 'package:dio/dio.dart';

// class ApiService {
//   final Dio _dio = Dio(
//     BaseOptions(
//       baseUrl: "http://10.0.2.2:8000/api",
//       connectTimeout: const Duration(seconds: 5),
//       receiveTimeout: const Duration(seconds: 3),
//     ),
//   );

//   Future<Response> login(String email, String password) async {
//     return _dio.post("/login", data: {"email": email, "password": password});
//   }

//   Future<Response> pointer(
//     String token,
//     String action,
//     String deviceMac,
//   ) async {
//     return _dio.post(
//       "/pointages/action",
//       data: {"action": action, "device_mac": deviceMac},
//       options: Options(
//         headers: {
//           "Authorization": "Bearer $token",
//           "Accept": "application/json",
//         },
//       ),
//     );
//   }

//   Future<String?> getPortique(String token) async {
//     final response = await _dio.get(
//       '/portique',
//       options: Options(headers: {'Authorization': 'Bearer $token'}),
//     );

//     if (response.statusCode == 200) {
//       return response.data['device_mac'] as String?;
//     }
//     return null;
//   }

//   // Récupère tous les portiques autorisés
//   Future<List<String>> getAuthorizedPortiques(String token) async {
//     final response = await _dio.get(
//       '/portiques', // endpoint qui retourne la liste des MAC
//       options: Options(headers: {'Authorization': 'Bearer $token'}),
//     );

//     if (response.statusCode == 200) {
//       // On suppose que la réponse est : { "portiques": ["00:11:22:33:44:55", ...] }
//       List<dynamic> data = response.data['portiques'];
//       return data.map((e) => e.toString()).toList();
//     }

//     return [];
//   }
// }
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:8000/api", // OK pour émulateur Android
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  /// Connexion utilisateur
  Future<Response> login(String email, String password) async {
    return await _dio.post(
      "/login",
      data: {"email": email, "password": password},
    );
  }

  /// Récupère la liste des MAC autorisés
  Future<List<String>> getAuthorizedPortiques(String token) async {
    try {
      final response = await _dio.get(
        '/portiques/authorized', // ← Endpoint corrigé
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        // Le backend renvoie : ["AA:BB:CC:...", ...]
        final List<dynamic> data = response.data;
        return data.map((e) => e.toString()).toList();
      }
    } on DioException catch (e) {
      print("Erreur getAuthorizedPortiques: ${e.message}");
    }
    return [];
  }

  /// Envoie un pointage
  Future<Response> pointer(
    String token,
    String action,
    String macAddress,
  ) async {
    // Normalisation : "Entrée" → "entrée"
    final type = action.toLowerCase() == 'entrée' ? 'entrée' : 'sortie';

    return await _dio.post(
      '/pointages', // ← Endpoint correct
      data: {"portique_mac": macAddress, "type": type},
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }

  // Optionnel : Récupérer le portique actuel (si besoin)
  Future<String?> getCurrentPortiqueMac(String token) async {
    try {
      final response = await _dio.get(
        '/portiques/authorized',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final List<dynamic> macs = response.data;
      return macs.isNotEmpty ? macs.first : null;
    } catch (e) {
      return null;
    }
  }
}
