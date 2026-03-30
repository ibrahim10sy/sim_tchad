import 'dart:convert';

import 'package:sim_tchad/models/BassinProduction.dart';
import 'package:sim_tchad/models/EnqueteMagasin.dart';
import 'package:sim_tchad/models/Enqueteur.dart';
import 'package:sim_tchad/models/Magasin.dart';
import 'package:sim_tchad/models/NiveauApprovisionnement.dart';
import 'package:sim_tchad/models/Produit.dart';

class PrixMagasin {
  int? idPrixMagasin;
  String? codePrix;
  String? image;
  String? uniteMesure;
  String? prixBordChamp;
  String? stockDisponible;
  String? variete;
  String? age;
  String? prixTransport;
  String? uniteTransport;
  String? moyenTransport;
  String? prixVente;
  String? observation;
  String? statut;
  String? dateAjout;
  String? qualiteProduit;
  String? dateModif;

  BassinProduction? bassinProduction;
  Magasin? magasin;
  Produit? produit;
  NiveauApprovisionnement? niveau;
  Enqueteur? enqueteur;
  EnqueteMagasin? enqueteMagasin;

  PrixMagasin({
    this.idPrixMagasin,
    this.codePrix,
    this.image,
    this.uniteMesure,
    this.prixBordChamp,
    this.stockDisponible,
    this.variete,
    this.age,
    this.prixTransport,
    this.uniteTransport,
    this.moyenTransport,
    this.prixVente,
    this.observation,
    this.statut,
    this.dateAjout,
    this.qualiteProduit,
    this.dateModif,
    this.bassinProduction,
    this.magasin,
    this.produit,
    this.niveau,
    this.enqueteur,
    this.enqueteMagasin,
  });

  /// Convertir en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'idPrixMagasin': idPrixMagasin,
      'codePrix': codePrix,
      'image': image,
      'uniteMesure': uniteMesure,
      'prixBordChamp': prixBordChamp,
      'stockDisponible': stockDisponible,
      'variete': variete,
      'age': age,
      'prixTransport': prixTransport,
      'uniteTransport': uniteTransport,
      'moyenTransport': moyenTransport,
      'prixVente': prixVente,
      'observation': observation,
      'statut': statut,
      'dateAjout': dateAjout,
      'qualiteProduit': qualiteProduit,
      'dateModif': dateModif,
      'bassinProduction': bassinProduction != null
          ? jsonEncode(bassinProduction!.toJson())
          : null,
      'magasin': magasin != null ? jsonEncode(magasin!.toJson()) : null,
      'produit': produit != null ? jsonEncode(produit!.toJson()) : null,
      'niveau': niveau != null ? jsonEncode(niveau!.toJson()) : null,
      'enqueteur': enqueteur != null ? jsonEncode(enqueteur!.toJson()) : null,
      'enqueteMagasin':
          enqueteMagasin != null ? jsonEncode(enqueteMagasin!.toJson()) : null,
    };
  }

  /// Construire depuis SQLite
  factory PrixMagasin.fromMap(Map<String, dynamic> map) {
    return PrixMagasin(
      idPrixMagasin: map['idPrixMagasin'],
      codePrix: map['codePrix'] ?? '',
      image: map['image'] ?? '',
      uniteMesure: map['uniteMesure'] ?? '',
      prixBordChamp: map['prixBordChamp'] ?? '',
      stockDisponible: map['stockDisponible'] ?? '',
      variete: map['variete'] ?? '',
      age: map['age'] ?? '',
      prixTransport: map['prixTransport'] ?? '',
      uniteTransport: map['uniteTransport'] ?? '',
      moyenTransport: map['moyenTransport'] ?? '',
      prixVente: map['prixVente'] ?? '',
      observation: map['observation'] ?? '',
      statut: map['statut'] ?? '',
      dateAjout: map['dateAjout'] ?? '',
      qualiteProduit: map['qualiteProduit'] ?? '',
      dateModif: map['dateModif'] ?? '',
      bassinProduction: map['bassinProduction'] != null
          ? BassinProduction.fromJson(jsonDecode(map['bassinProduction']))
          : null,
      magasin: map['magasin'] != null
          ? Magasin.fromJson(jsonDecode(map['magasin']))
          : null,
      produit: map['produit'] != null
          ? Produit.fromJson(jsonDecode(map['produit']))
          : null,
      niveau: map['niveau'] != null
          ? NiveauApprovisionnement.fromJson(jsonDecode(map['niveau']))
          : null,
      enqueteur: map['enqueteur'] != null
          ? Enqueteur.fromJson(jsonDecode(map['enqueteur']))
          : null,
      enqueteMagasin: map['enqueteMagasin'] != null
          ? EnqueteMagasin.fromJson(jsonDecode(map['enqueteMagasin']))
          : null,
    );
  }

  factory PrixMagasin.fromJson(Map<String, dynamic> json) {
    return PrixMagasin(
      idPrixMagasin: json['idPrixMagasin'],
      codePrix: json['codePrix'] ?? '',
      image: json['image'] ?? '',
      uniteMesure: json['uniteMesure'] ?? '',
      prixBordChamp: json['prixBordChamp'] ?? '',
      stockDisponible: json['stockDisponible'] ?? '',
      variete: json['variete'] ?? '',
      age: json['age'] ?? '',
      prixTransport: json['prixTransport'] ?? '',
      uniteTransport: json['uniteTransport'] ?? '',
      moyenTransport: json['moyenTransport'] ?? '',
      prixVente: json['prixVente'] ?? '',
      observation: json['observation'] ?? '',
      statut: json['statut'] ?? '',
      dateAjout: json['dateAjout'] ?? '',
      qualiteProduit: json['qualiteProduit'] ?? '',
      dateModif: json['dateModif'] ?? '',
      bassinProduction: json['bassinProduction'] != null
          ? BassinProduction.fromJson(jsonDecode(json['bassinProduction']))
          : null,
      magasin: json['magasin'] != null
          ? Magasin.fromJson(jsonDecode(json['magasin']))
          : null,
      produit: json['produit'] != null
          ? Produit.fromJson(jsonDecode(json['produit']))
          : null,
      niveau: json['niveau'] != null
          ? NiveauApprovisionnement.fromJson(jsonDecode(json['niveau']))
          : null,
      enqueteur: json['enqueteur'] != null
          ? Enqueteur.fromJson(jsonDecode(json['enqueteur']))
          : null,
      enqueteMagasin: json['enqueteMagasin'] != null
          ? EnqueteMagasin.fromJson(jsonDecode(json['enqueteMagasin']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uniteMesure': uniteMesure,
      'prixBordChamp': prixBordChamp,
      'stockDisponible': stockDisponible,
      'variete': variete ?? null,
      'prixTransport': prixTransport,
      'prixVente': prixVente,
      'observation': observation,
      'dateAjout': dateAjout,
      'produit': produit != null ? jsonEncode(produit!.toJson()) : null,
      'magasin': magasin != null ? jsonEncode(magasin!.toJson()) : null,
      'niveau': niveau != null ? jsonEncode(niveau!.toJson()) : null,
      'enqueteMagasin':
          enqueteMagasin != null ? jsonEncode(enqueteMagasin!.toJson()) : null,
      'bassinProduction': bassinProduction != null
          ? jsonEncode(bassinProduction!.toJson())
          : null,
      'age': age,
      'moyenTransport': moyenTransport,
      'uniteTransport': uniteTransport,
      'qualiteProduit': qualiteProduit,
    };
  }
}
