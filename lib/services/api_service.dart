
// import 'package:dio/dio.dart';

// class ApiService {
//   final Dio _dio = Dio(
//     BaseOptions(
//       baseUrl: "http://10.0.2.2:8000/api", // OK pour émulateur Android
//       connectTimeout: const Duration(seconds: 10),
//       receiveTimeout: const Duration(seconds: 10),
//       headers: {
//         'Accept': 'application/json',
//         'Content-Type': 'application/json',
//       },
//     ),
//   );

//   /// Connexion utilisateur
//   Future<Response> login(String email, String password) async {
//     return await _dio.post(
//       "/login",
//       data: {"email": email, "password": password},
//     );
//   }

//   /// Récupère la liste des MAC autorisés
//   Future<List<String>> getAuthorizedPortiques(String token) async {
//     try {
//       final response = await _dio.get(
//         '/portiques/authorized', // ← Endpoint corrigé
//         options: Options(headers: {'Authorization': 'Bearer $token'}),
//       );

//       if (response.statusCode == 200) {
//         // Le backend renvoie : ["AA:BB:CC:...", ...]
//         final List<dynamic> data = response.data;
//         return data.map((e) => e.toString()).toList();
//       }
//     } on DioException catch (e) {
//       print("Erreur getAuthorizedPortiques: ${e.message}");
//     }
//     return [];
//   }

//   /// Envoie un pointage
//   Future<Response> pointer(
//     String token,
//     String action,
//     String macAddress,
//   ) async {
//     // Normalisation : "Entrée" → "entrée"
//     final type = action.toLowerCase() == 'entrée' ? 'entrée' : 'sortie';

//     return await _dio.post(
//       '/pointages', // ← Endpoint correct
//       data: {"portique_mac": macAddress, "type": type},
//       options: Options(headers: {"Authorization": "Bearer $token"}),
//     );
//   }

//   // Optionnel : Récupérer le portique actuel (si besoin)
//   Future<String?> getCurrentPortiqueMac(String token) async {
//     try {
//       final response = await _dio.get(
//         '/portiques/authorized',
//         options: Options(headers: {'Authorization': 'Bearer $token'}),
//       );
//       final List<dynamic> macs = response.data;
//       return macs.isNotEmpty ? macs.first : null;
//     } catch (e) {
//       return null;
//     }
//   }
// }
// services/api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiService {
  // Dio instance
  late final Dio _dio;

  // Base URL (configurable)
  static const String _baseUrl = "http://10.0.2.2:8000/api"; // Émulateur Android
  // Pour iOS Simulator : "http://localhost:8000/api"
  // Pour appareil réel : "http://192.168.x.x:8000/api"

  // Constructeur
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      // Réponse JSON automatique
      responseType: ResponseType.json,
    ));

    // Intercepteurs
    _setupInterceptors();
  }

  // Configuration des intercepteurs
  void _setupInterceptors() {
    // 1. Logger uniquement en mode debug
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }

    // 2. Intercepteur personnalisé (logs, erreurs, etc.)
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Ajouter le token si disponible (optionnel ici, géré par méthode)
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (DioException e, handler) {
          // Gestion centralisée des erreurs
          String errorMessage = "Erreur réseau";

          if (e.response != null) {
            final data = e.response!.data;
            errorMessage = data is Map && data.containsKey('error')
                ? data['error']
                : "Erreur ${e.response!.statusCode}";
          } else if (e.type == DioExceptionType.connectionTimeout ||
                     e.type == DioExceptionType.receiveTimeout) {
            errorMessage = "Délai d'attente dépassé";
          } else if (e.type == DioExceptionType.connectionError) {
            errorMessage = "Pas de connexion Internet";
          }

          e = e.copyWith(message: errorMessage);
          handler.next(e);
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // 1. Connexion utilisateur
  // ──────────────────────────────────────────────────────────────
  Future<Response> login(String email, String password) async {
    return await _dio.post(
      "/login",
      data: {
        "email": email,
        "password": password,
      },
    );
  }

  // ──────────────────────────────────────────────────────────────
  // 2. Pointage GPS (PRINCIPAL)
  // ──────────────────────────────────────────────────────────────
  Future<Response> pointerGps({
    required String token,
    required String type, // "entrée" ou "sortie"
    required double latitude,
    required double longitude,
  }) async {
    return await _dio.post(
      '/pointages',
      data: {
        'type': type.toLowerCase(),
        'latitude': latitude,
        'longitude': longitude,
      },
      options: Options(
        headers: {"Authorization": "Bearer $token"},
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // 3. Pointage via Portique Bluetooth (OPTIONNEL)
  // ──────────────────────────────────────────────────────────────
  Future<Response> pointerPortique({
    required String token,
    required String type,
    required String macAddress,
  }) async {
    return await _dio.post(
      '/pointages',
      data: {
        'type': type.toLowerCase(),
        'portique_mac': macAddress,
      },
      options: Options(
        headers: {"Authorization": "Bearer $token"},
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // 4. Récupérer les MAC autorisées
  // ──────────────────────────────────────────────────────────────
  Future<List<String>> getAuthorizedPortiques(String token) async {
    try {
      final response = await _dio.get(
        '/portiques/authorized',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data is List) {
        return List<String>.from(response.data);
      }
    } on DioException catch (e) {
      if (kDebugMode) print("getAuthorizedPortiques error: ${e.message}");
    }
    return [];
  }

  // ──────────────────────────────────────────────────────────────
  // 5. Dernier pointage de l'utilisateur
  // ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getDernierPointage({
    required String token,
    required int employeId,
  }) async {
    try {
      final response = await _dio.get(
        '/pointages/dernier/$employeId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode != 404) {
        if (kDebugMode) print("getDernierPointage error: ${e.message}");
      }
    }
    return null;
  }

  // ──────────────────────────────────────────────────────────────
  // 6. Infos utilisateur connecté
  // ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getUser(String token) async {
    try {
      final response = await _dio.get(
        '/user',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      if (kDebugMode) print("getUser error: ${e.message}");
      return null;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // 7. (Bonus) Vérifier la connectivité
  // ──────────────────────────────────────────────────────────────
  Future<bool> checkConnectivity() async {
    try {
      final response = await _dio.get('/health').timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}