import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sim_tchad/utils/database_service.dart';

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
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed("/home");
        }
        return;
      }

      // Login online
      bool onlineLogin = await login(code, password);
      print("Online login result: $onlineLogin");

      if (onlineLogin) {
        print("Connexion en ligne OK");
        if (context.mounted) {
  Navigator.of(context).pushReplacementNamed("/home");
}
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

 static Future<bool> login(String codeEnqueteur, String password) async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}enqueteurs/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "codeEnqueteur": codeEnqueteur,
          "password": password
        }),
      );

      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();

        // 🔹 Token
        await prefs.setString("authToken", jsonEncode(data));

        // 🔥 IMPORTANT : sauvegarde login local
        await prefs.setString("userLogin", jsonEncode({
          "codeEnqueteur": codeEnqueteur,
          "password": password
        }));

        return true;
      }

      return false;
    } catch (e) {
      print("Erreur réseau: $e");
      return false;
    }
  }

  /// 🔹 LOGIN OFFLINE
  static Future<bool> checkLocalLogin(String code, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final storedLogin = prefs.getString("userLogin");

    if (storedLogin != null) {
      final data = jsonDecode(storedLogin);

      return data["codeEnqueteur"] == code &&
             data["password"] == password;
    }

    return false;
  }

  /// 🔹 récupérer user connecté
  static Future<Map<String, dynamic>?> getLocalUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString("authToken");

    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return null;
  }

  /// 🔹 Vérifier première connexion
  static Future<bool> isFirstLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return !prefs.containsKey("userLogin");
  }

  

  /// Déconnexion
  static Future<void> logout(BuildContext context) async {
    // 1️⃣ Supprimer le token et info utilisateur
  final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // 2️⃣ Supprimer toutes les données SQLite
    await DatabaseService.clearAllData();

    // 3️⃣ Naviguer vers la page login
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, "/login");

    print("User fully logged out and local data cleared");
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
