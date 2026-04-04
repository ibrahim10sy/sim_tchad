import 'dart:convert';
import 'Commune.dart';
import 'Enqueteur.dart';

class EnqueteCampagne {
  int? idEnquete;
  String numFiche;
  String dateEnquete;
  String? reference;
  Enqueteur enqueteur;
  String? dateEnregistrement;
  String? dateModif;
  Commune? commune;

  EnqueteCampagne({
    this.idEnquete,
    required this.numFiche,
    required this.dateEnquete,
    this.reference,
    required this.enqueteur,
    this.dateEnregistrement,
    this.dateModif,
    this.commune,
  });

  /// Conversion depuis JSON
 factory EnqueteCampagne.fromJson(Map<String, dynamic> json) {
   
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

    return EnqueteCampagne(
      idEnquete: json['idEnquete'],
      numFiche: json['numFiche'],
      dateEnquete: json['dateEnquete'],
      reference: json['reference'],
      dateEnregistrement: json['dateEnregistrement'],
      dateModif: json['dateModif'],
       enqueteur: parseEnqueteur(json['enqueteur']),
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
      'enqueteur': jsonEncode(enqueteur.toJson()),
      'dateEnregistrement': dateEnregistrement,
      'dateModif': dateModif,
       'commune': commune != null ? jsonEncode(commune!.toJson()) : null
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
  factory EnqueteCampagne.fromMap(Map<String, dynamic> map) {
    return EnqueteCampagne(
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