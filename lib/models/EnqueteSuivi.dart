import 'dart:convert';
import 'Commune.dart';
import 'Enqueteur.dart';

class EnqueteSuivi {
  int? idEnquete;
  String numFiche;
  String dateEnquete;
  String? reference;
  Enqueteur enqueteur;
  String? dateEnregistrement;
  String? dateModif;
  Commune? commune;

  EnqueteSuivi({
    this.idEnquete,
    required this.numFiche,
    required this.dateEnquete,
    this.reference,
    required this.enqueteur,
    this.dateEnregistrement,
    this.dateModif,
    this.commune,
  }); 

/// Convertit un JSON (ou un string JSON pour les relations) en objet Dart
 /// Convertit un JSON (ou un string JSON pour les relations) en objet Dart
  factory EnqueteSuivi.fromJson(Map<String, dynamic> json) {
    // Décoder si le champ relationnel est stocké en TEXT
    Enqueteur parseEnqueteur(dynamic data) {
      if (data is String) {
        return Enqueteur.fromJson(jsonDecode(data));
      } else if (data is Map<String, dynamic>) {
        return Enqueteur.fromJson(data);
      } else {
        throw Exception("Impossible de parser enqueteur: $data");
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

    return EnqueteSuivi(
      idEnquete: json['idEnquete'],
      numFiche: json['numFiche'],
      dateEnquete: json['dateEnquete'],
      reference: json['reference'],
      enqueteur: parseEnqueteur(json['enqueteur']),
      dateEnregistrement: json['dateEnregistrement'],
      dateModif: json['dateModif'],
      commune: parseCommune(json['commune']),
    );
  }

  /// Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'idEnquete': idEnquete,
      'numFiche': numFiche,
      'dateEnquete': dateEnquete,
      'reference': reference,
      'enqueteur': enqueteur.toJson(),
      'dateEnregistrement': dateEnregistrement,
      'dateModif': dateModif,
      'commune': commune?.toJson(),
    };
  }

  /// Conversion pour SQLite (objets imbriqués sérialisés en JSON)
  Map<String, dynamic> toMap() {
    return {
      'idEnquete': idEnquete,
      'numFiche': numFiche,
      'dateEnquete': dateEnquete,
      'reference': reference,
      'enqueteur': jsonEncode(enqueteur.toJson()),
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
          : throw Exception("Enqueteur obligatoire"),
      dateEnregistrement: map['dateEnregistrement'],
      dateModif: map['dateModif'],
      commune: map['commune'] != null ? Commune.fromJson(jsonDecode(map['commune'])) : null,
    );
  }
}