import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sim_tchad/core/constants/app_constants.dart';
import 'package:sim_tchad/models/Enqueteur.dart';
import 'package:sim_tchad/utils/database_service.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import 'package:sim_tchad/core/constants/app_constants.dart';

const String API_URL = AppConstants.baseUrl;
int retry = AppConstants.MAX_RETRIES;
int delay = AppConstants.RETRY_DELAY;

Future<bool> checkEnqueteCollecteExists(String numFiche) async {
  try {
    final response = await http
        .get(Uri.parse("${API_URL}enquete-collectes/check/$numFiche"));
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Future<bool> checkEnquetMagasinExists(String numFiche) async {
  try {
    final response = await http
        .get(Uri.parse("${API_URL}enquete-magasins/check/$numFiche"));
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Future<bool> checkEnquetSuiviExists(String numFiche) async {
  try {
    final response = await http
        .get(Uri.parse("${API_URL}enquete-Suivi/check/$numFiche"));
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

// --- SYNCHRONISATION D'UNE FICHE ---
Future<bool> syncFicheToServer(String numFiche) async {
  final localData = await DatabaseService.getFicheByNumFiche(numFiche);
  if (localData == null) {
    print("Aucune donnée à synchroniser.");
    return false;
  }

  final ficheExiste = await checkEnqueteCollecteExists(localData.numFiche!);
  if (ficheExiste) {
    print("La fiche ${localData.numFiche} existe déjà sur le serveur.");
    return true;
  }

  bool success = false;
  int attempt = 0;

  while (!success && attempt < retry) {
    try {
      attempt++;

      final formattedData = {
        'numFiche': localData.numFiche,
        'dateEnquete': localData.dateEnquete,
        "enqueteur": {"idEnqueteur": localData.enqueteur.idEnqueteur},
        "marche": {"idMarche": localData.marche!.idMarche!},
        'commune': {
          "idCommune": localData.commune!.idCommune,
        },
      };

      final response = await http.post(
        Uri.parse("${API_URL}enquete-collectes"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(formattedData),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print("Fiche synchronisée avec succès : ${localData.numFiche}");
        success = true;
      } else {
        print("Tentative $attempt/$retry échouée. Réponse : ${response.body}");
      }
    } catch (e) {
      print("Erreur lors de l'envoi (Tentative $attempt/$retry) : $e");
      if (attempt < retry) {
        await Future.delayed(Duration(milliseconds: delay));
      }
    }
  }

  if (!success) {
    print("Échec de la synchronisation pour ${localData.numFiche}");
  }

  return success;
}

Future<bool> syncFicheMagasinToServer(String numFiche) async {
  final localData = await DatabaseService.getFicheMagasiByNumFiche(numFiche);
  if (localData == null) {
    print("Aucune donnée à synchroniser.");
    return false;
  }

  final ficheExiste = await checkEnqueteCollecteExists(localData.numFiche!);
  if (ficheExiste) {
    print("La fiche ${localData.numFiche} existe déjà sur le serveur.");
    return true;
  }

  bool success = false;
  int attempt = 0;

  while (!success && attempt < retry) {
    try {
      attempt++;

      final formattedData = {
        'numFiche': localData.numFiche,
        'dateEnquete': localData.dateEnquete,
        "enqueteur": {"idEnqueteur": localData.enqueteur!.idEnqueteur},
        "magasin": {"idMagasin": localData.magasin!.idMagasin!},
        'commune': {
          "idCommune": localData.commune!.idCommune,
        },
      };

      final response = await http.post(
        Uri.parse("${API_URL}enquete-magasins"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(formattedData),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print("Fiche magasin synchronisée avec succès : ${localData.numFiche}");
        success = true;
      } else {
        print("Tentative $attempt/$retry échouée. Réponse : ${response.body}");
      }
    } catch (e) {
      print("Erreur lors de l'envoi (Tentative $attempt/$retry) : $e");
      if (attempt < retry) {
        await Future.delayed(Duration(milliseconds: delay));
      }
    }
  }

  if (!success) {
    print("Échec de la synchronisation pour ${localData.numFiche}");
  }

  return success;
}

Future<bool> syncDataMarcheByFicheServer(
    Enqueteur enqueteur, String numFiche) async {
  print("Sync en cours... $numFiche");

  try {
    // 1. Récupérer données locales
    final localData = await DatabaseService.getPrixMarcheByNum(numFiche);

    if (localData.isEmpty) {
      print("Aucune donnée à synchroniser.");
      return false;
    }

    // 2. Vérifier si fiche existe
    final ficheExists = await checkEnqueteCollecteExists(numFiche);

    if (!ficheExists) {
      final success = await syncFicheToServer(numFiche);
      if (!success) {
        print("Échec synchro fiche");
        return false;
      }
    }

    // 3. Construire JSON
    final data = localData.map((item) {
      print("data ${item.toJson()}");
      return {
        "variete": item.variete ?? null,
        "age": int.tryParse(item.age ?? "0"),
        "prixUnite1": int.tryParse(item.prixUnite1 ?? "0"),
        "prixUnite2": int.tryParse(item.prixUnite2 ?? "0"),
        "prixUnite3": int.tryParse(item.prixUnite3 ?? "0"),
        "uniteMesure2": item.uniteMesure2 ?? null,
        "uniteMesure3": item.uniteMesure3 ?? null,
        "prixTransport": int.tryParse(item.prixTransport ?? "0"),
        "moyenTransport": item.moyenTransport ?? null,
        "fournisseur": item.fournisseur ?? null,
        "qualiteProduit": item.qualiteProduit ?? null,
        "clientPrincipal": item.clientPrincipal ?? null,
        "uniteTransport": item.uniteTransport ?? null,
        "etatRoute": item.etatRoute ?? null,
        "origineProduit": item.origineProduit ?? null,
        "observation": item.observation ?? null,
        "dateAjout": item.dateAjout ?? null,
        "produit": {
          "idProduit": item.produit?.idProduit,
          "nomProduit": item.produit?.nomProduit,
        },
        "acteur": item.acteur != null
            ? {
                "idActeur": item.acteur?.idActeur,
              }
            : null,
        "niveau": item.niveau != null
            ? {
                "idNiveauApprovisionnement":
                    item.niveau?.idNiveauApprovisionnement,
              }
            : null,
        "marche":
            item.marche != null ? {"idMarche": item.marche!.idMarche} : null,
        "enqueteur":
            enqueteur != null ? {"idEnqueteur": enqueteur.idEnqueteur} : null,
        "enqueteCollecte": item.enqueteCollecte != null
            ? {"numFiche": item.enqueteCollecte!.numFiche}
            : null,
      };
    }).toList();

    bool success = false;
    int attempt = 0;

    while (!success && attempt < retry) {
      try {
        attempt++;

        var request = http.MultipartRequest(
          'POST',
          Uri.parse("${API_URL}prix-marches/batch"),
        );

        // 🔥 JSON
        request.fields['prixMarche'] = jsonEncode(data);

        // 🔥 Images
        for (int i = 0; i < localData.length; i++) {
          final item = localData[i];

          if (item.image != null && File(item.image!).existsSync()) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'images',
                item.image!,
                filename: "image_$i.jpg",
              ),
            );
          }
        }

        request.headers['Content-Type'] = 'multipart/form-data';

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode >= 200 && response.statusCode < 300) {
          print("✅ Sync réussie");

          // 🔥 SUPPRESSION DES DONNÉES LOCALES
          for (var item in localData) {
            await DatabaseService.delete(
              "PrixMarche",
              "idPrixMarche",
              item.idPrixMarche,
            );
          }

          // 🔥 SUPPRIMER LA FICHE
          await DatabaseService.delete(
            "EnqueteCollecte",
            "numFiche",
            numFiche,
          );

          success = true;
        } else {
          print("❌ Tentative $attempt échouée: $responseBody");
        }
      } catch (e) {
        print("❌ Erreur tentative $attempt: $e");

        if (attempt < retry) {
          await Future.delayed(Duration(milliseconds: delay));
        }
      }
    }

    return success;
  } catch (e) {
    print("❌ Erreur générale: $e");
    return false;
  }
}

Future<bool> syncDataMagasinByFicheServer(
    Enqueteur enqueteur, String numFiche) async {
  print("Sync en cours... $numFiche");

  try {
    // 1. Récupérer données locales
    final localData = await DatabaseService.getPrixMagasinByNum(numFiche);

    if (localData.isEmpty) {
      print("Aucune donnée à synchroniser.");
      return false;
    }

    // 2. Vérifier si fiche existe
    final ficheExists = await checkEnquetMagasinExists(numFiche);

    if (!ficheExists) {
      final success = await syncFicheMagasinToServer(numFiche);
      if (!success) {
        print("Échec synchro fiche");
        return false;
      }
    }

    // 3. Construire JSON
    final data = localData.map((item) {
      print("data ${item.toJson()}");
      return {
        "variete": item.variete ?? null,
        "age": int.tryParse(item.age ?? "0"),
        "prixBordChamp": int.tryParse(item.prixBordChamp ?? "0"),
        "stockDisponible": int.tryParse(item.stockDisponible ?? "0"),
        "uniteMesure": item.uniteMesure ?? null,
        "prixTransport": int.tryParse(item.prixTransport ?? "0"),
        "prixVente": int.tryParse(item.prixVente ?? "0"),
        "moyenTransport": item.moyenTransport ?? null,
        "uniteTransport": item.uniteTransport ?? null,
        "qualiteProduit": item.qualiteProduit ?? null,
        "observation": item.observation ?? null,
        "dateAjout": item.dateAjout ?? null,
        "produit": {
          "idProduit": item.produit?.idProduit,
          "nomProduit": item.produit?.nomProduit,
        },
        "bassinProduction": item.bassinProduction != null
            ? {
                "idBassin": item.bassinProduction?.idBassin,
              }
            : null,
        "niveau": item.niveau != null
            ? {
                "idNiveauApprovisionnement":
                    item.niveau?.idNiveauApprovisionnement,
              }
            : null,
        "magasin":
            item.magasin != null ? {"idMagasin": item.magasin!.idMagasin} : null,
        "enqueteur":
            enqueteur != null ? {"idEnqueteur": enqueteur.idEnqueteur} : null,
        "enqueteMagasin": item.enqueteMagasin != null
            ? {"numFiche": item.enqueteMagasin!.numFiche}
            : null,
      };
    }).toList();

    bool success = false;
    int attempt = 0;

    while (!success && attempt < retry) {
      try {
        attempt++;

        var request = http.MultipartRequest(
          'POST',
          Uri.parse("${API_URL}prix-magasins/batch"),
        );

        // 🔥 JSON
        request.fields['prixMagasin'] = jsonEncode(data);

        // 🔥 Images
        for (int i = 0; i < localData.length; i++) {
          final item = localData[i];

          if (item.image != null && File(item.image!).existsSync()) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'images',
                item.image!,
                filename: "image_$i.jpg",
              ),
            );
          }
        }

        request.headers['Content-Type'] = 'multipart/form-data';

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode >= 200 && response.statusCode < 300) {
          print("✅ Sync réussie");

          // 🔥 SUPPRESSION DES DONNÉES LOCALES
          for (var item in localData) {
            await DatabaseService.delete(
              "PrixMagasin",
              "idPrixMagasin",
              item.idPrixMagasin,
            );
          }

          // 🔥 SUPPRIMER LA FICHE
          await DatabaseService.delete(
            "EnqueteMagasin",
            "numFiche",
            numFiche,
          );

          success = true;
        } else {
          print("❌ Tentative $attempt échouée: $responseBody");
        }
      } catch (e) {
        print("❌ Erreur tentative $attempt: $e");

        if (attempt < retry) {
          await Future.delayed(Duration(milliseconds: delay));
        }
      }
    }

    return success;
  } catch (e) {
    print("❌ Erreur générale: $e");
    return false;
  }
}
