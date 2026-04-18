import 'dart:convert';

import 'package:sim_tchad/models/Acteur.dart';
import 'package:sim_tchad/models/EnqueteCollecte.dart';
import 'package:sim_tchad/models/Enqueteur.dart';
import 'package:sim_tchad/models/Marche.dart';
import 'package:sim_tchad/models/NiveauApprovisionnement.dart';
import 'package:sim_tchad/models/Produit.dart';

class PrixMarche {
  int? idPrixMarche;
  String? codePrix;
  String? variete;
  String? age;
  String prixUnite1;
  String prixUnite2;
  String? prixUnite3;
  String? uniteMesure2;
  String? uniteMesure3;
  String? prixTransport;
  String? moyenTransport;
  String? image;
  String fournisseur;
  String? qualiteProduit;
  String clientPrincipal;
  String? uniteTransport;
  String? etatRoute;
  String? origineProduit;
  String observation;
  String? statut;
  String? dateAjout;
  String? dateModif;
  String? latitude;
  String? longitude;
  String? commercant;

  Produit? produit;
  NiveauApprovisionnement? niveau;
  Marche? marche;
  Enqueteur? enqueteur;
  EnqueteCollecte? enqueteCollecte;

  PrixMarche({
    this.idPrixMarche,
    this.codePrix,
    required this.variete,
    this.age,
    required this.prixUnite1,
    required this.prixUnite2,
    this.prixUnite3,
    this.uniteMesure2,
    this.uniteMesure3,
    required this.prixTransport,
    this.moyenTransport,
    this.image,
    required this.fournisseur,
    this.qualiteProduit,
    required this.clientPrincipal,
    this.uniteTransport,
    this.etatRoute,
    this.origineProduit,
    required this.observation,
    this.statut,
    this.dateAjout,
    this.dateModif,
    this.latitude,
    this.longitude,
    this.produit,
    this.niveau,
    this.marche,
    this.commercant,
    this.enqueteur,
    this.enqueteCollecte,
  });

  /// Convertir vers Map pour SQLite (relations encodées en String JSON)
  Map<String, dynamic> toMap() {
    return {
      'idPrixMarche': idPrixMarche,
      'codePrix': codePrix,
      'variete': variete,
      'age': age,
      'prixUnite1': prixUnite1,
      'prixUnite2': prixUnite2,
      'prixUnite3': prixUnite3,
      'uniteMesure2': uniteMesure2,
      'uniteMesure3': uniteMesure3,
      'prixTransport': prixTransport,
      'moyenTransport': moyenTransport,
      'image': image,
      'fournisseur': fournisseur,
      'qualiteProduit': qualiteProduit,
      'clientPrincipal': clientPrincipal,
      'uniteTransport': uniteTransport,
      'etatRoute': etatRoute,
      'origineProduit': origineProduit,
      'observation': observation,
      'statut': statut,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'latitude': latitude,
      'longitude': longitude,
      'commercant': commercant,
      'produit': produit != null ? jsonEncode(produit!.toJson()) : null,
      'niveau': niveau != null ? jsonEncode(niveau!.toJson()) : null,
      'marche': marche != null ? jsonEncode(marche!.toJson()) : null,
      'enqueteur': enqueteur != null ? jsonEncode(enqueteur!.toJson()) : null,
      'enqueteCollecte': enqueteCollecte != null
          ? jsonEncode(enqueteCollecte!.toJson())
          : null,
    };
  }

