import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sim_tchad/core/constants/app_constants.dart';
import 'package:sim_tchad/models/DonneeSpecifique.dart';
import 'package:sim_tchad/models/Enqueteur.dart';
import 'package:sim_tchad/models/PrixMarche.dart';
import 'package:sim_tchad/models/SuiviCampagne.dart';
import 'package:sim_tchad/models/SuiviFlux.dart';
import 'package:sim_tchad/models/prixMagasin.dart';
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
    final response =
        await http.get(Uri.parse("${API_URL}enquete-magasins/check/$numFiche"));
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Future<bool> checkEnquetSuiviExists(String numFiche) async {
  try {
    final response =
        await http.get(Uri.parse("${API_URL}enquete-suivis/check/$numFiche"));
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Future<bool> checkEnquetCampagneExists(String numFiche) async {
  try {
    final response = await http
        .get(Uri.parse("${API_URL}enquete-campagnes/check/$numFiche"));
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

Future<bool> syncFicheSuiviToServer(String numFiche) async {
  final localData = await DatabaseService.getFicheSuiviByNumFiche(numFiche);
  if (localData == null) {
    print("Aucune donnée à synchroniser.");
    return false;
  }

  final ficheExiste = await checkEnquetSuiviExists(localData.numFiche!);
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
        'commune': {
          "idCommune": localData.commune!.idCommune,
        },
      };

      final response = await http.post(
        Uri.parse("${API_URL}enquete-suivis"),
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

Future<bool> syncFicheCampagneToServer(String numFiche) async {
  final localData = await DatabaseService.getFicheCampagneByNumFiche(numFiche);
  if (localData == null) {
    print("Aucune donnée à synchroniser.");
    return false;
  }

  final ficheExiste = await checkEnquetSuiviExists(localData.numFiche!);

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
        'commune': {
          "idCommune": localData.commune!.idCommune,
        },
      };

      final response = await http.post(
        Uri.parse("${API_URL}enquete-campagnes"),
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

Future<bool> syncDataSuiviCampagneByFicheServer(
    Enqueteur enqueteur, String numFiche) async {
  print("Sync en cours... $numFiche");

  try {
    // 1. Récupérer données locales
    final localData = await DatabaseService.getCampagneByNum(numFiche);

    if (localData.isEmpty) {
      print("Aucune donnée à synchroniser.");
      return false;
    }

    // 2. Vérifier si fiche existe
    final ficheExists = await checkEnquetCampagneExists(numFiche);

    if (!ficheExists) {
      final success = await syncFicheCampagneToServer(numFiche);
      if (!success) {
        print("Échec synchro fiche");
        return false;
      }
    }

    // 3. Construire JSON
    final data = localData.map((item) {
      return {
        "superficieHa": item.superficieHa ?? 0,
        "quantiteProduit": item.quantiteProduit ?? 0,
        "variete": item.variete ?? null,
        "dateSemi": item.dateSemi ?? null,
        "commentaire": item.commentaire ?? null,
        "dateAjout": item.dateAjout ?? null,
        "uniteMesure": item.uniteMesure ?? null,
        "produit": {
          "idProduit": item.produit?.idProduit,
          "nomProduit": item.produit?.nomProduit,
        },
        "enqueteur": {
          "idEnqueteur": enqueteur.idEnqueteur,
        },
        "enqueteCampagne": item.enqueteCampagne != null
            ? {"numFiche": item.enqueteCampagne!.numFiche}
            : null,
        "commune": item.commune != null
            ? {"idCommune": item.commune!.idCommune}
            : null,
        "campagne": item.campagne != null
            ? {"idCampagne": item.campagne!.idCampagne}
            : null,
        "bassinProduction": item.bassinProduction != null
            ? {"idBassin": item.bassinProduction!.idBassin}
            : null,
      };
    }).toList();

    print("DATA ENVOYÉE: ${jsonEncode(data)}");

    bool success = false;
    int attempt = 0;

    while (!success && attempt < retry) {
      try {
        attempt++;

        final response = await http.post(
          Uri.parse("${API_URL}suiviCampagnes/batch"),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(data), // ✅ ENVOI DU JSON
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          print("✅ Sync réussie");

          // 🔥 SUPPRESSION DES DONNÉES LOCALES
          for (var item in localData) {
            await DatabaseService.delete(
              "SuiviCampagne",
              "idSuiviCampagne",
              item.idSuiviCampagne,
            );
          }

          // 🔥 SUPPRIMER LA FICHE
          await DatabaseService.delete(
            "EnqueteCampagne", // ✅ corrigé
            "numFiche",
            numFiche,
          );

          success = true;
        } else {
          print("❌ Tentative $attempt échouée: ${response.body}");
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

Future<bool> syncDataSuiviByFicheServer(
    Enqueteur enqueteur, String numFiche) async {
  print("Sync en cours... $numFiche");

  try {
    // 1. Récupérer données locales
    final localData = await DatabaseService.getSuiviByNum(numFiche);

    if (localData.isEmpty) {
      print("Aucune donnée à synchroniser.");
      return false;
    }

    // 2. Vérifier si fiche existe
    final ficheExists = await checkEnquetSuiviExists(numFiche);

    if (!ficheExists) {
      final success = await syncFicheSuiviToServer(numFiche);
      if (!success) {
        print("Échec synchro fiche");
        return false;
      }
    }

    // 3. Construire JSON
    final data = localData.map((item) {
      return {
        "fluxEntrantTonne": item.fluxEntrantTonne ?? 0,
        "fluxSortantTonne": item.fluxSortantTonne ?? 0,
        "disponibilite": item.disponibilite ?? null,
        "difficulte": item.difficulte ?? null,
        "dateCollecte": item.dateCollecte ?? null,
        "observation": item.observation ?? null,
        "dateAjout": item.dateAjout ?? null,
        "uniteMesure": item.uniteMesure ?? null,
        "produit": {
          "idProduit": item.produit?.idProduit,
          "nomProduit": item.produit?.nomProduit,
        },
        "niveau": item.niveau != null
            ? {
                "idNiveauApprovisionnement":
                    item.niveau?.idNiveauApprovisionnement,
              }
            : null,
        "enqueteur": {
          "idEnqueteur": enqueteur.idEnqueteur,
        },
        "commune": item.commune != null
            ? {"idCommune": item.commune!.idCommune}
            : null,
        "enqueteSuivi": item.enqueteSuivi != null
            ? {"numFiche": item.enqueteSuivi!.numFiche}
            : null,
      };
    }).toList();

    print("DATA ENVOYÉE: ${jsonEncode(data)}");

    bool success = false;
    int attempt = 0;

    while (!success && attempt < retry) {
      try {
        attempt++;

        final response = await http.post(
          Uri.parse("${API_URL}suivis/batch"),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(data), // ✅ ENVOI DU JSON
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          print("✅ Sync réussie");

          // 🔥 SUPPRESSION DES DONNÉES LOCALES
          for (var item in localData) {
            await DatabaseService.delete(
              "SuiviFlux",
              "idSuivi",
              item.idSuivi,
            );
          }

          // 🔥 SUPPRIMER LA FICHE
          await DatabaseService.delete(
            "EnqueteSuivi", // ✅ corrigé
            "numFiche",
            numFiche,
          );

          success = true;
        } else {
          print("❌ Tentative $attempt échouée: ${response.body}");
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

Future<bool> syncDonneeSpecifiqueToServer(int idPrixMarche) async {
  final localData =
      await DatabaseService.getDonneesSpecifiquesByPrixMarche(idPrixMarche);
  if (localData.isEmpty) {
    print("Aucune donnée à synchroniser.");
    return false;
  }

  bool success = false;
  int attempt = 0;

  while (!success && attempt < retry) {
    try {
      attempt++;

      final response = await http.post(
        Uri.parse("${API_URL}donnees-specifiques/$idPrixMarche"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            localData.map((e) => e.toJson()).toList()), // ✅ ENVOI DU JSON
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print(
            "Donnees specificique synchronisée avec succès : ${localData.length} données spécifiques envoyées");
        success = true;
        // 🔥 SUPPRESSION DES DONNÉES LOCALES
        for (var item in localData) {
          await DatabaseService.delete(
            "DonneeSpecifique",
            "idDonneeSpecifique",
            item.id,
          );
        }
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
    print(
        "Échec de la synchronisation pour ${localData.length} données spécifiques");
  }

  return success;
}

Future<bool> syncDataMarcheByFicheServer(
  Enqueteur enqueteur,
  String numFiche,
) async {
  print("🚀 Sync en cours... $numFiche");

  try {
    final localData = await DatabaseService.getPrixMarcheByNum(numFiche);

    if (localData.isEmpty) {
      print("❌ Aucune donnée à synchroniser.");
      return false;
    }

    final ficheExists = await checkEnqueteCollecteExists(numFiche);

    if (!ficheExists) {
      final ok = await syncFicheToServer(numFiche);
      if (!ok) return false;
    }

    // =========================
    // 🔥 BUILD PRIX + DONNÉES SPÉCIFIQUES
    // =========================

    final List prixList = [];
    final List<List<Map<String, dynamic>>> donneesList = [];

    for (final item in localData) {
      final donnees = await DatabaseService.getDonneesSpecifiquesByPrixMarche(
        item.idPrixMarche!,
      );

      prixList.add({
        "variete": item.variete,
        "age": item.age,
        "prixUnite1": double.tryParse(item.prixUnite1) ?? 0,
        "prixUnite2": int.tryParse(item.prixUnite2),
        "prixUnite3": int.tryParse(item.prixUnite3 ?? "0"),
        "uniteMesure1": item.uniteMesure1,
        "uniteMesure2": item.uniteMesure2,
        "prixTransport": int.tryParse(item.prixTransport ?? "0"),
        "moyenTransport": item.moyenTransport,
        "fournisseur": item.fournisseur,
        "qualiteProduit": item.qualiteProduit,
        "clientPrincipal": item.clientPrincipal,
        "uniteTransport": item.uniteTransport,
        "etatRoute": item.etatRoute,
        "origineProduit": item.origineProduit,
        "observation": item.observation,
        "dateAjout": item.dateAjout,
        "commercant": item.commercant,
        "produit": {
          "idProduit": item.produit?.idProduit,
          "nomProduit": item.produit?.nomProduit,
        },
        "niveau": item.niveau != null
            ? {
                "idNiveauApprovisionnement":
                    item.niveau?.idNiveauApprovisionnement,
              }
            : null,
        "marche": item.marche != null
            ? {
                "idMarche": item.marche!.idMarche,
                "nomMarche": item.marche!.nomMarche,
                "commune": {
                  "idCommune": item.marche?.commune?.idCommune,
                }
              }
            : null,
        "enqueteur": enqueteur != null ? enqueteur : null,
        "enqueteCollecte": item.enqueteCollecte != null
            ? {"numFiche": item.enqueteCollecte!.numFiche}
            : null,
      });

      donneesList.add(
        donnees
            .map((d) => {
                  "caracteristiqueId": d.caracteristiqueId,
                  "valeur": d.valeur,
                })
            .toList(),
      );
    }

    // =========================
    // 🔥 REQUEST
    // =========================

    bool success = false;
    int attempt = 0;

    while (!success && attempt < retry) {
      try {
        attempt++;

        final request = http.MultipartRequest(
          'POST',
          Uri.parse("${API_URL}prix-marches/batch"),
        );

        request.fields['prixMarche'] = jsonEncode(prixList);
        request.fields['donneesSpecifiques'] = jsonEncode(donneesList);

        for (int i = 0; i < localData.length; i++) {
          final item = localData[i];

          if (item.image != null && File(item.image!).existsSync()) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'images',
                item.image!,
                filename: "img_$i.jpg",
              ),
            );
          }
        }

        final response = await request.send();
        final body = await response.stream.bytesToString();

        if (response.statusCode >= 200 && response.statusCode < 300) {
          print("✅ Sync réussie");

          // =========================
          // 🔥 CLEAN LOCAL DB
          // =========================

          final db = await openDatabaseConnection();
          final batch = db!.batch();

          for (var item in localData) {
            batch.delete(
              "DonneeSpecifique",
              where: "idPrixMarche = ?",
              whereArgs: [item.idPrixMarche],
            );

            batch.delete(
              "PrixMarche",
              where: "idPrixMarche = ?",
              whereArgs: [item.idPrixMarche],
            );
          }

          batch.delete(
            "EnqueteCollecte",
            where: "numFiche = ?",
            whereArgs: [numFiche],
          );

          await batch.commit(noResult: true);

          success = true;
        } else {
          print("❌ Erreur: $body");
        }
      } catch (e) {
        print("❌ Erreur sync: $e");
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
// Future<bool> syncDataMarcheByFicheServer(
//     Enqueteur enqueteur, String numFiche) async {
//   print("Sync en cours... $numFiche");

//   try {
//     // 1. Récupérer données locales
//     final localData = await DatabaseService.getPrixMarcheByNum(numFiche);

//     if (localData.isEmpty) {
//       print("Aucune donnée à synchroniser.");
//       return false;
//     }

//     // 2. Vérifier si fiche existe
//     final ficheExists = await checkEnqueteCollecteExists(numFiche);

//     if (!ficheExists) {
//       final success = await syncFicheToServer(numFiche);
//       if (!success) {
//         print("Échec synchro fiche");
//         return false;
//       }
//     }

//     // 3. Construire JSON
//     final data = localData.map((item) {
//       print("prix ${double.tryParse(item.prixUnite1)}");
//       return {
//         "variete": item.variete ?? null,
//         // "age": int.tryParse(item.age ?? "0"),
//         "prixUnite1": double.tryParse(item.prixUnite1) ?? 0,
//         "prixUnite2": int.tryParse(item.prixUnite2) ?? null,
//         // "prixUnite3": int.tryParse(item.prixUnite3) ?? null,
//         "uniteMesure2": item.uniteMesure2 ?? null,
//         "uniteMesure1": item.uniteMesure1 ?? null,
//         "prixTransport": int.tryParse(item.prixTransport ?? "0"),
//         "moyenTransport": item.moyenTransport ?? null,
//         "fournisseur": item.fournisseur ?? null,
//         "qualiteProduit": item.qualiteProduit ?? null,
//         "clientPrincipal": item.clientPrincipal ?? null,
//         "uniteTransport": item.uniteTransport ?? null,
//         "etatRoute": item.etatRoute ?? null,
//         "origineProduit": item.origineProduit ?? null,
//         "observation": item.observation ?? null,
//         "dateAjout": item.dateAjout ?? null,
//         "commercant": item.commercant ?? null,
//         "produit": {
//           "idProduit": item.produit?.idProduit,
//           "nomProduit": item.produit?.nomProduit,
//         },

//         "niveau": item.niveau != null
//             ? {
//                 "idNiveauApprovisionnement":
//                     item.niveau?.idNiveauApprovisionnement,
//               }
//             : null,
//         "marche": item.marche != null
//             ? {
//                 "idMarche": item.marche!.idMarche,
//                 "nomMarche": item.marche!.nomMarche,
//                 "commune": {
//                   "idCommune": item.marche?.commune != null
//                       ? item.marche?.commune.idCommune
//                       : null
//                 }
//               }
//             : null,
//         "enqueteur": enqueteur != null ? enqueteur : null,
//         "enqueteCollecte": item.enqueteCollecte != null
//             ? {"numFiche": item.enqueteCollecte!.numFiche}
//             : null,
//       };
//     }).toList();

//     bool success = false;
//     int attempt = 0;

//     while (!success && attempt < retry) {
//       try {
//         attempt++;

//         var request = http.MultipartRequest(
//           'POST',
//           Uri.parse("${API_URL}prix-marches/batch"),
//         );

//         // 🔥 JSON
//         request.fields['prixMarche'] = jsonEncode(data);

//         // 🔥 Images
//         for (int i = 0; i < localData.length; i++) {
//           final item = localData[i];

//           if (item.image != null && File(item.image!).existsSync()) {
//             request.files.add(
//               await http.MultipartFile.fromPath(
//                 'images',
//                 item.image!,
//                 filename: "image_$i.jpg",
//               ),
//             );
//           }
//         }

//         request.headers['Content-Type'] = 'multipart/form-data';

//         final response = await request.send();
//         final responseBody = await response.stream.bytesToString();

//         if (response.statusCode >= 200 && response.statusCode < 300) {
//           print("✅ Sync réussie");

//           // 🔥 SUPPRESSION DES DONNÉES LOCALES
//           for (var item in localData) {
//             await DatabaseService.delete(
//               "PrixMarche",
//               "idPrixMarche",
//               item.idPrixMarche,
//             );
//           }

//           // 🔥 SUPPRIMER LA FICHE
//           await DatabaseService.delete(
//             "EnqueteCollecte",
//             "numFiche",
//             numFiche,
//           );

//           success = true;
//         } else {
//           print("❌ Tentative $attempt échouée: $responseBody");
//         }
//       } catch (e) {
//         print("❌ Erreur tentative $attempt: $e");

//         if (attempt < retry) {
//           await Future.delayed(Duration(milliseconds: delay));
//         }
//       }
//     }

//     return success;
//   } catch (e) {
//     print("❌ Erreur générale: $e");
//     return false;
//   }
// }

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
        "magasin": item.magasin != null
            ? {"idMagasin": item.magasin!.idMagasin}
            : null,
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

//update methode
Future<bool> syncDataCampagneUpdateServer() async {
  try {
    final List<SuiviCampagne> localData =
        await DatabaseService.getAllSuiviCampagnes();

    if (localData.isEmpty) {
      print("Aucune donnée à synchroniser.");
      return false;
    }

    List<SuiviCampagne> failedItems = [];

    for (final item in localData) {
      bool success = false;
      int attempt = 0;

      while (!success && attempt < retry) {
        print("item ${item.codeSuiviCampagne}");
        try {
          attempt++;

          final formattedData = {
            "superficieHa": item.superficieHa ?? 0,
            "quantiteProduit": item.quantiteProduit ?? 0,
            "variete": item.variete ?? null,
            "dateSemi": item.dateSemi ?? null,
            "dateModif": item.dateModif ?? null,
            "commentaire": item.commentaire ?? null,
            "dateAjout": item.dateAjout ?? null,
            "uniteMesure": item.uniteMesure ?? null,
            "produit": {
              "idProduit": item.produit?.idProduit,
              "nomProduit": item.produit?.nomProduit,
            },
            "enqueteCampagne": item.enqueteCampagne != null
                ? {"numFiche": item.enqueteCampagne!.numFiche}
                : null,
            "campagne": item.campagne != null
                ? {"idCampagne": item.campagne!.idCampagne}
                : null,
            "commune": item.commune != null
                ? {"idCommune": item.commune!.idCommune}
                : null,
            "bassinProduction": item.bassinProduction != null
                ? {"idBassin": item.bassinProduction!.idBassin}
                : null,
          };

          final response = await http
              .put(
                Uri.parse("${API_URL}suiviCampagnes/${item.codeSuiviCampagne}"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode(formattedData),
              )
              .timeout(const Duration(seconds: 10));

          if (response.statusCode >= 200 && response.statusCode < 300) {
            print("✅ Donnée synchronisée avec succès : $formattedData");

            await DatabaseService.delete(
              "SuiviCampagnes",
              "idSuiviCampagne",
              item.idSuiviCampagne,
            );

            success = true;
          } else {
            print(
                "⚠️ Tentative $attempt/$retry échouée. Réponse : ${response.body}");
          }
        } catch (e) {
          print("❌ Erreur lors de l'envoi (Tentative $attempt/$retry) : $e");

          if (attempt < retry) {
            await Future.delayed(Duration(milliseconds: delay));
          }
        }
      }

      if (!success) {
        failedItems.add(item);
      }
    }

    // 🔥 Gestion des échecs
    if (failedItems.isNotEmpty) {
      print(
          "❌ ${failedItems.length} élément(s) non synchronisé(s). Réessai plus tard.");
    } else {
      // await deleteAllAgentReject();
      print("✅ Toutes les données ont été synchronisées !");
    }

    return failedItems.isEmpty;
  } catch (e) {
    print("❌ Erreur générale de synchronisation : $e");
    return false;
  }
}

Future<bool> syncDataAgentUpdateServer() async {
  try {
    final List<SuiviFlux> localData = await DatabaseService.getAllSuivi();

    if (localData.isEmpty) {
      print("Aucune donnée à synchroniser.");
      return false;
    }

    List<SuiviFlux> failedItems = [];

    for (final item in localData) {
      bool success = false;
      int attempt = 0;

      while (!success && attempt < retry) {
        print("item ${item.codeSuivi}");
        try {
          attempt++;

          final formattedData = {
            "codeSuivi": item.codeSuivi,
            "observation": item.observation ?? null,
            "fluxEntrantTonne": item.fluxEntrantTonne ?? null,
            "fluxSortantTonne": item.fluxSortantTonne ?? null,
            "disponibilite": item.disponibilite ?? null,
            "difficulte": item.difficulte ?? null,
            "dateCollecte": item.dateCollecte ?? null,
            "dateAjout": item.dateAjout ?? null,
            "uniteMesure": item.uniteMesure ?? null,
            "produit": item.produit?.idProduit != null
                ? {
                    "idProduit": item.produit!.idProduit,
                    "nomProduit": item.produit!.nomProduit,
                  }
                : null,
            "niveau": item.niveau?.idNiveauApprovisionnement != null
                ? {
                    "idNiveauApprovisionnement":
                        item.niveau!.idNiveauApprovisionnement,
                  }
                : null,
            "enqueteur": item.enqueteur?.idEnqueteur != null
                ? {"idEnqueteur": item.enqueteur!.idEnqueteur}
                : null,
            "enqueteSuivi": item.enqueteSuivi?.numFiche != null
                ? {"numFiche": item.enqueteSuivi!.numFiche}
                : null,
            "commune": item.commune?.idCommune != null
                ? {"idCommune": item.commune!.idCommune}
                : null,
          };

          final response = await http
              .put(
                Uri.parse("${API_URL}suivis/${item.codeSuivi}"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode(formattedData),
              )
              .timeout(const Duration(seconds: 10));

          if (response.statusCode >= 200 && response.statusCode < 300) {
            print("✅ Donnée synchronisée avec succès : $formattedData");

            await DatabaseService.delete(
              "SuiviFluxs",
              "idSuivi",
              item.idSuivi!,
            );

            success = true;
          } else {
            print(
                "⚠️ Tentative $attempt/$retry échouée. Réponse : ${response.body}");
          }
        } catch (e) {
          print("❌ Erreur lors de l'envoi (Tentative $attempt/$retry) : $e");

          if (attempt < retry) {
            await Future.delayed(Duration(milliseconds: delay));
          }
        }
      }

      if (!success) {
        failedItems.add(item);
      }
    }

    // 🔥 Gestion des échecs
    if (failedItems.isNotEmpty) {
      print(
          "❌ ${failedItems.length} élément(s) non synchronisé(s). Réessai plus tard.");
    } else {
      // await deleteAllAgentReject();
      print("✅ Toutes les données ont été synchronisées !");
    }

    return failedItems.isEmpty;
  } catch (e) {
    print("❌ Erreur générale de synchronisation : $e");
    return false;
  }
}

Future<bool> syncDataUpdateServer() async {
  try {
    final List<PrixMarche> localData =
        await DatabaseService.getAllPrixMarches();

    if (localData.isEmpty) {
      print("Aucune donnée à synchroniser.");
      return false;
    }

    List<PrixMarche> failedItems = [];

    for (final item in localData) {
      bool success = false;
      int attempt = 0;

      while (!success && attempt < retry) {
        try {
          attempt++;

          // 🔥 JSON sécurisé
          final formattedData = {
            "idPrixMarche": item.idPrixMarche,
            "codePrix": item.codePrix,
            "variete": item.variete,
            "age": int.tryParse(item.age ?? "0"),
            "prixUnite1": double.tryParse(item.prixUnite1),
            "prixUnite2": int.tryParse(item.prixUnite2) ?? null,
            // "prixUnite3": int.tryParse(item.prixUnite3 ?? "0"),
            "uniteMesure2": item.uniteMesure2,
            "uniteMesure1": item.uniteMesure1 ?? null,
            "uniteMesure3": item.uniteMesure3 ?? null,
            "prixTransport": int.tryParse(item.prixTransport ?? "0"),
            "moyenTransport": item.moyenTransport,
            "fournisseur": item.fournisseur,
            "clientPrincipal": item.clientPrincipal,
            "uniteTransport": item.uniteTransport,
            "etatRoute": item.etatRoute,
            "origineProduit": item.origineProduit,
            "observation": item.observation,
            "dateAjout": item.dateAjout,
            "commercant": item.commercant ?? null,

            // 🔥 relations (safe null)
            "produit": item.produit?.idProduit != null
                ? {"idProduit": item.produit!.idProduit}
                : null,

            "niveau": item.niveau?.idNiveauApprovisionnement != null
                ? {
                    "idNiveauApprovisionnement":
                        item.niveau!.idNiveauApprovisionnement
                  }
                : null,

            // "marche": item.marche?.idMarche != null
            //     ? {"idMarche": item.marche!.idMarche}
            //     : null,

            // "enqueteur": item.enqueteur?.idEnqueteur != null
            //     ? {"idEnqueteur": item.enqueteur!.idEnqueteur}
            //     : null,

            // "enqueteCollecte":
            //     item.enqueteCollecte?.numFiche != null
            //         ? {"numFiche": item.enqueteCollecte!.numFiche}
            //         : null,
          };

          // 🔥 Multipart request (IMPORTANT : dans la boucle)
          var request = http.MultipartRequest(
            'PUT',
            Uri.parse("${API_URL}prix-marches/${item.codePrix}"),
          );

          // 🔥 JSON
          request.fields['prixMarche'] = jsonEncode(formattedData);

          // 🔥 Image
          if (item.image != null && File(item.image!).existsSync()) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'image',
                item.image!,
                filename: "image_${item.idPrixMarche}.jpg",
              ),
            );
          }

          request.headers['Content-Type'] = 'multipart/form-data';

          final response = await request.send();
          final responseBody = await response.stream.bytesToString();

          if (response.statusCode >= 200 && response.statusCode < 300) {
            print("✅ Donnée synchronisée : $formattedData");

            await DatabaseService.delete(
              "PrixMarches",
              "idPrixMarche",
              item.idPrixMarche!,
            );
            success = true;
          } else {
            print("⚠️ Tentative $attempt/$retry échouée: $responseBody");
          }
        } catch (e) {
          print("❌ Erreur tentative $attempt/$retry : $e");

          if (attempt < retry) {
            await Future.delayed(Duration(milliseconds: delay));
          }
        }
      }

      if (!success) {
        failedItems.add(item);
      }
    }

    // 🔥 Gestion des échecs
    if (failedItems.isNotEmpty) {
      print("❌ ${failedItems.length} élément(s) non synchronisé(s).");
    } else {
      // await deleteAllPrixMarchesReject();
      print("✅ Toutes les données synchronisées !");
    }

    return failedItems.isEmpty;
  } catch (e) {
    print("❌ Erreur générale : $e");
    return false;
  }
}

Future<bool> syncDataMagasinUpdateServer() async {
  try {
    final List<PrixMagasin> localData =
        await DatabaseService.getAllPrixMagasins();

    if (localData.isEmpty) {
      print("Aucune donnée à synchroniser.");
      return false;
    }

    List<PrixMagasin> failedItems = [];

    for (final item in localData) {
      bool success = false;
      int attempt = 0;

      while (!success && attempt < retry) {
        try {
          attempt++;

          // 🔥 JSON sécurisé
          final formattedData = {
            "codePrix": item.codePrix,
            "prixBordChamp": int.tryParse(item.prixBordChamp ?? "0"),
            "stockDisponible": double.tryParse(item.stockDisponible ?? "0"),
            "variete": item.variete,
            "uniteMesure": item.uniteMesure,
            "age": int.tryParse(item.age ?? "0"),
            "prixTransport": int.tryParse(item.prixTransport ?? "0"),
            "uniteTransport": item.uniteTransport,
            "moyenTransport": item.moyenTransport,
            "prixVente": int.tryParse(item.prixVente ?? "0"),
            "observation": item.observation,
            "statut": item.statut,
            "dateAjout": item.dateAjout,

            // 🔥 relations (safe)
            "bassinProduction": item.bassinProduction?.idBassin != null
                ? {"idBassin": item.bassinProduction!.idBassin}
                : null,

            "magasin": item.magasin?.idMagasin != null
                ? {"idMagasin": item.magasin!.idMagasin}
                : null,

            "produit": item.produit?.idProduit != null
                ? {"idProduit": item.produit!.idProduit}
                : null,

            "niveau": item.niveau?.idNiveauApprovisionnement != null
                ? {
                    "idNiveauApprovisionnement":
                        item.niveau!.idNiveauApprovisionnement
                  }
                : null,

            // "enqueteur": item.enqueteur?.idEnqueteur != null
            //     ? {"idEnqueteur": item.enqueteur!.idEnqueteur}
            //     : null,

            // "enqueteMagasin": item.enqueteMagasin?.numFiche != null
            //     ? {"numFiche": item.enqueteMagasin!.numFiche}
            //     : null,
          };

          // 🔥 Multipart request
          var request = http.MultipartRequest(
            'PUT',
            Uri.parse("${API_URL}prix-magasins/${item.codePrix}"),
          );

          // 🔥 JSON
          request.fields['prixMagasin'] = jsonEncode(formattedData);

          // 🔥 Image
          if (item.image != null && File(item.image!).existsSync()) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'image',
                item.image!,
                filename: "image_${item.idPrixMagasin}.jpg",
              ),
            );
          }

          request.headers['Content-Type'] = 'multipart/form-data';

          final response = await request.send();
          final responseBody = await response.stream.bytesToString();

          if (response.statusCode >= 200 && response.statusCode < 300) {
            print("✅ Donnée synchronisée : $formattedData");

            await DatabaseService.delete(
              "PrixMagasins",
              "idPrixMagasin",
              item.idPrixMagasin!,
            );
            success = true;
          } else {
            print("⚠️ Tentative $attempt/$retry échouée: $responseBody");
          }
        } catch (e) {
          print("❌ Erreur tentative $attempt/$retry : $e");

          if (attempt < retry) {
            await Future.delayed(Duration(milliseconds: delay));
          }
        }
      }

      if (!success) {
        failedItems.add(item);
      }
    }

    // 🔥 Gestion des échecs
    if (failedItems.isNotEmpty) {
      print("❌ ${failedItems.length} élément(s) non synchronisé(s).");
    } else {
      // await deleteAllPrixMarchesReject();
      print("✅ Toutes les données synchronisées !");
    }

    return failedItems.isEmpty;
  } catch (e) {
    print("❌ Erreur générale : $e");
    return false;
  }
}
