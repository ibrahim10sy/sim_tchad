import 'dart:convert';

import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import 'api_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Authentication service
class AuthService {
  final ApiService apiService;

  AuthService({required this.apiService});

  static String baseUrl = AppConstants.baseUrl;

  /// Méthode principale de login
  static Future<void> loginUser(BuildContext context, String code, String password) async {
    print("loginUser called >>>");

    try {
      // Vérifier login local
      bool localLogin = await checkLocalLogin(code, password);
      print("Local login result: $localLogin");

      if (localLogin) {
        print("Connexion locale OK");
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, "/home");
        return;
      }

      // Login online
      bool onlineLogin = await login(code, password);
      print("Online login result: $onlineLogin");

      if (onlineLogin) {
        print("Connexion en ligne OK");
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, "/home");
      }
    } catch (e) {
      print("Erreur login: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Échec de connexion. Vérifiez vos identifiants.")),
      );
    }
  }

static Future<bool> resetPassword(String codeEnqueteur, String newPassword) async {
  try {
    // Utilisation de query parameters comme dans ton code React
    final response = await http.put(
      Uri.parse("${baseUrl}enqueteurs/$codeEnqueteur/password?password=$newPassword"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      
      // Mettre à jour les identifiants locaux pour le prochain login offline
      await prefs.setString(
        "userLogin",
        jsonEncode({"codeEnqueteur": codeEnqueteur, "password": newPassword}),
      );
      
      // Marquer localement que c'est fait
      await prefs.setBool("firstLoginDone", true);
      return true;
    }
    return false;
  } catch (e) {
    print("Erreur resetPassword: $e");
    return false;
  }
}

  /// Login en ligne et stockage du token uniquement
  static Future<bool> login(String codeEnqueteur, String password) async {
  final response = await http.post(
    Uri.parse("${baseUrl}enqueteurs/login"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"codeEnqueteur": codeEnqueteur, "password": password}),
  );

  print('login response: ${response.statusCode} - ${response.body}');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    final prefs = await SharedPreferences.getInstance();

    // 🔹 Stocker le token si disponible (ici pas de token, donc stocker idEnqueteur)
    await prefs.setString("authToken", jsonEncode(data)); // On garde toutes les infos utilisateur

    // 🔹 Stockage pour login offline (optionnel)
    await prefs.setString(
      "userLogin",
      jsonEncode({"codeEnqueteur": codeEnqueteur, "password": password}),
    );

    print("Utilisateur connecté stocké localement");
    return true;
  } else {
    throw Exception("Identifiants incorrects");
  }
}
/// Récupère l'utilisateur connecté en local
static Future<Map<String, dynamic>?> getLocalUser() async {
  final prefs = await SharedPreferences.getInstance();
  final userJson = prefs.getString("authToken"); // 🔹 stocké lors du login

  if (userJson != null) {
    return jsonDecode(userJson);
  }
  return null;
}
  /// Vérifier login local
  static Future<bool> checkLocalLogin(String codeEnqueteur, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final storedLogin = prefs.getString("userLogin");

    if (storedLogin != null) {
      final data = jsonDecode(storedLogin);

      if (data["codeEnqueteur"] == codeEnqueteur &&
          data["password"] == password) {
        print("Local login valid");
        return true;
      }
    }

    print("Local login invalid");
    return false;
  }

  /// Vérifier si c'est la première connexion
  static Future<bool> isFirstLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("authToken") == null;
  }

  /// Déconnexion
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("authToken");
    await prefs.remove("userLogin");
    print("User logged out");
  }

  // static Future<bool> isFirstLogin() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString("authToken") == null;
  // }

  // Future<void> logout() async {
  //   // Implement logout logic
  //   await Future.delayed(const Duration(milliseconds: 500));
  // }
}
