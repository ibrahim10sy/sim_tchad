import 'dart:convert';

import 'package:sim_tchad/models/Commune.dart';
import 'package:sim_tchad/models/EnqueteSuivi.dart';
import 'package:sim_tchad/models/Enqueteur.dart';
import 'package:sim_tchad/models/NiveauApprovisionnement.dart';
import 'package:sim_tchad/models/Produit.dart';

class SuiviFlux {
  int? idSuivi;
  String? codeSuivi;
  String observation;
  double fluxEntrantTonne;
  double fluxSortantTonne;
  String disponibilite;
  String difficulte;
  String dateCollecte;
  String dateAjout;
  String? dateModif;
  String? statut;
  String? latitude;
  String? longitude;
  Produit? produit;
  NiveauApprovisionnement? niveau;
  Enqueteur? enqueteur;
  EnqueteSuivi? enqueteSuivi;
  Commune? commune;

  SuiviFlux({
    this.idSuivi,
    this.codeSuivi,
    required this.observation,
    required this.fluxEntrantTonne,
    required this.fluxSortantTonne,
    required this.disponibilite,
    required this.difficulte,
    required this.dateCollecte,
    required this.dateAjout,
    this.dateModif,
    this.statut,
    this.latitude,
    this.longitude,
    this.produit,
    this.niveau,
    this.enqueteur,
    this.enqueteSuivi,
    this.commune,
  });

  /// Conversion depuis JSON
  factory SuiviFlux.fromJson(Map<String, dynamic> json) {
    return SuiviFlux(
      idSuivi: json['idSuivi'],
      codeSuivi: json['codeSuivi'],
      observation: json['observation'],
      fluxEntrantTonne: (json['fluxEntrantTonne'] ?? 0).toDouble(),
      fluxSortantTonne: (json['fluxSortantTonne'] ?? 0).toDouble(),
      disponibilite: json['disponibilite'],
      difficulte: json['difficulte'],
      dateCollecte: json['dateCollecte'],
      dateAjout: json['dateAjout'],
      dateModif: json['dateModif'],
      statut: json['statut'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      produit:
          json['produit'] != null ? Produit.fromJson(json['produit']) : null,
      niveau: json['niveau'] != null
          ? NiveauApprovisionnement.fromJson(json['niveau'])
          : null,
      enqueteur: json['enqueteur'] != null
          ? Enqueteur.fromJson(json['enqueteur'])
          : null,
      enqueteSuivi: json['enqueteSuivi'] != null
          ? EnqueteSuivi.fromJson(json['enqueteSuivi'])
          : null,
      commune:
          json['commune'] != null ? Commune.fromJson(json['commune']) : null,
    );
  }

  /// Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'observation': observation,
      'fluxEntrantTonne': fluxEntrantTonne,
      'fluxSortantTonne': fluxSortantTonne,
      'disponibilite': disponibilite,
      'difficulte': difficulte,
      'dateCollecte': dateCollecte,
      'dateAjout': dateAjout,
      'produit': produit != null ? jsonEncode(produit!.toJson()) : null,
      'niveau': niveau != null ? jsonEncode(niveau!.toJson()) : null,
      'commune': commune != null ? jsonEncode(commune!.toJson()) : null,
      'enqueteur': enqueteur != null ? jsonEncode(enqueteur!.toJson()) : null,
      'enqueteSuivi': enqueteSuivi != null
        ? jsonEncode(enqueteSuivi!.toJson())
        : null,
    };
  }

  /// Conversion pour SQLite (relations sérialisées en JSON string)
  Map<String, dynamic> toMap() {
    return {
      'idSuivi': idSuivi,
      'codeSuivi': codeSuivi,
      'observation': observation,
      'fluxEntrantTonne': fluxEntrantTonne,
      'fluxSortantTonne': fluxSortantTonne,
      'disponibilite': disponibilite,
      'difficulte': difficulte,
      'dateCollecte': dateCollecte,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'statut': statut,
      'latitude': latitude,
      'longitude': longitude,
      'produit': produit != null ? jsonEncode(produit!.toJson()) : null,
      'niveau': niveau != null ? jsonEncode(niveau!.toJson()) : null,
      'enqueteur': enqueteur != null ? jsonEncode(enqueteur!.toJson()) : null,
      'enqueteSuivi':
          enqueteSuivi != null ? jsonEncode(enqueteSuivi!.toJson()) : null,
      'commune': commune != null ? jsonEncode(commune!.toJson()) : null,
    };
  }

  /// Reconstruct depuis SQLite
  factory SuiviFlux.fromMap(Map<String, dynamic> map) {
    return SuiviFlux(
      idSuivi: map['idSuivi'],
      codeSuivi: map['codeSuivi'],
      observation: map['observation'],
      fluxEntrantTonne: (map['fluxEntrantTonne'] ?? 0).toDouble(),
      fluxSortantTonne: (map['fluxSortantTonne'] ?? 0).toDouble(),
      disponibilite: map['disponibilite'],
      difficulte: map['difficulte'],
      dateCollecte: map['dateCollecte'],
      dateAjout: map['dateAjout'],
      dateModif: map['dateModif'],
      statut: map['statut'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      produit: map['produit'] != null
          ? Produit.fromJson(jsonDecode(map['produit']))
          : null,
      niveau: map['niveau'] != null
          ? NiveauApprovisionnement.fromJson(jsonDecode(map['niveau']))
          : null,
      enqueteur: map['enqueteur'] != null
          ? Enqueteur.fromJson(jsonDecode(map['enqueteur']))
          : null,
      enqueteSuivi: map['enqueteSuivi'] != null
          ? EnqueteSuivi.fromJson(jsonDecode(map['enqueteSuivi']))
          : null,
      commune: map['commune'] != null
          ? Commune.fromJson(jsonDecode(map['commune']))
          : null,
    );
  }
}
