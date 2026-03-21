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
    return EnqueteCampagne(
      idEnquete: json['idEnquete'],
      numFiche: json['numFiche'],
      dateEnquete: json['dateEnquete'],
      reference: json['reference'],
      enqueteur: Enqueteur.fromJson(json['enqueteur']),
      dateEnregistrement: json['dateEnregistrement'],
      dateModif: json['dateModif'],
      commune: json['commune'] != null ? Commune.fromJson(json['commune']) : null,
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