import 'dart:convert';
import 'package:sim_tchad/models/EnqueteCampagne.dart';
import 'package:sim_tchad/models/EnqueteCollecte.dart';
import 'package:sim_tchad/models/EnqueteMagasin.dart';
import 'package:sim_tchad/models/EnqueteSuivi.dart';
import 'package:sim_tchad/models/PrixMarche.dart';
import 'package:sim_tchad/models/SuiviCampagne.dart';
import 'package:sim_tchad/models/SuiviFlux.dart';
import 'package:sim_tchad/models/prixMagasin.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class DatabaseService {
  /// ==========================
  /// UTILITAIRE : Décodage JSON pour relations
  /// ==========================
  static Map<String, dynamic> decodeRelations(Map<String, dynamic> item,
      [List<String>? relationFields]) {
    final result = Map<String, dynamic>.from(item);

    if (relationFields != null) {
      for (var field in relationFields) {
        if (result[field] != null && result[field] is String) {
          try {
            result[field] = jsonDecode(result[field]);
          } catch (e) {
            print("Erreur decoding $field : $e");
          }
        }
      }
    }

    return result;
  }

  /// ==========================
  /// INSERT
  /// ==========================
  static Future<int?> insert(String table, Map<String, dynamic> data) async {
    final db = await openDatabaseConnection();
    if (db == null) return null;

    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// ==========================
  /// GET ALL
  /// ==========================
  static Future<List<Map<String, dynamic>>> getAll(
    String table, [
    List<String>? relationFields,
  ]) async {
    final db = await openDatabaseConnection();
    if (db == null) return [];

    final rows = await db.query(table);
    return rows.map((row) => decodeRelations(row, relationFields)).toList();
  }

  /// ==========================
  /// GET BY ID
  /// ==========================
  static Future<Map<String, dynamic>?> getById(
    String table,
    String idColumn,
    dynamic id, [
    List<String>? relationFields,
  ]) async {
    final db = await openDatabaseConnection();
    if (db == null) return null;

    final result = await db.query(
      table,
      where: "$idColumn = ?",
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return decodeRelations(result.first, relationFields);
    }
    return null;
  }

  static Future<void> clearAllData() async {
    final db = await openDatabaseConnection();
    if (db == null) return;

    // Liste de toutes les tables à nettoyer
    final tables = [
      'EnqueteCollecte',
      'EnqueteMagasin',
      'EnqueteSuivi',
      'PrixMarche',
      'PrixMarches',
      'PrixMagasins',
      'PrixMagasin',
      'SuiviFlux',
      'SuiviFluxs',
      'Magasin',
      'Marche',
    ];

    for (var table in tables) {
      await db.delete(table);
    }

    print("Toutes les tables locales ont été vidées.");
  }


  /// ==========================
  /// UPDATE
  /// ==========================
  static Future<int?> update(
    String table,
    Map<String, dynamic> data,
    String idColumn,
    dynamic id,
  ) async {
    final db = await openDatabaseConnection();
    if (db == null) return null;

    return await db.update(
      table,
      data,
      where: "$idColumn = ?",
      whereArgs: [id],
    );
  }

  /// ==========================
  /// DELETE
  /// ==========================
  static Future<int?> delete(
    String table,
    String idColumn,
    dynamic id,
  ) async {
    final db = await openDatabaseConnection();
    if (db == null) return null;

    return await db.delete(
      table,
      where: "$idColumn = ?",
      whereArgs: [id],
    );
  }

  /// ==========================
  /// Méthodes pour fiches filtrées
  /// ==========================

  static Future<List<Map<String, dynamic>>> getFicheByReference(
      String reference,
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return [];

    try {
      final rows = await db.rawQuery(
        'SELECT * FROM EnqueteCollecte WHERE reference LIKE ?',
        ['%$reference%'],
      );

      return rows.map((row) => decodeRelations(row, relationFields)).toList();
    } catch (error) {
      print(error);
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getFicheByMagasin(String reference,
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return [];

    try {
      final rows = await db.rawQuery(
        'SELECT * FROM EnqueteMagasin WHERE reference LIKE ?',
        ['%$reference%'],
      );

      return rows.map((row) => decodeRelations(row, relationFields)).toList();
    } catch (error) {
      print(error);
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getFicheBySuivi(String reference,
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return [];

    try {
      final rows = await db.rawQuery(
        'SELECT * FROM EnqueteSuivi WHERE reference LIKE ?',
        ['%$reference%'],
      );

      return rows.map((row) => decodeRelations(row, relationFields)).toList();
    } catch (error) {
      print(error);
      return [];
    }
  }
  
  static Future<List<Map<String, dynamic>>> getFicheByCampagne(String reference,
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return [];

    try {
      final rows = await db.rawQuery(
        'SELECT * FROM EnqueteCampagne WHERE reference LIKE ?',
        ['%$reference%'],
      );

      return rows.map((row) => decodeRelations(row, relationFields)).toList();
    } catch (error) {
      print(error);
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getFicheByMarche(String reference,
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return [];

    try {
      final rows = await db.rawQuery(
        'SELECT * FROM EnqueteCollecte WHERE reference LIKE ?',
        ['%$reference%'],
      );

      return rows.map((row) => decodeRelations(row, relationFields)).toList();
    } catch (error) {
      print(error);
      return [];
    }
  }

  static Future<List<PrixMarche>> getAllPrixMarches(
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return [];

    try {
      final rows = await db.rawQuery('SELECT * FROM PrixMarches');

      return rows
          .map(
              (row) => PrixMarche.fromMap(decodeRelations(row, relationFields)))
          .toList();
    } catch (error) {
      print("Erreur marche $error");
      return [];
    }
  }

  static Future<List<PrixMagasin>> getAllPrixMagasins(
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return [];

    try {
      final rows = await db.rawQuery('SELECT * FROM PrixMagasins');
      print(rows
          .map((row) =>
              PrixMagasin.fromMap(decodeRelations(row, relationFields)))
          .toList());
      return rows
          .map((row) =>
              PrixMagasin.fromMap(decodeRelations(row, relationFields)))
          .toList();
    } catch (error) {
      print("Erreur magasin $error");
      return [];
    }
  }
  
  static Future<List<SuiviCampagne>> getAllSuiviCampagnes(
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return [];

    try {
      final rows = await db.rawQuery('SELECT * FROM SuiviCampagnes');
      print(rows
          .map((row) =>
              SuiviCampagne.fromMap(decodeRelations(row, relationFields)))
          .toList());
      return rows
          .map((row) =>
              SuiviCampagne.fromMap(decodeRelations(row, relationFields)))
          .toList();
    } catch (error) {
      print("Erreur magasin $error");
      return [];
    }
  }

  static Future<List<SuiviFlux>> getAllSuivi(
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return [];

    try {
      final rows = await db.rawQuery('SELECT * FROM SuiviFluxs');

      return rows
          .map((row) => SuiviFlux.fromMap(decodeRelations(row, relationFields)))
          .toList();
    } catch (error) {
      print("Erreur SuiviFlux $error");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getAllFicheMarche(
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return [];

    try {
      final rows = await db.rawQuery('SELECT * FROM EnqueteCollecte');

      return rows.map((row) => decodeRelations(row, relationFields)).toList();
    } catch (error) {
      print("Erreur collecte ${error}");
      return [];
    }
  }
  
  static Future<List<Map<String, dynamic>>> getAllFicheCampagne(
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return [];

    try {
      final rows = await db.rawQuery('SELECT * FROM EnqueteCampagne');

      return rows.map((row) => decodeRelations(row, relationFields)).toList();
    } catch (error) {
      print("Erreur collecte ${error}");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getAllFicheMagasin(
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return [];

    try {
      final rows = await db.rawQuery('SELECT * FROM EnqueteMagasin');

      return rows.map((row) => decodeRelations(row, relationFields)).toList();
    } catch (error) {
      print("Erreur magasin ${error}");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getAllFicheSuivi(
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return [];

    try {
      final rows = await db.rawQuery('SELECT * FROM EnqueteSuivi');

      return rows.map((row) => decodeRelations(row, relationFields)).toList();
    } catch (error) {
      print("Erreur suivi ${error}");
      return [];
    }
  }

  static Future<List<PrixMagasin>>  getPrixMagasinByNum(String numFiche,
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return [];

    try {
      // Récupérer tous les PrixMagasin
      final rows = await db.query('PrixMagasin');

      // Filtrer ceux qui correspondent au numFiche de l'enquete
      final filtered = rows.where((row) {
        if (row['enqueteMagasin'] == null) return false;

        try {
          final dynamic decoded = jsonDecode(row['enqueteMagasin'] as String);
          final Map<String, dynamic> enqueteJson =
              Map<String, dynamic>.from(decoded);
          return enqueteJson['numFiche'] == numFiche;
        } catch (e) {
          print('Erreur décodage JSON enqueteMagasin: $e');
          return false;
        }
      }).toList();

      // Convertir directement en Liste<PrixMagasin>
      final prixList = filtered.map((row) {
        final rowWithRelations = decodeRelations(row, relationFields);
        return PrixMagasin.fromJson(rowWithRelations);
      }).toList();

      return prixList;
    } catch (error) {
      print('Erreur getPrixMagasinByNum: $error');
      return [];
    }
  }

  static Future<List<PrixMarche>> getPrixMarcheByNum(String numFiche,
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return [];

    try {
      // Récupérer tous les PrixMarche
      final rows = await db.query('PrixMarche');

      // Filtrer ceux qui correspondent au numFiche de l'enquete
      final filtered = rows.where((row) {
        if (row['enqueteCollecte'] == null) return false;

        try {
          final dynamic decoded = row['enqueteCollecte'];
          Map<String, dynamic> enqueteJson;

          if (decoded is String) {
            enqueteJson = Map<String, dynamic>.from(jsonDecode(decoded));
          } else if (decoded is Map) {
            enqueteJson = Map<String, dynamic>.from(decoded);
          } else {
            return false;
          }

          return enqueteJson['numFiche'] == numFiche;
        } catch (e) {
          print('Erreur décodage JSON enqueteMarche: $e');
          return false;
        }
      }).toList();

      // Convertir en Liste<PrixMarche>
      final prixList = filtered.map((row) {
        final rowWithRelations = decodeRelations(row, relationFields);
        return PrixMarche.fromMap(rowWithRelations);
      }).toList();

      return prixList;
    } catch (error) {
      print('Erreur getPrixMarcheByNum: $error');
      return [];
    }
  }

  static Future<List<SuiviFlux>> getSuiviByNum(String numFiche,
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return [];

    try {
      final rows = await db.query('SuiviFlux');

      // Filtrer ceux qui correspondent au numFiche de l'enquete
      final filtered = rows.where((row) {
        if (row['enqueteSuivi'] == null) return false;

        try {
          final dynamic decoded = row['enqueteSuivi'];
          Map<String, dynamic> enqueteJson;

          if (decoded is String) {
            enqueteJson = Map<String, dynamic>.from(jsonDecode(decoded));
          } else if (decoded is Map) {
            enqueteJson = Map<String, dynamic>.from(decoded);
          } else {
            return false;
          }

          return enqueteJson['numFiche'] == numFiche;
        } catch (e) {
          print('Erreur décodage JSON enqueteSuivi: $e');
          return false;
        }
      }).toList();

      // Convertir en Liste<PrixMarche>
      final prixList = filtered.map((row) {
        final rowWithRelations = decodeRelations(row, relationFields);
        return SuiviFlux.fromMap(rowWithRelations);
      }).toList();

      return prixList;
    } catch (error) {
      print('Erreur getSuiviByNum: $error');
      return [];
    }
  }

  static Future<List<SuiviCampagne>> getCampagneByNum(String numFiche,
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return [];

    try {
      final rows = await db.query('SuiviCampagne');

      // Filtrer ceux qui correspondent au numFiche de l'enquete
      final filtered = rows.where((row) {
        if (row['enqueteCampagne'] == null) return false;

        try {
          final dynamic decoded = row['enqueteCampagne'];
          Map<String, dynamic> enqueteJson;

          if (decoded is String) {
            enqueteJson = Map<String, dynamic>.from(jsonDecode(decoded));
          } else if (decoded is Map) {
            enqueteJson = Map<String, dynamic>.from(decoded);
          } else {
            return false;
          }

          return enqueteJson['numFiche'] == numFiche;
        } catch (e) {
          print('Erreur décodage JSON enqueteCampagne: $e');
          return false;
        }
      }).toList();

      final prixList = filtered.map((row) {
        final rowWithRelations = decodeRelations(row, relationFields);
        return SuiviCampagne.fromMap(rowWithRelations);
      }).toList();

      return prixList;
    } catch (error) {
      print('Erreur getByNum: $error');
      return [];
    }
  }

  // static Future<List<Map<String, dynamic>>> getFicheBySuivi(String reference,
  //     [List<String>? relationFields]) async {
  //   final db = await openDatabaseConnection();
  //   if (db == null) return [];

  //   try {
  //     final rows = await db.rawQuery(
  //       'SELECT * FROM EnqueteSuivi WHERE reference LIKE ?',
  //       ['%$reference%'],
  //     );

  //     return rows.map((row) => decodeRelations(row, relationFields)).toList();
  //   } catch (error) {
  //     print(error);
  //     return [];
  //   }
  // }

  static Future<List<Map<String, dynamic>>> getFicheBySuiviCampagne(
      String reference,
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return [];

    try {
      final rows = await db.rawQuery(
        'SELECT * FROM EnqueteCampagne WHERE reference LIKE ?',
        ['%$reference%'],
      );

      return rows.map((row) => decodeRelations(row, relationFields)).toList();
    } catch (error) {
      print(error);
      return [];
    }
  }

  /// ==========================
  /// Méthodes GET BY NOM
  /// ==========================
  static Future<Map<String, dynamic>?> getFicheMagasinByNom(String reference,
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return null;

    final result = await db.query(
      "EnqueteMagasin",
      where: "reference = ?",
      whereArgs: [reference],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return decodeRelations(result.first, relationFields);
    }
    return null;
  }

  static Future<EnqueteCollecte?> getFicheByNumFiche(
    String numFiche, [
    List<String>? relationFields,
  ]) async {
    final db = await openDatabaseConnection();
    if (db == null) return null;

    try {
      final result = await db.query(
        "EnqueteCollecte",
        where: "numFiche = ?",
        whereArgs: [numFiche],
        limit: 1,
      );

      if (result.isNotEmpty) {
        Map<String, dynamic> data = result.first;

        // Décoder les relations si nécessaire
        if (relationFields != null && relationFields.isNotEmpty) {
          data = decodeRelations(data, relationFields);
        }

        // 🔥 Conversion en objet
        return EnqueteCollecte.fromJson(data);
      }
    } catch (e) {
      print("Erreur getFicheByNumFiche: $e");
    }

    return null;
  }

  static Future<EnqueteMagasin?> getFicheMagasiByNumFiche(
    String numFiche, [
    List<String>? relationFields,
  ]) async {
    final db = await openDatabaseConnection();
    if (db == null) return null;

    try {
      final result = await db.query(
        "EnqueteMagasin",
        where: "numFiche = ?",
        whereArgs: [numFiche],
        limit: 1,
      );

      if (result.isNotEmpty) {
        Map<String, dynamic> data = result.first;

        // Décoder les relations si nécessaire
        if (relationFields != null && relationFields.isNotEmpty) {
          data = decodeRelations(data, relationFields);
        }

        // 🔥 Conversion en objet
        return EnqueteMagasin.fromJson(data);
      }
    } catch (e) {
      print("Erreur EnqueteMagasin: $e");
    }

    return null;
  }

  static Future<EnqueteSuivi?> getFicheSuiviByNumFiche(
    String numFiche, [
    List<String>? relationFields,
  ]) async {
    final db = await openDatabaseConnection();
    if (db == null) return null;

    try {
      final result = await db.query(
        "EnqueteSuivi",
        where: "numFiche = ?",
        whereArgs: [numFiche],
        limit: 1,
      );

      if (result.isNotEmpty) {
        Map<String, dynamic> data = result.first;

        // Décoder les relations si nécessaire
        if (relationFields != null && relationFields.isNotEmpty) {
          data = decodeRelations(data, relationFields);
        }

        // 🔥 Conversion en objet
        return EnqueteSuivi.fromJson(data);
      }
    } catch (e) {
      print("Erreur EnqueteSuivi: $e");
    }

    return null;
  }

  static Future<EnqueteCampagne?> getFicheCampagneByNumFiche(
    String numFiche, [
    List<String>? relationFields,
  ]) async {
    final db = await openDatabaseConnection();
    if (db == null) return null;

    try {
      final result = await db.query(
        "EnqueteCampagne",
        where: "numFiche = ?",
        whereArgs: [numFiche],
        limit: 1,
      );

      if (result.isNotEmpty) {
        Map<String, dynamic> data = result.first;

        // Décoder les relations si nécessaire
        if (relationFields != null && relationFields.isNotEmpty) {
          data = decodeRelations(data, relationFields);
        }

        // 🔥 Conversion en objet
        return EnqueteCampagne.fromJson(data);
      }
    } catch (e) {
      print("Erreur EnqueteCampagne: $e");
    }

    return null;
  }

  static Future<Map<String, dynamic>?> getFicheCampagneByDateAndCampagne(
      String date, String reference,
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return null;

    // On vérifie si une fiche existe pour CETTE date ET CE magasin précis
    final result = await db.query(
      "EnqueteCampagne",
      where: "dateEnquete = ? AND reference = ?",
      whereArgs: [date, reference],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return decodeRelations(result.first, relationFields);
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getFicheMagasinByDateAndMagasin(
      String date, String reference,
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return null;

    // On vérifie si une fiche existe pour CETTE date ET CE magasin précis
    final result = await db.query(
      "EnqueteMagasin",
      where: "dateEnquete = ? AND reference = ?",
      whereArgs: [date, reference],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return decodeRelations(result.first, relationFields);
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getFicheSuiviByDateAndSuivi(
      String date, String reference,
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return null;

    // On vérifie si une fiche existe pour CETTE date ET CE magasin précis
    final result = await db.query(
      "EnqueteSuivi",
      where: "dateEnquete = ? AND reference = ?",
      whereArgs: [date, reference],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return decodeRelations(result.first, relationFields);
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getFicheMarcheByDateAndMarche(
      String date, String reference,
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return null;

    // On vérifie si une fiche existe pour CETTE date ET CE magasin précis
    final result = await db.query(
      "EnqueteCollecte",
      where: "dateEnquete = ? AND reference = ?",
      whereArgs: [date, reference],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return decodeRelations(result.first, relationFields);
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getFicheCampagneByDate(String date,
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return null;

    final result = await db.query(
      "EnqueteCampagne",
      where: "dateEnquete = ?",
      whereArgs: [date],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return decodeRelations(result.first, relationFields);
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getFicheMagasinByDate(String date,
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return null;

    final result = await db.query(
      "EnqueteMagasin",
      where: "dateEnquete = ?",
      whereArgs: [date],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return decodeRelations(result.first, relationFields);
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getFicheMarcheByDate(String date,
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return null;

    final result = await db.query(
      "EnqueteCollecte",
      where: "dateEnquete = ?",
      whereArgs: [date],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return decodeRelations(result.first, relationFields);
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getFicheMarcheByNom(String reference,
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return null;

    final result = await db.query(
      "EnqueteCollecte",
      where: "reference = ?",
      whereArgs: [reference],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return decodeRelations(result.first, relationFields);
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getFicheSuiviByNom(String reference,
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return null;

    final result = await db.query(
      "EnqueteSuivi",
      where: "reference = ?",
      whereArgs: [reference],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return decodeRelations(result.first, relationFields);
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getFicheCampagneByNom(String reference,
      [List<String>? relationFields]) async {
    final db = await openDatabaseConnection();
    if (db == null) return null;

    final result = await db.query(
      "EnqueteCampagne",
      where: "reference = ?",
      whereArgs: [reference],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return decodeRelations(result.first, relationFields);
    }
    return null;
  }
}
