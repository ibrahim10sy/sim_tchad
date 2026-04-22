class DonneeSpecifique {
  int? id;
  int caracteristiqueId;
  String valeur;

  DonneeSpecifique({
    this.id,
    required this.caracteristiqueId,
    required this.valeur,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'caracteristiqueId': caracteristiqueId,
      'valeur': valeur,
    };
  }

  factory DonneeSpecifique.fromMap(Map<String, dynamic> map) {
    return DonneeSpecifique(
      id: map['id'],
      caracteristiqueId: map['caracteristiqueId'],
      valeur: map['valeur'],
    );
  }

 factory DonneeSpecifique.fromJson(Map<String, dynamic> json) {
    return DonneeSpecifique(
      id: json['id'],
      caracteristiqueId: json['caracteristiqueId'],
      valeur: json['valeur'],
    );
  }
  
  //toJson 
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caracteristiqueId': caracteristiqueId,
      'valeur': valeur
    };
  }
}