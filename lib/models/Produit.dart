import 'dart:convert';
import 'package:sim_tchad/models/CategorieProduit.dart';

class Produit {
  final int idProduit;
  final String codeProduit;
  final String nomProduit;
  final String? image;
  final String? description;
  final String? dateAjout;
  final String? dateModif;
  final CategorieProduit? categorieProduit;

  Produit({
    required this.idProduit,
    required this.codeProduit,
    required this.nomProduit,
    this.image,
    this.description,
    this.dateAjout,
    this.dateModif,
    this.categorieProduit,
  });

  /// JSON -> Objet
  factory Produit.fromJson(Map<String, dynamic> json) {

    CategorieProduit? categorie;

    if (json['categorieProduit'] != null) {
      if (json['categorieProduit'] is String) {
        categorie =
            CategorieProduit.fromJson(jsonDecode(json['categorieProduit']));
      } else {
        categorie =
            CategorieProduit.fromJson(json['categorieProduit']);
      }
    }

    return Produit(
      idProduit: json['idProduit'],
      codeProduit: json['codeProduit'],
      nomProduit: json['nomProduit'],
      image: json['image'],
      description: json['description'],
      dateAjout: json['dateAjout'],
      dateModif: json['dateModif'],
      categorieProduit: categorie,
    );
  }

  /// Objet -> JSON
  Map<String, dynamic> toJson() {
    return {
      'idProduit': idProduit,
      'codeProduit': codeProduit,
      'nomProduit': nomProduit,
      'image': image,
      'description': description,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'categorieProduit': categorieProduit?.toJson(),
    };
  }

  /// Objet -> SQLite
  Map<String, dynamic> toMap() {
    return {
      'idProduit': idProduit,
      'codeProduit': codeProduit,
      'nomProduit': nomProduit,
      'image': image,
      'description': description,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'categorieProduit': categorieProduit != null
          ? jsonEncode(categorieProduit!.toJson())
          : null,
    };
  }

  /// SQLite -> Objet
  factory Produit.fromMap(Map<String, dynamic> map) {

    CategorieProduit? categorie;

    if (map['categorieProduit'] != null) {
      var decoded = jsonDecode(map['categorieProduit']);
      categorie = CategorieProduit.fromJson(decoded);
    }

    return Produit(
      idProduit: map['idProduit'],
      codeProduit: map['codeProduit'],
      nomProduit: map['nomProduit'],
      image: map['image'],
      description: map['description'],
      dateAjout: map['dateAjout'],
      dateModif: map['dateModif'],
      categorieProduit: categorie,
    );
  }
}