import 'dart:convert';
import 'package:sim_tchad/models/Commune.dart';

class Marche {
  final int idMarche;
  final String codeMarche;
  final String nomMarche;
  final String? latitude;
  final String localite;
  final String? observation;
  final String? dateAjout;
  final String? dateModif;
  final String? longitude;
  final Commune commune;

  Marche({
    required this.idMarche,
    required this.codeMarche,
    required this.nomMarche,
    this.latitude,
    required this.localite,
    this.observation,
    this.dateAjout,
    this.dateModif,
    this.longitude,
    required this.commune,
  });

  /// Convertit depuis JSON ou String JSON
  factory Marche.fromJson(Map<String, dynamic> json) {
    Commune parseCommune(dynamic data) {
      if (data is String) {
        return Commune.fromJson(jsonDecode(data));
      } else if (data is Map<String, dynamic>) {
        return Commune.fromJson(data);
      } else {
        throw Exception("Impossible de parser commune: $data");
      }
    }

    return Marche(
      idMarche: json['idMarche'],
      codeMarche: json['codeMarche'],
      nomMarche: json['nomMarche'],
      latitude: json['latitude'],
      localite: json['localite'],
      observation: json['observation'],
      dateAjout: json['dateAjout'],
      dateModif: json['dateModif'],
      longitude: json['longitude'],
      commune: parseCommune(json['commune']),
    );
  }

  /// Convertit l'objet en JSON (relations encodées en TEXT pour SQLite)
  Map<String, dynamic> toJson() {
    return {
      'idMarche': idMarche,
      'codeMarche': codeMarche,
      'nomMarche': nomMarche,
      'latitude': latitude,
      'localite': localite,
      'observation': observation,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'longitude': longitude,
      'commune': jsonEncode(commune.toJson()),
    };
  }
}