import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sim_tchad/core/constants/app_constants.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

const String API_URL = AppConstants.baseUrl;

/// ==========================
/// Gestion erreurs
/// ==========================
void handleError(Object error, String resource) {

  if (error is SocketException) {

    print("Pas de connexion internet pour $resource");

  } else {

    print("Erreur lors de la récupération de $resource : $error");

  }

}

/// ==========================
/// Fetch + Insert optimisé
/// ==========================
// Future<void> fetchDataResource(
//     String endpoint,
//     String table,
//     String resource,
//     ) async {

//   try {

//     final response = await http.get(Uri.parse('$API_URL$endpoint'));

//     if (response.statusCode == 200) {

//       final List<dynamic> data = jsonDecode(response.body);

//       final db = await openDatabaseConnection();

//       if (db == null) return;

//       await db.transaction((txn) async {

//         final batch = txn.batch();

//         for (var item in data) {

//           batch.insert(
//             table,
//             Map<String, dynamic>.from(item),
//             conflictAlgorithm: ConflictAlgorithm.replace,
//           );

//         }

//         await batch.commit(noResult: true);

//       });

//       print("$resource synchronisé (${data.length})");

//     } else {

//       print("Erreur serveur $resource : ${response.statusCode}");

//     }

//   } catch (error) {

//     handleError(error, resource);

//   }

Future<void> fetchDataResource(
    String endpoint,
    String table,
    String resource,
    List<String> allowedColumns, // colonnes qu'on veut vraiment stocker
    ) async {

  try {
    final response = await http.get(Uri.parse('$API_URL$endpoint'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> data = jsonDecode(response.body);
      final db = await openDatabaseConnection();
      if (db == null) return;

      await db.transaction((txn) async {
        final batch = txn.batch();

        for (var item in data) {
          // Filtrer et préparer uniquement les champs autorisés
          Map<String, dynamic> filteredItem = {};
          item.forEach((key, value) {
            if (allowedColumns.contains(key)) {
              // On ignore les booléens et on convertit seulement Map/List en String
              if (value is Map || value is List) {
                filteredItem[key] = jsonEncode(value);
              } else if (value is num || value is String || value == null) {
                filteredItem[key] = value;
              }
              // Tout autre type (ex: bool) est ignoré
            }
          });

          batch.insert(
            table,
            filteredItem,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        await batch.commit(noResult: true);
      });

      print("$resource synchronisé (${data.length})");

    } else {
      print("Erreur serveur $resource : ${response.statusCode}");
    }

  } catch (error) {
    handleError(error, resource);
  }
}


