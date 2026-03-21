import 'package:sim_tchad/models/Commune.dart';

import 'acteur.dart';

class Enqueteur {
  int idEnqueteur;
  String codeEnqueteur;
  String nomEnqueteur;
  String? email;
  String? adresse;
  String? localite;
  String? telephone;
  String? whatsApp;
  String? password;
  String? dateAjout;
  String? dateModif;
  bool statutEnqueteur;
  bool resetPassword;
  Acteur? acteur;
  Commune? commune;

  Enqueteur({
    required this.idEnqueteur,
    required this.codeEnqueteur,
    required this.nomEnqueteur,
    this.email,
    this.adresse,
    this.localite,
    this.telephone,
    this.whatsApp,
    this.password,
    this.dateAjout,
    this.dateModif,
    required this.statutEnqueteur,
    required this.resetPassword,
    this.acteur,
    this.commune,
  });

  /// Conversion depuis JSON
  factory Enqueteur.fromJson(Map<String, dynamic> json) {
    return Enqueteur(
      idEnqueteur: json['idEnqueteur'] ?? 0,
      codeEnqueteur: json['codeEnqueteur'] ?? '',
      nomEnqueteur: json['nomEnqueteur'] ?? '',
      email: json['email'],
      adresse: json['adresse'],
      localite: json['localite'],
      telephone: json['telephone'],
      whatsApp: json['whatsApp'],
      password: json['password'],
      dateAjout: json['dateAjout'],
      dateModif: json['dateModif'],
      statutEnqueteur: json['statutEnqueteur'] ?? false,
      resetPassword: json['resetPassword'] ?? false,
      acteur: json['acteur'] != null
          ? Acteur.fromJson(json['acteur'])
          : null,
      commune: json['commune'] != null
          ? Commune.fromJson(json['commune'])
          : null,
    );
  }

  /// Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'idEnqueteur': idEnqueteur,
      'codeEnqueteur': codeEnqueteur,
      'nomEnqueteur': nomEnqueteur,
      'email': email,
      'adresse': adresse,
      'localite': localite,
      'telephone': telephone,
      'whatsApp': whatsApp,
      'password': password,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'statutEnqueteur': statutEnqueteur,
      'resetPassword': resetPassword,
      'acteur': acteur?.toJson(),
      'commune': commune?.toJson(),
    };
  }
}