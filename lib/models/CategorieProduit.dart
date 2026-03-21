import 'dart:convert';

import 'package:sim_tchad/models/Filiere.dart';

class CategorieProduit {
  int? idCategorieProduit;
  String? codeCategorie;
  String? libelle;
  String? description;
  String? dateAjout;
  String? dateModif;
  Filiere? filiere;

  CategorieProduit({
    this.idCategorieProduit,
    this.codeCategorie,
    this.libelle,
    this.description,
    this.dateAjout,
    this.dateModif,
    this.filiere,
  });

  /// JSON -> Objet
  factory CategorieProduit.fromJson(Map<String, dynamic> json) {

    Filiere? filiereObj;

    if (json['filiere'] != null) {
      if (json['filiere'] is String) {
        filiereObj = Filiere.fromJson(jsonDecode(json['filiere']));
      } else {
        filiereObj = Filiere.fromJson(json['filiere']);
      }
    }

    return CategorieProduit(
      idCategorieProduit: json['idCategorieProduit'],
      codeCategorie: json['codeCategorie'],
      libelle: json['libelle'],
      description: json['description'],
      dateAjout: json['dateAjout'],
      dateModif: json['dateModif'],
      filiere: filiereObj,
    );
  }

  /// Objet -> JSON
  Map<String, dynamic> toJson() {
    return {
      'idCategorieProduit': idCategorieProduit,
      'codeCategorie': codeCategorie,
      'libelle': libelle,
      'description': description,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'filiere': filiere?.toJson(),
    };
  }

  /// Objet -> SQLite Map
  Map<String, dynamic> toMap() {
    return {
      'idCategorieProduit': idCategorieProduit,
      'codeCategorie': codeCategorie,
      'libelle': libelle,
      'description': description,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'filiere': filiere != null ? jsonEncode(filiere!.toJson()) : null,
    };
  }

  /// SQLite Map -> Objet
  factory CategorieProduit.fromMap(Map<String, dynamic> map) {

    Filiere? filiereObj;

    if (map['filiere'] != null) {
      var decoded = jsonDecode(map['filiere']);
      filiereObj = Filiere.fromJson(decoded);
    }

    return CategorieProduit(
      idCategorieProduit: map['idCategorieProduit'],
      codeCategorie: map['codeCategorie'],
      libelle: map['libelle'],
      description: map['description'],
      dateAjout: map['dateAjout'],
      dateModif: map['dateModif'],
      filiere: filiereObj,
    );
  }
}