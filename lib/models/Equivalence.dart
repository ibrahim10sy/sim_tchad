import 'package:sim_tchad/models/Commune.dart';
import 'package:sim_tchad/models/Produit.dart';
import 'package:sim_tchad/models/Unite.dart';

class Equivalence {
  final int? id;
  final double equivalenceUnite;
  final Unite unite;
  final Produit produit;
  final Commune commune;

  Equivalence({
    this.id,
    required this.equivalenceUnite,
    required this.unite,
    required this.produit,
    required this.commune,
  });

  /// 🔹 Convertir JSON -> Objet
  factory Equivalence.fromJson(Map<String, dynamic> json) {
    return Equivalence(
      id: json['id'],
      equivalenceUnite: (json['equivalenceUnite'] as num).toDouble(),
      unite: Unite.fromJson(json['unite']),
      produit: Produit.fromJson(json['produit']),
      commune: Commune.fromJson(json['commune']),
    );
  }

  /// 🔹 Convertir Objet -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'equivalenceUnite': equivalenceUnite,
      'unite': unite.toJson(),
      'produit': produit.toJson(),
      'commune': commune.toJson(),
    };
  }
}