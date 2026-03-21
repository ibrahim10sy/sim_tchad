import 'dart:convert';

import 'package:sim_tchad/models/Commune.dart';

class Magasin {
  final int idMagasin;
  final String codeMagasin;
  final String nomMagasin;
  final String? latitude;
  final String? localite;
  final String? contactMagasin;
  final String? dateAjout;
  final String? dateModif;
  final String? longitude;
  final Commune commune;

  Magasin({
    required this.idMagasin,
    required this.codeMagasin,
    required this.nomMagasin,
    this.latitude,
    this.localite,
    this.contactMagasin,
    this.dateAjout,
    this.dateModif,
    this.longitude,
    required this.commune,
  });

  factory Magasin.fromJson(Map<String, dynamic> json) {
    return Magasin(
      idMagasin: json['idMagasin'],
      codeMagasin: json['codeMagasin'],
      nomMagasin: json['nomMagasin'],
      latitude: json['latitude'],
      localite: json['localite'],
      contactMagasin: json['contactMagasin'],
      dateAjout: json['dateAjout'],
      dateModif: json['dateModif'],
      longitude: json['longitude'],
      commune: Commune.fromJson(
      json['commune'] is String
          ? jsonDecode(json['commune'])
          : json['commune'],
    ),
    );
  }

   Map<String, dynamic> toJson() {
    return {
      'idMagasin': idMagasin,
      'codeMagasin': codeMagasin,
      'nomMagasin': nomMagasin,
      'latitude': latitude,
      'localite': localite,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'longitude': longitude,
      'commune': commune.toJson(), // Assure-toi que Commune a aussi toJson()
    };
  }
}