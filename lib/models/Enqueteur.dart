import 'package:sim_tchad/models/Acteur.dart';
import 'package:sim_tchad/models/Commune.dart';
import 'dart:convert';


class Enqueteur {
  int? idEnqueteur;
  String? codeEnqueteur;
  String? nomEnqueteur;
  String? email;
  String? adresse;
  String? telephone;
  String? whatsApp;
  String? password;
  String? dateAjout;
  String? dateModif;
  bool? statutEnqueteur;
  bool? resetPassword;
  Acteur? acteur;
  Commune? commune;

  Enqueteur({
     this.idEnqueteur,
     this.codeEnqueteur,
     this.nomEnqueteur,
    this.email,
    this.adresse,
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

 static Acteur? _parseActeur(dynamic data) {
  if (data == null) return null;

  if (data is String) {
    return Acteur.fromJson(jsonDecode(data));
  } else if (data is Map<String, dynamic>) {
    return Acteur.fromJson(data);
  }

  return null; // sécurité
}

static Commune? _parseCommune(dynamic data) {
  if (data == null) return null;

  if (data is String) {
    return Commune.fromJson(jsonDecode(data));
  } else if (data is Map<String, dynamic>) {
    return Commune.fromJson(data);
  }

  return null;
}

  /// Conversion depuis JSON
  factory Enqueteur.fromJson(Map<String, dynamic> json) {
  return Enqueteur(
    idEnqueteur: json['idEnqueteur'] ?? 0,
    codeEnqueteur: json['codeEnqueteur'] ?? '',
    nomEnqueteur: json['nomEnqueteur'] ?? '',
    email: json['email'] ?? '',
    adresse: json['adresse'] ?? '',
    telephone: json['telephone'] ?? '',
    whatsApp: json['whatsApp'] ?? '',
    password: json['password'] ?? '',
    dateAjout: json['dateAjout']?? '',
    dateModif: json['dateModif'] ?? '',
    statutEnqueteur: json['statutEnqueteur'] ?? false,
    resetPassword: json['resetPassword'] ?? false,
    acteur: _parseActeur(json['acteur']),
    commune: _parseCommune(json['commune']),
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