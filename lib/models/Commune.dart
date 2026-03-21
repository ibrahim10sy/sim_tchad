class Commune {
  final int idCommune;
  final String codeCommune;
  final String nom;
  final String? description;

  Commune({
    required this.idCommune,
    required this.codeCommune,
    required this.nom,
    this.description,
  });

  factory Commune.fromJson(Map<String, dynamic> json) {
    return Commune(
      idCommune: json['idCommune'],
      codeCommune: json['codeCommune'],
      nom: json['nom'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
        'idCommune': idCommune,
        'codeCommune': codeCommune,
        'nom': nom,
        'description': description,
      };
}