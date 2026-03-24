import 'dart:convert';

import 'package:sim_tchad/models/Commune.dart';
import 'package:sim_tchad/models/Enqueteur.dart';


class EnqueteSuivi {
  int? idEnquete;
  String numFiche;
  String dateEnquete;
  String? reference;
  Enqueteur? enqueteur;
  String? dateEnregistrement;
  String? dateModif;
  Commune? commune;

  EnqueteSuivi({
    this.idEnquete,
    required this.numFiche,
    required this.dateEnquete,
    this.reference,
     this.enqueteur,
    this.dateEnregistrement,
    this.dateModif,
    this.commune,
  });


static Enqueteur? _parseEnqueteur(dynamic data) {
  if (data == null) return null;

  try {
    if (data is String) {
      // 🔥 Vérifier si c’est du vrai JSON
      if (data.trim().startsWith('{')) {
        return Enqueteur.fromJson(jsonDecode(data));
      } else {
        print("Format invalide Enqueteur: $data");
        return null;
      }
    } else if (data is Map<String, dynamic>) {
      return Enqueteur.fromJson(data);
    }
  } catch (e) {
    print("Erreur parsing Enqueteur: $e");
  }

  return null;
}

static Commune? _parseCommune(dynamic data) {
  if (data == null) return null;

  try {
    if (data is String) {
      // 🔥 Vérifier si c’est du vrai JSON
      if (data.trim().startsWith('{')) {
        return Commune.fromJson(jsonDecode(data));
      } else {
        print("Format invalide Enqueteur: $data");
        return null;
      }
    } else if (data is Map<String, dynamic>) {
      return Commune.fromJson(data);
    }
  } catch (e) {
    print("Erreur parsing Enqueteur: $e");
  }

  return null;
}

  /// Conversion depuis JSON
  factory EnqueteSuivi.fromJson(Map<String, dynamic> json) {
  return EnqueteSuivi(
    idEnquete: json['idEnquete'],
    numFiche: json['numFiche'],
    dateEnquete: json['dateEnquete'],
    reference: json['reference'],
    enqueteur: json['enqueteur'] != null
        ? _parseEnqueteur(json['enqueteur'])
        : null,
    dateEnregistrement: json['dateEnregistrement'],
    dateModif: json['dateModif'],
    commune: json['commune'] != null
        ? _parseCommune(json['commune'])
        : null,
  );
}

  /// Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'idEnquete': idEnquete,
      'numFiche': numFiche,
      'dateEnquete': dateEnquete,
      'reference': reference,
       'enqueteur': jsonEncode(enqueteur!.toJson()),
      'dateEnregistrement': dateEnregistrement,
      'dateModif': dateModif,
      'commune': commune != null ? jsonEncode(commune!.toJson()) : null,
    };
  }

  /// Conversion pour SQLite (objets imbriqués sérialisés en JSON)
  Map<String, dynamic> toMap() {
    return {
      'idEnquete': idEnquete,
      'numFiche': numFiche,
      'dateEnquete': dateEnquete,
      'reference': reference,
     'enqueteur': enqueteur != null ? jsonEncode(enqueteur!.toJson()) : null,
      'dateEnregistrement': dateEnregistrement,
      'dateModif': dateModif,
      'commune': commune != null ? jsonEncode(commune!.toJson()) : null,
    };
  }

  /// Reconstruction depuis SQLite
  factory EnqueteSuivi.fromMap(Map<String, dynamic> map) {
    return EnqueteSuivi(
      idEnquete: map['idEnquete'],
      numFiche: map['numFiche'],
      dateEnquete: map['dateEnquete'],
      reference: map['reference'],
      enqueteur: map['enqueteur'] != null
          ? Enqueteur.fromJson(jsonDecode(map['enqueteur']))
          : null,
      dateEnregistrement: map['dateEnregistrement'],
      dateModif: map['dateModif'],
      commune: map['commune'] != null ? Commune.fromJson(jsonDecode(map['commune'])) : null,
    );
  }
}