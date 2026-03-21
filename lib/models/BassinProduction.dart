import 'dart:convert';
import 'Filiere.dart';

class BassinProduction {
  int? idBassin;
  String? codeBassin;
  String? libelle;
  String? latitude;
  String? observation;
  bool? statut;
  String? dateAjout;
  String? dateModif;
  List<Filiere>? filiere;
  String? longitude;

  BassinProduction({
    this.idBassin,
    this.codeBassin,
    this.libelle,
    this.latitude,
    this.observation,
    this.statut,
    this.dateAjout,
    this.dateModif,
    this.filiere,
    this.longitude,
  });

  /// Conversion depuis JSON
  factory BassinProduction.fromJson(Map<String, dynamic> json) {
    List<Filiere>? filiereList;

    if (json['filiere'] != null) {
      filiereList = List<Map<String, dynamic>>.from(json['filiere'])
          .map((f) => Filiere.fromJson(f))
          .toList();
    }

    return BassinProduction(
      idBassin: json['idBassin'],
      codeBassin: json['codeBassin'],
      libelle: json['libelle'],
      latitude: json['latitude'],
      observation: json['observation'],
      statut: json['statut'],
      dateAjout: json['dateAjout'],
      dateModif: json['dateModif'],
      filiere: filiereList,
      longitude: json['longitude'],
    );
  }

  /// Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'idBassin': idBassin,
      'codeBassin': codeBassin,
      'libelle': libelle,
      'latitude': latitude,
      'observation': observation,
      'statut': statut,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'filiere': filiere?.map((f) => f.toJson()).toList(),
      'longitude': longitude,
    };
  }

  /// Conversion pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'idBassin': idBassin,
      'codeBassin': codeBassin,
      'libelle': libelle,
      'latitude': latitude,
      'observation': observation,
      'statut': statut == true ? 1 : 0,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'filiere': filiere != null
          ? jsonEncode(filiere!.map((f) => f.toJson()).toList())
          : null,
      'longitude': longitude,
    };
  }

  /// Reconstruction depuis SQLite
  factory BassinProduction.fromMap(Map<String, dynamic> map) {
    List<Filiere>? filiereList;

    if (map['filiere'] != null) {
      var decoded = jsonDecode(map['filiere']);
      filiereList = List<Map<String, dynamic>>.from(decoded)
          .map((f) => Filiere.fromJson(f))
          .toList();
    }

    return BassinProduction(
      idBassin: map['idBassin'],
      codeBassin: map['codeBassin'],
      libelle: map['libelle'],
      latitude: map['latitude'],
      observation: map['observation'],
      statut: map['statut'] == 1,
      dateAjout: map['dateAjout'],
      dateModif: map['dateModif'],
      filiere: filiereList,
      longitude: map['longitude'],
    );
  }
}