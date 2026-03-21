import 'dart:convert';

import 'package:sim_tchad/models/Filiere.dart';

class Variete {
  int? idVariete;
  String? codeVariete;
  String? libelle;
  String? observation;
  bool? statut;
  String? dateAjout;
  String? dateModif;
  Filiere? filiere;

  Variete({
    this.idVariete,
    this.codeVariete,
    this.libelle,
    this.observation,
    this.statut,
    this.dateAjout,
    this.dateModif,
    this.filiere,
  });

  factory Variete.fromJson(Map<String, dynamic> json) {

    Filiere? filiereObj;

    if (json['filiere'] != null) {
      if (json['filiere'] is String) {
        filiereObj = Filiere.fromJson(jsonDecode(json['filiere']));
      } else {
        filiereObj = Filiere.fromJson(json['filiere']);
      }
    }

    return Variete(
      idVariete: json['idVariete'],
      codeVariete: json['codeVariete'],
      libelle: json['libelle'],
      observation: json['observation'],
      statut: json['statut'],
      dateAjout: json['dateAjout'],
      dateModif: json['dateModif'],
      filiere: filiereObj,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idVariete': idVariete,
      'codeVariete': codeVariete,
      'libelle': libelle,
      'observation': observation,
      'statut': statut,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'filiere': filiere?.toJson(),
    };
  }
}