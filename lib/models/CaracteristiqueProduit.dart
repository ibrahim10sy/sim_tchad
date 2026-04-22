class CaracteristiqueProduit {
  final int? id;
  final String? nom;
  final String? type;

  final int? idProduit;
  final String? codeProduit;
  final String? nomProduit;

  CaracteristiqueProduit({
    this.id,
    this.nom,
    this.type,
    this.idProduit,
    this.codeProduit,
    this.nomProduit,
  });

  // 🔥 FROM JSON
  factory CaracteristiqueProduit.fromJson(Map<String, dynamic> json) {
    return CaracteristiqueProduit(
      id: json['id'],
      nom: json['nom'],
      type: json['type'],
      idProduit: json['idProduit'],
      codeProduit: json['codeProduit'],
      nomProduit: json['nomProduit'],
    );
  }

  // 🔥 TO JSON (optionnel mais utile)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'type': type,
      'idProduit': idProduit,
      'codeProduit': codeProduit,
      'nomProduit': nomProduit,
    };
  }
}