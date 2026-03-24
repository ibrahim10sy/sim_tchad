
import 'dart:convert';

import 'package:sim_tchad/models/Commune.dart';
import 'package:sim_tchad/models/Enqueteur.dart';
import 'package:sim_tchad/models/Magasin.dart';

class EnqueteMagasin {
  int? idEnquete;
  String numFiche;
  String dateEnquete;
  String? reference;
  Enqueteur? enqueteur;
  Magasin magasin;
  String? dateEnregistrement;
  String? dateModif;
  Commune? commune;

  EnqueteMagasin({
    this.idEnquete,
    required this.numFiche,
    required this.dateEnquete,
     this.reference,
    required this.enqueteur,
    required this.magasin,
    this.dateEnregistrement,
    this.dateModif,
    this.commune,
  });

  /// Convertit un JSON (ou String JSON) en objet Dart
  factory EnqueteMagasin.fromJson(Map<String, dynamic> json) {
    Enqueteur parseEnqueteur(dynamic data) {
      if (data is String) {
        return Enqueteur.fromJson(jsonDecode(data));
      } else if (data is Map<String, dynamic>) {
        return Enqueteur.fromJson(data);
      } else {
        throw Exception("Impossible de parser enqueteur: $data");
      }
    }

    Magasin parseMagasin(dynamic data) {
      if (data is String) {
        return Magasin.fromJson(jsonDecode(data));
      } else if (data is Map<String, dynamic>) {
        return Magasin.fromJson(data);
      } else {
        throw Exception("Impossible de parser magasin: $data");
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

    return EnqueteMagasin(
      idEnquete: json['idEnquete'],
      numFiche: json['numFiche'],
      dateEnquete: json['dateEnquete'],
      reference: json['reference'] ?? '',
      enqueteur: parseEnqueteur(json['enqueteur']),
      magasin: parseMagasin(json['magasin']),
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
      'magasin': jsonEncode(magasin.toJson()),
      'dateEnregistrement': dateEnregistrement,
      'dateModif': dateModif,
      'commune': commune != null ? jsonEncode(commune!.toJson()) : null,
    };
  }
}