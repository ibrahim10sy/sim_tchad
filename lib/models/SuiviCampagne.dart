import 'dart:convert';

import 'package:sim_tchad/models/Acteur.dart';
import 'package:sim_tchad/models/BassinProduction.dart';
import 'package:sim_tchad/models/Campagne.dart';
import 'package:sim_tchad/models/Commune.dart';
import 'package:sim_tchad/models/EnqueteCampagne.dart';
import 'package:sim_tchad/models/Enqueteur.dart';
import 'package:sim_tchad/models/Produit.dart';


class SuiviCampagne {
  int? idSuiviCampagne;
  String? codeSuiviCampagne;
  String? commentaire;
  String? dateSemi;
  double? superficieHa;
  double? quantiteProduit;
  String? variete;
  String? dateAjout;
  String? dateModif;
  String? statut;
  String? latitude;
  String? longitude;
  String? uniteMesure;
  Produit? produit;
  BassinProduction? bassinProduction;
  Campagne? campagne;
  Enqueteur? enqueteur;
  Commune? commune;
  EnqueteCampagne? enqueteCampagne;

  SuiviCampagne({
    this.idSuiviCampagne,
    this.codeSuiviCampagne,
    this.commentaire,
    this.dateSemi,
    this.superficieHa,
    this.quantiteProduit,
    this.variete,
    this.dateAjout,
    this.dateModif,
    this.uniteMesure,
    this.statut,
    this.latitude,
    this.longitude,
    this.produit,
    this.bassinProduction,
    this.campagne,
    this.enqueteur,
    this.commune,
    this.enqueteCampagne,
  });

  /// 🔹 FROM JSON (API)
  factory SuiviCampagne.fromJson(Map<String, dynamic> json) {
    return SuiviCampagne(
      idSuiviCampagne: json['idSuiviCampagne'],
      codeSuiviCampagne: json['codeSuiviCampagne'],
      commentaire: json['commentaire'],
      dateSemi: json['dateSemi'],
      superficieHa: (json['superficieHa'] ?? 0).toDouble(),
      quantiteProduit:
          (json['quantiteProduit'] ?? 0).toDouble(),
      variete: json['variete'],
      uniteMesure: json['uniteMesure'],
      dateAjout: json['dateAjout'],
      dateModif: json['dateModif'],
      statut: json['statut'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      
      produit: json['produit'] != null
          ? Produit.fromJson(json['produit'])
          : null,

      bassinProduction: json['bassinProduction'] != null
          ? BassinProduction.fromJson(json['bassinProduction'])
          : null,

      campagne: json['campagne'] != null
          ? Campagne.fromJson(json['campagne'])
          : null,
      enqueteur: json['enqueteur'] != null
          ? Enqueteur.fromJson(json['enqueteur'])
          : null,

      commune:
          json['commune'] != null ? Commune.fromJson(json['commune']) : null,

      enqueteCampagne: json['enqueteCampagne'] != null
          ? EnqueteCampagne.fromJson(json['enqueteCampagne'])
          : null,
    );
  }

  /// 🔹 TO JSON (API)
  Map<String, dynamic> toJson() {
    return {
      'commentaire': commentaire,
      'dateSemi': dateSemi,
      'superficieHa': superficieHa,
      'quantiteProduit': quantiteProduit,
      'variete': variete,
      'dateAjout': dateAjout,

      "uniteMesure": uniteMesure,
  
      'produit': produit != null
          ? jsonEncode(produit!.toJson())
          : null,
  
      'bassinProduction': bassinProduction != null
          ? jsonEncode(bassinProduction!.toJson())
          : null,

      'campagne':
          campagne != null ? jsonEncode(campagne!.toJson()) : null,


      // 'enqueteur':
      //     enqueteur != null ? jsonEncode(enqueteur!.toJson()) : null,

      'commune':
          commune != null ? jsonEncode(commune!.toJson()) : null,

      'enqueteCampagne': enqueteCampagne != null
          ? jsonEncode(enqueteCampagne!.toJson())
          : null,
    };
  }

  /// 🔹 SQLITE MAP
  Map<String, dynamic> toMap() {
    return {
      'idSuiviCampagne': idSuiviCampagne,
      'codeSuiviCampagne': codeSuiviCampagne,
      'commentaire': commentaire,
      'dateSemi': dateSemi,
      'superficieHa': superficieHa,
      'quantiteProduit': quantiteProduit,
      'variete': variete,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'statut': statut,
      'latitude': latitude,
      'longitude': longitude,
      'uniteMesure':uniteMesure,
    
      'produit': produit != null
          ? jsonEncode(produit!.toJson())
          : null,

      'bassinProduction': bassinProduction != null
          ? jsonEncode(bassinProduction!.toJson())
          : null,

      'campagne':
          campagne != null ? jsonEncode(campagne!.toJson()) : null,

      'enqueteur':
          enqueteur != null ? jsonEncode(enqueteur!.toJson()) : null,

      'commune':
          commune != null ? jsonEncode(commune!.toJson()) : null,

      'enqueteCampagne': enqueteCampagne != null
          ? jsonEncode(enqueteCampagne!.toJson())
          : null
    };
  }

  /// 🔹 FROM SQLITE
  factory SuiviCampagne.fromMap(Map<String, dynamic> map) {
    return SuiviCampagne(
      idSuiviCampagne: map['idSuiviCampagne'],
      codeSuiviCampagne: map['codeSuiviCampagne'],
      commentaire: map['commentaire'],
      dateSemi: map['dateSemi'],
      superficieHa: (map['superficieHa'] ?? 0).toDouble(),
      quantiteProduit:
          (map['quantiteProduit'] ?? 0).toDouble(),
      variete: map['variete'],
      dateAjout: map['dateAjout'],
      dateModif: map['dateModif'],
      statut: map['statut'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      uniteMesure: map['uniteMesure'],
      produit: map['produit'] != null
          ? Produit.fromJson(
              jsonDecode(map['produit']))
          : null,
      bassinProduction: map['bassinProduction'] != null
          ? BassinProduction.fromJson(
              jsonDecode(map['bassinProduction']))
          : null,

      campagne: map['campagne'] != null
          ? Campagne.fromJson(jsonDecode(map['campagne']))
          : null,

      enqueteur: map['enqueteur'] != null
          ? Enqueteur.fromJson(jsonDecode(map['enqueteur']))
          : null,

      commune: map['commune'] != null
          ? Commune.fromJson(jsonDecode(map['commune']))
          : null,

      enqueteCampagne: map['enqueteCampagne'] != null
          ? EnqueteCampagne.fromJson(
              jsonDecode(map['enqueteCampagne']))
          : null,
    );
  }
}