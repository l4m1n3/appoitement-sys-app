import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiService {
  // Dio instance
  late final Dio _dio;

  // Base URL (configurable)
  static const String _baseUrl =
      "https://10.0.2.2:8000/api"; // Émulateur Android
  // Pour iOS Simulator : "http://localhost:8000/api"
  // Pour appareil réel : "http://192.168.x.x:8000/api"

  // Constructeur
  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 12),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        // Réponse JSON automatique
        responseType: ResponseType.json,
      ),
    );

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
      data: {"email": email, "password": password},
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
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // POINTAGE VIA PORTIQUE BLUETOOTH (NOUVELLE API)
  // ──────────────────────────────────────────────────────────────
  Future<Response> pointerPortique({
    required String token,
    required String type, // "entrée" ou "sortie"
    required String macAddress, // ex: "AA:BB:CC:11:22:33"
  }) async {
    return await _dio.post(
      '/pointages/bluetooth', // Nouvelle route
      data: {
        'type': type.toLowerCase(), // "entrée" ou "sortie"
        'portique_mac': macAddress.toUpperCase(), // Format MAC standard
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        validateStatus: (status) => status! < 500, // Gérer les erreurs 4xx
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
        '/pointages/employe/$employeId/dernier',
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
      final response = await _dio
          .get('/health')
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