  factory PrixMarche.fromJson(Map<String, dynamic> json) {
    return PrixMarche(
      idPrixMarche: json['idPrixMarche'],
      codePrix: json['codePrix'],
      variete: json['variete'],
      age: json['age'],
      prixUnite1: json['prixUnite1'] ?? "",
      prixUnite2: json['prixUnite2'] ?? "",
      prixUnite3: json['prixUnite3'],
      uniteMesure2: json['uniteMesure2'],
      uniteMesure3: json['uniteMesure3'],
      prixTransport: json['prixTransport'],
      moyenTransport: json['moyenTransport'],
      image: json['image'],
      fournisseur: json['fournisseur'] ?? "",
      qualiteProduit: json['qualiteProduit'],
      clientPrincipal: json['clientPrincipal'] ?? "",
      uniteTransport: json['uniteTransport'],
      etatRoute: json['etatRoute'],
      origineProduit: json['origineProduit'],
      observation: json['observation'] ?? "",
      statut: json['statut'],
      dateAjout: json['dateAjout'],
      dateModif: json['dateModif'],
      latitude: json['latitude'],
      longitude: json['longitude'],

      // Relations (objet JSON → objet Dart)
      produit:
          json['produit'] != null ? Produit.fromJson(json['produit']) : null,
      niveau: json['niveau'] != null
          ? NiveauApprovisionnement.fromJson(json['niveau'])
          : null,
      marche: json['marche'] != null ? Marche.fromJson(json['marche']) : null,
      commercant: json['commercant'] != null ? json['commercant'] : null,
      enqueteur: json['enqueteur'] != null
          ? Enqueteur.fromJson(json['enqueteur'])
          : null,
      enqueteCollecte: json['enqueteCollecte'] != null
          ? EnqueteCollecte.fromJson(jsonDecode(json['enqueteCollecte']))
          : null,
    );
  }

  /// Construire depuis SQLite (String JSON reconverti en objets)
  factory PrixMarche.fromMap(Map<String, dynamic> map) {
    return PrixMarche(
      idPrixMarche: map['idPrixMarche'],
      codePrix: map['codePrix'],
      variete: map['variete'],
      age: map['age'],
      prixUnite1: map['prixUnite1'],
      prixUnite2: map['prixUnite2'],
      prixUnite3: map['prixUnite3'],
      uniteMesure2: map['uniteMesure2'],
      uniteMesure3: map['uniteMesure3'],
      prixTransport: map['prixTransport'],
      moyenTransport: map['moyenTransport'],
      image: map['image'],
      fournisseur: map['fournisseur'],
      qualiteProduit: map['qualiteProduit'],
      clientPrincipal: map['clientPrincipal'],
      uniteTransport: map['uniteTransport'],
      etatRoute: map['etatRoute'],
      origineProduit: map['origineProduit'],
      observation: map['observation'],
      statut: map['statut'],
      dateAjout: map['dateAjout'],
      dateModif: map['dateModif'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      produit: map['produit'] != null
          ? Produit.fromJson(jsonDecode(map['produit']))
          : null,
      niveau: map['niveau'] != null
          ? NiveauApprovisionnement.fromJson(jsonDecode(map['niveau']))
          : null,
      marche: map['marche'] != null
          ? Marche.fromJson(jsonDecode(map['marche']))
          : null,
      commercant: map['commercant'] != null ? map['commercant'] : null,
      enqueteur: map['enqueteur'] != null
          ? Enqueteur.fromJson(jsonDecode(map['enqueteur']))
          : null,
      enqueteCollecte: map['enqueteCollecte'] != null
          ? EnqueteCollecte.fromJson(jsonDecode(map['enqueteCollecte']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'variete': variete,
      'prixUnite1': prixUnite1,
      'prixUnite2': prixUnite2,
      // 'prixUnite3': prixUnite3,
      'uniteMesure2': uniteMesure2,
      'uniteMesure3': uniteMesure3,
      'prixTransport': prixTransport,
      'moyenTransport': moyenTransport,
      'image': image,
      'fournisseur': fournisseur,
      'qualiteProduit': qualiteProduit,
      'clientPrincipal': clientPrincipal,
      'uniteTransport': uniteTransport,
      'commercant': commercant,
      'etatRoute': etatRoute,
      'origineProduit': origineProduit,
      'observation': observation,
      'dateAjout': dateAjout,
      // Relations encodées en JSON String
      'produit': produit != null ? jsonEncode(produit!.toJson()) : null,
      'niveau': niveau != null ? jsonEncode(niveau!.toJson()) : null,
      'marche': marche != null ? jsonEncode(marche!.toJson()) : null,
      'enqueteCollecte': enqueteCollecte != null
          ? jsonEncode(enqueteCollecte!.toJson())
          : null,
    };
  }
}
