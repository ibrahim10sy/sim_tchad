import 'dart:convert';

import 'package:sim_tchad/models/Commune.dart';
import 'package:sim_tchad/models/Produit.dart';
import 'package:sim_tchad/models/UniteConventionnelle.dart';

class EquivalenceUnite {
  final int? id;
  final double equivalenceUnite;
   UniteConventionnelle? uniteConventionnelle;
   Produit? produit;
   Commune? commune;

  EquivalenceUnite({
    this.id,
    required this.equivalenceUnite,
     this.uniteConventionnelle,
     this.produit,
     this.commune,
  });

  // 🔹 Convertir JSON -> Objet
  factory EquivalenceUnite.fromJson(Map<String, dynamic> json) {

     // Décoder si le champ relationnel est stocké en TEXT
    UniteConventionnelle parseUniteConventionnelle(dynamic data) {
      if (data is String) {
        return UniteConventionnelle.fromJson(jsonDecode(data));
      } else if (data is Map<String, dynamic>) {
        return UniteConventionnelle.fromJson(data);
      } else {
        throw Exception("Impossible de parser uniteConventionnelle: $data");
      }
    }

    Produit parseProduit(dynamic data) {
      if (data is String) {
        return Produit.fromJson(jsonDecode(data));
      } else if (data is Map<String, dynamic>) {
        return Produit.fromJson(data);
      } else {
        throw Exception("Impossible de parser produit: $data");
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
    

    return EquivalenceUnite(
      id: json['id'],
      equivalenceUnite: (json['equivalenceUnite'] as num).toDouble(),
      uniteConventionnelle: json['uniteConventionnelle'] != null ? parseUniteConventionnelle(json['uniteConventionnelle']) : null,
      produit: json['produit'] != null ? parseProduit(json['produit']) : null,
      commune: json['commune'] != null ? parseCommune(json['commune']) : null,
    );
  }

 

  // 🔹 Convertir Objet -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'equivalenceUnite': equivalenceUnite,
      'uniteConventionnelle': uniteConventionnelle != null ? jsonEncode(uniteConventionnelle!.toJson()) : null,
      'produit': produit != null ? jsonEncode(produit!.toJson()) : null,
      'commune': commune != null ? jsonEncode(commune!.toJson()) : null,
     
    };
  }
}