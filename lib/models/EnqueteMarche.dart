
import 'dart:convert';

import 'package:sim_tchad/models/Commune.dart';
import 'package:sim_tchad/models/Enqueteur.dart';
import 'package:sim_tchad/models/Marche.dart';

class EnqueteMarche{
  int? idEnquete;
  String numFiche;
  String dateEnquete;
  String reference;
  Enqueteur? enqueteur;
  Marche marche;
  String? dateEnregistrement;
  String? dateModif;
  Commune? commune;

  EnqueteMarche({
    this.idEnquete,
    required this.numFiche,
    required this.dateEnquete,
    required this.reference,
    required this.enqueteur,
    required this.marche,
    this.dateEnregistrement,
    this.dateModif,
    this.commune,
  });

  /// Convertit un JSON (ou String JSON) en objet Dart
  factory EnqueteMarche.fromJson(Map<String, dynamic> json) {
    Enqueteur parseEnqueteur(dynamic data) {
      if (data is String) {
        return Enqueteur.fromJson(jsonDecode(data));
      } else if (data is Map<String, dynamic>) {
        return Enqueteur.fromJson(data);
      } else {
        throw Exception("Impossible de parser enqueteur: $data");
      }
    }

    Marche parsemarche(dynamic data) {
      if (data is String) {
        return Marche.fromJson(jsonDecode(data));
      } else if (data is Map<String, dynamic>) {
        return Marche.fromJson(data);
      } else {
        throw Exception("Impossible de parser marche: $data");
      }
    }

    Commune? parseCommune(dynamic data) {
      if (data == null) return null;
      if (data is String) {
        return Commune.fromJson(jsonDecode(data));
      } else if (data is Map<String, dynamic>) {
        return Commune.fromJson(data);
      } else {
        throw Exception("Impossible de parser commune: $data");
      }
    }

    return EnqueteMarche(
      idEnquete: json['idEnquete'],
      numFiche: json['numFiche'],
      dateEnquete: json['dateEnquete'],
      reference: json['reference'],
      enqueteur: parseEnqueteur(json['enqueteur']),
      marche: parsemarche(json['marche']),
      dateEnregistrement: json['dateEnregistrement'],
      dateModif: json['dateModif'],
      commune: parseCommune(json['commune']),
    );
  }

  /// Convertit l'objet Dart en JSON (relations encodées en TEXT pour SQLite)
  Map<String, dynamic> toJson() {
    return {
      'idEnquete': idEnquete,
      'numFiche': numFiche,
      'dateEnquete': dateEnquete,
      'reference': reference,
      'enqueteur': jsonEncode(enqueteur!.toJson()),
      'marche': jsonEncode(marche.toJson()),
      'dateEnregistrement': dateEnregistrement,
      'dateModif': dateModif,
      'commune': commune != null ? jsonEncode(commune!.toJson()) : null,
    };
  }
}